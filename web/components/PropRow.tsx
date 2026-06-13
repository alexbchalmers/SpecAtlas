export default function PropRow({
  label,
  value,
  isUrl,
  pill,
}: {
  label: string;
  value: string | null | undefined;
  isUrl?: boolean;
  pill?: string | null;
}) {
  if (!value) return null;
  return (
    <>
      <dt className="text-zinc-500 font-medium whitespace-nowrap">{label}</dt>
      <dd className="text-zinc-300 flex items-center gap-2 min-w-0">
        {isUrl ? (
          <a
            href={value}
            target="_blank"
            rel="noopener noreferrer"
            className="text-indigo-400 hover:text-indigo-300 transition-colors break-all"
          >
            {value}
          </a>
        ) : (
          value
        )}
        {pill && (
          <span className="text-xs px-2 py-0.5 rounded bg-zinc-800 text-zinc-400 shrink-0 whitespace-nowrap">
            {pill}
          </span>
        )}
      </dd>
    </>
  );
}
