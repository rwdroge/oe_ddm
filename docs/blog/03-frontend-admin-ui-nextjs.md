---
title: "Building the DDM Admin UI with Next.js 14 (App Router + Typed Routes)"
date: 2025-09-23
author: oe_ddm team
description: How we structured routes, navigation, and API bindings for a modern DDM admin experience.
---

# Building the DDM Admin UI with Next.js 14 (App Router + Typed Routes)

## Goals
- Make DDM configuration discoverable and safe.
- Provide visibility into masking state across tables and roles.
- Keep the front end thin—server remains the source of truth.

## Project layout
- App Router pages under `web-next/src/app/(dashboard)/`:
  - `authorization-tags/`, `field-masking/`, `user-management/`, `data-viewer/`, `monitoring/`, `audit-logs/`, `role-management/`, plus `layout.tsx` and `page.tsx`.
- Navigation lives in `web-next/src/components/layout/Sidebar.tsx`.
- API bindings are centralized in `web-next/src/services/api.ts` with types in `web-next/src/types/api.ts`.

## Navigation (typed routes)
Excerpt from `web-next/src/components/layout/Sidebar.tsx`:
```tsx
const navigation = [
  { name: 'Dashboard', href: '/', icon: HomeIcon },
  { name: 'Role Management', href: '/role-management', icon: UserGroupIcon },
  { name: 'Authorization Tags', href: '/authorization-tags', icon: TagIcon },
  { name: 'Field Masking', href: '/field-masking', icon: EyeSlashIcon },
  { name: 'User Management', href: '/user-management', icon: UserGroupIcon },
  { name: 'Data Viewer', href: '/data-viewer', icon: DocumentTextIcon },
  { name: 'Monitoring', href: '/monitoring', icon: ChartBarIcon },
  { name: 'Audit Logs', href: '/audit-logs', icon: DocumentTextIcon },
] as const
```

We use Next.js typed routes (via `.next/types`) for safer linking and `usePathname()` to highlight the active section.

## API client and types
`web-next/src/services/api.ts` consolidates all calls with axios, request/response interceptors, and well-defined types from `web-next/src/types/api.ts`.

Example method:
```ts
static async getTables(): Promise<TablesListResponse> {
  const response = await apiClient.get('/tables');
  return response.data;
}
```

Error surfacing helper:
```ts
export function getApiErrorMessage(err: any, fallback = 'Request failed'): string {
  const backend = err?.backendError || err?.response?.data?.error
  if (backend && typeof backend === 'string') return backend
  const msg = err?.message
  if (msg && typeof msg === 'string') return msg
  return fallback
}
```

## Auth model (simple and explicit)
- Credentials stored in `localStorage` under `ddm-auth`.
- axios request interceptor adds Basic Auth.
- 401 responses clear auth and redirect to `/login`.

## UX: Field Masking page
- `web-next/src/app/(dashboard)/field-masking/page.tsx`
- Select a table, fetch fields, configure masks, and view existing configurations (`/table-configs`).
- Clear loading and error states, with refresh button.

## Developer experience
- Path aliases in `web-next/tsconfig.json` (`@/services/*`, `@/types/*`, etc.).
- Strict TypeScript for safer refactors.
- Tailwind for consistent, responsive layout.

## Troubleshooting typed routes
If you remove a route and still see it referenced, clear `.next` and restart the TypeScript server (see Part 4 for details).

## Repository links
- UI Sidebar (navigation): https://github.com/rwdroge/oe_ddm/blob/main/web-next/src/components/layout/Sidebar.tsx
- Field Masking page: https://github.com/rwdroge/oe_ddm/blob/main/web-next/src/app/(dashboard)/field-masking/page.tsx
- UI API client: https://github.com/rwdroge/oe_ddm/blob/main/web-next/src/services/api.ts
- UI API types: https://github.com/rwdroge/oe_ddm/blob/main/web-next/src/types/api.ts
- Next.js tsconfig: https://github.com/rwdroge/oe_ddm/blob/main/web-next/tsconfig.json

---

Prev: [Inside the ABL Back-end: Service Layer + PASOE Webhandlers for DDM](./02-backend-architecture-abl-pasoe.md)

Next: [The Case of the Missing Next.js Page](./04-debugging-missing-nextjs-page.md)
