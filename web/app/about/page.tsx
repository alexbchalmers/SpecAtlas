import type { Metadata } from 'next';
import { getAbout } from '@/lib/content';
import Markdown from '@/components/Markdown';

export async function generateMetadata(): Promise<Metadata> {
  const { meta } = await getAbout();
  return { title: meta.title };
}

export default async function AboutPage() {
  const { body } = await getAbout();
  return (
    <div className="max-w-3xl">
      <Markdown>{body}</Markdown>
    </div>
  );
}
