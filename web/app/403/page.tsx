import Link from 'next/link';
import type { Metadata } from 'next';

export const metadata: Metadata = { title: 'Forbidden' };

export default function Forbidden() {
  return (
    <div className="py-16">
      <p className="text-sm font-medium text-indigo-400 mb-2">403</p>
      <h1 className="text-4xl font-bold text-zinc-100 mb-4">Forbidden</h1>
      <p className="text-xl text-zinc-400 mb-8 max-w-2xl">
        You do not have permission to access this resource.
      </p>
      <Link
        href="/"
        className="bg-indigo-600 hover:bg-indigo-500 text-white px-6 py-3 rounded-lg font-medium transition-colors"
      >
        Go to Home
      </Link>
    </div>
  );
}
