'use client';

import { useEffect, useRef, useState } from 'react';

interface Props {
  syntax: string;
  links?: Record<string, string>;
}

export default function MermaidDiagram({ syntax, links = {} }: Props) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [ready,  setReady]  = useState(false);
  const [error,  setError]  = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function render() {
      try {
        const mermaid = (await import('mermaid')).default;
        mermaid.initialize({ startOnLoad: false, suppressErrorRendering: true });

        const uid       = `mermaid-${Math.random().toString(36).slice(2)}`;
        const { svg }   = await mermaid.render(uid, syntax);

        if (cancelled || !containerRef.current) return;

        containerRef.current.innerHTML = svg;

        // Add click handlers to commit label text nodes that match the links map
        const svgEl = containerRef.current.querySelector('svg');
        if (svgEl) {
          const textEls = svgEl.querySelectorAll<SVGTextElement>('text');
          for (const el of textEls) {
            const label = el.textContent?.trim() ?? '';
            const href  = links[label];
            if (href) {
              el.style.cursor = 'pointer';
              const clickable = el.closest('g') ?? el;
              clickable.addEventListener('click', () => { window.location.href = href; });
            }
          }
        }

        setReady(true);
      } catch (err) {
        if (!cancelled) {
          setError(err instanceof Error ? err.message : 'Failed to render diagram');
        }
      }
    }

    render();
    return () => { cancelled = true; };
  }, [syntax, links]);

  if (error) {
    return (
      <div className="text-red-400 text-sm p-4 border border-red-900 rounded-lg bg-red-950/20">
        Failed to render diagram: {error}

        <pre className="mt-4 p-2 bg-zinc-800 rounded text-xs overflow-auto">
          {syntax}
        </pre>
      </div>
    );
  }

  return (
    <div className="relative">
      {!ready && (
        <div className="animate-pulse bg-zinc-800 rounded-lg h-96 w-full" />
      )}
      <div
        ref={containerRef}
        className={ready ? 'overflow-x-auto' : 'hidden'}
      />
    </div>
  );
}
