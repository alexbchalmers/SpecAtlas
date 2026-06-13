import type { Metadata } from 'next';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { runQuery } from '@/lib/neo4j';
import StatusBadge from '@/components/StatusBadge';
import PropRow from '@/components/PropRow';
import { specHref, fmtSections } from '@/lib/utils';

export const dynamic = 'force-dynamic';

const BACK_LABELS: Record<string, string> = {
  OBSOLETES:             'OBSOLETED BY',
  REFERENCES:            'REFERENCED BY',
  HAS_RELATED_AUTHORITY: 'RELATED FROM',
};

interface Props {
  params: Promise<{ id: string }>;
}

interface RevisionNode {
  authorityDraftRevisionId: string;
  reference:                string | null;
  title:                    string;
  type:                     string | null;
  status:                   string[] | null;
  atlasStatus:              string[] | null;
  publishedDate:            string | null;
  revisionSequence:         number | null;
  ietfStream:               string | null;
  canonicalUrl:             string | null;
  canonicalFormat:          string | null;
  plainTextUrl:             string | null;
  htmlUrl:                  string | null;
  otherUrl:                 string | null;
  otherFormat:              string | null;
}

interface RevRelationship {
  relType:                string;
  targetId:               string;
  targetNodeType:         string;
  targetTitle:            string;
  targetRef:              string | null;
  targetAuthoritySection: string[] | null;
  relationship:           string | null;
}

interface RevBackLink {
  relType:        string;
  sourceId:       string;
  sourceNodeType: string;
  sourceTitle:    string;
  sourceRef:      string | null;
}

interface AdoptedAsItem {
  authorityId: string;
  reference:   string | null;
  title:       string;
}

interface RevDetailRow {
  revision:      RevisionNode;
  parentDraft:   { authorityDraftId: string; reference: string | null; title: string } | null;
  relationships: RevRelationship[];
  backLinks:     RevBackLink[];
  adoptedAs:     AdoptedAsItem[];
}

async function fetchDetail(rawId: string): Promise<RevDetailRow | null> {
  const id   = decodeURIComponent(rawId);
  const rows = await runQuery<RevDetailRow>(`
    MATCH (rev:AuthorityDraftRevision {authorityDraftRevisionId: $id})

    OPTIONAL MATCH (d:AuthorityDraft)-[:HAS_REVISION]->(rev)

    OPTIONAL MATCH (rev)-[rel]->(target)
    WHERE type(rel) IN ['HAS_RELATED_AUTHORITY', 'OBSOLETES']
    WITH rev, d, collect(DISTINCT {
      relType:                type(rel),
      targetId:               CASE WHEN target:Authority      THEN target.authorityId
                                   WHEN target:AuthorityGroup THEN target.authorityGroupId
                                   ELSE                            target.authorityDraftRevisionId END,
      targetNodeType:         CASE WHEN target:Authority      THEN 'Authority'
                                   WHEN target:AuthorityGroup THEN 'AuthorityGroup'
                                   ELSE                            'AuthorityDraftRevision' END,
      targetTitle:            target.title,
      targetRef:              target.reference,
      targetAuthoritySection: rel.targetAuthoritySection,
      relationship:           rel.relationship
    }) AS relationships

    OPTIONAL MATCH (source)-[bl]->(rev)
    WHERE (type(bl) = 'OBSOLETES' AND source:AuthorityDraftRevision)
       OR (type(bl) = 'REFERENCES' AND (source:Authority OR source:AuthorityDraftRevision))
       OR (type(bl) = 'HAS_RELATED_AUTHORITY' AND (source:Authority OR source:AuthorityGroup OR source:AuthorityDraftRevision))
    WITH rev, d, relationships, collect(DISTINCT {
      relType:        type(bl),
      sourceId:       CASE WHEN source:Authority      THEN source.authorityId
                           WHEN source:AuthorityGroup THEN source.authorityGroupId
                           ELSE                            source.authorityDraftRevisionId END,
      sourceNodeType: CASE WHEN source:Authority      THEN 'Authority'
                           WHEN source:AuthorityGroup THEN 'AuthorityGroup'
                           ELSE                            'AuthorityDraftRevision' END,
      sourceTitle:    source.title,
      sourceRef:      source.reference
    }) AS backLinks

    OPTIONAL MATCH (rev)-[:ADOPTED_AS]->(adoptedAuth:Authority)

    RETURN
      rev {.*} AS revision,
      CASE WHEN d IS NOT NULL THEN {
        authorityDraftId: d.authorityDraftId,
        reference:        d.reference,
        title:            d.title
      } ELSE null END AS parentDraft,
      relationships,
      backLinks,
      collect(DISTINCT {
        authorityId: adoptedAuth.authorityId,
        reference:   adoptedAuth.reference,
        title:       adoptedAuth.title
      }) AS adoptedAs
  `, { id });
  return rows[0] ?? null;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id }   = await params;
  const detail   = await fetchDetail(id);
  if (!detail)   return { title: 'Not Found' };
  const { revision: r } = detail;
  return { title: r.reference ? `${r.reference} — ${r.title}` : r.title };
}

export default async function DraftRevisionDetailPage({ params }: Props) {
  const { id } = await params;
  const detail = await fetchDetail(id);
  if (!detail) notFound();

  const { revision: r, parentDraft, relationships, backLinks, adoptedAs } = detail;

  const validRelationships = relationships.filter((rel) => rel.targetId);
  const validBackLinks     = backLinks.filter((b) => b.sourceId);
  const validAdoptedAs     = adoptedAs.filter((a) => a.authorityId);

  return (
    <div className="max-w-3xl">
      <div className="mb-6 flex items-center gap-4">
        <Link href="/draft-revisions" className="text-zinc-500 hover:text-zinc-300 text-sm transition-colors">
          ← Draft Revisions
        </Link>
        {parentDraft && (
          <>
            <span className="text-zinc-700 text-sm">·</span>
            <Link
              href={`/drafts/${encodeURIComponent(parentDraft.authorityDraftId)}`}
              className="text-zinc-500 hover:text-zinc-300 text-sm transition-colors"
            >
              {parentDraft.reference ?? parentDraft.title}
            </Link>
          </>
        )}
      </div>

      {r.reference && (
        <p className="text-indigo-400 text-sm font-mono mb-1">{r.reference}</p>
      )}
      <h1 className="text-3xl font-bold text-zinc-100 mb-4">{r.title}</h1>

      <div className="flex flex-wrap gap-2 mb-8">
        {(r.status ?? []).map((s) => <StatusBadge key={s} status={s} />)}
        {(r.atlasStatus ?? []).map((s) => (
          <span key={s} className="text-xs px-2 py-1 rounded-full bg-indigo-900/50 text-indigo-300">{s}</span>
        ))}
      </div>

      {/* Details */}
      <section className="mb-8">
        <h2 className="text-lg font-semibold text-zinc-200 mb-4 border-b border-zinc-600 pb-2">Details</h2>
        <dl className="grid grid-cols-[auto_1fr] gap-x-8 gap-y-2 text-sm">
          <PropRow label="Type"          value={r.type} />
          <PropRow label="Sequence"      value={r.revisionSequence != null ? String(r.revisionSequence) : null} />
          <PropRow label="Published"     value={r.publishedDate} />
          <PropRow label="IETF Stream"   value={r.ietfStream} />
          <PropRow label="Canonical URL" value={r.canonicalUrl}  isUrl pill={r.canonicalFormat} />
          <PropRow label="HTML"          value={r.htmlUrl}       isUrl />
          <PropRow label="Plain text"    value={r.plainTextUrl}  isUrl />
          <PropRow label="Other URL"     value={r.otherUrl}      isUrl pill={r.otherFormat} />
        </dl>
      </section>

      {/* Adopted As */}
      {validAdoptedAs.length > 0 && (
        <section className="mb-8">
          <h2 className="text-lg font-semibold text-zinc-200 mb-4 border-b border-zinc-600 pb-2">
            Adopted As
          </h2>
          <ul className="space-y-1.5 text-sm">
            {validAdoptedAs.map((a) => (
              <li key={a.authorityId}>
                <Link
                  href={`/specifications/${encodeURIComponent(a.authorityId)}`}
                  className="text-indigo-400 hover:text-indigo-300 transition-colors"
                >
                  {a.reference ? `${a.reference} — ${a.title}` : a.title}
                </Link>
              </li>
            ))}
          </ul>
        </section>
      )}

      {/* Relationships + Back-links */}
      {(validRelationships.length > 0 || validBackLinks.length > 0) && (
        <section className="mb-8">
          <h2 className="text-lg font-semibold text-zinc-200 mb-4 border-b border-zinc-600 pb-2">
            Relationships
          </h2>
          <div className="grid grid-cols-[auto_1fr] gap-x-3 gap-y-1.5 text-sm items-start">

            {validRelationships.flatMap((rel, i) => {
              const href     = specHref(rel.targetNodeType, rel.targetId);
              const label    = rel.targetRef ? `${rel.targetRef} — ${rel.targetTitle}` : rel.targetTitle;
              const sections = fmtSections(rel.targetAuthoritySection);
              return [
                <span
                  key={`fwd-badge-${i}`}
                  className="font-mono text-xs text-center bg-zinc-800 text-zinc-400 px-2 py-0.5 rounded whitespace-nowrap"
                >
                  {rel.relType}
                </span>,
                <div key={`fwd-content-${i}`} className="min-w-0 flex items-baseline gap-2 pb-1 flex-wrap">
                  {href
                    ? <Link href={href} className="text-indigo-400 hover:text-indigo-300 transition-colors">{label}</Link>
                    : <span className="text-zinc-300">{label}</span>
                  }
                  {sections && <span className="text-zinc-500 text-xs">{sections}</span>}
                  {rel.relationship && <span className="text-zinc-500 text-xs italic">{rel.relationship}</span>}
                </div>,
              ];
            })}

            {validRelationships.length > 0 && validBackLinks.length > 0 && (
              <div className="col-span-2 border-t border-zinc-800 pt-1" />
            )}

            {validBackLinks.flatMap((b, i) => {
              const href  = specHref(b.sourceNodeType, b.sourceId);
              const label = b.sourceRef ? `${b.sourceRef} — ${b.sourceTitle}` : b.sourceTitle;
              return [
                <span
                  key={`bl-badge-${i}`}
                  className="font-mono text-xs text-center bg-zinc-800 text-zinc-400 px-2 py-0.5 rounded whitespace-nowrap"
                >
                  {BACK_LABELS[b.relType] ?? b.relType}
                </span>,
                <div key={`bl-content-${i}`} className="min-w-0">
                  {href
                    ? <Link href={href} className="text-indigo-400 hover:text-indigo-300 transition-colors">{label}</Link>
                    : <span className="text-zinc-300">{label}</span>
                  }
                </div>,
              ];
            })}

          </div>
        </section>
      )}
    </div>
  );
}
