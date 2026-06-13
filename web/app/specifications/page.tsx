import type { Metadata } from 'next';
import { fetchSpecsGrouped } from '@/lib/queries/specifications';
import SpecificationsClient from '@/components/SpecificationsClient';

export const dynamic  = 'force-dynamic';
export const metadata: Metadata = { title: 'Specifications' };

export default async function SpecificationsPage() {
  const data = await fetchSpecsGrouped();
  return <SpecificationsClient {...data} />;
}
