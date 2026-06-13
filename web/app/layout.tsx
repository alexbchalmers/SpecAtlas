import type { Metadata } from 'next';
import Script from 'next/script';
import './globals.css';
import Navigation from '@/components/Navigation';

export const metadata: Metadata = {
  title: {
    template: '%s | SpecAtlas',
    default:  'SpecAtlas',
  },
  description: 'A reference catalogue for technical specifications and standards in Digital Identity technologies.',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-zinc-950 text-zinc-100 min-h-screen">
        <Navigation />
        <main className="max-w-6xl mx-auto px-4 py-8">
          {children}
        </main>
        {/* Font Awesome Kit — renders <i class="fa-..."> icons (incl. those injected from Markdown) */}
        <Script
          src="https://kit.fontawesome.com/d43d7dec27.js"
          crossOrigin="anonymous"
          strategy="afterInteractive"
        />
      </body>
    </html>
  );
}
