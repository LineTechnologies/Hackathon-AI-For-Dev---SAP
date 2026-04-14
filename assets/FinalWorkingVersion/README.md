# Long Tail Vendor Management

Application SAP Fiori Elements pour identifier et gérer les fournisseurs inactifs dans S/4HANA.

Développée dans le cadre du **Hackathon AI FOR DEV – SAP** en 4 sprints itératifs : Sprint 1 via SAP Project Accelerator, Sprints 2–4 via Claude Code.

---

## Contexte métier

Au fil du temps, le référentiel fournisseurs d'une entreprise accumule une « long tail » de fournisseurs avec peu ou pas d'activité récente. Cette situation génère plusieurs risques :

- Prolifération de fournisseurs sans Bon de Commande ni facture récente
- Données bancaires et coordonnées potentiellement obsolètes
- Difficulté à identifier visuellement les fournisseurs inactifs ou à risque dans les outils standard S/4HANA
- Actions de nettoyage (blocage, clôture) disperses et non tracées

**L'application permet aux acheteurs et contrôleurs SAP de :**

- Visualiser rapidement les fournisseurs inactifs ou sous-actifs
- Consulter un score de risque calculé automatiquement (inactivité, retards de paiement, retards de livraison, complétude des données)
- Naviguer vers la fiche détail d'un fournisseur pour un diagnostic complet
- Exécuter des actions métier (blocage, déblocage, demande de clôture) directement depuis l'application
- Synchroniser les données depuis les API S/4HANA standard

---

## Fonctionnalités

### Liste des fournisseurs (List Report)
- Tableau filtrable avec indicateurs de criticité colorés (vert / orange / rouge)
- Filtres : pays, catégorie, statut de blocage, mois d'inactivité, date du dernier BC
- KPI synthétiques en en-tête : total fournisseurs, inactifs, haut risque, montant à risque
- Colonnes : ID, nom, pays, catégorie, date dernier BC, date dernière facture, montant PO, mois d'inactivité, score de risque, statut

### Fiche fournisseur (Object Page)
- En-tête avec nom, pays/catégorie, statut de risque coloré, statut de blocage
- Onglet **Détails** : informations générales, adresse, données fiscales et bancaires, responsable compte
- Onglet **Bons de commande** : liste avec dates, montants, statuts de livraison
- Onglet **Factures** : liste avec dates d'échéance, statuts et retards de paiement
- Actions métier : **Bloquer**, **Débloquer**, **Demander la clôture** (avec saisie de motif)
- Journal des actions tracé (historique horodaté par utilisateur)

### Score de risque
Calculé côté serveur CAP, combinant :
- **Inactivité** — mois depuis la dernière activité PO ou facture
- **Retards de paiement moyens** — jours de retard moyen sur les factures
- **Retards de livraison moyens** — jours de retard moyen sur les bons de commande
- **Complétude des données** — adresse, données fiscales, données bancaires

Résultat : score 0–100 avec statut `Faible` / `Moyen` / `Élevé`, affiché avec criticité colorée.

### Synchronisation S/4HANA
Action `Sync S/4HANA` qui consomme 3 API S/4HANA standard :
- `API_BUSINESS_PARTNER` — données fournisseurs (Business Partners)
- `CE_PURCHASEORDER_0001` — bons de commande
- `API_SUPPLIERINVOICE_PROCESS_SRV` — factures fournisseurs

---

## Stack technique

| Couche | Technologie |
|---|---|
| Backend | SAP CAP (Node.js) — service OData V4 |
| Modèle de données | CDS (`.cds`) — entités, relations, annotations UI |
| Frontend | SAP Fiori Elements (UI5 1.136) — List Report + Object Page |
| Annotations UI | `annotations.cds` — SelectionFields, LineItem, Facets, Actions |
| Base de données (dev) | SQLite in-memory (via `@cap-js/sqlite`) |
| Intégration SAP | Remote Services + Destinations BTP (profil `hybrid`) |
| Sandbox API | SAP API Business Hub (profil `sandbox`) |

---

## Architecture des fichiers

```
├── app/
│   ├── vendormanagementapp/        ← Application Fiori Elements
│   │   ├── annotations.cds         ← Toutes les annotations UI (colonnes, filtres, actions)
│   │   ├── webapp/
│   │   │   ├── manifest.json       ← Routing, modèle OData, configuration UI5
│   │   │   ├── ext/                ← Extensions custom (KPI header, boutons d'action)
│   │   │   └── i18n/               ← Libellés multilingues (FR/EN)
│   │   └── _i18n/                  ← Libellés pour les annotations CDS
│   └── services.cds                ← Import des annotations UI
├── db/
│   └── schema.cds                  ← Modèle de données : Vendors, PurchaseOrders, Invoices, ActionLog
├── srv/
│   ├── service.cds                 ← Service OData V4 exposé (projections + actions)
│   ├── service.js                  ← Handlers CAP (calculs, sync S/4, actions métier)
│   └── external/                   ← Modèles EDMX des API S/4HANA importées
├── test/
│   └── data/                       ← Données CSV de mock (chargées automatiquement en dev)
└── docs/
    └── guide-integration-s4hana.md ← Guide de connexion aux API S/4HANA réelles
```

---

## Modèle de données

### `Vendors` — entité principale (draft-enabled)

| Champ | Type | Description |
|---|---|---|
| `vendorID` | String | Identifiant S/4HANA du fournisseur |
| `vendorName` | String | Dénomination sociale |
| `country` | String(3) | Pays (code ISO) |
| `category` | String | Catégorie d'achat |
| `blockingStatus` | String | `Actif` \| `Bloqué` \| `En cours de clôture` |
| `lastPODate` | Date | Date du dernier Bon de Commande |
| `lastInvoiceDate` | Date | Date de la dernière facture |
| `totalPOAmount` | Decimal | Montant total des PO |
| `inactivityMonths` | Integer (virtual) | Mois depuis la dernière activité (calculé) |
| `riskScore` | Integer (virtual) | Score de risque 0–100 (calculé) |
| `riskStatus` | String (virtual) | `Faible` \| `Moyen` \| `Élevé` (calculé) |

### `PurchaseOrders` — N:1 vers Vendors
Champs clés : `purchaseOrderID`, `lastPODate`, `totalPOAmount`, `status`, `plannedDeliveryDate`, `deliveryDate`

### `Invoices` — N:1 vers Vendors
Champs clés : `invoiceID`, `lastInvoiceDate`, `dueDate`, `paymentDate`, `totalAmount`, `paymentStatus`, `paymentDelay`

### `ActionLog` — journal des actions métier
Champs clés : `vendorID`, `action` (`Block` | `Unblock` | `RequestClosure`), `actionDate`, `user`, `reason`

---

## Démarrage

### Prérequis
- Node.js LTS
- npm

### Installation

```bash
npm install
```

### Mode développement — données mock locales

```bash
# Avec hot reload et ouverture automatique du navigateur
npm run watch-vendormanagementapp
```

Application : `http://localhost:4004/vendormanagementapp/webapp/index.html`

Endpoint OData : `http://localhost:4004/odata/v4/long-tail-vendor-management-srv/`

### Mode sandbox — API SAP Business Hub

Créer un fichier `default-env.json` à la racine avec votre clé API :

```json
{
  "S4_API_KEY": "votre-clé-api-sap"
}
```

```bash
npm run sandbox
```

### Mode hybrid — API S/4HANA réelles via destinations BTP

Configurer les destinations BTP dans `default-env.json` (`s4_sandbox_BusinessPartner`, `s4_sandbox_PurchaseOrder`, `s4_sandbox_SupplierInvoices`), puis :

```bash
npm run watch-vendormanagementapp-prod
```

Voir le [guide d'intégration S/4HANA](docs/guide-integration-s4hana.md) pour la configuration complète.

---

## Linting

```bash
# Lint racine (règles CDS SAP)
npx eslint .

# Lint application Fiori (règles UI5)
cd app/vendormanagementapp && npx eslint .
```

---

## Données de test

En mode développement, CAP charge automatiquement les fichiers CSV depuis `test/data/` au démarrage. Le jeu de données couvre tous les profils de fournisseurs pour valider les règles de gestion et l'affichage :

- ~18% actifs récents (inactivité < 6 mois) — criticité verte
- ~17% actifs sous-actifs (6–11 mois) — criticité orange
- ~25% actifs inactifs (12–30 mois) — criticité rouge
- ~18% bloqués (15–36 mois d'inactivité)
- ~22% en cours de clôture (24–48 mois d'inactivité)

---

## Développement itératif — Sprints

| Sprint | Titre | Périmètre | Outil |
|---|---|---|---|
| **Sprint 1** | Initialisation | List Report + filtres + entités principales | SAP Project Accelerator (BAS) |
| **Sprint 2** | Insights & KPI | Score de risque, statut, en-tête KPI | Claude Code |
| **Sprint 3** | Navigation & Object Page | Fiche détail fournisseur, indicateurs | Claude Code |
| **Sprint 4** | Actions métier & Intégration S/4 | Blocage, déblocage, clôture, sync API | Claude Code |

---
 
*Guide version 1.0 — Adapted for Hackathon GenAI For Dev Workshops - SAP x Line | 2026*

*Author: Line*