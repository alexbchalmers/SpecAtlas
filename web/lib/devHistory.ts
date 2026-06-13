import { runQuery } from '@/lib/neo4j';

// ---- Types ----------------------------------------------------------------

interface AdoptedAuthority {
  authorityId: string;
  reference:   string | null;
  title:       string;
}

interface DraftRevision {
  id:                 string;
  reference:          string | null;
  status:             string[] | null;
  publishedDate:      string | null;
  revisionSequence:   number | null;
  obsoletesRevIds:    string[];        // revision-level OBSOLETES targets (cross-draft merges)
  adoptedAuthorities: AdoptedAuthority[]; // ADOPTED_AS from this revision
}

interface DraftData {
  draftId:          string;
  draftRef:         string | null;
  draftTitle:       string;
  replacesDraftIds: string[];
  revisions:        DraftRevision[];
}

export interface DevHistoryData {
  viewedAuthorityId: string | null; // the spec being viewed (highlighted on Adopted); null when entered from a draft
  startDraftId:      string;
  drafts:            DraftData[];
}

// ---- Data fetching ---------------------------------------------------------

async function resolveStartDraftFromAuthority(authorityId: string): Promise<string | null> {
  const rows = await runQuery<{ startDraftId: string | null }>(`
    MATCH (a:Authority {authorityId: $id})
    OPTIONAL MATCH (a)-[:DRAFTED_BY]->(d:AuthorityDraft)
    RETURN d.authorityDraftId AS startDraftId
    LIMIT 1
  `, { id: authorityId });
  return rows[0]?.startDraftId ?? null;
}

async function fetchDraftFamily(startDraftId: string): Promise<DraftData[]> {
  // Step 1 — family = connected component over REPLACES + revision-level OBSOLETES.
  // No-arrow relationshipFilter = both directions; APOC is available on the Aura instance.
  const step1 = await runQuery<{ draftIds: string[] }>(`
    MATCH (start:AuthorityDraft {authorityDraftId: $startDraftId})
    CALL apoc.path.subgraphNodes(start, {
      relationshipFilter: 'REPLACES|HAS_REVISION|OBSOLETES',
      labelFilter: '+AuthorityDraft|+AuthorityDraftRevision',
      maxLevel: -1
    }) YIELD node
    WITH node WHERE node:AuthorityDraft
    RETURN collect(DISTINCT node.authorityDraftId) AS draftIds
  `, { startDraftId });

  const draftIds = step1[0]?.draftIds ?? [];
  if (draftIds.length === 0) return [];

  // Step 2 — full detail for every draft in the family
  interface Step2Row {
    draftId:          string;
    draftRef:         string | null;
    draftTitle:       string;
    replacesDraftIds: string[];
    revisions:        DraftRevision[];
  }

  const step2 = await runQuery<Step2Row>(`
    MATCH (d:AuthorityDraft) WHERE d.authorityDraftId IN $draftIds

    OPTIONAL MATCH (d)-[:REPLACES]->(replacedD:AuthorityDraft)
    WITH d, collect(DISTINCT replacedD.authorityDraftId) AS replacesDraftIds

    OPTIONAL MATCH (d)-[:HAS_REVISION]->(rev:AuthorityDraftRevision)
    OPTIONAL MATCH (rev)-[:OBSOLETES]->(obsRev:AuthorityDraftRevision)
    OPTIONAL MATCH (rev)-[:ADOPTED_AS]->(adoptedAuth:Authority)
    WITH d, replacesDraftIds, rev,
         collect(DISTINCT obsRev.authorityDraftRevisionId) AS obsoletesRevIds,
         collect(DISTINCT CASE WHEN adoptedAuth IS NOT NULL THEN {
           authorityId: adoptedAuth.authorityId,
           reference:   adoptedAuth.reference,
           title:       adoptedAuth.title
         } ELSE null END) AS adoptedRaw
    ORDER BY rev.revisionSequence

    WITH d, replacesDraftIds,
         collect(
           CASE WHEN rev.authorityDraftRevisionId IS NOT NULL THEN {
             id:                 rev.authorityDraftRevisionId,
             reference:          rev.reference,
             status:             rev.status,
             publishedDate:      rev.publishedDate,
             revisionSequence:   rev.revisionSequence,
             obsoletesRevIds:    obsoletesRevIds,
             adoptedAuthorities: [x IN adoptedRaw WHERE x IS NOT NULL]
           } ELSE null END
         ) AS revisionsRaw

    RETURN
      d.authorityDraftId                      AS draftId,
      d.reference                             AS draftRef,
      d.title                                 AS draftTitle,
      replacesDraftIds,
      [r IN revisionsRaw WHERE r IS NOT NULL] AS revisions
  `, { draftIds });

  return step2.map((row) => ({
    draftId:          row.draftId,
    draftRef:         row.draftRef,
    draftTitle:       row.draftTitle,
    replacesDraftIds: (row.replacesDraftIds ?? []).filter(Boolean),
    revisions:        (row.revisions ?? []).filter((r) => r?.id),
  }));
}

export async function fetchDevHistoryFromAuthority(authorityId: string): Promise<DevHistoryData | null> {
  const startDraftId = await resolveStartDraftFromAuthority(authorityId);
  if (!startDraftId) return null;
  const drafts = await fetchDraftFamily(startDraftId);
  if (drafts.length === 0) return null;
  return { viewedAuthorityId: authorityId, startDraftId, drafts };
}

export async function fetchDevHistoryFromDraft(draftId: string): Promise<DevHistoryData | null> {
  const drafts = await fetchDraftFamily(draftId);
  if (drafts.length === 0) return null;
  return { viewedAuthorityId: null, startDraftId: draftId, drafts };
}

// ---- Mermaid syntax generation ---------------------------------------------

function sanitizeId(s: string): string {
  return s.replace(/"/g, "'");
}

function quoteBranch(name: string): string {
  return `"${name}"`;
}

interface SynthRevision extends DraftRevision {
  draftId:     string;
  draftBranch: string;
  seq:         number;
}

/**
 * Produces gitGraph BT syntax via a greedy topological emission.
 *
 * Ordering constraints (edge u -> v ⇒ u emitted before v):
 *  - within a draft: revisionSequence order (≡ the REVISES chain)
 *  - OBSOLETES (source rev obsoletes target rev): target before source
 *  - REPLACES (source draft replaces target draft): all target revisions before
 *    the source draft's first revision
 *
 * The viewed Authority's Adopted commit is highlighted; all ADOPTED_AS authorities
 * of the start draft are rendered, sibling specs are not.
 */
export function generateMermaidSyntax(data: DevHistoryData): {
  syntax: string;
  links:  Record<string, string>;
} {
  const { viewedAuthorityId, startDraftId, drafts } = data;

  const draftById = new Map<string, DraftData>(drafts.map((d) => [d.draftId, d]));
  const branchOf  = (draftId: string): string => {
    const d = draftById.get(draftId);
    return d ? (d.draftRef ?? d.draftId) : draftId;
  };

  // Flatten revisions (sorted within each draft by revisionSequence)
  const revById      = new Map<string, SynthRevision>();
  const revToDraftId = new Map<string, string>();
  const allRevisions: SynthRevision[] = [];
  const firstRevOf   = new Map<string, SynthRevision>();
  const lastRevOf    = new Map<string, SynthRevision>();

  for (const d of drafts) {
    const sorted = [...d.revisions].sort(
      (a, b) => (a.revisionSequence ?? 0) - (b.revisionSequence ?? 0)
    );
    sorted.forEach((rev, i) => {
      const sr: SynthRevision = {
        ...rev,
        draftId:     d.draftId,
        draftBranch: d.draftRef ?? d.draftId,
        seq:         rev.revisionSequence ?? 0,
      };
      revById.set(rev.id, sr);
      revToDraftId.set(rev.id, d.draftId);
      allRevisions.push(sr);
      if (i === 0) firstRevOf.set(d.draftId, sr);
      lastRevOf.set(d.draftId, sr);
    });
  }

  // ---- Dependency graph ----
  const successors = new Map<string, string[]>();
  const inDegree   = new Map<string, number>();
  for (const r of allRevisions) inDegree.set(r.id, 0);

  const addEdge = (u: string, v: string) => {
    if (u === v || !revById.has(u) || !revById.has(v)) return;
    const list = successors.get(u);
    if (list) list.push(v);
    else successors.set(u, [v]);
    inDegree.set(v, (inDegree.get(v) ?? 0) + 1);
  };

  for (const d of drafts) {
    const sorted = allRevisions.filter((r) => r.draftId === d.draftId).sort((a, b) => a.seq - b.seq);
    for (let i = 1; i < sorted.length; i++) addEdge(sorted[i - 1].id, sorted[i].id);
  }
  for (const r of allRevisions) {
    for (const t of r.obsoletesRevIds ?? []) addEdge(t, r.id); // target before source
  }
  for (const d of drafts) {
    const firstX = firstRevOf.get(d.draftId);
    if (!firstX) continue;
    for (const replacedId of d.replacesDraftIds) {
      const lastY = lastRevOf.get(replacedId);
      if (lastY) addEdge(lastY.id, firstX.id);
    }
  }

  // ---- Emit ----
  const lines: string[] = [];
  const links: Record<string, string> = {};

  lines.push('---');
  lines.push('config:');
  lines.push('  look: "neo"');
  lines.push('  theme: "base"');
  lines.push('  gitGraph:');
  lines.push('    mainBranchName: "Adopted"');
  lines.push('    parallelCommits: true');
  lines.push('---');
  lines.push('');
  lines.push('gitGraph BT:');

  const sortedDrafts = [...drafts].sort((a, b) =>
    (a.draftRef ?? a.draftId).localeCompare(b.draftRef ?? b.draftId)
  );
  for (const d of sortedDrafts) {
    lines.push(`  branch ${quoteBranch(d.draftRef ?? d.draftId)}`);
  }

  const emitted         = new Set<string>();
  const draftStarted    = new Set<string>();
  const branchHasCommit = new Set<string>(); // branches with ≥1 emitted commit (incl. merge commits)
  const inDeg           = new Map(inDegree);
  const startBranch     = branchOf(startDraftId);
  let   currentBranch   = '';                // '' = none checked out yet (forces a checkout)
  let   markerIdx       = 0;

  const checkout = (branch: string) => {
    if (currentBranch === branch) return;
    lines.push(`  checkout ${branch === 'Adopted' ? 'Adopted' : quoteBranch(branch)}`);
    currentBranch = branch;
  };
  // Mermaid rejects `merge` on a branch with no commits — drop a blank anchor first.
  const ensureAnchor = () => {
    if (branchHasCommit.has(currentBranch)) return;
    markerIdx += 1;
    lines.push(`  commit id:"${' '.repeat(markerIdx)}" type:HIGHLIGHT`);
    branchHasCommit.add(currentBranch);
  };
  const emitCommit = (id: string, highlight: boolean) => {
    lines.push(`  commit id:"${id}"${highlight ? ' type:HIGHLIGHT' : ''}`);
    branchHasCommit.add(currentBranch);
  };
  const emitMerge = (branch: string) => {
    ensureAnchor();
    lines.push(`  merge ${quoteBranch(branch)}`);
    branchHasCommit.add(currentBranch); // a merge produces a commit
  };

  const pickNext = (): SynthRevision | null => {
    const ready = allRevisions.filter((r) => !emitted.has(r.id) && (inDeg.get(r.id) ?? 0) === 0);
    if (ready.length === 0) return null;
    const pref = currentBranch || startBranch; // bias toward the start draft on the first pick
    const onPref = ready.filter((r) => r.draftBranch === pref).sort((a, b) => a.seq - b.seq);
    if (onPref.length > 0) return onPref[0];
    return ready.sort((a, b) => {
      const ad = a.publishedDate ?? '';
      const bd = b.publishedDate ?? '';
      if (ad !== bd) return ad < bd ? -1 : 1;            // nulls ('') first
      if (a.draftBranch !== b.draftBranch) return a.draftBranch.localeCompare(b.draftBranch);
      return a.seq - b.seq;
    })[0];
  };

  let processed = 0;
  while (processed < allRevisions.length) {
    const r = pickNext();
    if (!r) break; // cycle guard (data is a DAG today)
    processed += 1;

    checkout(r.draftBranch);

    // REPLACES merges — only at the first commit of the absorbing branch
    if (!draftStarted.has(r.draftId)) {
      draftStarted.add(r.draftId);
      const replaced = (draftById.get(r.draftId)?.replacesDraftIds ?? []).filter((id) => draftById.has(id));
      for (const replacedId of replaced) emitMerge(branchOf(replacedId));
    }

    // OBSOLETES merges at this commit point (cross-draft)
    for (const t of r.obsoletesRevIds ?? []) {
      const srcDraftId = revToDraftId.get(t);
      if (srcDraftId && srcDraftId !== r.draftId) emitMerge(branchOf(srcDraftId));
    }

    const commitId = sanitizeId(r.reference ?? r.id);
    emitCommit(commitId, false);
    links[commitId] = `/draft-revisions/${encodeURIComponent(r.id)}`;

    emitted.add(r.id);
    for (const s of successors.get(r.id) ?? []) inDeg.set(s, (inDeg.get(s) ?? 0) - 1);

    // Adopted-branch commits — only adoptions of the start draft
    if (r.draftId === startDraftId && (r.adoptedAuthorities?.length ?? 0) > 0) {
      for (const auth of r.adoptedAuthorities) {
        checkout('Adopted');
        emitMerge(startBranch); // ensureAnchor drops the Adopted blank on first use
        const authId = sanitizeId(auth.reference ?? auth.title);
        emitCommit(authId, auth.authorityId === viewedAuthorityId);
        links[authId] = `/specifications/${encodeURIComponent(auth.authorityId)}`;
      }
    }
  }

  // Cycle guard: emit leftovers in sequence order (should not happen with current data)
  if (processed < allRevisions.length) {
    const leftover = allRevisions.filter((r) => !emitted.has(r.id)).sort((a, b) => a.seq - b.seq);
    for (const r of leftover) {
      checkout(r.draftBranch);
      const commitId = sanitizeId(r.reference ?? r.id);
      emitCommit(commitId, false);
      links[commitId] = `/draft-revisions/${encodeURIComponent(r.id)}`;
      emitted.add(r.id);
    }
    console.warn(`generateMermaidSyntax: ${leftover.length} revisions emitted out of dependency order (possible cycle).`);
  }

  return { syntax: lines.join('\n'), links };
}
