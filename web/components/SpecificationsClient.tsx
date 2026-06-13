'use client';

import { useState, useMemo, useCallback } from 'react';
import Link from 'next/link';
import type { DisplayGroup, AuthorityListItem } from '@/lib/types';
import StatusBadge from '@/components/StatusBadge';

interface Props {
  tree:          DisplayGroup[];
  uncategorized: AuthorityListItem[];
  totalCount:    number;
}

function collectAllIds(groups: DisplayGroup[]): string[] {
  return groups.flatMap((g) => [g.orgId, ...collectAllIds(g.children)]);
}

export default function SpecificationsClient({ tree, uncategorized, totalCount }: Props) {
  const allIds              = useMemo(() => collectAllIds(tree), [tree]);
  const [collapsed, setCollapsed] = useState<Set<string>>(new Set());

  const anyCollapsed = collapsed.size > 0;

  const handleToggleAll = useCallback(() => {
    setCollapsed(anyCollapsed ? new Set() : new Set(allIds));
  }, [anyCollapsed, allIds]);

  const handleToggleGroup = useCallback((orgId: string) => {
    setCollapsed((prev) => {
      const next = new Set(prev);
      if (next.has(orgId)) next.delete(orgId);
      else next.add(orgId);
      return next;
    });
  }, []);

  return (
    <div>
      <div className="flex items-start justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold text-zinc-100 mb-1">Specifications</h1>
          <p className="text-zinc-500 text-sm">{totalCount} specifications indexed</p>
        </div>
        <button
          onClick={handleToggleAll}
          className="mt-1 text-sm text-zinc-400 hover:text-zinc-200 border border-zinc-700
                     hover:border-zinc-500 px-3 py-1.5 rounded transition-colors shrink-0"
        >
          {anyCollapsed ? 'Expand All' : 'Collapse All'}
        </button>
      </div>

      {tree.map((group) => (
        <OrgGroup
          key={group.orgId}
          group={group}
          collapsed={collapsed}
          onToggle={handleToggleGroup}
        />
      ))}

      {uncategorized.length > 0 && (
        <div>
          <div className="py-2 border-b border-zinc-800 mt-4">
            <span className="text-sm font-semibold text-zinc-200">Other</span>
          </div>
          {uncategorized.map((spec) => (
            <SpecRow key={spec.authorityId} spec={spec} depth={0} />
          ))}
        </div>
      )}
    </div>
  );
}

function OrgGroup({
  group,
  collapsed,
  onToggle,
}: {
  group:     DisplayGroup;
  collapsed: Set<string>;
  onToggle:  (orgId: string) => void;
}) {
  if (group.specs.length === 0 && group.children.length === 0) return null;

  const isCollapsed = collapsed.has(group.orgId);

  const textClass =
    group.depth === 0 ? 'text-sm font-semibold text-zinc-200' :
    group.depth === 1 ? 'text-sm font-medium text-zinc-300' :
                        'text-xs font-medium text-zinc-400';

  return (
    <div>
      <button
        onClick={() => onToggle(group.orgId)}
        aria-expanded={!isCollapsed}
        className="w-full py-2 border-b border-zinc-800 mt-4 flex items-center gap-2
                   text-left hover:bg-zinc-900/40 transition-colors"
        style={group.depth > 0 ? { paddingLeft: `${group.depth * 20}px` } : undefined}
      >
        <span
          aria-hidden
          className={`text-zinc-500 text-xs shrink-0 transition-transform duration-150
                      ${isCollapsed ? '' : 'rotate-90'}`}
        >
          ›
        </span>
        <span className={textClass}>{group.name}</span>
      </button>

      {!isCollapsed && (
        <>
          {group.specs.map((spec) => (
            <SpecRow key={spec.authorityId} spec={spec} depth={group.depth} />
          ))}
          {group.children.map((child) => (
            <OrgGroup
              key={child.orgId}
              group={child}
              collapsed={collapsed}
              onToggle={onToggle}
            />
          ))}
        </>
      )}
    </div>
  );
}

function SpecRow({ spec, depth }: { spec: AuthorityListItem; depth: number }) {
  return (
    <div
      className="flex items-center gap-4 py-2 border-b border-zinc-800/40
                 hover:bg-zinc-900 transition-colors text-sm"
      style={{ paddingLeft: `${(depth + 1) * 20}px` }}
    >
      <span
        title={spec.reference ?? undefined}
        className="text-zinc-500 font-mono w-44 shrink-0 text-xs truncate"
      >
        {spec.reference ?? '—'}
      </span>
      <Link
        href={`/specifications/${encodeURIComponent(spec.authorityId)}`}
        title={spec.title}
        className="text-indigo-400 hover:text-indigo-300 transition-colors flex-1 min-w-0 truncate"
      >
        {spec.title}
      </Link>
      <div className="flex gap-1 shrink-0 flex-wrap justify-end">
        {spec.status.map((s) => <StatusBadge key={s} status={s} />)}
      </div>
    </div>
  );
}
