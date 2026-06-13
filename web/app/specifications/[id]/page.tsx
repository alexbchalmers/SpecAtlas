import type { Metadata } from 'next';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { runQuery } from '@/lib/neo4j';
import type { AuthorityDetail } from '@/lib/types';
import StatusBadge from '@/components/StatusBadge';
import PropRow from '@/components/PropRow';
import { fetchOrgHierarchyInfo } from '@/lib/queries/specifications';
import { specHref, fmtSections } from '@/lib/utils';

export const dynamic = 'force-dynamic';

const FWD_ORDER = ['DEPRECATES', 'OBSOLETES', 'SUPERSEDES', 'UPDATES', 'CORRECTS', 'HAS_RELATED_AUTHORITY'];
const FWD_LABELS: Record<string, string> = {
  DEPRECATES:             'DEPRECATES',
  OBSOLETES:              'OBSOLETES',
  SUPERSEDES:             'SUPERSEDES',
  UPDATES:                'UPDATES',
  CORRECTS:               'CORRECTS',
  HAS_RELATED_AUTHORITY:  'HAS RELATED AUTHORITY',
};

const BACK_ORDER = ['CORRECTS', 'DEPRECATES', 'OBSOLETES', 'SUPERSEDES', 'UPDATES', 'HAS_RELATED_AUTHORITY'];
const BACK_LABELS: Record<string, string> = {
  CORRECTS:               'CORRECTED BY',
  DEPRECATES:             'DEPRECATED BY',
  OBSOLETES:              'OBSOLETED BY',
  SUPERSEDES:             'SUPERSEDED BY',
  UPDATES:                'UPDATED BY',
  HAS_RELATED_AUTHORITY:  'HAS RELATED AUTHORITY',
};

interface Props {
  params: Promise<{ id: string }>;
}

async function fetchDetail(rawId: string): Promise<AuthorityDetail | null> {
  const id   = decodeURIComponent(rawId);
  const rows = await runQuery<AuthorityDetail>(`
    MATCH (a:Authority {authorityId: $id})
    OPTIONAL MATCH (org:ControllingOrg)-[:CONTROLS]->(a)

    OPTIONAL MATCH (a)-[rel]->(target)
    WHERE (type(rel) IN ['DEPRECATES', 'OBSOLETES', 'SUPERSEDES'] AND (target:Authority OR target:AuthorityGroup))
       OR (type(rel) IN ['UPDATES', 'CORRECTS'] AND target:Authority)
       OR (type(rel) = 'HAS_RELATED_AUTHORITY' AND (target:Authority OR target:AuthorityGroup OR target:AuthorityDraftRevision))
    WITH a, org,
      collect(DISTINCT {
        relType:                type(rel),
        targetId:               CASE WHEN target:Authority      THEN target.authorityId
                                     WHEN target:AuthorityGroup THEN target.authorityGroupId
                                     ELSE target.authorityDraftRevisionId END,
        targetNodeType:         CASE WHEN target:Authority      THEN 'Authority'
                                     WHEN target:AuthorityGroup THEN 'AuthorityGroup'
                                     ELSE 'AuthorityDraftRevision' END,
        targetTitle:            target.title,
        targetRef:              target.reference,
        targetAuthoritySection: rel.targetAuthoritySection,
        relationship:           rel.relationship
      }) AS relationships

    OPTIONAL MATCH (a)-[ref:REFERENCES]->(refTarget)
    WITH a, org, relationships,
      collect(DISTINCT {
        targetId:               CASE WHEN refTarget:Authority      THEN refTarget.authorityId
                                     WHEN refTarget:AuthorityGroup THEN refTarget.authorityGroupId
                                     ELSE refTarget.authorityDraftRevisionId END,
        targetNodeType:         CASE WHEN refTarget:Authority      THEN 'Authority'
                                     WHEN refTarget:AuthorityGroup THEN 'AuthorityGroup'
                                     ELSE 'AuthorityDraftRevision' END,
        targetTitle:            refTarget.title,
        targetRef:              refTarget.reference,
        referenceType:          ref.referenceType,
        targetAuthoritySection: ref.targetAuthoritySection
      }) AS references

    OPTIONAL MATCH (source)-[bl]->(a)
    WHERE (type(bl) IN ['HAS_RELATED_AUTHORITY'] AND (source:Authority OR source:AuthorityGroup OR source:AuthorityDraftRevision))
       OR (type(bl) IN ['DEPRECATES', 'OBSOLETES', 'SUPERSEDES'] AND (source:Authority OR source:AuthorityGroup))
       OR (type(bl) IN ['CORRECTS', 'UPDATES'] AND source:Authority)
    WITH a, org, relationships, references,
      collect(DISTINCT {
        relType:        type(bl),
        sourceId:       CASE WHEN source:Authority      THEN source.authorityId
                             WHEN source:AuthorityGroup THEN source.authorityGroupId
                             ELSE null END,
        sourceNodeType: CASE WHEN source:Authority      THEN 'Authority'
                             WHEN source:AuthorityGroup THEN 'AuthorityGroup'
                             ELSE null END,
        sourceTitle:    source.title,
        sourceRef:      source.reference,
        relationship:   bl.relationship
      }) AS backLinks

    OPTIONAL MATCH (a)-[:DEFINES]->(art:Artifact)
    WITH a, org, relationships, references, backLinks, collect(DISTINCT {
      artifactId:      art.artifactId,
      artifactType:    art.artifactType,
      artifactSubtype: art.artifactSubtype,
      fullName:        art.fullName,
      shortName:       art.shortName
    }) AS artifacts

    OPTIONAL MATCH (a)-[:MEMBER_OF]->(grp:AuthorityGroup)

    RETURN
      a {.*} AS authority,
      org {
        .controllingOrgId, .shortName, .fullName, .url,
        .organizationType, .status, .startDate, .endDate
      } AS org,
      relationships,
      references,
      backLinks,
      artifacts,
      collect(DISTINCT {
        groupId:   grp.authorityGroupId,
        reference: grp.reference,
        title:     grp.title
      }) AS memberOf,
      CASE WHEN (a)-[:DRAFTED_BY]->(:AuthorityDraft) THEN true ELSE false END AS hasDraftHistory
  `, { id });
  return rows[0] ?? null;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id }  = await params;
  const detail  = await fetchDetail(id);
  if (!detail) return { title: 'Not Found' };
  const ref     = detail.authority.reference;
  return { title: ref ? `${ref} — ${detail.authority.title}` : detail.authority.title };
}


export default async function SpecificationDetailPage({ params }: Props) {
  const { id }  = await params;
  const detail  = await fetchDetail(id);
  if (!detail) notFound();

  const { authority: a, org, relationships, backLinks, references, artifacts, memberOf, hasDraftHistory } = detail;

  const validMemberOf      = (memberOf ?? []).filter((m) => m.groupId);
  const validRelationships = relationships
    .filter((r) => r.targetId)
    .sort((a, b) => {
      const ai = FWD_ORDER.indexOf(a.relType);
      const bi = FWD_ORDER.indexOf(b.relType);
      return (ai === -1 ? 999 : ai) - (bi === -1 ? 999 : bi);
    });

  const validBackLinks = backLinks
    .filter((b) => b.sourceId)
    .sort((a, b) => BACK_ORDER.indexOf(a.relType) - BACK_ORDER.indexOf(b.relType));

  const validRefs      = references.filter((r) => r.targetId);
  const validArtifacts = artifacts.filter((art) => art.artifactId);

  const { successor, topOrg } = org
    ? await fetchOrgHierarchyInfo(org.controllingOrgId)
    : { successor: null, topOrg: null };

  return (
    <div className="max-w-3xl">
      <div className="mb-6">
        <Link href="/specifications" className="text-zinc-500 hover:text-zinc-300 text-sm transition-colors">
          ← Specifications
        </Link>
      </div>

      {a.reference && (
        <p className="text-indigo-400 text-sm font-mono mb-1">{a.reference}</p>
      )}
      <h1 className="text-3xl font-bold text-zinc-100 mb-4">{a.title}</h1>

      <div className="flex flex-wrap gap-2 mb-8">
        {a.status.map((s) => <StatusBadge key={s} status={s} />)}
        {a.atlasStatus.map((s) => (
          <span key={s} className="text-xs px-2 py-1 rounded-full bg-indigo-900/50 text-indigo-300">{s}</span>
        ))}
      </div>

      {/* Details */}
      <section className="mb-8">
        <h2 className="text-lg font-semibold text-zinc-200 mb-4 border-b border-zinc-600 pb-2">Details</h2>
        <dl className="grid grid-cols-[auto_1fr] gap-x-8 gap-y-2 text-sm">
          <PropRow label="Type"        value={a.type} />
          <PropRow label="Version"     value={a.versionTag} />
          {(a.publishedDate || hasDraftHistory) && (
            <>
              <dt className="text-zinc-500 font-medium whitespace-nowrap">Published</dt>
              <dd className="text-zinc-300 flex items-center gap-3">
                <span>{a.publishedDate ?? '—'}</span>
                {hasDraftHistory && (
                  <Link
                    href={`/specifications/${encodeURIComponent(a.authorityId)}/history`}
                    className="text-xs px-2 py-0.5 rounded border border-zinc-700 text-zinc-400 hover:text-zinc-200 hover:border-zinc-500 transition-colors"
                  >
                    Development History
                  </Link>
                )}
              </dd>
            </>
          )}
          <PropRow label="Deprecated"  value={a.deprecatedDate} />
          <PropRow label="Withdrawn"   value={a.withdrawnDate} />
          <PropRow label="IETF Stream" value={a.ietfStream} />
          {a.doi && (
            <>
              <dt className="text-zinc-500 font-medium whitespace-nowrap">doi</dt>
              <dd className="text-zinc-300">
                <a
                  href={`https://doi.org/${encodeURIComponent(a.doi)}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-indigo-400 hover:text-indigo-300 transition-colors break-all"
                >
                  {a.doi}
                </a>
              </dd>
            </>
          )}
          <PropRow label="Canonical URL" value={a.canonicalUrl} isUrl pill={a.canonicalFormat} />
          <PropRow label="HTML"          value={a.htmlUrl}      isUrl />
          <PropRow label="Plain text"    value={a.plainTextUrl} isUrl />
          <PropRow label="Other URL"     value={a.otherUrl}     isUrl pill={a.otherFormat} />
        </dl>

        {Array.isArray(a.atlasCategory) && a.atlasCategory.length > 0 && (
          <div className="mt-4 flex flex-wrap gap-1">
            {a.atlasCategory.map((c) => (
              <span key={c} className="text-xs px-2 py-0.5 rounded bg-zinc-800 text-zinc-400">{c}</span>
            ))}
          </div>
        )}

        {Array.isArray(a.notes) && a.notes.length > 0 && (
          <ul className="mt-4 space-y-1 text-sm text-zinc-400 list-disc list-inside">
            {a.notes.map((n, i) => <li key={i}>{n}</li>)}
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
            {topOrg && (
              <p className="text-zinc-400">
                {topOrg.fullName ?? topOrg.shortName}
              </p>
            )}
            <p className="text-zinc-100 font-medium mt-1">{org.fullName ?? org.shortName}</p>
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

          {successor && (
            <div className="mt-2 border border-zinc-700 rounded-lg p-4 text-sm">
              <p className="text-xs mb-2">
                <span className="px-2 py-0.5 rounded bg-yellow-900 text-yellow-300 shrink-0 whitespace-nowrap">
                  Successor Organization
                </span>
              </p>
              <p className="text-zinc-100 font-medium">
                {successor.fullName ?? successor.shortName}
              </p>
              {successor.url && (
                <a
                  href={successor.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-indigo-400 hover:text-indigo-300 transition-colors mt-1 block break-all"
                >
                  {successor.url}
                </a>
              )}
            </div>
          )}
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

      {/* Relationships — forward links + back-links in one section, divided */}
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
                  {FWD_LABELS[r.relType] ?? r.relType}
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
                <div key={`bl-content-${i}`} className="min-w-0 flex items-baseline gap-2 pb-1 flex-wrap">
                  {href
                    ? <Link href={href} className="text-indigo-400 hover:text-indigo-300 transition-colors">{label}</Link>
                    : <span className="text-zinc-300">{label}</span>
                  }
                  {b.relationship && <span className="text-zinc-500 text-xs italic">{b.relationship}</span>}
                </div>,
              ];
            })}

          </div>
        </section>
      )}

      {/* References */}
      {validRefs.length > 0 && (
        <section className="mb-8">
          <h2 className="text-lg font-semibold text-zinc-200 mb-4 border-b border-zinc-600 pb-2">
            References
          </h2>
          <div className="grid grid-cols-[auto_1fr] gap-x-3 gap-y-1.5 text-sm items-start">
            {validRefs.flatMap((r, i) => {
              const href     = specHref(r.targetNodeType, r.targetId);
              const label    = r.targetRef ? `${r.targetRef} — ${r.targetTitle}` : r.targetTitle;
              const sections = fmtSections(r.targetAuthoritySection);
              return [
                <span
                  key={`ref-badge-${i}`}
                  className="font-mono text-xs text-center bg-zinc-800 text-zinc-400 px-2 py-0.5 rounded whitespace-nowrap"
                >
                  {r.referenceType ?? '—'}
                </span>,
                <div key={`ref-content-${i}`} className="min-w-0 flex items-baseline gap-2 flex-wrap">
                  {href
                    ? <Link href={href} className="text-indigo-400 hover:text-indigo-300 transition-colors">{label}</Link>
                    : <span className="text-zinc-300">{label}</span>
                  }
                  {sections && <span className="text-zinc-500 text-xs">{sections}</span>}
                </div>,
              ];
            })}
          </div>
        </section>
      )}

      {/* Artifacts */}
      {validArtifacts.length > 0 && (
        <section className="mb-8">
          <h2 className="text-lg font-semibold text-zinc-200 mb-4 border-b border-zinc-600 pb-2">
            Artifacts
          </h2>
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

