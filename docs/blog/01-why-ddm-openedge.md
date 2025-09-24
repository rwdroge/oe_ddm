---
title: "Why We Built a Modern DDM Admin for OpenEdge (ABL + PASOE + Next.js)"
date: 2025-09-23
author: oe_ddm team
description: The origin story—problem, approach, and tech stack for a pragmatic OpenEdge Dynamic Data Masking administration solution.
---

# Why We Built a Modern DDM Admin for OpenEdge (ABL + PASOE + Next.js)

## The problem
- **Compliance pressure**: Enforce least-privilege access while preserving developer velocity.
- **Operational reality**: Data masking must be configurable, reversible, and visible to admins.
- **OpenEdge context**: Use first-class OpenEdge APIs and deployment patterns.

## Our approach
- **Dynamic Data Masking (DDM)** with format-preserving strategies.
- **REST boundary** via PASOE webhandlers.
- **Modern admin UI** built in Next.js 14 App Router for usability and speed.
- **DevContainers** for a reproducible dev setup.

## Repository structure
See full structure in `README.md`, highlighted pieces:
- ABL service: `src/ddm/DataAdminMaskingService.cls`
- PASOE handlers: `src/webhandlers/MaskingApiHandler.cls`
- PAS config: `conf/openedge.properties`
- Web UI: `web-next/`

## Repository links
- ABL service: https://github.com/rwdroge/oe_ddm/blob/main/src/ddm/DataAdminMaskingService.cls
- PASOE handler: https://github.com/rwdroge/oe_ddm/blob/main/src/webhandlers/MaskingApiHandler.cls
- PAS config: https://github.com/rwdroge/oe_ddm/blob/main/conf/openedge.properties
- UI API client: https://github.com/rwdroge/oe_ddm/blob/main/web-next/src/services/api.ts
- UI Sidebar (navigation): https://github.com/rwdroge/oe_ddm/blob/main/web-next/src/components/layout/Sidebar.tsx

```mermaid
flowchart LR
  UI[Next.js Admin UI (web-next)] --> REST[REST API (PASOE)\nwebhandlers.MaskingApiHandler]
  REST --> SERVICE[ABL Service\n(ddm.DataAdminMaskingService)]
  SERVICE --> DDMAPI[OpenEdge DataAdmin DDM API]
  DDMAPI --> DB[(OpenEdge DB)]
```

## Quick start
- Web UI dev server (from `web-next/`):
```bash
npm install
npm run dev -- --port 42137
```
- PASOE health:
```bash
curl http://localhost:8810/api/masking/health
```

## Why these technologies?
- **ABL + DataAdmin API**: First-party DDM operations and predictable performance.
- **PASOE**: A well-trodden path for HTTP boundaries in OpenEdge.
- **Next.js**: Fast DX, typed routes, flexible layouts for admin workflows.
- **DevContainers**: Align contributor environments.

## What’s next
In Part 2, we go deep on the ABL back-end—service design, webhandlers, and endpoints.

---

Next: [Inside the ABL Back-end: Service Layer + PASOE Webhandlers for DDM](./02-backend-architecture-abl-pasoe.md)
