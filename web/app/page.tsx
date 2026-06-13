import Link from 'next/link';

export default function HomePage() {
  return (
    <div className="py-16">
      <h1 className="text-4xl font-bold text-zinc-100 mb-4">SpecAtlas</h1>
      <p className="text-xl text-zinc-400 mb-8 max-w-2xl">
        A guide to technical specifications, standards, and protocols. This release is a work in progress, with more content and features to come.
      </p>
      <div className="flex gap-4 flex-wrap">
        <Link
          href="/specifications"
          className="bg-indigo-600 hover:bg-indigo-500 text-white px-6 py-3 rounded-lg font-medium transition-colors"
        >
          Browse Specifications
        </Link>
        <Link
          href="/about"
          className="border border-zinc-700 hover:border-zinc-500 text-zinc-300 hover:text-zinc-100
                     px-6 py-3 rounded-lg font-medium transition-colors"
        >
          About the Project
        </Link>
      </div>
      <img src="/content-images/sampleVisualization.svg" alt="Sample Visualization" className="mt-12 rounded-lg border border-zinc-700" />
    </div>
  );
}
