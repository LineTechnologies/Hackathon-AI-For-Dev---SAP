# De la maquette CSV aux API S/4HANA réelles

## Guide d'intégration SAP CAP + BTP Destinations

> Ce guide documente la démarche complète pour faire évoluer une application SAP CAP d'un
> fonctionnement sur données locales (fichiers CSV / SQLite) vers la consommation d'API S/4HANA
> standard, via des destinations BTP. Il couvre l'architecture, les choix techniques, la
> configuration et les pièges rencontrés en pratique.

---

## Table des matières

1. [Contexte et architecture cible](#1-contexte-et-architecture-cible)
2. [Phase 1 — Maquette avec données locales (CSV)](#2-phase-1--maquette-avec-données-locales-csv)
3. [Phase 2 — Import des modèles d'API S/4HANA](#3-phase-2--import-des-modèles-dapi-s4hana)
4. [Phase 3 — Configuration CAP des services externes](#4-phase-3--configuration-cap-des-services-externes)
5. [Phase 4 — Implémentation du pattern Sync](#5-phase-4--implémentation-du-pattern-sync)
6. [Les destinations BTP — Guide détaillé](#6-les-destinations-btp--guide-détaillé)
7. [Profil Sandbox — Test local sans BTP](#7-profil-sandbox--test-local-sans-btp)
8. [Profil Hybrid — Test local avec BTP](#8-profil-hybrid--test-local-avec-btp)
9. [Référence des mappings de champs](#9-référence-des-mappings-de-champs)
10. [Troubleshooting](#10-troubleshooting)
11. [Checklist complète](#11-checklist-complète)

---

## 1. Contexte et architecture cible

### Le point de départ

Une application SAP CAP démarre naturellement avec des données locales. CAP charge automatiquement des fichiers CSV dans une base SQLite en développement — c'est rapide, sans dépendances réseau, idéal pour valider le modèle de données et l'UI Fiori.

Mais cette approche atteint ses limites dès qu'on veut :
- Valider que le modèle CAP est compatible avec les entités S/4HANA réelles
- Tester la configuration des destinations BTP et l'authentification
- Vérifier les mappings de champs avant un déploiement

### Le choix architectural : pattern Sync

Deux approches sont possibles pour intégrer S/4HANA dans une app CAP :

**Option A — Lecture temps réel (delegation pattern)**
À chaque requête Fiori, CAP délègue directement à S/4HANA et retourne les données.

**Option B — Synchronisation locale (sync pattern)**
Une action `syncFromS4()` tire les données depuis S/4HANA et les écrit dans la base locale CAP. L'UI Fiori lit toujours les données locales.

Le pattern Sync est recommandé pour les applications enrichissant les données S/4HANA avec une logique métier propre (scores de risque, statuts applicatifs, historique d'actions, draft Fiori) :

| Critère | Sync local | Lecture temps réel |
|---|---|---|
| Draft Fiori Elements | ✅ Compatible | ❌ Incompatible |
| Champs calculés côté CAP | ✅ Simples | ⚠️ Complexes à maintenir |
| Performance UI | ✅ Pas de latence | ⚠️ Latence réseau à chaque lecture |
| Disponibilité si S/4 indisponible | ✅ App fonctionnelle | ❌ App bloquée |
| Actions métier (block, close…) | ✅ Sur données locales | ⚠️ Gestion de conflits complexe |
| Fraîcheur des données | ⚠️ Dépend de la fréquence de sync | ✅ Temps réel |

### Architecture cible

```
┌─────────────────────────────────────────────────────────────────┐
│  Fiori Elements (List Report + Object Page)                     │
│  ← lit toujours les données de la base locale CAP              │
└───────────────────────────┬─────────────────────────────────────┘
                            │ OData V4
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  CAP Service (Node.js)                                          │
│                                                                 │
│  ┌─────────────────────────────────┐                           │
│  │ Base locale (SQLite / HANA)     │ ◄── action syncFromS4()  │
│  │ Vendors, PurchaseOrders,        │                           │
│  │ Invoices, ActionLog             │                           │
│  │ + champs enrichis CAP           │                           │
│  └─────────────────────────────────┘                           │
└──────────────────────────────┬──────────────────────────────────┘
                               │ cds.connect.to() via BTP Destinations
            ┌──────────────────┼──────────────────┐
            ▼                  ▼                  ▼
   API_BUSINESS_PARTNER  CE_PURCHASEORDER_0001  API_SUPPLIERINVOICE
   A_Supplier             PurchaseOrder          A_SupplierInvoice
   (OData V2)             (OData V4)             (OData V2)
```

### Structure du projet après intégration

```
project/
├── db/
│   └── schema.cds              ← Modèle de données local (inchangé)
├── srv/
│   ├── service.cds             ← Ajout de l'action syncFromS4()
│   ├── service.js              ← Handler sync + fonctions de mapping
│   └── external/
│       ├── API_BUSINESS_PARTNER.edmx    ← Téléchargé depuis api.sap.com
│       ├── API_BUSINESS_PARTNER.csn     ← Généré par `cds import`
│       ├── CE_PURCHASEORDER_0001.edmx
│       ├── CE_PURCHASEORDER_0001.csn
│       ├── API_SUPPLIERINVOICE_PROCESS_SRV.edmx
│       └── API_SUPPLIERINVOICE_PROCESS_SRV.csn
├── app/
│   └── vendormanagementapp/
│       └── annotations.cds     ← Bouton "Sync S/4HANA" ajouté
├── test/
│   └── data/                   ← CSV conservés pour le dev sans connexion
├── package.json                ← cds.requires avec profils [sandbox]/[hybrid]
├── .cdsrc-private.json         ← Credentials locaux (JAMAIS commité)
└── .env                        ← Variables d'environnement (JAMAIS commité)
```

---

## 2. Phase 1 — Maquette avec données locales (CSV)

### Comment CAP charge les fichiers CSV

En développement (`cds watch`), CAP détecte et charge automatiquement les fichiers CSV depuis `test/data/` au démarrage. La base est recréée en mémoire à chaque redémarrage. La convention de nommage est stricte :

```
test/data/<namespace>-<NomEntité>.csv
```

Exemple :
```
test/data/longTailVendorManagement-Vendors.csv
test/data/longTailVendorManagement-PurchaseOrders.csv
test/data/longTailVendorManagement-Invoices.csv
test/data/longTailVendorManagement-ActionLog.csv
```

### Règles de format des CSV

```csv
ID,vendorID,vendorName,country,category,blockingStatus,lastPODate,totalPOAmount
550e8400-e29b-41d4-a716-446655440001,V001,Acme Corp,FR,IT,Actif,2024-01-15,45000.00
550e8400-e29b-41d4-a716-446655440002,V002,Beta GmbH,DE,Logistics,Bloqué,2023-06-01,12500.00
```

Règles importantes :
- Les clés primaires (`ID`) et les clés étrangères (`vendors_ID`) doivent être en **format UUID**
- Les dates sont au format `YYYY-MM-DD`
- Les valeurs booléennes : `true` / `false`
- Les associations gérées par CAP génèrent une colonne `<association>_ID` (ex: `vendors_ID`)

### Coexistence CSV + données S/4HANA

Les CSV et la synchronisation S/4HANA peuvent coexister. Au démarrage avec `cds watch`, CAP charge les CSV. Quand on déclenche `syncFromS4()`, les données S/4HANA sont **upsertées** par-dessus les données CSV :
- Les enregistrements CSV dont la clé métier (`vendorID`, `purchaseOrderID`) correspond à une entrée S/4HANA sont **mis à jour**
- Les nouveaux enregistrements S/4HANA sont **insérés**
- Les champs non présents dans S/4HANA (riskScore, ActionLog...) sont **préservés**

Cela permet de garder des données de test enrichies tout en validant la connectivité S/4HANA.

---

## 3. Phase 2 — Import des modèles d'API S/4HANA

### Trouver les API sur SAP Business Accelerator Hub

Le [SAP Business Accelerator Hub](https://api.sap.com) (anciennement API Hub) est le catalogue officiel de toutes les API SAP. Pour chaque API, il fournit :
- La documentation complète des entités et champs
- Un environnement sandbox pour tester sans S/4HANA réel
- Le fichier EDMX (métamodèle OData) à télécharger

**API utilisées dans ce projet :**

| API | Nom technique | Version OData | Usage |
|---|---|---|---|
| Business Partner | `API_BUSINESS_PARTNER` | V2 | Fournisseurs |
| Purchase Order (Cloud) | `CE_PURCHASEORDER_0001` | V4 | Bons de commande |
| Supplier Invoice | `API_SUPPLIERINVOICE_PROCESS_SRV` | V2 | Factures |

### Télécharger et importer le fichier EDMX

**Étape 1 — Télécharger l'EDMX :**
1. Aller sur [api.sap.com](https://api.sap.com)
2. Rechercher l'API (ex: `API_BUSINESS_PARTNER`)
3. Onglet **"API Specification"** → télécharger le format **"EDMX"**
4. Placer le fichier dans `srv/external/`

**Étape 2 — Importer dans CAP :**
```bash
# Depuis la racine du projet — génère le .csn et met à jour package.json
cds import srv/external/API_BUSINESS_PARTNER.edmx --as cds
cds import srv/external/CE_PURCHASEORDER_0001.edmx --as cds
cds import srv/external/API_SUPPLIERINVOICE_PROCESS_SRV.edmx --as cds
```

Cette commande :
- Compile l'EDMX en `.csn` (format JSON interne de CAP, ne jamais éditer manuellement)
- Met à jour la section `cds.requires` de `package.json` avec le `kind` et `model` corrects

### Déclarer les imports dans service.cds

Les modèles doivent être importés dans `service.cds` pour que CAP connaisse les types lors des appels runtime :

```cds
// srv/service.cds

using { API_BUSINESS_PARTNER as bupaAPI }           from './external/API_BUSINESS_PARTNER';
using { CE_PURCHASEORDER_0001 as poAPI }            from './external/CE_PURCHASEORDER_0001';
using { API_SUPPLIERINVOICE_PROCESS_SRV as invAPI } from './external/API_SUPPLIERINVOICE_PROCESS_SRV';

service monService {
  // Ces using n'exposent rien via OData — ils rendent les types disponibles pour cds.connect.to()
  // ...
}
```

### Explorer les entités disponibles

Le fichier `.csn` est un JSON volumineux. Pour identifier rapidement les entités disponibles :

```bash
# Lister toutes les entités d'une API
grep -o '"[A-Za-z_]*":{"kind":"entity"' srv/external/API_BUSINESS_PARTNER.csn | \
  sed 's/:{"kind":"entity"//g' | tr -d '"'
```

Entités principales utilisées dans ce projet :

| API | Entité | Clé primaire |
|---|---|---|
| `API_BUSINESS_PARTNER` | `A_Supplier` | `Supplier` (String 10) |
| `API_BUSINESS_PARTNER` | `A_BusinessPartner` | `BusinessPartner` (String 10) |
| `CE_PURCHASEORDER_0001` | `PurchaseOrder` | `PurchaseOrder` (String 10) |
| `CE_PURCHASEORDER_0001` | `PurchaseOrderItem` | `PurchaseOrder` + `PurchaseOrderItem` |
| `API_SUPPLIERINVOICE_PROCESS_SRV` | `A_SupplierInvoice` | `SupplierInvoice` + `FiscalYear` |

> **Note :** Dans S/4HANA, `Supplier` et `BusinessPartner` partagent le même ID numérique.
> Un fournisseur (`A_Supplier`) a une entrée miroir dans `A_BusinessPartner` avec le même identifiant.
> C'est via `A_BusinessPartner` qu'on récupère les données d'adresse (pays, ville, etc.).

---

## 4. Phase 3 — Configuration CAP des services externes

### Configuration de base dans package.json

```json
"cds": {
  "requires": {
    "API_BUSINESS_PARTNER": {
      "kind": "odata-v2",
      "model": "srv/external/API_BUSINESS_PARTNER",
      "credentials": {
        "destination": "s4_sandbox_BusinessPartner"
      }
    },
    "CE_PURCHASEORDER_0001": {
      "kind": "odata",
      "model": "srv/external/CE_PURCHASEORDER_0001",
      "credentials": {
        "destination": "s4_sandbox_PurchaseOrder"
      }
    },
    "API_SUPPLIERINVOICE_PROCESS_SRV": {
      "kind": "odata-v2",
      "model": "srv/external/API_SUPPLIERINVOICE_PROCESS_SRV",
      "credentials": {
        "destination": "s4_sandbox_SupplierInvoice"
      }
    }
  }
}
```

Le champ `kind` détermine comment CAP interprète les réponses :
- `"odata-v2"` → enveloppe `{ d: { results: [...] } }`, dates `/Date(ms)/`
- `"odata"` → enveloppe `{ value: [...] }`, dates ISO 8601

Le champ `credentials.destination` indique le **nom de la destination BTP** à résoudre au runtime.

### Les profils d'environnement CAP

CAP supporte une surcharge de configuration par profil grâce à la syntaxe `[nom-profil]`. Ces sections s'appliquent uniquement quand la variable `CDS_ENV` (ou `NODE_ENV`) correspond au nom du profil. Les valeurs sont **fusionnées** (merge), pas remplacées en bloc.

```json
"cds": {
  "requires": {
    "API_BUSINESS_PARTNER": {
      "kind": "odata-v2",
      "model": "srv/external/API_BUSINESS_PARTNER",
      "credentials": {
        "destination": "s4_sandbox_BusinessPartner"   ← utilisé par défaut (hybrid/prod)
      }
    },
    "[sandbox]": {
      "API_BUSINESS_PARTNER": {
        "credentials": {
          "url": "https://sandbox.api.sap.com/...",   ← surcharge l'url uniquement
          "authentication": "NoAuthentication",
          "headers": { "APIKey": "${S4_API_KEY}" }    ← ${VAR} est résolu depuis l'environnement
        }
      }
    }
  }
}
```

Avec `CDS_ENV=sandbox`, les champs `url`, `authentication` et `headers` écrasent les credentials par défaut, mais `kind` et `model` restent ceux du bloc parent.

### Hiérarchie de chargement des fichiers de config

CAP charge et fusionne plusieurs sources de configuration, dans cet ordre de priorité (le plus fort en dernier) :

```
package.json  ←  .cdsrc.json  ←  .cdsrc-private.json  ←  variables d'environnement
    (versionné)                       (JAMAIS commité)
```

C'est pourquoi `.cdsrc-private.json` est l'endroit idéal pour les credentials de développement : il surcharge `package.json` sans jamais être poussé dans le dépôt git.

### Gestion des credentials secrets

**Règle absolue :** ne jamais mettre de clés API, mots de passe ou tokens dans un fichier versionné (`package.json`, `manifest.yml`, etc.).

**Option 1 — `.cdsrc-private.json`** (recommandé pour le développement) :

```json
{
  "requires": {
    "[sandbox]": {
      "API_BUSINESS_PARTNER": {
        "credentials": {
          "headers": { "APIKey": "ma-cle-api-secrete" }
        }
      },
      "CE_PURCHASEORDER_0001": {
        "credentials": {
          "headers": { "APIKey": "ma-cle-api-secrete" }
        }
      },
      "API_SUPPLIERINVOICE_PROCESS_SRV": {
        "credentials": {
          "headers": { "APIKey": "ma-cle-api-secrete" }
        }
      }
    }
  }
}
```

Ajouter au `.gitignore` :
```
.cdsrc-private.json
.env
```

**Option 2 — Variable d'environnement via `.env`** :

```bash
# .env
S4_API_KEY=ma-cle-api-secrete
```

Et référencer dans `package.json` avec la syntaxe `${NOM_VARIABLE}` :
```json
"headers": { "APIKey": "${S4_API_KEY}" }
```

CAP résout les `${...}` au démarrage depuis `process.env`.

---

## 5. Phase 4 — Implémentation du pattern Sync

### 5.1 Déclarer l'action dans service.cds

```cds
// srv/service.cds
service longTailVendorManagementSrv {

  // ... entités locales (Vendors, PurchaseOrders, Invoices, ActionLog) ...

  // Action non liée (unbound) : pas de contexte d'entité requis
  // Exposée en POST /odata/v4/long-tail-vendor-management-srv/syncFromS4
  @Common.Label: 'Synchroniser depuis S/4HANA'
  action syncFromS4() returns String;
}
```

### 5.2 Handler principal dans service.js

```javascript
// srv/service.js — dans la méthode init(), avant return super.init()

this.on('syncFromS4', async (req) => {
  const log = cds.log('s4sync')
  log.info('syncFromS4 déclenché par', req.user?.id || 'anonymous')

  try {
    // cds.connect.to() est mis en cache — appels parallèles sans risque
    const [BupaAPI, PoAPI, InvAPI] = await Promise.all([
      cds.connect.to('API_BUSINESS_PARTNER'),
      cds.connect.to('CE_PURCHASEORDER_0001'),
      cds.connect.to('API_SUPPLIERINVOICE_PROCESS_SRV')
    ])

    const { Vendors, PurchaseOrders, Invoices } = cds.entities('longTailVendorManagement')

    // ⚠️ SÉQUENTIEL obligatoire : POs et Invoices ont besoin des UUID vendors
    const vCount = await syncVendors(BupaAPI, Vendors)
    const pCount = await syncPurchaseOrders(PoAPI, PurchaseOrders, Vendors)
    const iCount = await syncInvoices(InvAPI, Invoices, Vendors)

    const msg = `Sync OK: ${vCount} fournisseurs, ${pCount} BdC, ${iCount} factures`
    log.info(msg)
    return msg

  } catch (err) {
    cds.log('s4sync').error('Sync échoué:', err)
    req.error(503, `Sync échoué: ${err.message}`)
  }
})
```

### 5.3 Appeler un service externe

```javascript
// Obtenir une instance de service externe
const BupaAPI = await cds.connect.to('API_BUSINESS_PARTNER')

// ── Méthode A : CQL typé ──────────────────────────────────────────────────────
// Recommandé pour des requêtes simples sans expand complexe
const { A_Supplier } = BupaAPI.entities
const suppliers = await BupaAPI.run(
  SELECT.from(A_Supplier)
    .columns('Supplier', 'SupplierName', 'PurchasingIsBlocked')
    .limit(500)
)

// ── Méthode B : send() avec path OData brut ───────────────────────────────────
// Recommandé pour les $expand, $filter complexes, ou quand on veut contrôler
// exactement le path OData envoyé au backend
const result = await BupaAPI.send({
  method: 'GET',
  path: '/A_Supplier?$select=Supplier,SupplierName&$expand=to_Company($select=Country)&$top=500'
})
```

> **Conseil :** Utiliser `send()` dès que la requête implique un `$expand`, un `$filter` avec des
> caractères spéciaux, ou quand on débogue (on voit exactement ce qui est envoyé).
> Le CQL CAP applique ses propres transformations qui peuvent différer du comportement OData attendu.

### 5.4 Gérer les formats de réponse OData V2 vs V4

Les deux versions d'OData ont des formats de réponse différents. CAP peut les normaliser automatiquement selon les versions, mais ce n'est pas garanti dans tous les cas. Une fonction défensive est indispensable :

```javascript
/**
 * Extrait le tableau de résultats d'une réponse OData, quel que soit le format.
 * - OData V4 : { value: [...] }
 * - OData V2 brut : { d: { results: [...] } }
 * - CAP normalisé : { value: [...] } ou tableau direct
 */
function extractResults(response) {
  if (!response) return []
  if (Array.isArray(response.value)) return response.value
  if (response.d?.results) return response.d.results
  if (Array.isArray(response)) return response
  return []
}
```

### 5.5 Parser les dates OData V2

OData V2 sérialise les dates en millisecondes depuis l'epoch Unix, encapsulées dans une chaîne :

```
/Date(1711843200000)/     →   2024-03-31
/Date(1711843200000+0000)/  →  avec timezone offset
```

```javascript
function parseODataDate(val) {
  if (!val) return null
  if (typeof val === 'string' && val.startsWith('/Date(')) {
    const ms = parseInt(val.match(/\d+/)[0])
    return new Date(ms).toISOString().substring(0, 10) // "2024-03-31"
  }
  return val // déjà une chaîne ISO (OData V4 ou CAP normalisé)
}
```

Appliquer cette fonction à **tous les champs de type Date** reçus depuis des API OData V2.

### 5.6 Pattern upsert

L'opération centrale de la sync est un upsert : insérer les nouvelles entrées, mettre à jour les existantes, sans créer de doublons. CAP v9 ne propose pas de `UPSERT` natif sur une clé métier arbitraire — on implémente manuellement :

```javascript
// 1. Charger les entrées existantes en une seule requête (évite les N+1)
const existing = await SELECT.from(Entity).columns('ID', 'businessKey')
const existingMap = Object.fromEntries(existing.map(e => [e.businessKey, e.ID]))

const toInsert = []
const toUpdate = []

// 2. Trier les enregistrements distants
for (const record of remoteRecords) {
  const existingID = existingMap[record.businessKey]
  if (existingID) {
    toUpdate.push({ ID: existingID, /* champs à mettre à jour */ })
  } else {
    toInsert.push({ ID: cds.utils.uuid(), businessKey: record.businessKey, /* tous les champs */ })
  }
}

// 3. Bulk insert (une seule requête SQL)
if (toInsert.length > 0) await INSERT.into(Entity).entries(toInsert)

// 4. Updates unitaires (pas de bulk UPDATE sur clé UUID arbitraire en CAP)
for (const record of toUpdate) {
  const { ID, ...fields } = record
  await UPDATE(Entity).set(fields).where({ ID })
}
```

### 5.7 Résoudre les FK UUID entre entités

Le modèle CAP utilise des UUID comme clés primaires. S/4HANA utilise des identifiants métier (String 10). Après avoir synced les vendors, il faut résoudre les `vendors_ID` (FK UUID) dans les POs et les factures :

```javascript
// Charger la map { vendorID_métier → UUID_CAP } après sync des vendors
const vendorRows = await SELECT.from(VendorsEntity).columns('ID', 'vendorID')
const vendorUUIDMap = Object.fromEntries(vendorRows.map(v => [v.vendorID, v.ID]))

// Lors du mapping d'un PO :
const vendorID = po.Supplier                          // "0010000001" (clé S/4)
const vendors_ID = vendorUUIDMap[vendorID] ?? null    // UUID CAP correspondant
```

### 5.8 Rendre la sync idempotente

La sync peut être appelée plusieurs fois sans danger si :
1. L'upsert est basé sur la **clé métier** (pas l'UUID), donc pas de doublons
2. Les champs CAP-spécifiques ne sont **jamais écrasés** si ils ont été modifiés côté CAP :

```javascript
// Exemple : ne pas écraser blockingStatus si une action CAP est en cours
const found = existingMap[vendorID]
if (found) {
  toUpdate.push({
    ID: found.ID,
    vendorName: s.SupplierName,
    // Préserver blockingStatus si pendingAction est actif côté CAP
    ...(found.pendingAction ? {} : { blockingStatus })
  })
}
```

### 5.9 Exposer le bouton dans Fiori List Report

```cds
// app/vendormanagementapp/annotations.cds

annotate longTailVendorManagementSrv.Vendors with @UI.LineItem: [
  // ... colonnes existantes ...

  // Action non liée → bouton dans la toolbar, sans sélection de ligne requise
  {
    $Type : 'UI.DataFieldForAction',
    Action: 'longTailVendorManagementSrv.syncFromS4',
    Label : 'Sync S/4HANA',
    ![@UI.Importance]: #High
  }
];
```

L'action `syncFromS4` étant **non liée** (unbound), le chemin dans `Action` est `<NomService>.<NomAction>` sans entité intermédiaire.

---

## 6. Les destinations BTP — Guide détaillé

### Qu'est-ce qu'une destination BTP ?

Une **destination** est une entrée de configuration centralisée dans le **Destination Service** de SAP BTP. Elle stocke :
- L'URL du système cible
- La méthode d'authentification et les credentials associés
- Des propriétés additionnelles (headers, certificats, etc.)

L'application ne connaît jamais l'URL ni les credentials du backend directement — elle ne connaît que le **nom logique de la destination**. Le Destination Service fait le lien au runtime.

### Flux complet d'un appel via destination

```
┌──────────────┐
│   App CAP    │
│              │   1. cds.connect.to('API_BUSINESS_PARTNER')
│  service.js  │──────────────────────────────────────────────────────────────┐
└──────────────┘                                                              │
                                                                              ▼
                                                               ┌─────────────────────────┐
                                                               │  @sap-cloud-sdk/         │
                                                               │  connectivity            │
                                                               │                          │
                                                               │  2. Lit la config :      │
                                                               │     destination:          │
                                                               │     "s4_sandbox_BUPA"    │
                                                               └────────────┬────────────┘
                                                                            │
                                                               3. Appelle le Destination Service BTP
                                                                            │
                                                               ┌────────────▼────────────┐
                                                               │  BTP Destination Service │
                                                               │                          │
                                                               │  s4_sandbox_BUPA:        │
                                                               │   URL: https://sandbox.. │
                                                               │   Auth: NoAuthentication │
                                                               │   APIKey: xxxxx          │
                                                               └────────────┬────────────┘
                                                                            │
                                                               4. Retourne URL + headers
                                                                            │
                                                               ┌────────────▼────────────┐
                                                               │  Requête HTTP finale     │
                                                               │  GET https://sandbox.   │
                                                               │  api.sap.com/...        │
                                                               │  APIKey: xxxxx          │
                                                               └────────────┬────────────┘
                                                                            │
                                                                            ▼
                                                               ┌────────────────────────┐
                                                               │  S/4HANA / API externe  │
                                                               └────────────────────────┘
```

L'authentification entre l'app et le Destination Service lui-même passe par XSUAA (OAuth2). C'est pourquoi les deux services doivent être liés à l'application.

### Types d'authentification disponibles dans une destination

| Type | Quand l'utiliser |
|---|---|
| `NoAuthentication` | Sandbox public avec API key en header |
| `BasicAuthentication` | S/4HANA on-premise avec user/password SAP |
| `OAuth2ClientCredentials` | Service-to-service sans utilisateur (ex: integrations) |
| `OAuth2SAMLBearerAssertion` | S/4HANA Cloud avec propagation d'identité utilisateur |
| `PrincipalPropagation` | S/4HANA on-premise via Cloud Connector avec SSO |

### Créer les instances de service BTP nécessaires

Deux services BTP sont nécessaires pour que CAP puisse résoudre les destinations :

**1. Service Destination** — stocke les définitions de destinations

Via BTP Cockpit : **Service Marketplace** → **Destination** → plan `lite` → créer instance `sandbox-destination`

Via CF CLI :
```bash
cf create-service destination lite sandbox-destination
cf create-service-key sandbox-destination sandbox-destination-key
```

**2. Service XSUAA** — fournit les tokens OAuth2 pour appeler le Destination Service

Créer un fichier `xs-security.json` :
```json
{
  "xsappname": "mon-app-sandbox",
  "tenant-mode": "dedicated"
}
```

Via CF CLI :
```bash
cf create-service xsuaa application sandbox-xsuaa -c xs-security.json
cf create-service-key sandbox-xsuaa sandbox-xsuaa-key
```

### Créer les destinations dans BTP Cockpit

**Cockpit BTP** → sous-compte → **Connectivity** → **Destinations** → **New Destination**

---

**Destination pour SAP Business Accelerator Hub (API_BUSINESS_PARTNER) :**

```
Name:               s4_sandbox_BusinessPartner
Type:               HTTP
URL:                https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BUSINESS_PARTNER
Proxy Type:         Internet
Authentication:     NoAuthentication

Additional Properties:
  APIKey            <votre clé Business Accelerator Hub>
  HTML5.DynamicDestination   true
```

> La propriété `APIKey` dans "Additional Properties" est injectée comme header HTTP `APIKey: <valeur>`
> par le SAP Cloud SDK sur chaque requête sortante. Le nom de la propriété doit correspondre
> exactement au nom du header attendu par l'API cible.

---

**Destination pour S/4HANA on-premise (via Cloud Connector) :**

```
Name:               s4_prod_BusinessPartner
Type:               HTTP
URL:                http://<virtual-host>:<virtual-port>
Proxy Type:         OnPremise
Authentication:     BasicAuthentication
User:               RFC_USER
Password:           <mot de passe>

Additional Properties:
  sap-client        100
```

> `Proxy Type: OnPremise` indique au Destination Service de router la requête via le **SAP Cloud
> Connector** (SCC), l'agent installé dans le réseau on-premise qui établit un tunnel sécurisé
> vers BTP sans ouvrir de ports entrants.

---

**Destination pour S/4HANA Cloud avec OAuth2 :**

```
Name:               s4_cloud_BusinessPartner
Type:               HTTP
URL:                https://<tenant>.s4hana.cloud.sap
Proxy Type:         Internet
Authentication:     OAuth2SAMLBearerAssertion
Audience:           https://<tenant>.s4hana.cloud.sap
AuthTokenEndpoint:  https://<tenant>.authentication.sap.hana.ondemand.com/oauth/token
Client ID:          <client id>
Client Secret:      <client secret>
```

### Lier les services à l'application (déploiement CF)

Dans `mta.yaml` (déploiement MTA) :
```yaml
modules:
  - name: mon-app-srv
    type: nodejs
    requires:
      - name: sandbox-destination
      - name: sandbox-xsuaa

resources:
  - name: sandbox-destination
    type: org.cloudfoundry.managed-service
    parameters:
      service: destination
      service-plan: lite

  - name: sandbox-xsuaa
    type: org.cloudfoundry.managed-service
    parameters:
      service: xsuaa
      service-plan: application
      path: ./xs-security.json
```

Pour le développement local sans déployer, voir la section [Profil Hybrid](#8-profil-hybrid--test-local-avec-btp).

---

## 7. Profil Sandbox — Test local sans BTP

Cette approche est la plus simple pour valider la connectivité aux API S/4HANA en local : **pas de BTP, pas de Cloud Foundry, juste une clé API** du SAP Business Accelerator Hub.

### Obtenir une clé API

1. Aller sur [api.sap.com](https://api.sap.com) et se connecter avec son compte SAP (S-user ou P-user)
2. Cliquer sur son avatar → **Settings**
3. Section **"API Key"** → **"Show API Key"**
4. Copier la clé (unique par compte, valide pour toutes les API du hub)

### Configurer le profil sandbox

Stocker la clé dans `.cdsrc-private.json` (jamais dans `package.json`) :

```json
{
  "requires": {
    "[sandbox]": {
      "API_BUSINESS_PARTNER": {
        "credentials": {
          "headers": { "APIKey": "votre-cle-ici" }
        }
      },
      "CE_PURCHASEORDER_0001": {
        "credentials": {
          "headers": { "APIKey": "votre-cle-ici" }
        }
      },
      "API_SUPPLIERINVOICE_PROCESS_SRV": {
        "credentials": {
          "headers": { "APIKey": "votre-cle-ici" }
        }
      }
    }
  }
}
```

Ce profil **fusionne** avec `package.json` : seuls les champs `credentials` sont surchargés. Les champs `kind`, `model` et `url` (si défini dans `package.json` pour le profil sandbox) restent inchangés.

### Lancer en mode sandbox

```bash
CDS_ENV=sandbox npm run watch-vendormanagementapp
# ou
CDS_ENV=sandbox cds watch
```

CAP affiche au démarrage les services résolus :
```
[cds] - loaded model from 4 file(s):
[cds] - connect to API_BUSINESS_PARTNER > odata-v2 {
  url: 'https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BUSINESS_PARTNER'
}
```

### Déclencher la synchronisation

**Via HTTP (REST client ou curl) :**
```http
POST http://localhost:4004/odata/v4/long-tail-vendor-management-srv/syncFromS4
Content-Type: application/json

{}
```

**Via l'interface Fiori :**
Cliquer le bouton **"Sync S/4HANA"** dans la toolbar du List Report.

### Logs attendus en cas de succès

```
[s4sync] - syncFromS4 déclenché par anonymous
[s4sync] - 500 fournisseurs reçus depuis S/4
[s4sync] - Pays résolu pour 342 fournisseurs
[s4sync] - Fournisseurs: 500 insérés, 0 mis à jour
[s4sync] - 487 BdC reçus depuis S/4
[s4sync] - BdC: 487 insérés, 0 mis à jour
[s4sync] - 412 factures reçues depuis S/4
[s4sync] - Factures: 412 insérées, 0 mises à jour
[s4sync] - Sync OK: 500 fournisseurs, 487 BdC, 412 factures
```

---

## 8. Profil Hybrid — Test local avec BTP

Le profil **hybrid** permet de tester en local tout en passant par les **vrais services BTP** : Destination Service et XSUAA. C'est l'étape entre le développement local pur et le déploiement CF complet.

### Prérequis

```bash
# Vérifier que CF CLI est installé
cf --version

# Se connecter à Cloud Foundry
cf login -a https://api.cf.eu10-004.hana.ondemand.com  # adapter la région

# Cibler l'organisation et l'espace
cf target -o "mon-org" -s "Dev"
```

Les deux instances de service doivent exister dans l'espace CF ciblé :
- `sandbox-destination` (service Destination, plan `lite`)
- `sandbox-xsuaa` (service XSUAA, plan `application`)

### Créer les bindings avec `cds bind`

La commande `cds bind` récupère les credentials d'une instance de service CF et les écrit dans `.cdsrc-private.json`. Elle crée une service key si elle n'existe pas, ou en réutilise une existante.

```bash
# Lier le Destination Service
cds bind -2 sandbox-destination

# Lier XSUAA
cds bind -2 sandbox-xsuaa
```

Résultat dans `.cdsrc-private.json` :
```json
{
  "requires": {
    "[hybrid]": {
      "destinations": {
        "binding": {
          "type": "cf",
          "apiEndpoint": "https://api.cf.eu10-004.hana.ondemand.com",
          "org": "mon-org",
          "space": "Dev",
          "instance": "sandbox-destination",
          "key": "sandbox-destination-key"
        },
        "kind": "destinations",
        "vcap": { "name": "destinations" }
      },
      "auth": {
        "binding": {
          "type": "cf",
          "apiEndpoint": "https://api.cf.eu10-004.hana.ondemand.com",
          "org": "mon-org",
          "space": "Dev",
          "instance": "sandbox-xsuaa",
          "key": "sandbox-xsuaa-key"
        },
        "kind": "xsuaa-auth",
        "vcap": { "name": "auth" }
      }
    }
  }
}
```

Au démarrage en mode hybrid, CAP utilise ces bindings pour appeler CF et obtenir les credentials VCAP_SERVICES des services liés, exactement comme si l'app était déployée.

### Vérifier les destinations dans BTP Cockpit

Avant de lancer en mode hybrid, s'assurer que les destinations existent dans le sous-compte BTP :

**Cockpit BTP** → sous-compte → **Connectivity** → **Destinations**

| Nom | URL cible | Auth | Propriétés additionnelles |
|---|---|---|---|
| `s4_sandbox_BusinessPartner` | `https://sandbox.api.sap.com/.../API_BUSINESS_PARTNER` | NoAuthentication | `APIKey: <clé>` |
| `s4_sandbox_PurchaseOrder` | `https://sandbox.api.sap.com/.../purchaseorder/0001` | NoAuthentication | `APIKey: <clé>` |
| `s4_sandbox_SupplierInvoice` | `https://sandbox.api.sap.com/.../API_SUPPLIERINVOICE_PROCESS_SRV` | NoAuthentication | `APIKey: <clé>` |

> Utiliser le bouton **"Check Connection"** dans le Cockpit pour vérifier la connectivité réseau
> vers chaque destination avant de tester depuis l'app.

### Lancer en mode hybrid

```bash
cds watch --profile hybrid
# ou
CDS_ENV=hybrid npm run watch-vendormanagementapp
```

Au démarrage, CAP :
1. Lit les bindings CF depuis `.cdsrc-private.json`
2. Appelle CF pour obtenir les VCAP credentials de `sandbox-destination` et `sandbox-xsuaa`
3. Configure SAP Cloud SDK avec ces credentials
4. À chaque appel de `cds.connect.to()`, résout la destination via le Destination Service BTP

---

## 9. Référence des mappings de champs

### API_BUSINESS_PARTNER → Vendors

| Champ S/4HANA | Entité | Champ local | Notes |
|---|---|---|---|
| `Supplier` | `A_Supplier` | `vendorID` | Clé métier String(10), padded left zeros |
| `SupplierName` | `A_Supplier` | `vendorName` | |
| `PurchasingIsBlocked` | `A_Supplier` | → `blockingStatus` | `true` → 'Bloqué' |
| `PaymentIsBlockedForSupplier` | `A_Supplier` | → `blockingStatus` | OR avec PurchasingIsBlocked |
| `TaxNumber1` | `A_Supplier` | `taxNumber` | Numéro fiscal |
| `Country` | `A_BusinessPartnerAddress` | `country` | Via expand sur `A_BusinessPartner` |
| *(généré)* | — | `ID` | `cds.utils.uuid()` |
| `'Autre'` *(défaut)* | — | `category` | Pas de catégorie dans l'API standard |

**Logique de blockingStatus :**
```javascript
const blockingStatus = (s.PurchasingIsBlocked || s.PaymentIsBlockedForSupplier) ? 'Bloqué' : 'Actif'
// Ne pas écraser si pendingAction est actif côté CAP
```

### CE_PURCHASEORDER_0001 → PurchaseOrders

| Champ S/4HANA | Entité | Champ local | Notes |
|---|---|---|---|
| `PurchaseOrder` | `PurchaseOrder` | `purchaseOrderID` | Clé métier String(10) |
| `Supplier` | `PurchaseOrder` | `vendorID` | |
| *(résolu depuis Vendors)* | — | `vendors_ID` | FK UUID après sync vendors |
| `PurchaseOrderDate` | `PurchaseOrder` | `lastPODate` | |
| Σ `NetAmount` des items | `PurchaseOrderItem` | `totalPOAmount` | ⚠️ Pas au niveau header |
| `PurchasingProcessingStatus` | `PurchaseOrder` | `status` | Voir mapping ci-dessous |
| `PurchaseOrderDate[0:7]` | — | `poMonth` | Format "YYYY-MM" pour graphiques |

**Mapping PurchasingProcessingStatus :**
```javascript
{ '01': 'En cours', '02': 'Livré', '03': 'Clôturé' }
```

### API_SUPPLIERINVOICE_PROCESS_SRV → Invoices

| Champ S/4HANA | Entité | Champ local | Notes |
|---|---|---|---|
| `SupplierInvoice + '/' + FiscalYear` | `A_SupplierInvoice` | `invoiceID` | Clé composite |
| `InvoicingParty` | `A_SupplierInvoice` | `vendorID` | ≠ `Supplier` — partie facturante |
| *(résolu depuis Vendors)* | — | `vendors_ID` | FK UUID après sync vendors |
| `PostingDate` | `A_SupplierInvoice` | `lastInvoiceDate` | Format `/Date(ms)/` en OData V2 |
| `InvoiceGrossAmount` | `A_SupplierInvoice` | `totalAmount` | |
| `SupplierInvoicePaymentStatus` | `A_SupplierInvoice` | `paymentStatus` | Voir mapping ci-dessous |
| `DueCalculationBaseDate` | `A_SupplierInvoice` | `dueDate` | |

**Mapping SupplierInvoicePaymentStatus :**
```javascript
{ 'O': 'En attente', 'C': 'Payée', '': 'En attente' }
```

---

## 10. Troubleshooting

### Erreur : `destination not found` ou `503 Service Unavailable`

**Causes possibles :**
1. La destination n'existe pas dans BTP Cockpit
2. Le nom de la destination dans `package.json` ne correspond pas à celui dans BTP
3. L'instance de service Destination (`sandbox-destination`) n't est pas liée à l'app
4. En mode hybrid : le binding CF est expiré ou les credentials CF sont invalides

**Diagnostic :**
```bash
# Vérifier les bindings CF actifs
cf services

# Vérifier la connexion à une destination depuis CF
cf env mon-app-srv | grep -A 5 "destinations"

# Recréer le binding local
cds bind -2 sandbox-destination
```

---

### Erreur : `401 Unauthorized` sur l'API sandbox

**Causes :**
1. La clé API est incorrecte ou expirée
2. Le header `APIKey` n'est pas injecté (problème de config)
3. L'API n'est pas activée dans le Business Accelerator Hub (certaines API nécessitent une activation)

**Diagnostic :**
```bash
# Tester directement l'API avec curl
curl -H "APIKey: votre-cle" \
  "https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Supplier?\$top=1"
```

---

### Résultats vides : `Aucun fournisseur retourné depuis S/4`

**Cause probable :** Les données sandbox sont partagées et peuvent être vides ou limitées selon l'API.

**Diagnostic :**
- Tester directement dans le Business Accelerator Hub : onglet **"Try Out"** sur la page de l'API
- Certaines API sandbox retournent des données statiques, d'autres sont vides par défaut
- Vérifier avec `$top=5` d'abord pour confirmer qu'il y a des données

---

### `vendors_ID` est `null` dans les POs/Invoices après sync

**Cause :** Le `Supplier` dans les POs ne correspond à aucun `vendorID` dans la table Vendors.

**Raisons possibles :**
- La sync des vendors a échoué silencieusement avant celle des POs
- Les données sandbox des POs référencent des fournisseurs qui ne sont pas dans `A_Supplier`
- Le `Supplier` est padded différemment (`0000000123` vs `123`)

**Diagnostic :**
```bash
# Via OData — vérifier combien de POs ont un vendors_ID nul
GET /odata/v4/long-tail-vendor-management-srv/PurchaseOrders?$filter=vendors_ID eq null&$count=true
```

---

### Dates incorrectes après sync (1970 ou date aberrante)

**Cause :** Le format `/Date(ms)/` de l'API OData V2 n'est pas parsé.

**Solution :** Vérifier que la fonction `parseODataDate()` est bien appelée sur tous les champs date :
```javascript
lastInvoiceDate: parseODataDate(inv.PostingDate),
dueDate:         parseODataDate(inv.DueCalculationBaseDate),
```

---

### Timeout sur la sync dans Fiori (`Request timeout`)

**Cause :** La sync synchrone dépasse le timeout OData de Fiori Elements (30s par défaut).

**Solutions immédiates :**
- Réduire `$top` à 50-100 pendant les tests
- Appeler `syncFromS4` directement via HTTP REST client (pas de timeout UI)

**Solution robuste pour la production :**
Implémenter une action asynchrone avec polling :
```javascript
this.on('syncFromS4', async (req) => {
  // Lancer la sync en arrière-plan
  setImmediate(() => runSync().catch(console.error))
  // Retourner immédiatement
  return 'Sync démarrée en arrière-plan'
})
```

---

### `kind: "odata"` vs `kind: "odata-v2"` — erreur de parsing

**Symptôme :** Les dates arrivent comme `{}` au lieu d'une chaîne, ou les résultats sont `undefined`.

**Cause :** Le mauvais `kind` est utilisé. CAP applique des transformations différentes selon la version.

**Règle :**
- Vérifier sur [api.sap.com](https://api.sap.com) l'onglet "Overview" → champ "Protocol"
- `OData V2` → `"kind": "odata-v2"`
- `OData V4` → `"kind": "odata"`

---

### Les credentials de `.cdsrc-private.json` ne sont pas appliqués

**Cause probable :** Le profil n'est pas activé.

**Vérification :**
```bash
# Afficher la config effective résolue par CAP
CDS_ENV=sandbox cds env | grep -A 10 "API_BUSINESS_PARTNER"
```

Si les credentials ne montrent pas la clé API, vérifier :
1. Le nom du profil dans `.cdsrc-private.json` est bien `[sandbox]`
2. La variable `CDS_ENV=sandbox` est bien passée au démarrage
3. Le fichier est dans le **répertoire racine** du projet (même niveau que `package.json`)

---

## 11. Checklist complète

### Mise en place initiale

- [ ] Fichiers EDMX téléchargés depuis api.sap.com pour chaque API
- [ ] `cds import` exécuté pour chaque EDMX → fichiers `.csn` générés dans `srv/external/`
- [ ] `package.json` mis à jour avec les trois services dans `cds.requires` (avec `kind`, `model`, `credentials.destination`)
- [ ] `using ... from './external/...'` ajoutés dans `srv/service.cds`
- [ ] Action `syncFromS4()` déclarée dans `srv/service.cds`
- [ ] Handler `this.on('syncFromS4', ...)` implémenté dans `srv/service.js`
- [ ] Fonctions de sync (`syncVendors`, `syncPurchaseOrders`, `syncInvoices`) implémentées
- [ ] `parseODataDate()` et `extractResults()` définies et utilisées
- [ ] Bouton "Sync S/4HANA" ajouté dans `annotations.cds`
- [ ] `.cdsrc-private.json` ajouté au `.gitignore`
- [ ] `.env` ajouté au `.gitignore`

### Test en mode sandbox (sans BTP)

- [ ] Clé API récupérée sur api.sap.com
- [ ] Profil `[sandbox]` configuré dans `.cdsrc-private.json` avec la clé API
- [ ] URLs sandbox configurées dans `package.json` pour le profil `[sandbox]`
- [ ] App lancée avec `CDS_ENV=sandbox`
- [ ] `POST /syncFromS4` retourne un message de succès
- [ ] Données visibles dans le List Report Fiori
- [ ] `vendors_ID` non nul sur les POs et Invoices
- [ ] `riskScore` et `inactivityMonths` calculés correctement
- [ ] Deuxième appel à `syncFromS4` → pas de doublons

### Test en mode hybrid (avec BTP)

- [ ] CF CLI installé et `cf login` effectué
- [ ] Instances `sandbox-destination` et `sandbox-xsuaa` créées dans CF
- [ ] Destinations créées dans BTP Cockpit avec les bonnes URLs et clés API
- [ ] "Check Connection" OK pour chaque destination dans BTP Cockpit
- [ ] `cds bind -2 sandbox-destination` exécuté
- [ ] `cds bind -2 sandbox-xsuaa` exécuté
- [ ] `.cdsrc-private.json` contient le bloc `[hybrid]` avec les deux bindings CF
- [ ] App lancée avec `CDS_ENV=hybrid` (ou `--profile hybrid`)
- [ ] `POST /syncFromS4` retourne un message de succès en passant par BTP

---

*Guide rédigé dans le cadre du projet Long Tail Vendor Management — LVMH TECH Hackathon AI FOR DEV – SAP.*
