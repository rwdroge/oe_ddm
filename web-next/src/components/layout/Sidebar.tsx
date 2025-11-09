
'use client'

import { useState, type ComponentType, type SVGProps } from 'react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import type { Route } from 'next'
import { cn } from '@/lib/utils'
import {
  HomeIcon,
  ShieldCheckIcon,
  CogIcon,
  DocumentTextIcon,
  UserGroupIcon,
  TagIcon,
  EyeSlashIcon,
  ChartBarIcon,
  Bars3Icon,
  XMarkIcon,
} from '@heroicons/react/24/outline'

// Logical flow for DDM administration
// 1) Dashboard overview
// 2) Configure global settings
// 3) Define access (roles), auth tags, and then masking
// 4) Manage users and security admin
// 5) Operations & insights (viewer, monitoring, audit)
const navigation = [
  { name: 'Dashboard', href: '/', icon: HomeIcon },
  { name: 'Role Management', href: '/role-management', icon: UserGroupIcon },
  { name: 'Authorization Tags', href: '/authorization-tags', icon: TagIcon },
  { name: 'Field Masking', href: '/field-masking', icon: EyeSlashIcon },
  { name: 'User Management', href: '/user-management', icon: UserGroupIcon },
  { name: 'Data Viewer', href: '/data-viewer', icon: DocumentTextIcon },
  { name: 'Monitoring', href: '/monitoring', icon: ChartBarIcon },
  { name: 'Audit Logs', href: '/audit-logs', icon: DocumentTextIcon },
] as const satisfies readonly {
  name: string
  href: Route
  icon: ComponentType<SVGProps<SVGSVGElement>>
}[]

export default function Sidebar() {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const pathname = usePathname()

  return (
    <>
      {/* Mobile sidebar */}
      <div className={cn(
        'relative z-50 lg:hidden',
        sidebarOpen ? 'block' : 'hidden'
      )}>
        <div className="fixed inset-0 bg-gray-900/80" onClick={() => setSidebarOpen(false)} />
        <div className="fixed inset-0 flex">
          <div className="relative mr-16 flex w-full max-w-xs flex-1">
            <div className="absolute left-full top-0 flex w-16 justify-center pt-5">
              <button
                type="button"
                className="-m-2.5 p-2.5"
                onClick={() => setSidebarOpen(false)}
              >
                <XMarkIcon className="h-6 w-6 text-white" />
              </button>
            </div>
            <div className="flex grow flex-col gap-y-5 overflow-y-auto bg-white px-6 pb-2">
              <div className="flex h-16 shrink-0 items-center">
                <ShieldCheckIcon className="h-8 w-8 text-primary-600" />
                <span className="ml-2 text-xl font-bold text-gray-900">DDM Admin</span>
              </div>
              <nav className="flex flex-1 flex-col">
                <ul role="list" className="flex flex-1 flex-col gap-y-7">
                  <li>
                    <ul role="list" className="-mx-2 space-y-1">
                      {navigation.map((item) => (
                        <li key={item.name}>
                          <Link
                            href={item.href}
                            className={cn(
                              pathname === item.href
                                ? 'bg-gray-50 text-primary-600'
                                : 'text-gray-700 hover:text-primary-600 hover:bg-gray-50',
                              'group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold'
                            )}
                          >
                            <item.icon
                              className={cn(
                                pathname === item.href ? 'text-primary-600' : 'text-gray-400 group-hover:text-primary-600',
                                'h-6 w-6 shrink-0'
                              )}
                            />
                            {item.name}
                          </Link>
                        </li>
                      ))}
                    </ul>
                  </li>
                </ul>
              </nav>
            </div>
          </div>
        </div>
      </div>

      {/* Static sidebar for desktop */}
      <div className="hidden lg:fixed lg:inset-y-0 lg:z-50 lg:flex lg:w-72 lg:flex-col">
        <div className="flex grow flex-col gap-y-5 overflow-y-auto border-r border-gray-200 bg-white px-6">
          <div className="flex h-16 shrink-0 items-center">
            <ShieldCheckIcon className="h-8 w-8 text-primary-600" />
            <span className="ml-2 text-xl font-bold text-gray-900">DDM Admin</span>
          </div>
          <nav className="flex flex-1 flex-col">
            <ul role="list" className="flex flex-1 flex-col gap-y-7">
              <li>
                <ul role="list" className="-mx-2 space-y-1">
                  {navigation.map((item) => (
                    <li key={item.name}>
                      <Link
                        href={item.href}
                        className={cn(
                          pathname === item.href
                            ? 'bg-gray-50 text-primary-600'
                            : 'text-gray-700 hover:text-primary-600 hover:bg-gray-50',
                          'group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold'
                        )}
                      >
                        <item.icon
                          className={cn(
                            pathname === item.href ? 'text-primary-600' : 'text-gray-400 group-hover:text-primary-600',
                            'h-6 w-6 shrink-0'
                          )}
                        />
                        {item.name}
                      </Link>
                    </li>
                  ))}
                </ul>
              </li>
            </ul>
          </nav>
        </div>
      </div>

      {/* Mobile menu button */}
      <div className="sticky top-0 z-40 flex items-center gap-x-6 bg-white px-4 py-4 shadow-sm sm:px-6 lg:hidden">
        <button
          type="button"
          className="-m-2.5 p-2.5 text-gray-700 lg:hidden"
          onClick={() => setSidebarOpen(true)}
        >
          <Bars3Icon className="h-6 w-6" />
        </button>
        <div className="flex-1 text-sm font-semibold leading-6 text-gray-900">
          DDM Administration
        </div>
      </div>
    </>
  )
}
