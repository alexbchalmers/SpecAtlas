import type { Root } from 'hast';

/**
 * Rehype plugin: turn Font Awesome emojicode into `<i>` icon tags so the
 * Font Awesome Kit script can render them.
 *
 *   :fa-solid fa-exclamation:  ->  <i class="fa-solid fa-exclamation"></i>
 *
 * The content between the colons must be whitespace-separated Font Awesome
 * tokens (each matching /^fa[\w-]+$/), which avoids matching things like
 * time ranges ("10:30") or ratios. Code/pre text is left untouched.
 */

interface HastNode {
  type:        string;
  tagName?:    string;
  value?:      string;
  properties?: { className?: string[] };
  children?:   HastNode[];
}

const FA_TOKEN  = /^fa[\w-]+$/i;
const EMOJICODE = /:([^:\n]+?):/g;

function makeIcon(inner: string): HastNode {
  return {
    type:       'element',
    tagName:    'i',
    properties: { className: inner.trim().split(/\s+/) },
    children:   [],
  };
}

function splitText(value: string): HastNode[] | null {
  EMOJICODE.lastIndex = 0;
  const out: HastNode[] = [];
  let last = 0;
  let found = false;
  let m: RegExpExecArray | null;
  while ((m = EMOJICODE.exec(value)) !== null) {
    const tokens = m[1].trim().split(/\s+/);
    if (!tokens.every((t) => FA_TOKEN.test(t))) continue;
    found = true;
    if (m.index > last) out.push({ type: 'text', value: value.slice(last, m.index) });
    out.push(makeIcon(m[1]));
    last = m.index + m[0].length;
  }
  if (!found) return null;
  if (last < value.length) out.push({ type: 'text', value: value.slice(last) });
  return out;
}

function walk(node: HastNode): void {
  if (!node.children) return;
  const isCode = node.type === 'element' && (node.tagName === 'code' || node.tagName === 'pre');
  const result: HastNode[] = [];
  for (const child of node.children) {
    if (child.type === 'text' && !isCode) {
      const split = splitText(child.value ?? '');
      if (split) {
        result.push(...split);
        continue;
      }
    }
    walk(child);
    result.push(child);
  }
  node.children = result;
}

export default function rehypeFontAwesome() {
  return (tree: Root): void => {
    walk(tree as unknown as HastNode);
  };
}
