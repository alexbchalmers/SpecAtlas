import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { getDoc } from '@/lib/content';
import Markdown from '@/components/Markdown';

export async function generateMetadata(): Promise<Metadata> {
  const doc = await getDoc('index');
  return { title: doc?.meta.title ?? 'Docs' };
}

export default async function DocsIndexPage() {
  const doc = await getDoc('index');
  if (!doc) notFound();
  return <Markdown>{doc.body}</Markdown>;
}
