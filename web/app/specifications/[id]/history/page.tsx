import type { Metadata } from 'next';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { runQuery } from '@/lib/neo4j';
import { fetchDevHistoryFromAuthority, generateMermaidSyntax } from '@/lib/devHistory';
import MermaidDiagram from '@/components/MermaidDiagram';

export const dynamic = 'force-dynamic';

interface Props {
  params: Promise<{ id: string }>;
}

async function fetchSpecTitle(id: string): Promise<{ reference: string | null; title: string } | null> {
  const rows = await runQuery<{ reference: string | null; title: string }>(`
    MATCH (a:Authority {authorityId: $id})
    RETURN a.reference AS reference, a.title AS title
  `, { id });
  return rows[0] ?? null;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id } = await params;
  const info   = await fetchSpecTitle(decodeURIComponent(id));
  if (!info) return { title: 'Not Found' };
  const label  = info.reference ? `${info.reference} — ${info.title}` : info.title;
  return { title: `Development History — ${label}` };
}

export default async function SpecHistoryPage({ params }: Props) {
  const { id }  = await params;
  const rawId   = decodeURIComponent(id);
  const data    = await fetchDevHistoryFromAuthority(rawId);
  if (!data) notFound();

  const { syntax, links } = generateMermaidSyntax(data);
  const info      = await fetchSpecTitle(rawId);
  const backLabel = info?.reference ?? info?.title ?? 'Specification';

  return (
    <div className="max-w-5xl">
      <div className="mb-6">
        <Link
          href={`/specifications/${encodeURIComponent(rawId)}`}
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
