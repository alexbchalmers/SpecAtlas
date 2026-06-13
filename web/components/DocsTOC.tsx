'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import type { DocMeta } from '@/lib/content';

function hrefFor(slug: string): string {
  return slug === 'index' ? '/docs' : `/docs/${slug}`;
}

export default function DocsTOC({ docs }: { docs: DocMeta[] }) {
  const pathname = usePathname();

  return (
    <nav aria-label="Documentation" className="sticky top-8">
      <p className="text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-3">Documentation</p>
      <ul className="space-y-1.5 text-sm">
        {docs.map((doc) => {
          const href   = hrefFor(doc.slug);
          const active = pathname === href;
          return (
            <li key={doc.slug}>
              <Link
                href={href}
                aria-current={active ? 'page' : undefined}
                className={`block transition-colors ${
                  active ? 'text-indigo-400 font-medium' : 'text-zinc-400 hover:text-zinc-100'
                }`}
              >
                {doc.title}
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
