# Hands-on Joule Studio – Gestion des fournisseurs avec Skills et Agent

Bienvenue à ce hackathon Joule Studio !

Dans cet atelier, vous allez créer pas à pas des **Joule Skills** et un **Agent Joule** pour aider les métiers à gérer leurs fournisseurs directement en langage naturel, sans avoir à naviguer dans plusieurs applications SAP. 

L’objectif est d’obtenir, en fin de workshop, une démonstration complète dans laquelle un utilisateur peut :
- demander le **blocage** ou le **déblocage** d’un fournisseur ;
- récupérer une **évaluation** de ce fournisseur depuis S/4HANA ;
- obtenir une **recommandation argumentée** avant de prendre sa décision. 
Les actions **SAP Build Process Automation** nécessaires pour dialoguer avec S/4HANA sont déjà disponibles, mais toutes ne seront pas utiles : à vous d’identifier les bonnes actions et de les exposer à Joule via les Skills. 

---

## Contexte général

Nous souhaitons équiper la fonction achats / risques avec un copilote Joule capable de répondre à des questions du type :

> « Peux-tu vérifier ce fournisseur et me dire s’il faut le bloquer ? »  
> « Débloque le fournisseur 12345 si le risque est faible. »

Pour cela, nous allons :
- utiliser des **actions SAP Build** pour exécuter les opérations techniques (blocage, déblocage, lecture des données dans S/4HANA) ;
- encapsuler ces actions dans des **Joule Skills** ;
- orchestrer le tout dans un **Agent Joule** qui raisonne, enquête et propose une recommandation.
La récupération d’informations externes (web, bases tiers, presse…) est **optionnelle** : concentrez-vous d’abord sur les données internes S/4HANA, puis ajoutez des sources externes seulement si le temps le permet. 

---

## Prérequis

Avant de commencer, assurez-vous d’avoir :

- un **accès à Joule Studio** dans votre sous-compte BTP / environnement SAP Build ; 
- un espace SAP Build Process Automation avec les **actions déjà créées** pour :
  - bloquer un fournisseur,
  - débloquer un fournisseur,
  - récupérer les informations d’évaluation d’un fournisseur dans S/4HANA ;
- les liens / captures d’écran fournis par les organisateurs pour vous guider dans l’interface Joule Studio.  

Aucune expérience préalable de Joule Studio n’est requise, mais une familiarité avec SAP Build ou S/4HANA est un plus.

---

## Vue d’ensemble des sprints

Le workshop est structuré en **3 sprints** progressifs :

1. **Sprint 1 : Skill de blocage / déblocage**  
   Obtenir un premier résultat concret : une skill qui permet à l’agent de demander un blocage ou un déblocage fournisseur, avec récapitulatif et confirmation.  
2. **Sprint 2 : Skill d’évaluation fournisseur**  
   Récupérer l’évaluation d’un fournisseur et produire un score à partir des critères définis.  
3. **Sprint 3 : Agent Joule décisionnel**  
   Construire un agent qui enquête, consolide les informations (internes et éventuellement externes) et propose une recommandation argumentée avant d’appeler les skills.

Vous pouvez avancer à votre rythme, mais nous vous recommandons de **valider chaque sprint** avant de passer au suivant.

---

## Sprint 1 – Skill de blocage / déblocage fournisseur

> « Je veux un premier résultat concret et démontrable : un Skill Joule qui permet à l’agent de demander un blocage ou déblocage fournisseur en langage naturel.  
> L’utilisateur ne doit fournir que le numéro fournisseur.  
> Ensuite, Joule doit afficher un récapitulatif et demander une validation avant d’exécuter l’action. »

### Objectif

Créer une **Skill Joule** qui encapsule les actions SAP Build de blocage / déblocage d’un fournisseur. L’utilisateur doit simplement fournir le **numéro fournisseur / BP**, et Joule doit :  

1. récupérer les informations nécessaires pour présenter un **récapitulatif** (ex. nom du fournisseur, statut actuel) ;  
2. demander explicitement à l’utilisateur de **confirmer** l’action ;  
3. seulement après confirmation, appeler l’action SAP Build correspondante.
   
### Étapes proposées

1. **Explorer les actions disponibles**
   - Ouvrez la liste des actions SAP Build mises à disposition.
   - Identifiez celles liées au blocage / déblocage fournisseur et celles qui sont “pièges” (non nécessaires à ce use case).

2. **Créer la Skill Joule**
   - Dans Joule Studio, créez une nouvelle **Skill** dédiée au blocage / déblocage.
   - Définissez clairement :
     - l’intention : « gérer le statut de blocage d’un fournisseur » ;
     - les entrées : numéro fournisseur / BP (type simple, obligatoire) ;
     - les sorties : statut final, message de confirmation.

3. **Brancher l’action SAP Build**
   - Associez la Skill à l’action SAP Build correcte (blocage ou déblocage).
   - Vérifiez la correspondance des paramètres (nom, type, format).

4. **Gérer la confirmation**
   - Ajoutez une étape dans votre logique de Skill / Agent (selon la configuration) pour :
     - présenter un récapitulatif au format lisible ;
     - demander à l’utilisateur de confirmer (« Oui, bloque » / « Non, annule »).  
   - Assurez-vous que **sans confirmation explicite**, aucune action de blocage n’est exécutée.

5. **Tester en conversation**
   - Depuis Joule, testez des phrases comme :
     - « Bloque le fournisseur 12300010 »
     - « Débloque le fournisseur 12300010 »  
   - Validez que :
     - un récapitulatif s’affiche,
     - la confirmation est bien demandée,
     - l’action ne part qu’après validation.
    
## Livrables attendus

- **Les Skills Joule configurées** :
  - 1 Skill de blocage / déblocage fournisseur (Sprint 1),

## Les étapes de création

| #    | Steps    | Captures |
| :--: | :--- |  :-----   |
| 0 | Ouvrir SAP Build et naviguer vers les actions. Les actions sont les appels API qui peuvent sont configurés pour pouvoir être utilisés en tant que Skill. Il est possible d'importer un Swagger ou bien d'utiliser directement les APIs publiés par SAP sur le Business Accelerator Hub | ![alt text](images/SAPBuild_Landing.png) |
| 1 | Toutes les actions que vous trouverez ici ne sont pas forcément utiles pour répondre au besoin, vous pouvez les analyser pour voir ce qui répond le mieux au besoin | ![alt text](images/Actions.png) |
| 2 | Revenez au lobby, puis ouvrez le projet Joule Studio - Hackathon 2026, puis commencez la création du skill | ![alt text](images/EmptySkill.png) |
| 3 | L'élément déterminant du Skill va être la configuration de l'action. Une fois celle-ci choisie, il vous faudra dans un premier temps indiquer une variable de destination. Les destinations sont les éléments permettant à l'agent de s'authentifier lors d'un appel API, ils contiennent les credentials et le endpoint à appeler. | ![alt text](images/CreateAction.png) |
| 4 | Ensuite, comme pour un appel API classique, on indique les paramètres de l'appel que Joule doit effectuer. | ![alt text](images/ActionInput.png) |
| 5bis | Attention, pour s'assurer que les paramètres soient envoyés correctement, il est conseillé de les indiquer depuis l'éditeur de formule. | ![alt text](images/ApplyFormula.png) |
| 5 | Voici un exemple de skill complet, notez toutefois qu'il n'existe pas qu'une unique solution au besoin, n'hésitez pas à proposer votre proche approche. | ![alt text](images/CompletedSkill.png) |
---

## Sprint 2 – Skill d’évaluation fournisseur

> « Maintenant, il faut évaluer nos fournisseurs.  
> Je veux un Skill Joule qui permet à l’agent de récupérer l’évaluation d’un fournisseur.  
> L’utilisateur ne doit fournir que le numéro fournisseur.  
> Ensuite, Joule va définir le score selon les critères définis. »

### Objectif

Créer une **Skill Joule d’évaluation** qui utilise une action SAP Build pour récupérer les données de scoring ou d’évaluation d’un fournisseur dans S/4HANA, et qui calcule ou expose un **score** selon les critères définis dans le système (ou dans votre logique).

### Étapes proposées

1. **Analyser l’action d’évaluation**
   - Parcourez les actions SAP Build disponibles pour trouver celle qui renvoit :
     - des scores,
     - des indicateurs de fiabilité, conformité, performance, etc.

2. **Créer la Skill d’évaluation**
   - Créez une Skill dédiée : « Évaluer un fournisseur ».
   - Entrée attendue : numéro fournisseur / BP.
   - Sorties attendues :
     - valeur(s) de score,
     - éventuels détails par critère,
     - interprétation simple (par ex. “faible”, “moyen”, “élevé”).
3. **Définir la logique de score**
   - En fonction des données retournées :
     - soit utilisez directement un score déjà calculé par S/4HANA,
     - soit appliquez une logique simple (par exemple moyenne de plusieurs critères).

4. **Tester la Skill**
   - Demandez à Joule :
     - « Donne-moi l’évaluation du fournisseur 1000001 »
   - Vérifiez que :
     - la Skill est appelée,
     - les données remontent,
     - le score ou la conclusion sont compréhensibles pour un utilisateur métier.
    
Pour ce Skill, l'essentiel est que l'agent soit capable de récupérer les éléments de notation. Il n'est pas obligatoire d'inclure une logique selon le score, celle-ci peut être définie dans le sprint 3.
---

## Sprint 3 – Agent Joule décisionnel

> « Les Skill exécutent, très bien. Maintenant je veux un Agent Joule qui aide à décider.  
> Avant de bloquer/débloquer, l’agent doit enquêter : récupérer des infos internes et externes* (web, base tiers, presse, etc.) et produire une recommandation argumentée.  
> Ensuite seulement, l’utilisateur choisit et l’agent déclenche l’action via le Skill. »

\* La récupération d’informations **externes** est optionnelle dans le cadre du hackathon.

### Objectif

Construire un **Agent Joule** qui, à partir d’une simple question de l’utilisateur, va :

1. utiliser la **Skill d’évaluation** (Sprint 2) pour récupérer les données internes S/4HANA ;
2. éventuellement enrichir avec des informations externes (web, bases tierces…) si vous décidez d’aller plus loin ; 
3. analyser ces informations et produire une **recommandation argumentée** (par ex. “conserver ce fournisseur” ou “recommander un blocage”) ;
4. proposer ensuite à l’utilisateur de confirmer l’action de blocage / déblocage ;
5. enfin, appeler la **Skill de blocage / déblocage** (Sprint 1) pour exécuter l’action.

### Étapes proposées

1. **Créer l’Agent Joule**
   - Dans Joule Studio, créez un nouvel Agent dédié à la recommandation fournisseur. 
   - Définissez son rôle :
     - aider l’utilisateur à décider de bloquer ou non un fournisseur,
     - expliquer sa recommandation en langage naturel. 

2. **Connecter les Skills existantes**
   - Associez à l’agent :
     - la Skill de blocage / déblocage (Sprint 1),
     - la Skill d’évaluation (Sprint 2). 

3. **Définir la stratégie de décision**
   - Indiquez à l’agent, dans sa description / ses instructions :
     - comment interpréter le score d’évaluation,
     - à partir de quel niveau de risque il doit recommander un blocage ou une surveillance. 

4. **(Optionnel) Ajouter des sources externes**
   - Si le temps le permet, autorisez l’agent à compléter l’analyse par des informations externes (web, bases tierces, presse…) via des outils ou actions supplémentaires. 
   - Assurez-vous de bien distinguer dans la réponse ce qui vient d’S/4HANA et ce qui vient de l’extérieur.

5. **Scénarios de test**
   - Essayez des prompts comme :
     - « Peux tu me faire une recommendation sur les fournisseurs 1000036, 12300001 et 12300010? »
     - « Est-ce que ce fournisseur présente un risque ? »  
   - Vérifiez que l’agent :
     - récupère l’évaluation,
     - explique sa recommandation,
     - propose ensuite d’exécuter le blocage / déblocage via la Skill appropriée,
     - demande toujours la **validation finale** avant d’exécuter l’action.

Exemple de rendu final : ![alt text](images/RenduFinal.png)

---

## Conseils pour réussir le hackathon

- **Commencez simple.** Un agent qui maîtrise bien les données internes S/4HANA vaut mieux qu’un agent “tout connecté” mais instable.
- **Soignez les descriptions** des Skills et de l’Agent : c’est ce qui aide Joule à choisir le bon outil au bon moment. 
- **Testez en langage naturel** dès que possible pour valider que le comportement est compréhensible du point de vue métier.
- **Repérez les “pièges”** dans les actions SAP Build : toutes ne servent pas au scénario. Justifiez vos choix.
- **Gardez la main humaine** : aucune action sensible (blocage) ne doit être exécutée sans confirmation explicite dans la conversation. 
