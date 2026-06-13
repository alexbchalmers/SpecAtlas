import Link from 'next/link';
import { runQuery } from '@/lib/neo4j';
import StatusBadge from '@/components/StatusBadge';

export const dynamic = 'force-dynamic';

interface RevisionItem {
  authorityDraftRevisionId: string;
  reference:                string | null;
  title:                    string;
  status:                   string[] | null;
  publishedDate:            string | null;
}

interface DraftGroup {
  authorityDraftId: string;
  draftRef:         string | null;
  draftTitle:       string;
  revisions:        RevisionItem[];
}

async function fetchRevisions(): Promise<DraftGroup[]> {
  return runQuery<DraftGroup>(`
    MATCH (d:AuthorityDraft)
    OPTIONAL MATCH (d)-[:HAS_REVISION]->(rev:AuthorityDraftRevision)
    WITH d, rev
    ORDER BY coalesce(d.reference, d.title) ASC, rev.publishedDate DESC
    WITH d, collect(CASE WHEN rev IS NOT NULL THEN {
      authorityDraftRevisionId: rev.authorityDraftRevisionId,
      reference:     rev.reference,
      title:         rev.title,
      status:        rev.status,
      publishedDate: rev.publishedDate
    } ELSE null END) AS revisionRaw
    RETURN
      d.authorityDraftId AS authorityDraftId,
      d.reference        AS draftRef,
      d.title            AS draftTitle,
      [r IN revisionRaw WHERE r IS NOT NULL] AS revisions
    ORDER BY coalesce(d.reference, d.title)
  `);
}

export default async function DraftRevisionsPage() {
  const groups     = await fetchRevisions();
  const totalCount = groups.reduce((n, g) => n + g.revisions.length, 0);

  return (
    <div className="max-w-4xl">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-zinc-100">Draft Revisions</h1>
        <p className="text-zinc-400 mt-2 text-sm">
          {totalCount} revisions across {groups.length} draft series
        </p>
      </div>

      <div className="space-y-8">
        {groups.map((g) => (
          <div key={g.authorityDraftId}>
            <div className="flex items-baseline gap-3 mb-2 pb-1 border-b border-zinc-800">
              <Link
                href={`/drafts/${encodeURIComponent(g.authorityDraftId)}`}
                className="font-mono text-sm text-indigo-400 hover:text-indigo-300 transition-colors"
              >
                {g.draftRef ?? g.draftTitle}
              </Link>
              {g.draftRef && (
                <span className="text-zinc-500 text-xs truncate">{g.draftTitle}</span>
              )}
            </div>

            {g.revisions.length === 0 ? (
              <p className="text-zinc-600 text-xs pl-2">No revisions</p>
            ) : (
              <ul className="space-y-1">
                {g.revisions.map((r) => (
                  <li key={r.authorityDraftRevisionId} className="flex items-center gap-3 text-sm pl-2">
                    <Link
                      href={`/draft-revisions/${encodeURIComponent(r.authorityDraftRevisionId)}`}
                      className="font-mono text-xs text-indigo-400 hover:text-indigo-300 transition-colors w-72 shrink-0 truncate"
                      title={r.reference ?? undefined}
                    >
                      {r.reference ?? r.authorityDraftRevisionId}
                    </Link>
                    <div className="flex flex-wrap gap-1 items-center min-w-0">
                      {(r.status ?? []).map((s) => <StatusBadge key={s} status={s} />)}
                      {r.publishedDate && (
                        <span className="text-zinc-500 text-xs">{r.publishedDate}</span>
                      )}
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
