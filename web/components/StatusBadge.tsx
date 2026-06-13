// Maps Authority.status values to Tailwind utility classes for the pill badge.
// ring-1 is used for bordered variants so the ring doesn't affect layout.
const STATUS_CLASSES: Record<string, string> = {
  'active':          'bg-green-800 text-green-200',
  'updated':         'bg-zinc-800 text-zinc-300 ring-1 ring-green-600',
  'errata':          'bg-zinc-800 text-zinc-300 ring-1 ring-orange-500',
  'informational':   'bg-zinc-800 text-zinc-300',
  'living standard': 'bg-blue-800 text-blue-200',
  'superseded':      'bg-yellow-800 text-yellow-100',
  'obsoleted':       'bg-orange-800 text-orange-200',
  'deprecated':      'bg-red-900 text-red-300',
  'withdrawn':       'bg-red-900 text-red-300 ring-1 ring-white/50',
  'unknown':         'bg-zinc-800 text-zinc-400',
};

const DEFAULT_CLASS = 'bg-zinc-800 text-zinc-400';

export function statusBadgeClass(status: string): string {
  return STATUS_CLASSES[status.toLowerCase()] ?? DEFAULT_CLASS;
}

export default function StatusBadge({ status }: { status: string }) {
  return (
    <span className={`text-xs px-2 py-0.5 rounded-full ${statusBadgeClass(status)}`}>
      {status}
    </span>
  );
}
