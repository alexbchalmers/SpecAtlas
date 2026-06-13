import { runQuery } from '@/lib/neo4j';
import type { AuthorityListItem, OrgRow, DisplayGroup } from '@/lib/types';

// Orgs whose parent chain is severed in the display tree (treated as top-level peers).
// ISO/IEC JTC 1 is jointly owned by ISO and IEC; nesting it under either would be misleading.
const PEER_ORG_SHORTNAMES = new Set(['ISO/IEC JTC 1']);

interface SpecQueryRow extends AuthorityListItem {
  orgId: string | null;
}

async function fetchOrgs(): Promise<OrgRow[]> {
  return runQuery<OrgRow>(`
    MATCH (org:ControllingOrg)
    OPTIONAL MATCH (parent:ControllingOrg)-[:HAS_CHILD_ORG]->(org)
    WITH org, collect(DISTINCT parent.controllingOrgId) AS parentIds
    OPTIONAL MATCH (successor:ControllingOrg)-[:SUCCEEDED_ORG|PREVIOUSLY_KNOWN_AS]->(org)
    WITH org, parentIds, collect(DISTINCT successor.controllingOrgId) AS successorIds
    RETURN
      org.controllingOrgId AS orgId,
      org.shortName        AS shortName,
      org.fullName         AS fullName,
      org.displayGroup     AS displayGroup,
      parentIds,
      successorIds
  `);
}

async function fetchSpecs(): Promise<SpecQueryRow[]> {
  return runQuery<SpecQueryRow>(`
    MATCH (a:Authority)
    OPTIONAL MATCH (org:ControllingOrg)-[:CONTROLS]->(a)
    RETURN
      a.authorityId AS authorityId,
      a.title       AS title,
      a.reference   AS reference,
      a.status      AS status,
      a.atlasStatus AS atlasStatus,
      org.controllingOrgId AS orgId
    ORDER BY coalesce(a.reference, a.title)
  `);
}

// Given an org's direct controllingOrgId, resolve which display-group org it belongs to.
// Step 1: follow SUCCEEDED_ORG/PREVIOUSLY_KNOWN_AS chain (old org → current org).
// Step 2: follow HAS_CHILD_ORG chain upward until displayGroup: true or the root.
function resolveDisplayGroupId(
  directOrgId: string | null,
  orgsById:    Map<string, OrgRow>
): string | null {
  if (!directOrgId) return null;

  // Step 1 — follow successor chain
  let orgId     = directOrgId;
  const visited = new Set<string>();
  while (orgId && !visited.has(orgId)) {
    visited.add(orgId);
    const org       = orgsById.get(orgId);
    const successor = org?.successorIds.find((id) => !!id);
    if (!successor) break;
    orgId = successor;
  }

  // Step 2 — follow parent chain until displayGroup or root
  visited.clear();
  let currentId = orgId;
  while (currentId && !visited.has(currentId)) {
    visited.add(currentId);
    const org = orgsById.get(currentId);
    if (!org) return currentId;
    if (org.displayGroup) return currentId;
    const parentId = org.parentIds.find((id) => !!id) ?? null;
    if (!parentId) return currentId;
    currentId = parentId;
  }
  return currentId;
}

// Walk up the HAS_CHILD_ORG chain from startId, adding all ancestors to `allIds`.
// Stops at PEER_ORG_SHORTNAMES so their parents are not included.
function collectAncestors(startId: string, orgsById: Map<string, OrgRow>, allIds: Set<string>): void {
  const visited = new Set<string>();
  let current: string | null = startId;
  while (current && !visited.has(current)) {
    visited.add(current);
    const org = orgsById.get(current);
    if (!org || PEER_ORG_SHORTNAMES.has(org.shortName)) break;
    const parentId = org.parentIds.find((id) => !!id) ?? null;
    if (!parentId) break;
    allIds.add(parentId);
    current = parentId;
  }
}

function buildTree(displayGroupIds: Set<string>, orgsById: Map<string, OrgRow>): DisplayGroup[] {
  // Include ancestors of display groups for visual context
  const allIds = new Set<string>(displayGroupIds);
  for (const id of displayGroupIds) collectAncestors(id, orgsById, allIds);

  // Build node objects
  const nodeMap = new Map<string, DisplayGroup>();
  for (const orgId of allIds) {
    const org = orgsById.get(orgId);
    if (!org) continue;
    nodeMap.set(orgId, { orgId, name: org.fullName ?? org.shortName, depth: 0, specs: [], children: [] });
  }

  // Wire parent → child; PEER_ORGS always become roots
  const roots: DisplayGroup[] = [];
  for (const [orgId, node] of nodeMap) {
    const org    = orgsById.get(orgId)!;
    let   parent: DisplayGroup | null = null;

    if (!PEER_ORG_SHORTNAMES.has(org.shortName)) {
      for (const pid of org.parentIds) {
        if (pid && nodeMap.has(pid)) { parent = nodeMap.get(pid)!; break; }
      }
    }

    if (parent) parent.children.push(node);
    else        roots.push(node);
  }

  // Set depths and sort alphabetically at every level
  function setDepthAndSort(groups: DisplayGroup[], depth: number): void {
    groups.sort((a, b) => a.name.localeCompare(b.name));
    for (const g of groups) { g.depth = depth; setDepthAndSort(g.children, depth + 1); }
  }
  setDepthAndSort(roots, 0);

  return roots;
}

interface OrgChainRow {
  orgId:     string;
  shortName: string;
  fullName:  string | null;
  url:       string | null;
  latest:    { controllingOrgId: string; shortName: string; fullName: string | null; url: string | null } | null;
  parentIds: string[];
  isStart:   boolean;
}

export interface OrgHierarchyInfo {
  successor: { shortName: string; fullName: string | null; url: string | null } | null;
  topOrg:    { shortName: string; fullName: string | null; url: string | null } | null;
}

export async function fetchOrgHierarchyInfo(orgId: string): Promise<OrgHierarchyInfo> {
  const rows = await runQuery<OrgChainRow>(`
    MATCH (start:ControllingOrg {controllingOrgId: $orgId})
    OPTIONAL MATCH (start)<-[:HAS_CHILD_ORG*1..]-(ancestor:ControllingOrg)
    WITH start, collect(DISTINCT ancestor) AS ancestors
    UNWIND [start] + ancestors AS org
    OPTIONAL MATCH (parent:ControllingOrg)-[:HAS_CHILD_ORG]->(org)
    WITH start, org, collect(DISTINCT parent.controllingOrgId) AS parentIds
    OPTIONAL MATCH (latest:ControllingOrg)-[:SUCCEEDED_ORG|PREVIOUSLY_KNOWN_AS*1..]->(org)
      WHERE NOT (:ControllingOrg)-[:SUCCEEDED_ORG|PREVIOUSLY_KNOWN_AS]->(latest)
    WITH start, org, parentIds, collect(latest)[0] AS latest
    RETURN
      org.controllingOrgId AS orgId,
      org.shortName        AS shortName,
      org.fullName         AS fullName,
      org.url              AS url,
      CASE WHEN latest IS NOT NULL THEN {
        controllingOrgId: latest.controllingOrgId,
        shortName:        latest.shortName,
        fullName:         latest.fullName,
        url:              latest.url
      } ELSE null END AS latest,
      parentIds,
      org.controllingOrgId = start.controllingOrgId AS isStart
  `, { orgId });

  if (rows.length === 0) return { successor: null, topOrg: null };

  const orgMap    = new Map(rows.map((r) => [r.orgId, r]));
  const startRow  = rows.find((r) => r.isStart);
  if (!startRow) return { successor: null, topOrg: null };

  // Successor: the latest version of the direct org, if it was superseded
  const successor = startRow.latest
    ? { shortName: startRow.latest.shortName, fullName: startRow.latest.fullName, url: startRow.latest.url }
    : null;

  // Top org: walk up parent chain, stopping at PEER_ORGS or root
  let current    = startRow;
  const visited  = new Set<string>();
  while (!PEER_ORG_SHORTNAMES.has(current.shortName)) {
    if (visited.has(current.orgId)) break;
    visited.add(current.orgId);
    const parentId = current.parentIds.find((id) => id && orgMap.has(id)) ?? null;
    if (!parentId) break;
    current = orgMap.get(parentId)!;
  }

  // If we never moved off start, start itself is the top
  if (current.orgId === startRow.orgId) return { successor, topOrg: null };

  // Resolve the top org to its latest version
  const topLatest = current.latest;
  const topOrg    = topLatest
    ? { shortName: topLatest.shortName, fullName: topLatest.fullName, url: topLatest.url }
    : { shortName: current.shortName,   fullName: current.fullName,   url: current.url   };

  return { successor, topOrg };
}

export interface SpecsGroupedResult {
  tree:          DisplayGroup[];
  uncategorized: AuthorityListItem[];
  totalCount:    number;
}

export async function fetchSpecsGrouped(): Promise<SpecsGroupedResult> {
  const [specs, orgsArr] = await Promise.all([fetchSpecs(), fetchOrgs()]);

  const orgsById = new Map<string, OrgRow>(orgsArr.map((o) => [o.orgId, o]));

  // Resolve display group for every spec
  const displayGroupIds = new Set<string>();
  const specToGroupId   = new Map<string, string | null>();
  for (const spec of specs) {
    const dgId = resolveDisplayGroupId(spec.orgId, orgsById);
    specToGroupId.set(spec.authorityId, dgId);
    if (dgId) displayGroupIds.add(dgId);
  }

  const tree = buildTree(displayGroupIds, orgsById);

  // Index tree nodes for O(1) lookup
  const nodeByOrgId = new Map<string, DisplayGroup>();
  function indexTree(groups: DisplayGroup[]): void {
    for (const g of groups) { nodeByOrgId.set(g.orgId, g); indexTree(g.children); }
  }
  indexTree(tree);

  // Assign specs to their resolved group (or uncategorized)
  const uncategorized: AuthorityListItem[] = [];
  for (const spec of specs) {
    const dgId              = specToGroupId.get(spec.authorityId) ?? null;
    const { orgId: _, ...specItem } = spec;
    const node              = dgId ? nodeByOrgId.get(dgId) : undefined;
    if (node) node.specs.push(specItem);
    else      uncategorized.push(specItem);
  }

  // Specs are already ORDER BY in the query; no re-sort needed.

  return { tree, uncategorized, totalCount: specs.length };
}
