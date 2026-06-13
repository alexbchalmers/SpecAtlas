import Link from 'next/link';
import { runQuery } from '@/lib/neo4j';

export const dynamic = 'force-dynamic';

interface GroupListItem {
  authorityGroupId: string;
  reference:        string | null;
  title:            string;
  groupType:        string | null;
  atlasStatus:      string[] | null;
}

async function fetchGroups(): Promise<GroupListItem[]> {
  return runQuery<GroupListItem>(`
    MATCH (g:AuthorityGroup)
    RETURN
      g.authorityGroupId AS authorityGroupId,
      g.reference        AS reference,
      g.title            AS title,
      g.groupType        AS groupType,
      g.atlasStatus      AS atlasStatus
    ORDER BY coalesce(g.reference, g.title)
  `);
}

export default async function GroupsPage() {
  const groups = await fetchGroups();
  return (
    <div className="max-w-4xl">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-zinc-100">Authority Groups</h1>
        <p className="text-zinc-400 mt-2 text-sm">{groups.length} groups indexed</p>
      </div>
      <ul>
        {groups.map((g) => (
          <li
            key={g.authorityGroupId}
            className="flex items-start gap-4 py-2.5 border-b border-zinc-800/60 last:border-0"
          >
            <span
              className="font-mono text-xs text-indigo-400 w-56 shrink-0 pt-0.5 truncate"
              title={g.reference ?? undefined}
            >
              {g.reference ?? '—'}
            </span>
            <div className="min-w-0 flex-1">
              <Link
                href={`/groups/${encodeURIComponent(g.authorityGroupId)}`}
                className="text-zinc-100 hover:text-indigo-300 transition-colors text-sm"
                title={g.title}
              >
                {g.title}
              </Link>
              {g.groupType && (
                <span className="text-xs text-zinc-500 ml-2">{g.groupType}</span>
              )}
            </div>
            <div className="flex flex-wrap gap-1 shrink-0">
              {(g.atlasStatus ?? []).map((s) => (
                <span
                  key={s}
                  className="text-xs px-2 py-0.5 rounded-full bg-indigo-900/50 text-indigo-300 whitespace-nowrap"
                >
                  {s}
                </span>
              ))}
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}
