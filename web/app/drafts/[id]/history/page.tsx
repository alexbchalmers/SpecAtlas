import type { Metadata } from 'next';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { runQuery } from '@/lib/neo4j';
import { fetchDevHistoryFromDraft, generateMermaidSyntax } from '@/lib/devHistory';
import MermaidDiagram from '@/components/MermaidDiagram';

export const dynamic = 'force-dynamic';

interface Props {
  params: Promise<{ id: string }>;
}

async function fetchDraftTitle(id: string): Promise<{ reference: string | null; title: string } | null> {
  const rows = await runQuery<{ reference: string | null; title: string }>(`
    MATCH (d:AuthorityDraft {authorityDraftId: $id})
    RETURN d.reference AS reference, d.title AS title
  `, { id });
  return rows[0] ?? null;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id } = await params;
  const info   = await fetchDraftTitle(decodeURIComponent(id));
  if (!info) return { title: 'Not Found' };
  const label  = info.reference ? `${info.reference} — ${info.title}` : info.title;
  return { title: `Development History — ${label}` };
}

export default async function DraftHistoryPage({ params }: Props) {
  const { id }  = await params;
  const rawId   = decodeURIComponent(id);
  const data    = await fetchDevHistoryFromDraft(rawId);
  if (!data) notFound();

  const { syntax, links } = generateMermaidSyntax(data);
  const info      = await fetchDraftTitle(rawId);
  const backLabel = info?.reference ?? info?.title ?? 'Draft';

  return (
    <div className="max-w-5xl">
      <div className="mb-6">
        <Link
          href={`/drafts/${encodeURIComponent(rawId)}`}
          className="text-zinc-500 hover:text-zinc-300 text-sm transition-colors"
        >
          ← {backLabel}
        </Link>
      </div>
      <h1 className="text-2xl font-bold text-zinc-100 mb-8">Development History</h1>
      <MermaidDiagram syntax={syntax} links={links} />
    </div>
  );
}
