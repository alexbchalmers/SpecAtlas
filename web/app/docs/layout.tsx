import { getDocsList } from '@/lib/content';
import DocsTOC from '@/components/DocsTOC';

export default async function DocsLayout({ children }: { children: React.ReactNode }) {
  const docs = await getDocsList();
  return (
    <div className="flex gap-8">
      <aside className="hidden md:block w-56 shrink-0">
        <DocsTOC docs={docs} />
      </aside>
      <div className="min-w-0 flex-1 max-w-3xl">{children}</div>
    </div>
  );
}
