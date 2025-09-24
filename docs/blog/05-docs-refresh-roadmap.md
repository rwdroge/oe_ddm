---
title: "Docs that Don’t Rot: Keeping README and UI in Sync (Lessons + Roadmap)"
date: 2025-09-23
author: oe_ddm team
description: How we refreshed the README to match the code, the practices we adopted, and what we’re building next.
---

# Docs that Don’t Rot: Keeping README and UI in Sync (Lessons + Roadmap)

## What we changed
We refreshed `README.md` so it mirrors the actual repository:
- Project structure now includes `src/webhandlers/` and clarifies `src/ddm/`.
- “Components” reflect real files:
  - ABL service: `src/ddm/DataAdminMaskingService.cls`
  - Web handlers: `src/webhandlers/MaskingApiHandler.cls`
- Examples updated to match existing programs under `src/examples/`:
  - `CorrectDDMExample.p`, `ProperDDMExample.p`
- REST examples aligned with current endpoints used by the UI:
  - `GET /api/masking/health`, `POST /api/masking/configure-field`, etc.

## Practices to prevent drift
- Treat `README.md` as an interface—if a path or endpoint moves, update docs in the same PR.
- Keep typed client (`web-next/src/services/api.ts`) as the single source for REST endpoints.
- Prefer repository-relative paths in docs so readers can navigate easily.
- Add a lightweight “Docs check” to PR review: confirm examples and file paths resolve.

## Roadmap
- Surface more DDM insights in the UI:
  - Field-level configuration summaries per table (`/table-configs`).
  - Role and tag relationships visualization.
- Harden the back-end:
  - Integration tests for PASOE endpoints.
  - Tighter error typing and consistent error payloads.
- Auth & security:
  - Optional login flow improvements in the UI.
  - Role-aware views.
- DX improvements:
  - CI pipeline for type-check, lint, and build.
  - Packaging and deployment guides for PASOE and the Next.js UI.

## Links
- Repo structure and guides: `README.md`
- ABL service: `src/ddm/DataAdminMaskingService.cls`
- PASOE handlers: `src/webhandlers/MaskingApiHandler.cls`
- UI API client: `web-next/src/services/api.ts`

---

Prev: [The Case of the Missing Next.js Page](./04-debugging-missing-nextjs-page.md)
