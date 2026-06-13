import { promises as fs } from 'fs';
import path from 'path';
import matter from 'gray-matter';

export interface DocMeta {
  slug:  string;
  title: string;
  order: number;
}

export interface MarkdownDoc {
  meta: DocMeta;
  body: string;
}

const CONTENT_DIR = path.join(process.cwd(), 'content');
const DOCS_DIR    = path.join(CONTENT_DIR, 'docs');

interface FrontMatter {
  title?: string;
  order?: number;
}

function parse(raw: string, slug: string): MarkdownDoc {
  const { data, content } = matter(raw);
  const fm = data as FrontMatter;
  return {
    meta: {
      slug,
      title: fm.title ?? slug,
      order: typeof fm.order === 'number' ? fm.order : 999,
    },
    body: content,
  };
}

export async function getAbout(): Promise<MarkdownDoc> {
  const raw = await fs.readFile(path.join(CONTENT_DIR, 'about.md'), 'utf8');
  return parse(raw, 'about');
}

export async function getDocsList(): Promise<DocMeta[]> {
  const entries = await fs.readdir(DOCS_DIR);
  const docs = await Promise.all(
    entries
      .filter((f) => f.endsWith('.md'))
      .map(async (f) => {
        const slug = f.replace(/\.md$/, '');
        const raw  = await fs.readFile(path.join(DOCS_DIR, f), 'utf8');
        return parse(raw, slug).meta;
      })
  );
  return docs.sort((a, b) => a.order - b.order || a.title.localeCompare(b.title));
}

export async function getDoc(slug: string): Promise<MarkdownDoc | null> {
  // Guard against path traversal; slugs are simple filenames
  if (!/^[a-z0-9-]+$/i.test(slug)) return null;
  try {
    const raw = await fs.readFile(path.join(DOCS_DIR, `${slug}.md`), 'utf8');
    return parse(raw, slug);
  } catch {
    return null;
  }
}
