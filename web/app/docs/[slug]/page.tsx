import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { getDoc, getDocsList } from '@/lib/content';
import Markdown from '@/components/Markdown';

// Only the docs present at build time are generated; any other slug 404s (no runtime fs).
export const dynamicParams = false;

interface Props {
  params: Promise<{ slug: string }>;
}

export async function generateStaticParams() {
  const docs = await getDocsList();
  return docs.filter((d) => d.slug !== 'index').map((d) => ({ slug: d.slug }));
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const doc = await getDoc(slug);
  return { title: doc?.meta.title ?? 'Not Found' };
}

export default async function DocPage({ params }: Props) {
  const { slug } = await params;
  const doc = await getDoc(slug);
  if (!doc) notFound();
  return <Markdown>{doc.body}</Markdown>;
}
