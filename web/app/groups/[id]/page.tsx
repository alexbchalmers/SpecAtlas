import type { Metadata } from 'next';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { runQuery } from '@/lib/neo4j';
import PropRow from '@/components/PropRow';
import { specHref, fmtSections } from '@/lib/utils';

export const dynamic = 'force-dynamic';

const BACK_LABELS: Record<string, string> = {
  SUPERSEDES:            'SUPERSEDED BY',
  OBSOLETES:             'OBSOLETED BY',
  DEPRECATES:            'DEPRECATED BY',
  REFERENCES:            'REFERENCED BY',
  HAS_RELATED_AUTHORITY: 'RELATED FROM',
};

interface Props {
  params: Promise<{ id: string }>;
}

interface GroupNode {
  authorityGroupId: string;
  reference:        string | null;
  title:            string;
  groupType:        string | null;
  atlasStatus:      string[] | null;
  url:              string | null;
  notes:            string[] | null;
}

interface GroupMember {
  memberId:       string;
  memberNodeType: string;
  memberRef:      string | null;
  memberTitle:    string;
}

interface GroupRelationship {
  relType:                string;
  targetId:               string;
  targetNodeType:         string;
  targetTitle:            string;
  targetRef:              string | null;
  targetAuthoritySection: string[] | null;
  relationship:           string | null;
}

interface GroupArtifact {
  artifactId:      string;
  artifactType:    string;
  artifactSubtype: string | null;
  fullName:        string | null;
  shortName:       string | null;
}

interface GroupBackLink {
  relType:        string;
  sourceId:       string;
  sourceNodeType: string;
  sourceTitle:    string;
  sourceRef:      string | null;
}

interface GroupMemberOf {
  groupId:   string;
  reference: string | null;
  title:     string;
}

interface GroupDetailRow {
  group:         GroupNode;
  org:           { controllingOrgId: string; shortName: string; fullName: string | null; url: string | null } | null;
  members:       GroupMember[];
  relationships: GroupRelationship[];
  artifacts:     GroupArtifact[];
  backLinks:     GroupBackLink[];
  memberOf:      GroupMemberOf[];
}

async function fetchDetail(rawId: string): Promise<GroupDetailRow | null> {
  const id   = decodeURIComponent(rawId);
  const rows = await runQuery<GroupDetailRow>(`
    MATCH (g:AuthorityGroup {authorityGroupId: $id})
    OPTIONAL MATCH (org:ControllingOrg)-[:CONTROLS]->(g)

    OPTIONAL MATCH (member)-[:MEMBER_OF]->(g)
    WITH g, org, collect(DISTINCT {
      memberId:       CASE WHEN member:Authority      THEN member.authorityId
                           WHEN member:AuthorityDraft THEN member.authorityDraftId
                           ELSE                            member.authorityGroupId END,
      memberNodeType: CASE WHEN member:Authority      THEN 'Authority'
                           WHEN member:AuthorityDraft THEN 'AuthorityDraft'
                           ELSE                            'AuthorityGroup' END,
      memberRef:   member.reference,
      memberTitle: member.title
    }) AS members

    OPTIONAL MATCH (g)-[rel:HAS_RELATED_AUTHORITY]->(target)
    WITH g, org, members, collect(DISTINCT {
      relType:                type(rel),
      targetId:               CASE WHEN target:Authority      THEN target.authorityId
                                   WHEN target:AuthorityGroup THEN target.authorityGroupId
                                   ELSE                            target.authorityDraftRevisionId END,
      targetNodeType:         CASE WHEN target:Authority      THEN 'Authority'
                                   WHEN target:AuthorityGroup THEN 'AuthorityGroup'
                                   ELSE                            'AuthorityDraftRevision' END,
      targetTitle:            target.title,
      targetRef:              target.reference,
      targetAuthoritySection: rel.targetAuthoritySection,
      relationship:           rel.relationship
    }) AS relationships

    OPTIONAL MATCH (g)-[:DEFINES]->(art:Artifact)
    WITH g, org, members, relationships, collect(DISTINCT {
      artifactId:      art.artifactId,
      artifactType:    art.artifactType,
      artifactSubtype: art.artifactSubtype,
      fullName:        art.fullName,
      shortName:       art.shortName
    }) AS artifacts

    OPTIONAL MATCH (source)-[bl]->(g)
    WHERE type(bl) IN ['SUPERSEDES', 'OBSOLETES', 'DEPRECATES', 'REFERENCES', 'HAS_RELATED_AUTHORITY']
      AND (source:Authority OR source:AuthorityGroup)
    WITH g, org, members, relationships, artifacts, collect(DISTINCT {
      relType:        type(bl),
      sourceId:       CASE WHEN source:Authority THEN source.authorityId ELSE source.authorityGroupId END,
      sourceNodeType: CASE WHEN source:Authority THEN 'Authority' ELSE 'AuthorityGroup' END,
      sourceTitle:    source.title,
      sourceRef:      source.reference
    }) AS backLinks

    OPTIONAL MATCH (g)-[:MEMBER_OF]->(grp:AuthorityGroup)

    RETURN
      g {.*} AS group,
      org { .controllingOrgId, .shortName, .fullName, .url } AS org,
      members,
      relationships,
      artifacts,
      backLinks,
      collect(DISTINCT {
        groupId:   grp.authorityGroupId,
        reference: grp.reference,
        title:     grp.title
      }) AS memberOf
  `, { id });
  return rows[0] ?? null;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id }  = await params;
  const detail  = await fetchDetail(id);
  if (!detail)  return { title: 'Not Found' };
  const { group: g } = detail;
  return { title: g.reference ? `${g.reference} — ${g.title}` : g.title };
}

export default async function GroupDetailPage({ params }: Props) {
  const { id } = await params;
  const detail = await fetchDetail(id);
  if (!detail) notFound();

  const { group: g, org, members, relationships, artifacts, backLinks, memberOf } = detail;

  const validMemberOf      = (memberOf ?? []).filter((m) => m.groupId);
  const validMembers       = members.filter((m) => m.memberId);
  const validRelationships = relationships.filter((r) => r.targetId);
  const validArtifacts     = artifacts.filter((a) => a.artifactId);
  const validBackLinks     = backLinks.filter((b) => b.sourceId);

  return (
    <div className="max-w-3xl">
      <div className="mb-6">
        <Link href="/groups" className="text-zinc-500 hover:text-zinc-300 text-sm transition-colors">
          ← Authority Groups
        </Link>
      </div>

      {g.reference && (
        <p className="text-indigo-400 text-sm font-mono mb-1">{g.reference}</p>
      )}
      <h1 className="text-3xl font-bold text-zinc-100 mb-4">{g.title}</h1>

      <div className="flex flex-wrap gap-2 mb-8">
        {(g.atlasStatus ?? []).map((s) => (
          <span key={s} className="text-xs px-2 py-1 rounded-full bg-indigo-900/50 text-indigo-300">{s}</span>
        ))}
      </div>

      {/* Details */}
      <section className="mb-8">
        <h2 className="text-lg font-semibold text-zinc-200 mb-4 border-b border-zinc-600 pb-2">Details</h2>
        <dl className="grid grid-cols-[auto_1fr] gap-x-8 gap-y-2 text-sm">
          <PropRow label="Group Type" value={g.groupType} />
          <PropRow label="URL"        value={g.url}       isUrl />
        </dl>
        {Array.isArray(g.notes) && g.notes.filter(Boolean).length > 0 && (
          <ul className="mt-4 space-y-1 text-sm text-zinc-400 list-disc list-inside">
            {g.notes.filter(Boolean).map((n, i) => <li key={i}>{n}</li>)}
          </ul>
        )}
      </section>

      {/* Controlling Organization */}
      {org && (
        <section className="mb-8">
          <h2 className="text-lg font-semibold text-zinc-200 mb-4 border-b border-zinc-600 pb-2">
            Controlling Organization
          </h2>
          <div className="bg-zinc-900 rounded-lg p-4 text-sm">
            <p className="text-zinc-100 font-medium">{org.fullName ?? org.shortName}</p>
            {org.url && (
              <a
                href={org.url}
                target="_blank"
                rel="noopener noreferrer"
                className="text-indigo-400 hover:text-indigo-300 transition-colors mt-2 block break-all"
              >
                {org.url}
              </a>
            )}
          </div>
        </section>
      )}

      {/* Members */}
      {validMembers.length > 0 && (
        <section className="mb-8">
          <h2 className="text-lg font-semibold text-zinc-200 mb-4 border-b border-zinc-600 pb-2">
            Members
          </h2>
          <ul className="space-y-1.5 text-sm">
            {validMembers.map((m) => {
              const href  = specHref(m.memberNodeType, m.memberId);
              const label = m.memberRef ? `${m.memberRef} — ${m.memberTitle}` : m.memberTitle;
              return (
                <li key={m.memberId}>
                  {href
                    ? <Link href={href} className="text-indigo-400 hover:text-indigo-300 transition-colors">{label}</Link>
                    : <span className="text-zinc-300">{label}</span>
                  }
                </li>
              );
            })}
          </ul>
        </section>
      )}

      {/* Member of */}
      {validMemberOf.length > 0 && (
        <section className="mb-8">
          <h2 className="text-lg font-semibold text-zinc-200 mb-4 border-b border-zinc-600 pb-2">
            Member of
          </h2>
          <ul className="space-y-1.5 text-sm">
            {validMemberOf.map((m) => (
              <li key={m.groupId}>
                <Link
                  href={`/groups/${encodeURIComponent(m.groupId)}`}
                  className="text-indigo-400 hover:text-indigo-300 transition-colors"
                >
                  {m.reference ? `${m.reference} — ${m.title}` : m.title}
                </Link>
              </li>
            ))}
          </ul>
        </section>
      )}

      {/* Relationships + Back-links */}
      {(validRelationships.length > 0 || validBackLinks.length > 0) && (
        <section className="mb-8">
          <h2 className="text-lg font-semibold text-zinc-200 mb-4 border-b border-zinc-600 pb-2">
            Relationships
          </h2>
          <div className="grid grid-cols-[auto_1fr] gap-x-3 gap-y-1.5 text-sm items-start">

            {validRelationships.flatMap((r, i) => {
              const href     = specHref(r.targetNodeType, r.targetId);
              const label    = r.targetRef ? `${r.targetRef} — ${r.targetTitle}` : r.targetTitle;
              const sections = fmtSections(r.targetAuthoritySection);
              return [
                <span
                  key={`fwd-badge-${i}`}
                  className="font-mono text-xs text-center bg-zinc-800 text-zinc-400 px-2 py-0.5 rounded whitespace-nowrap"
                >
                  {r.relType}
                </span>,
                <div key={`fwd-content-${i}`} className="min-w-0 flex items-baseline gap-2 pb-1 flex-wrap">
                  {href
                    ? <Link href={href} className="text-indigo-400 hover:text-indigo-300 transition-colors">{label}</Link>
                    : <span className="text-zinc-300">{label}</span>
                  }
                  {sections && <span className="text-zinc-500 text-xs">{sections}</span>}
                  {r.relationship && <span className="text-zinc-500 text-xs italic">{r.relationship}</span>}
                </div>,
              ];
            })}

            {validRelationships.length > 0 && validBackLinks.length > 0 && (
              <div className="col-span-2 border-t border-zinc-800 pt-1" />
            )}

            {validBackLinks.flatMap((b, i) => {
              const href  = specHref(b.sourceNodeType, b.sourceId);
              const label = b.sourceRef ? `${b.sourceRef} — ${b.sourceTitle}` : b.sourceTitle;
              return [
                <span
                  key={`bl-badge-${i}`}
                  className="font-mono text-xs text-center bg-zinc-800 text-zinc-400 px-2 py-0.5 rounded whitespace-nowrap"
                >
                  {BACK_LABELS[b.relType] ?? b.relType}
                </span>,
                <div key={`bl-content-${i}`} className="min-w-0">
                  {href
                    ? <Link href={href} className="text-indigo-400 hover:text-indigo-300 transition-colors">{label}</Link>
                    : <span className="text-zinc-300">{label}</span>
                  }
                </div>,
              ];
            })}

          </div>
        </section>
      )}

      {/* Artifacts */}
      {validArtifacts.length > 0 && (
        <section className="mb-8">
          <h2 className="text-lg font-semibold text-zinc-200 mb-4 border-b border-zinc-600 pb-2">Artifacts</h2>
          <div className="grid grid-cols-[auto_1fr] gap-x-3 gap-y-1.5 text-sm items-start">
            {validArtifacts.flatMap((art, i) => [
              <div key={`art-badges-${i}`} className="flex gap-1.5">
                <span className="font-mono text-xs bg-zinc-800 text-zinc-400 px-2 py-0.5 rounded whitespace-nowrap">
                  {art.artifactType}
                </span>
                {art.artifactSubtype && (
                  <span className="text-xs bg-zinc-800/60 text-zinc-500 px-2 py-0.5 rounded whitespace-nowrap">
                    {art.artifactSubtype}
                  </span>
                )}
              </div>,
              <span key={`art-name-${i}`} className="text-zinc-300 min-w-0">
                {art.fullName ?? art.shortName}
              </span>,
            ])}
          </div>
        </section>
      )}
    </div>
  );
}
