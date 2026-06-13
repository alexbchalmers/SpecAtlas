import Link from 'next/link';
import { runQuery } from '@/lib/neo4j';
import StatusBadge from '@/components/StatusBadge';

export const dynamic = 'force-dynamic';

interface DraftListItem {
  authorityDraftId: string;
  reference:        string | null;
  title:            string;
  type:             string | null;
  status:           string[] | null;
  atlasStatus:      string[] | null;
  revCount:         number;
}

async function fetchDrafts(): Promise<DraftListItem[]> {
  return runQuery<DraftListItem>(`
    MATCH (d:AuthorityDraft)
    OPTIONAL MATCH (d)-[:HAS_REVISION]->(rev:AuthorityDraftRevision)
    WITH d, count(rev) AS revCount
    RETURN
      d.authorityDraftId AS authorityDraftId,
      d.reference        AS reference,
      d.title            AS title,
      d.type             AS type,
      d.status           AS status,
      d.atlasStatus      AS atlasStatus,
      revCount
    ORDER BY coalesce(d.reference, d.title)
  `);
}

export default async function DraftsPage() {
  const drafts = await fetchDrafts();
  return (
    <div className="max-w-4xl">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-zinc-100">Authority Drafts</h1>
        <p className="text-zinc-400 mt-2 text-sm">{drafts.length} drafts indexed</p>
      </div>
      <ul>
        {drafts.map((d) => (
          <li
            key={d.authorityDraftId}
            className="flex items-start gap-4 py-2.5 border-b border-zinc-800/60 last:border-0"
          >
            <span
              className="font-mono text-xs text-indigo-400 w-72 shrink-0 pt-0.5 truncate"
              title={d.reference ?? undefined}
            >
              {d.reference ?? '—'}
            </span>
            <div className="min-w-0 flex-1">
              <Link
                href={`/drafts/${encodeURIComponent(d.authorityDraftId)}`}
                className="text-zinc-100 hover:text-indigo-300 transition-colors text-sm"
                title={d.title}
              >
                {d.title}
              </Link>
              <div className="flex flex-wrap gap-1 mt-1">
                {(d.status ?? []).map((s) => <StatusBadge key={s} status={s} />)}
                {(d.atlasStatus ?? []).map((s) => (
                  <span key={s} className="text-xs px-2 py-0.5 rounded-full bg-indigo-900/50 text-indigo-300">
                    {s}
                  </span>
                ))}
              </div>
            </div>
            <span className="text-xs text-zinc-500 shrink-0 pt-0.5 whitespace-nowrap">
              {d.revCount} rev{d.revCount === 1 ? '' : 's'}
            </span>
          </li>
        ))}
      </ul>
    </div>
  );
}
