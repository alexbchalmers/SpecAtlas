export function specHref(nodeType: string, id: string): string | null {
  switch (nodeType) {
    case 'Authority':              return `/specifications/${encodeURIComponent(id)}`;
    case 'AuthorityGroup':         return `/groups/${encodeURIComponent(id)}`;
    case 'AuthorityDraft':         return `/drafts/${encodeURIComponent(id)}`;
    case 'AuthorityDraftRevision': return `/draft-revisions/${encodeURIComponent(id)}`;
    default:                       return null;
  }
}

export function fmtSections(sections: string[] | null): string {
  const s = (sections ?? []).filter(Boolean);
  return s.length > 0 ? s.map((x) => `§${x}`).join(', ') : '';
}
