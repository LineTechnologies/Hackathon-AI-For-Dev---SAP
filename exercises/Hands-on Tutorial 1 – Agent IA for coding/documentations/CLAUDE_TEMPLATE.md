# CLAUDE.md
TODO : modify it with hands-on elements

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**PO Control Tower Risk Monitor** — A SAP CAP + SAP UI5 Fiori Elements application for LVMH procurement teams to monitor and manage at-risk, delayed, and blocked Purchase Orders.

## Commands

```bash
# Install dependencies
npm install

# Start dev server (with mock data, hot reload)
npm run watch-pocontroltowerriskmonitor

# Start production-like server
npm start  # runs cds-serve

# Generate Cloud Foundry deployment config
cd app/pocontroltowerriskmonitor && npm run deploy-config
```

**Access Points (dev server on port 4004):**
- App: `http://localhost:4004/pocontroltowerriskmonitor/webapp/`
- OData service: `http://localhost:4004/odata/v4/pocontroltower-srv/`
- Fiori Launchpad: `http://localhost:4004/`

**Linting:** ESLint is configured via `eslint.config.mjs` (root extends `@sap/cds`, app extends `@sap-ux/eslint-plugin-fiori-tools`). No explicit lint script — use `npx eslint .`.

**Tests:** OPA integration tests live in `app/pocontroltowerriskmonitor/webapp/test/`. No npm test script is configured; tests run via the `testsuite.qunit.js` entry point in-browser.

## Architecture

The project follows the standard SAP CAP three-layer architecture:

```
db/schema.cds          → CDS entity definitions (data model)
srv/service.cds        → OData V4 service exposing entities
app/services.cds       → References app-level annotations
app/pocontroltowerriskmonitor/
  annotations.cds      → UI5/Fiori annotations (columns, filters, facets)
  webapp/manifest.json → App routing, OData model binding, UI5 config
  webapp/Component.js  → AppComponent (extends sap/fe/core/AppComponent)
test/data/*.csv        → Mock data loaded by CAP at startup
```

**Data flow:** UI5 Fiori Elements reads `manifest.json` to configure OData V4 binding → CAP evaluates CDS projections in `srv/service.cds` → SQLite serves data loaded from CSV files in `test/data/`.

### Key Entities (`db/schema.cds`)

- **PurchaseOrderItems** — Core entity (24 fields). Key fields: `purchaseOrder`, `purchaseOrderItem`, `supplier`, `material`, `scheduleLineDeliveryDate`, `itemDeliveryStatus`, `statusCriticality`, `isBlocked`.
- **PurchaseOrderHeaders** — Header aggregation entity (8 fields). Associated 1:N from Items via `purchaseOrder` field.

### Status / Criticality Mapping

The `itemDeliveryStatus` and `statusCriticality` fields drive the visual traffic-light display:

| Status | Criticality | Color |
|--------|-------------|-------|
| OnTrack | 3 | Green |
| AtRisk | 2 | Orange |
| Late | 1 | Red |
| Blocked | 0 | Gray |

Business rule: default filter shows only `AtRisk` + `Late` items, further filtered by the logged-in buyer's ID.

### UI Layer

The frontend is pure **Fiori Elements** (no custom views). UI behavior is driven entirely by:
- `annotations.cds` — defines `UI.LineItem` (15 columns), `UI.SelectionFields` (filter bar), `UI.Facets` (4 Object Page sections), and `UI.DataPoint`/criticality bindings.
- `manifest.json` — routes to `sap.fe.templates.ListReport` and `sap.fe.templates.ObjectPage`.

Changing UI layout (columns, filters, sections) means editing `annotations.cds`, not JavaScript.

### Mock Data

`test/data/pocontroltower-PurchaseOrderItems.csv` and `pocontroltower-PurchaseOrderHeaders.csv` contain 20+ records with varied statuses, suppliers, plants, and currencies. CAP auto-loads these CSV files on startup.

## Sprint Roadmap Context

- **Sprint 1 (current):** List Report + Object Page MVP with mock data and status visualization.
- **Sprint 2–5 (planned):** KPI headers, supplier graphs, Object Page drill-down, business actions (send reminders, block/reschedule), and AI risk assessment. Specs in `documentations/PO_ControlTower_Spec_Sprint2_5.docx`.

## Deployment

Target: SAP BTP Cloud Foundry. Required role: `PO_CONTROL_TOWER_USER`. Run `npm run deploy-config` from the app directory to generate CF deployment manifests.
