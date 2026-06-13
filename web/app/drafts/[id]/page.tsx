import type { Metadata } from 'next';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { runQuery } from '@/lib/neo4j';
import StatusBadge from '@/components/StatusBadge';
import { specHref } from '@/lib/utils';

export const dynamic = 'force-dynamic';

interface Props {
  params: Promise<{ id: string }>;
}

interface DraftNode {
  authorityDraftId: string;
  reference:        string | null;
  title:            string;
  type:             string | null;
  status:           string[] | null;
  atlasStatus:      string[] | null;
}

interface RevisionItem {
  revisionId:    string;
  reference:     string | null;
  title:         string;
  status:        string[] | null;
  publishedDate: string | null;
}

interface PublishedAsItem {
  authorityId: string;
  reference:   string | null;
  title:       string;
}

interface MemberOfItem {
  groupId:   string;
  reference: string | null;
  title:     string;
}

interface DeprecatedByItem {
  sourceId:    string;
  sourceTitle: string;
  sourceRef:   string | null;
}

interface DraftDetailRow {
  draft:       DraftNode;
  org:         { controllingOrgId: string; shortName: string; fullName: string | null; url: string | null } | null;
  publishedAs: PublishedAsItem[];
  revisions:   RevisionItem[];
  memberOf:    MemberOfItem[];
  deprecatedBy: DeprecatedByItem[];
}

async function fetchDetail(rawId: string): Promise<DraftDetailRow | null> {
  const id   = decodeURIComponent(rawId);
  const rows = await runQuery<DraftDetailRow>(`
    MATCH (d:AuthorityDraft {authorityDraftId: $id})
    OPTIONAL MATCH (org:ControllingOrg)-[:CONTROLS]->(d)

    OPTIONAL MATCH (pub:Authority)-[:DRAFTED_BY]->(d)
    WITH d, org, collect(DISTINCT {
      authorityId: pub.authorityId,
      reference:   pub.reference,
      title:       pub.title
    }) AS publishedAs

    OPTIONAL MATCH (d)-[:HAS_REVISION]->(rev:AuthorityDraftRevision)
    WITH d, org, publishedAs, rev
    ORDER BY rev.revisionSequence DESC
    WITH d, org, publishedAs, collect({
      revisionId:    rev.authorityDraftRevisionId,
      reference:     rev.reference,
      title:         rev.title,
      status:        rev.status,
      publishedDate: rev.publishedDate
    }) AS revisions

    OPTIONAL MATCH (d)-[:MEMBER_OF]->(grp:AuthorityGroup)
    WITH d, org, publishedAs, revisions, collect(DISTINCT {
      groupId:   grp.authorityGroupId,
      reference: grp.reference,
      title:     grp.title
    }) AS memberOf

    OPTIONAL MATCH (source:Authority)-[:DEPRECATES]->(d)

    RETURN
      d {.*} AS draft,
      org { .controllingOrgId, .shortName, .fullName, .url } AS org,
      publishedAs,
      revisions,
      memberOf,
      collect(DISTINCT {
        sourceId:    source.authorityId,
        sourceTitle: source.title,
        sourceRef:   source.reference
      }) AS deprecatedBy
  `, { id });
  return rows[0] ?? null;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id }  = await params;
  const detail  = await fetchDetail(id);
  if (!detail)  return { title: 'Not Found' };
  const { draft: d } = detail;
  return { title: d.reference ? `${d.reference} — ${d.title}` : d.title };
}

export default async function DraftDetailPage({ params }: Props) {
  const { id } = await params;
  const detail = await fetchDetail(id);
  if (!detail) notFound();

  const { draft: d, org, publishedAs, revisions, memberOf, deprecatedBy } = detail;

  const validPublishedAs  = publishedAs.filter((p) => p.authorityId);
  const validRevisions    = revisions.filter((r) => r.revisionId);
  const validMemberOf     = memberOf.filter((m) => m.groupId);
  const validDeprecatedBy = deprecatedBy.filter((x) => x.sourceId);

  return (
    <div className="max-w-3xl">
      <div className="mb-6">
        <Link href="/drafts" className="text-zinc-500 hover:text-zinc-300 text-sm transition-colors">
          ← Authority Drafts
        </Link>
      </div>

      {d.reference && (
        <p className="text-indigo-400 text-sm font-mono mb-1">{d.reference}</p>
      )}
      <h1 className="text-3xl font-bold text-zinc-100 mb-4">{d.title}</h1>

      <div className="flex flex-wrap gap-2 mb-8">
        {(d.status ?? []).map((s) => <StatusBadge key={s} status={s} />)}
        {(d.atlasStatus ?? []).map((s) => (
          <span key={s} className="text-xs px-2 py-1 rounded-full bg-indigo-900/50 text-indigo-300">{s}</span>
        ))}
      </div>

      {/* Details */}
      {d.type && (
        <section className="mb-8">
          <h2 className="text-lg font-semibold text-zinc-200 mb-4 border-b border-zinc-600 pb-2">Details</h2>
          <dl className="grid grid-cols-[auto_1fr] gap-x-8 gap-y-2 text-sm">
            <dt className="text-zinc-500 font-medium whitespace-nowrap">Type</dt>
            <dd className="text-zinc-300">{d.type}</dd>
          </dl>
        </section>
      )}

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

      {/* Published As */}
      {validPublishedAs.length > 0 && (
        <section className="mb-8">
          <h2 className="text-lg font-semibold text-zinc-200 mb-4 border-b border-zinc-600 pb-2">
            Published As
          </h2>
          <ul className="space-y-1.5 text-sm">
            {validPublishedAs.map((p) => (
              <li key={p.authorityId}>
                <Link
                  href={`/specifications/${encodeURIComponent(p.authorityId)}`}
                  className="text-indigo-400 hover:text-indigo-300 transition-colors"
                >
                  {p.reference ? `${p.reference} — ${p.title}` : p.title}
                </Link>
              </li>
            ))}
          </ul>
        </section>
      )}

      {/* Revisions */}
      {validRevisions.length > 0 && (
        <section className="mb-8">
          <div className="flex items-center justify-between mb-4 border-b border-zinc-600 pb-2">
            <h2 className="text-lg font-semibold text-zinc-200">Revisions</h2>
            <Link
              href={`/drafts/${encodeURIComponent(d.authorityDraftId)}/history`}
              className="text-xs px-2 py-0.5 rounded border border-zinc-700 text-zinc-400 hover:text-zinc-200 hover:border-zinc-500 transition-colors"
            >
              Development History
            </Link>
          </div>
          <ul className="space-y-2 text-sm">
            {validRevisions.map((r) => (
              <li key={r.revisionId} className="flex items-start gap-3">
                <Link
                  href={`/draft-revisions/${encodeURIComponent(r.revisionId)}`}
                  className="font-mono text-indigo-400 hover:text-indigo-300 transition-colors shrink-0"
                >
                  {r.reference ?? r.revisionId}
                </Link>
                <div className="flex flex-wrap gap-1 items-center">
                  {(r.status ?? []).map((s) => <StatusBadge key={s} status={s} />)}
                  {r.publishedDate && (
                    <span className="text-zinc-500 text-xs">{r.publishedDate}</span>
                  )}
                </div>
              </li>
            ))}
          </ul>
        </section>
      )}

      {/* Group Membership */}
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

      {/* Deprecated By */}
      {validDeprecatedBy.length > 0 && (
        <section className="mb-8">
          <h2 className="text-lg font-semibold text-zinc-200 mb-4 border-b border-zinc-600 pb-2">
            Relationships
          </h2>
          <div className="grid grid-cols-[auto_1fr] gap-x-3 gap-y-1.5 text-sm items-start">
            {validDeprecatedBy.flatMap((x, i) => {
              const href  = specHref('Authority', x.sourceId);
              const label = x.sourceRef ? `${x.sourceRef} — ${x.sourceTitle}` : x.sourceTitle;
              return [
                <span
                  key={`bl-badge-${i}`}
                  className="font-mono text-xs text-center bg-zinc-800 text-zinc-400 px-2 py-0.5 rounded whitespace-nowrap"
                >
                  DEPRECATED BY
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
    </div>
  );
}
