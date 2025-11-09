---
title: "The Case of the Missing Next.js Page (Typed Routes and Stale Caches)"
date: 2025-09-23
author: oe_ddm team
description: A real debugging story—how a phantom route in .next/types caused a TypeScript error and how we fixed it.
---

# The Case of the Missing Next.js Page (Typed Routes and Stale Caches)

## Symptom
TypeScript reported:
```
File '/workspaces/oe_ddm/web-next/src/app/(dashboard)/configuration/page.tsx' not found.
The file is in the program because:
  Matched by include pattern '**/*.tsx' in '/workspaces/oe_ddm/web-next/tsconfig.json'
```

## What we saw
- There was no `web-next/src/app/(dashboard)/configuration/` folder.
- `web-next/tsconfig.json` intentionally includes typed routes: 
  ```json
  {
    "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"]
  }
  ```
- The `.next` build artifacts still contained references to the old route:
  - `.next/server/app/(dashboard)/configuration/page.js`
  - `.next/static/chunks/app/(dashboard)/configuration/page.js`
  - `.next/types/app/(dashboard)/configuration/page.ts`

## Root cause
Next.js typed routes are generated into `.next/types`. When we removed the `configuration/` page, the generated type references lingered in `.next`. Because `tsconfig.json` includes `".next/types/**/*.ts"`, TypeScript still “saw” the route and expected a source file that no longer existed.

## The fix
1. Stop the dev server.
2. Remove the Next.js cache:
   ```bash
   rm -rf web-next/.next
   ```
3. Restart the TypeScript server in your IDE (or just rebuild):
   ```bash
   cd web-next
   npm run dev
   ```
4. Optional: If the page was supposed to exist, recreate it at `web-next/src/app/(dashboard)/configuration/page.tsx`.

## Prevention tips
- Keep `Sidebar` links (`web-next/src/components/layout/Sidebar.tsx`) in sync with folders under `web-next/src/app/(dashboard)/`.
- When renaming/removing routes, clear `.next` if typed routes behave oddly.
- Prefer small, frequent rebuilds during route work.

---

Prev: [Building the DDM Admin UI with Next.js 14](./03-frontend-admin-ui-nextjs.md)

Next: [Docs that Don’t Rot: Keeping README and UI in Sync](./05-docs-refresh-roadmap.md)
