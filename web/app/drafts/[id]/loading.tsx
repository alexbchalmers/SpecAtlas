export default function DraftDetailLoading() {
  return (
    <div className="max-w-3xl animate-pulse">
      <div className="h-4 w-28 bg-zinc-800 rounded mb-6" />
      <div className="h-3 w-48 bg-zinc-800 rounded mb-2" />
      <div className="h-9 w-3/4 bg-zinc-800 rounded mb-4" />
      <div className="flex gap-2 mb-8">
        <div className="h-6 w-16 bg-zinc-800 rounded-full" />
        <div className="h-6 w-20 bg-zinc-800 rounded-full" />
      </div>
      <div className="border-b border-zinc-800 pb-2 mb-4">
        <div className="h-5 w-20 bg-zinc-800 rounded" />
      </div>
      <div className="space-y-3">
        {Array.from({ length: 6 }).map((_, i) => (
          <div key={i} className="h-4 bg-zinc-800 rounded" style={{ width: `${60 + (i % 3) * 10}%` }} />
        ))}
      </div>
    </div>
  );
}
