import ReactMarkdown, { type Components } from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { remarkAlert } from 'remark-github-blockquote-alert';
import rehypeFontAwesome from '@/lib/rehype-fontawesome';
import MermaidDiagram from '@/components/MermaidDiagram';

// Prose styling tuned to the site's zinc/indigo palette (see Navigation/detail pages).
const PROSE = [
  'prose prose-invert max-w-none',
  'prose-headings:text-zinc-100',
  'prose-h2:border-b-3 prose-h2:border-zinc-500',
  'prose-h3:text-2xl prose-h3:font-semibold',
  'prose-h4:font-bold',
  'prose-h5:underline prose-h5:underline-offset-2 prose-h5:decoration-zinc-400',
  'prose-p:text-zinc-300',
  'prose-a:text-indigo-400 prose-a:no-underline hover:prose-a:text-indigo-300',
  'prose-strong:text-zinc-100',
  'prose-li:text-zinc-300',
  'prose-th:text-zinc-200',
  'prose-code:text-indigo-400 prose-code:before:content-none prose-code:after:content-none',
  'prose-pre:bg-zinc-900 prose-pre:border prose-pre:border-zinc-800',
  'prose-blockquote:text-zinc-400 prose-blockquote:border-zinc-700',
  'prose-blockquote:[&>p]:before:content-none prose-blockquote:[&>p]:after:content-none',
  'prose-img:rounded-lg',
].join(' ');

const components: Components = {
  code({ className, children }) {
    const lang = /language-(\w+)/.exec(className ?? '')?.[1];
    if (lang === 'mermaid') {
      return <MermaidDiagram syntax={String(children).trim()} />;
    }
    return <code className={className}>{children}</code>;
  },
};

export default function Markdown({ children }: { children: string }) {
  return (
    <div className={PROSE}>
      <ReactMarkdown
        remarkPlugins={[remarkGfm, remarkAlert]}
        rehypePlugins={[rehypeFontAwesome]}
        components={components}
      >
        {children}
      </ReactMarkdown>
    </div>
  );
}
