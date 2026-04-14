# Master the Machine: The Essential Guide to Prompting Claude Code

## Introduction
Welcome to the new era of software development. If you are not used to interacting with Generative AI on a daily basis, watching Claude Code autonomously navigate your terminal and write applications might feel like magic. But underneath, it is a highly logical, learnable skill.

Unlike a traditional search engine where you type a few disjointed keywords, Claude is designed to act as a highly capable, yet completely literal, pair programmer. It can generate complete SAP CAP data models, debug complex Fiori interfaces, and refactor entire files. However, there is one golden rule you must remember: the quality of the output is entirely dependent on the quality of your input. If your instructions (your "prompts") are vague, Claude will guess your intentions—and it often guesses wrong. If your prompts are precise, contextual, and structured, Claude becomes an incredible accelerator for your project.

This guide is designed to bridge the gap between human intent and machine execution. Whether you are tackling today's workshop mission or building enterprise-grade extensions, these principles will give you the foundation to communicate effectively with Claude Code.

## Objectives of this Guide
By following this guide, you will be able to:
* Adopt the "AI Manager" Mindset: Learn how to shift from writing raw code syntax to delegating tasks with clear, context-rich instructions.
* Structure the Perfect Prompt: Master the anatomy of a successful engineering prompt (Context, Task, Constraints, and Expected Output).
* Leverage Claude Code's Unique Features: Understand how to instruct an AI that has direct access to your local file system, IDE, and terminal commands.
* Iterate and Debug Effectively: Learn the exact steps to take when Claude makes a mistake, hallucinates a feature, or breaks existing logic.
* Protect Your Codebase: Apply safety guardrails to ensure you remain in control of your project's architecture while the AI does the heavy lifting.

---

## The 2-Minute Cheat Sheet

> **Before diving into the full guide, here's everything you need to know to get started right now.**

### The #1 Mindset Shift

Stop thinking *"how do I code this?"* → Start thinking *"how do I brief a senior engineer?"*

Claude does **exactly what you say**, not what you meant. Vague prompt = wrong output. Precise prompt = great output.

---

### The Perfect Prompt: CTCO Framework

Every prompt should have these 4 ingredients:

| Ingredient | Question it answers | Example |
|---|---|---|
| **C**ontext | Where are we? | *"I'm working on a SAP CAP project. The entity is in @db/schema.cds"* |
| **T**ask | What do we need? | *"Add a bound action `approveOrder` that sets Status to 'Approved'"* |
| **C**onstraints | What are the rules? | *"Use srv.on() pattern. Do not modify annotations.cds"* |
| **O**utput | What does done look like? | *"Show only modified files. Do NOT run the app."* |

---

### An other prompting framework
| Ingredient | Question it answers | Example | Optional (Yes/No) |
|---|---|---|---|
| **E**xpertise | What is the scope of expertise / knowledge? | *"You are an expert on CAP and Fiori developpment projects..."* | No |
| **C**ontext | Where are we? | *"I'm working on a SAP CAP project. The entity is in @db/schema.cds"* | No |
| **T**ask & *M*issions | What do we need? | *"Add a bound action `approveOrder` that sets Status to 'Approved'"* | No |
| **C**onstraints | What are the rules? | *"Use srv.on() pattern. Do not modify annotations.cds"* | Yes |
| **A**dditional context | What do we need to know more? | *"..."* | Yes |
| **O**utput | What does done look like? | *"..."* | Yes |

---

### The 4-Phase Workflow

For any non-trivial task, **never jump straight to implementation:**

```
1. EXPLORE  →  Ask Claude to READ your files first (Plan Mode ON)
2. PLAN     →  Ask Claude to PROPOSE a step-by-step plan, review it
3. IMPLEMENT → Switch to Normal Mode, let Claude EXECUTE
4. VERIFY   →  Ask Claude to RUN tests and CHECK consistency
```

> Use `Shift+Tab` to toggle **Plan Mode** — Claude thinks without touching your files.

---

### 5 Rules to Protect Your Codebase

1. **One goal per prompt** — never mix "add feature" + "refactor" in the same request
2. **Name files that must NOT be touched** — always explicit, never assumed
3. **Scope your investigations** — *"look only in @srv/"*, not *"find all problems"*
4. **Make Claude confirm** before deleting files, running deploys, or committing
5. **Two failed attempts?** → `/clear` and rewrite a better initial prompt, don't keep patching

---

### When Things Go Wrong

| Symptom | Fix |
|---|---|
| Wrong output, first time | Refine and retry with more explicit constraints |
| Wrong output, second time | `/clear` → rewrite the initial prompt from scratch |
| Claude ignores earlier rules | Context window is full → `/compact` or `/clear` |
| Claude uses an API/annotation you don't recognize | Ask it to verify: *"Confirm this exists in the official CAP docs"* |
| Claude keeps modifying files you didn't want changed | Add them explicitly to `CLAUDE.md` under **Do Not Modify** |

---

### CLAUDE.md — Set It Once, Benefit Forever

Create this file at the root of your project. Claude reads it automatically at every session — it's your project's permanent memory. Include: tech stack, file map, coding standards, forbidden files, and test commands.

> Keep it short. A bloated CLAUDE.md is ignored at the bottom. If Claude already does something right without being told → delete that line.

---

### Essential Shortcuts

| Command | What it does |
|---|---|
| `Shift+Tab` | Toggle Plan Mode (read/analyze without editing) |
| `/clear` | Fresh start — wipe context |
| `/compact` | Compress history, keep key context |
| `@filename` | Feed a file directly into your prompt |
| `!command` | Run a shell command from inside Claude Code |

> **Ready to go deeper?** The sections below explain each of these points in detail, with full examples and templates you can copy directly into your projects.

---
 
 ## Table of Contents

- [Part 1 — The AI Manager Mindset](#part-1--the-ai-manager-mindset)
  - [Stop Thinking Like a Developer. Start Thinking Like a Tech Lead.](#stop-thinking-like-a-developer-start-thinking-like-a-tech-lead)
  - [The Critical Behavioral Shift in Claude 4.x](#the-critical-behavioral-shift-in-claude-4x)
- [Part 2 — Anatomy of a Perfect Prompt](#part-2--anatomy-of-a-perfect-prompt)
  - [2.1 — C: Context (Where are we?)](#21--c-context-where-are-we)
  - [2.2 — T: Task (What do we need?)](#22--t-task-what-do-we-need)
  - [2.3 — C: Constraints (What are the rules?)](#23--c-constraints-what-are-the-rules)
  - [2.4 — O: Output (What does "done" look like?)](#24--o-output-what-does-done-look-like)
  - [2.5 — Putting It All Together](#25--putting-it-all-together)
- [Part 3 — Claude Code's Unique Features](#part-3--claude-codes-unique-features)
  - [3.1 — Direct File System Access with `@`](#31--direct-file-system-access-with-)
  - [3.2 — CLAUDE.md: Your Project's Permanent Memory](#32--claudemd-your-projects-permanent-memory)
  - [3.3 — Plan Mode: Separate Thinking from Doing](#33--plan-mode-separate-thinking-from-doing)
  - [3.4 — Custom Slash Commands](#34--custom-slash-commands)
  - [3.5 — Feeding Data Directly](#35--feeding-data-directly)
- [Part 4 — The Four-Phase Workflow](#part-4--the-four-phase-workflow)
  - [Phase 1 — Explore (Plan Mode ON)](#phase-1--explore-plan-mode-on)
  - [Phase 2 — Plan (Plan Mode ON)](#phase-2--plan-plan-mode-on)
  - [Phase 3 — Implement (Plan Mode OFF)](#phase-3--implement-plan-mode-off)
  - [Phase 4 — Verify](#phase-4--verify)
- [Part 5 — Iterating and Debugging Like a Pro](#part-5--iterating-and-debugging-like-a-pro)
  - [5.1 — The Two-Strike Rule](#51--the-two-strike-rule)
  - [5.2 — The Anatomy of a Good Debug Prompt](#52--the-anatomy-of-a-good-debug-prompt)
  - [5.3 — Isolating Hallucinations](#53--isolating-hallucinations)
  - [5.4 — Asking Claude to Explain, Not Just Generate](#54--asking-claude-to-explain-not-just-generate)
- [Part 6 — Protecting Your Codebase](#part-6--protecting-your-codebase)
  - [6.1 — The Principle of Minimal Change](#61--the-principle-of-minimal-change)
  - [6.2 — Reversibility Before Action](#62--reversibility-before-action)
  - [6.3 — Scope Your Investigations](#63--scope-your-investigations)
  - [6.4 — Understanding the Context Window](#64--understanding-the-context-window)
- [Part 7 — Advanced Patterns](#part-7--advanced-patterns)
  - [7.1 — The "Throw-Away First Draft" Technique](#71--the-throw-away-first-draft-technique)
  - [7.2 — Example-Driven Prompting](#72--example-driven-prompting)
  - [7.3 — Structured Prompts with XML Tags](#73--structured-prompts-with-xml-tags)
  - [7.4 — The Plan-Then-Parallelize Pattern](#74--the-plan-then-parallelize-pattern-advanced)
- [Quick Reference Cheat Sheet](#quick-reference-cheat-sheet)
- [Closing Thoughts: The Compounding Advantage](#closing-thoughts-the-compounding-advantage)

---

## Part 1 — The AI Manager Mindset
 
### Stop Thinking Like a Developer. Start Thinking Like a Tech Lead.
 
The single biggest mistake new Claude Code users make is treating it like an autocomplete tool — feeding it one line at a time and waiting for it to "fill in the blanks." Claude Code is not an autocomplete tool. It is an autonomous agent capable of reading your entire codebase, running terminal commands, writing tests, and validating its own output.
 
The mental shift you need to make is this:
 
> **Old mindset:** "How do I write this function?"
> **New mindset:** "How do I clearly brief a senior engineer to write this function correctly the first time?"
 
Think of yourself as a **Tech Lead delegating to a brilliant but literally-minded contractor.** This contractor:
 
- Will do exactly what you say, not what you meant
- Has read every file in your project if you point them to it
- Will confidently make incorrect assumptions if you leave gaps in the brief
- Produces dramatically better work when given examples, not just descriptions
- Can plan, implement, test, and verify — but only if you tell them to
 
This mindset unlocks everything. Every section of this guide is a technique to become a better delegator.
 
### The Critical Behavioral Shift in Claude 4.x
 
> [!IMPORTANT]
> If you have used earlier Claude versions, be aware that Claude 4.x models (Sonnet 4.6, Opus 4.6) no longer try to "infer your intent" and expand on vague requests. They execute your instructions literally. A prompt that worked in 2024 may produce a much narrower output in 2026. **Be more explicit, not less.**
 
---
 
## Part 2 — Anatomy of a Perfect Prompt
 
Every strong Claude Code prompt is built from four ingredients. Think of it as the **CTCO Framework**: **C**ontext, **T**ask, **C**onstraints, **O**utput.
 
### 2.1 — C: Context (Where are we?)
 
Context is the most underrated ingredient. Claude Code cannot "see" your project unless you show it. Always open a prompt by grounding Claude in the current state of affairs.
 
**What to include in Context:**
- The technology stack (e.g., SAP CAP, Node.js, SAPUI5 Fiori Elements)
- The specific file(s) relevant to the task
- What already exists and must not be broken
- Any recent decisions or architectural constraints
 
**Without context (weak):**
```
Add a field for supplier rating to the purchase order.
```
 
**With context (strong):**
```
I am working on a SAP CAP project targeting S/4HANA. The main entity
is in @db/schema.cds and is called PurchaseOrders. The OData service
is exposed in @srv/po-service.cds. There is already a Fiori Elements
List Report app consuming the service in @app/po-list/.
 
Add a new field `SupplierRating` (type Decimal, precision 5, scale 2)
to the PurchaseOrders entity.
```
 
The `@` symbol in Claude Code references a file directly — Claude reads it before responding.
 
### 2.2 — T: Task (What do we need?)
 
Be specific about the action. Avoid vague verbs like "improve," "fix," or "handle." Use precise verbs that define a clear outcome.
 
| Vague | Precise |
|---|---|
| "Fix the error" | "The CAP service throws error 400 when the `DeliveryDate` field is empty. Add server-side validation that returns a readable error message to the Fiori UI." |
| "Make the list better" | "In the List Report, add a column for `NetValue` with a currency unit linked to `Currency`, formatted as a `UI.DataField`." |
| "Add some actions" | "Create a CAP bound action `approveOrder` on the `PurchaseOrders` entity. It should update the `Status` field to `'Approved'` and set `ApprovedBy` to `$user.id`." |
 
### 2.3 — C: Constraints (What are the rules?)
 
This is where you protect your architecture. Constraints prevent Claude from "solving" your problem in a way that introduces new problems.
 
**Common constraints to specify:**
- Files that must NOT be modified
- Libraries or patterns that must (or must not) be used
- Standards to follow (e.g., SAP Fiori Design Guidelines, CDS naming conventions)
- Performance or compatibility requirements
 
**Example:**
```
Constraints:
- Do not modify the existing CDS annotations in @app/po-list/annotations.cds.
- The new action must be registered using CAP's srv.on() handler pattern in @srv/po-service.js.
- Do not introduce new npm dependencies.
- The Fiori action button must use the `UI.DataFieldForAction` annotation, not JavaScript.
```
 
### 2.4 — O: Output (What does "done" look like?)
 
Tell Claude exactly what you expect to see when it is finished. This prevents Claude from stopping prematurely or delivering more than needed.
 
**Example:**
```
Expected output:
1. The updated schema.cds with the new SupplierRating field.
2. An updated annotations.cds adding the field to the Fiori line item table.
3. A brief explanation of any change made to the service layer.
Do NOT run the application. Do NOT modify package.json.
```
 
### 2.5 — Putting It All Together
 
Here is a complete, production-grade prompt using the CTCO framework:
 
```
## Context
I am building a Purchase Order Control Tower application using SAP CAP
(Node.js) and Fiori Elements. The data model is defined in @db/schema.cds.
The main OData service is at @srv/po-service.cds with its implementation
in @srv/po-service.js. There is an existing List Report page for
PurchaseOrders in @app/po-list/annotations.cds.
 
## Task
Add a CAP bound action called `flagForReview` to the `PurchaseOrders`
entity. When triggered, it should:
1. Set the `Status` field to 'UnderReview'
2. Add a log entry in a new `StatusHistory` association (entity
   StatusHistory must be created if it doesn't exist yet)
3. Return the updated PurchaseOrder record
 
## Constraints
- Follow CAP best practices: define the action in .cds, implement in .js
- Use srv.on() handler pattern, not inline arrow functions
- The StatusHistory entity must have: ID (UUID), OrderID, ChangedAt
  (Timestamp), OldStatus, NewStatus, ChangedBy (String)
- Do not modify any existing annotations in annotations.cds
- Do not install new npm packages
 
## Expected Output
1. Updated schema.cds with the StatusHistory entity and association
2. Updated po-service.cds with the action declaration
3. Updated po-service.js with the srv.on('flagForReview') implementation
4. A brief summary of every file changed and why
```
 
---
 
## Part 3 — Claude Code's Unique Features
 
Claude Code is not just Claude-in-a-chat-window. It has unique capabilities that make it fundamentally different — and more powerful — than browser-based AI.
 
### 3.1 — Direct File System Access with `@`
 
Use the `@` prefix to reference specific files directly in your prompt. Claude reads them before generating a response — this is more reliable than describing a file's content.
 
```
Review @srv/po-service.js and @db/schema.cds for any field name
mismatches between the entity definition and the service handler.
```
 
You can reference multiple files and even entire directories:
 
```
Read the full structure of @app/po-list/ and tell me which annotations
file controls the column layout of the List Report table.
```
 
### 3.2 — CLAUDE.md: Your Project's Permanent Memory
 
`CLAUDE.md` is a special file you place at the root of your project. Claude Code reads it automatically at the start of every session — it acts as persistent context that you never have to re-explain.
 
**What to put in CLAUDE.md:**
 
```markdown
# Project: PO Control Tower — Hackathon
 
## Tech Stack
- SAP CAP (Node.js runtime)
- SAPUI5 Fiori Elements (List Report + Object Page)
- SAP BTP, Cloud Foundry environment
- SQLite for local dev, HANA for production
 
## Architecture Rules
- All CDS entities live in /db/schema.cds
- OData service definition: /srv/po-service.cds
- Business logic handlers: /srv/po-service.js (use srv.on() pattern)
- Fiori annotations: /app/po-list/annotations.cds (do not mix UI and
  service-layer logic)
 
## Coding Standards
- Entity names: PascalCase (e.g., PurchaseOrders)
- Field names: PascalCase (e.g., DeliveryDate)
- Handler functions: camelCase (e.g., approveOrder)
- Always add @readonly or @mandatory to applicable CDS fields
- Never use inline arrow functions in srv.on() handlers
 
## Do Not Touch
- /db/data/ (CSV seed files are production reference data)
- /app/po-list/webapp/manifest.json (managed by team lead)
 
## Test Command
Run `cds watch` to start local server. Test OData at http://localhost:4004
```
 
> [!TIP]
> Keep your `CLAUDE.md` concise. If it becomes too long, Claude will start ignoring sections buried at the bottom. Prune anything Claude already does correctly without being told.
 
### 3.3 — Plan Mode: Separate Thinking from Doing
 
Claude Code has a **Plan Mode** (activated with `Shift+Tab`). In Plan Mode, Claude analyzes and proposes — it does not make any changes to your files.
 
**Always use Plan Mode for:**
- Large, multi-file tasks before letting Claude execute
- Understanding the impact of a change before committing
- Reviewing Claude's interpretation of your request
 
**Workflow example:**
1. Switch to Plan Mode (`Shift+Tab`)
2. Enter your prompt: "Add paginated stock risk analysis to the Object Page"
3. Claude proposes a plan — review it. Does it touch the right files? Does the approach match your architecture?
4. If yes: switch back to Normal Mode and say "Execute the plan."
5. If no: correct the plan before a single line of code is written.
 
This saves enormous amounts of time compared to letting Claude run and then undoing unwanted changes.
 
### 3.4 — Custom Slash Commands
 
For tasks you run repeatedly, you can create **custom slash commands** stored in `.claude/commands/`. These are markdown files that Claude treats as reusable prompt templates.
 
**Example: `.claude/commands/new-cap-entity.md`**
```markdown
Create a new CAP entity based on the following specification:
 
Entity name: $ARGUMENTS
 
Apply these standards:
- Add the entity to @db/schema.cds
- Add managed fields: createdAt, createdBy, modifiedAt, modifiedBy
- Expose it in @srv/po-service.cds with full CRUD
- Add basic Fiori annotations (List + Object Page) in @app/po-list/annotations.cds
```
 
Run it with: `/new-cap-entity StockRiskItems`
 
### 3.5 — Feeding Data Directly
 
Claude Code can receive data piped from the terminal. This is powerful for debugging:
 
```bash
# Pipe error logs directly to Claude
cat logs/error.log | claude "Analyze this error log and identify the root cause"
 
# Pipe OData response for analysis
curl http://localhost:4004/odata/v4/po/PurchaseOrders | claude \
  "This is an OData response. Check if the Incoterms field is present
   and correctly typed."
```
 
---
 
## Part 4 — The Four-Phase Workflow
 
The most effective way to use Claude Code for non-trivial tasks is to follow a structured four-phase loop. Trying to jump straight to implementation on a complex feature is the #1 cause of wasted time and broken code.
 
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  1. EXPLORE │───>│  2. PLAN    │───>│ 3. IMPLEMENT│───>│  4. VERIFY  │
│  (read-only)│    │  (no edits) │    │  (write)    │    │  (test)     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```
 
### Phase 1 — Explore (Plan Mode ON)
 
Ask Claude to read and understand the relevant parts of your codebase before doing anything else. This prevents Claude from making incorrect assumptions about what already exists.
 
```
Read @db/schema.cds, @srv/po-service.cds, and @srv/po-service.js.
Explain:
1. What entities currently exist?
2. How are handlers structured?
3. Are there any existing actions defined?
Do not make any changes yet.
```
 
### Phase 2 — Plan (Plan Mode ON)
 
Ask Claude to propose a precise, step-by-step implementation plan. Review it carefully before proceeding.
 
```
Based on your exploration, create a detailed implementation plan for
adding a `StockRisk` classification field to PurchaseOrders that:
- Is calculated based on Quantity and LeadTime
- Is exposed as a virtual field in the service
- Is displayed in the Fiori Object Page header
 
List every file you will modify, what change you will make, and why.
```
 
Interrogate the plan:
- Does it touch files you did not expect?
- Does the approach fit your architecture standards?
- Is the plan missing a step (e.g., did it forget to add annotations)?
 
### Phase 3 — Implement (Plan Mode OFF)
 
Only now do you switch to Normal Mode and let Claude execute.
 
```
The plan looks good. Execute it now. Start with schema.cds,
then the service layer, then the annotations.
```
 
For large implementations, instruct Claude to **pause between files** so you can review incrementally:
 
```
Execute the plan step by step. After modifying each file, stop and
wait for my approval before continuing to the next step.
```
 
### Phase 4 — Verify
 
Always ask Claude to verify its own work. Claude can run tests, check for syntax errors, or validate consistency between files.
 
```
Now verify the implementation:
1. Run `cds build` and report any errors
2. Check that all new CDS field names match their usage in po-service.js
3. Confirm the Fiori annotation for StockRisk references the correct
   entity set name
```

> [!NOTE]
> **The golden rule of verification:** If you cannot verify it, do not ship it. Claude can produce plausible-looking code that silently fails at runtime. Always run your test command.
 
---
 
## Part 5 — Iterating and Debugging Like a Pro
 
Even the best prompts sometimes yield imperfect results. This is normal. The skill is in how you recover — efficiently, without wasting tokens or frustration.
 
### 5.1 — The Two-Strike Rule
 
If Claude gives you the wrong output once, refine your prompt and try again. If it gives you the wrong output a second time, **do not keep correcting in the same session.** Instead:
 
1. Run `/clear` to start a fresh context
2. Rewrite your initial prompt incorporating everything you learned from the two failed attempts
3. Be more explicit about the constraint or detail that Claude missed
 
Continuing to correct in a degraded context costs more time than starting fresh with a better prompt.
 
### 5.2 — The Anatomy of a Good Debug Prompt
 
When you encounter an error, give Claude the full picture, not just the error message.
 
**Weak debug prompt:**
```
It's not working. Fix it.
```
 
**Strong debug prompt:**
```
## Error
Running `cds watch` throws the following error:
[paste the full stack trace]
 
## Context
This error appeared after I added the `flagForReview` action to
@srv/po-service.cds. Before that change, the service started correctly.
 
## What I've already tried
I checked that the action is declared in the .cds file and the handler
name matches in po-service.js. Both look correct to me.
 
## Request
Identify the root cause of this error and provide the minimal fix.
Do not refactor any surrounding code.
```
 
### 5.3 — Isolating Hallucinations
 
Claude will occasionally reference a CDS annotation, a CAP API method, or a Fiori feature that does not exist or has changed in a recent version. This is called **hallucination**.
 
**How to catch and fix it:**
1. If a generated API call or annotation looks unfamiliar, ask Claude to verify it: "Is `cds.context.user.tenant` a valid CAP Node.js API? Show me the official documentation path."
2. Ask Claude to search the web or reference specific documentation: "Check the official SAP CAP documentation at cap.cloud.sap and confirm the correct syntax for defining a virtual field."
3. Cross-reference with your test command — if `cds build` fails, the hallucination is proven.
 
### 5.4 — Asking Claude to Explain, Not Just Generate
 
One of the most powerful debugging techniques is to ask Claude to explain its own output before you accept it.
 
```
Before I accept this change, explain in plain language:
1. What exactly does this handler do?
2. Why did you choose to use `req.reject()` here instead of `req.error()`?
3. Are there any edge cases this does not handle?
```
 
This forces Claude to reason through its own code — and it will often catch its own mistakes in the process.
 
---
 
## Part 6 — Protecting Your Codebase
 
Autonomy is Claude Code's superpower — and its risk. As Claude works, it can make changes you did not intend. Here is how to remain in control.
 
### 6.1 — The Principle of Minimal Change
 
Always instruct Claude to make the **smallest possible change** that achieves the goal. Resist the temptation to ask Claude to "improve," "clean up," or "refactor" in the same prompt as a feature request.
 
**Dangerous:**
```
Add the new action and also clean up the file and improve the error handling.
```
 
**Safe:**
```
Add only the `flagForReview` action. Do not modify any existing code,
do not rename any variables, and do not change any formatting.
A follow-up prompt will handle code quality separately.
```
 
### 6.2 — Reversibility Before Action
 
For any operation that is hard to undo — deleting files, running migrations, making git commits, calling external APIs — tell Claude to ask for your confirmation first.
 
You can bake this into your `CLAUDE.md`:
 
```markdown
## Safety Rules
Before executing any of the following, ALWAYS ask for my confirmation:
- Deleting any file
- Running `cds deploy` or any database migration command
- Making any git commit or push
- Calling any external API or webhook
```
 
### 6.3 — Scope Your Investigations
 
A common trap is asking Claude to "investigate" something across your entire codebase with no boundaries. Claude will read hundreds of files, consuming your context window rapidly and slowing down subsequent prompts.
 
**Vague (fills context fast):**
```
Find all the problems in this codebase.
```
 
**Scoped (targeted and efficient):**
```
In the @srv/ directory only, identify up to 3 potential issues with
how the OData service handles authorization. Ignore the /app and /db
directories.
```
 
### 6.4 — Understanding the Context Window
 
Claude Code works within a **context window** — a finite "working memory" for each session. As the conversation grows, older information may degrade in relevance, and Claude's accuracy can decline.
 
**Signs your context window is getting crowded:**
- Claude starts ignoring constraints you set earlier
- Claude repeats work it already did
- Responses become slower and less focused
 
**What to do:**
- Run `/compact` to compress the conversation history while preserving key decisions
- Run `/clear` to start completely fresh (use when switching to a new, unrelated task)
- Keep sessions focused: one goal per session is more efficient than chaining ten tasks
 
---
 
## Part 7 — Advanced Patterns
 
### 7.1 — The "Throw-Away First Draft" Technique
 
For complex, uncertain features, intentionally let Claude write a first draft without obsessing over quality. Use it as a **discovery tool**, not a production deliverable.
 
1. Prompt Claude to build the feature end-to-end, fast and rough.
2. Review the draft. Note where Claude diverged from your mental model.
3. `/clear` the session.
4. Write a second, sharper prompt informed by what you discovered.
 
The first draft is not wasted — it teaches you what questions you forgot to ask.
 
### 7.2 — Example-Driven Prompting
 
Claude responds dramatically better to examples than to descriptions. If you want a new handler to follow the same pattern as an existing one, show it:
 
```
Write a new handler for the `rejectOrder` action.
Follow the exact same pattern as this existing handler:
 
[paste the existing approveOrder handler code here]
 
The only differences should be:
- Action name: rejectOrder
- Status value: 'Rejected'
- Add a mandatory `RejectionReason` parameter (String)
```
 
### 7.3 — Structured Prompts with XML Tags
 
For complex, multi-part tasks, use XML-like tags to give Claude a clear structure to parse. Claude is specifically trained to handle structured inputs:
 
```xml
<context>
  Project: SAP CAP PO Control Tower
  Files: @db/schema.cds, @srv/po-service.js
  Current sprint: Sprint 3 — CAP Actions and Validations
</context>
 
<task>
  Implement server-side validation for the PurchaseOrders service.
  Reject any order where Quantity is greater than 10,000 with the
  message: "Quantity exceeds maximum allowed order volume."
</task>
 
<constraints>
  - Use req.error() with HTTP status 400
  - Validation must fire on CREATE and UPDATE events
  - Do not modify the CDS schema
</constraints>
 
<output_format>
  Show only the modified sections of po-service.js.
  Include a one-line comment above each new block explaining its purpose.
</output_format>
```
 
### 7.4 — The Plan-Then-Parallelize Pattern (Advanced)
 
For very large features spanning multiple independent files, you can instruct Claude to break the work into independent streams:
 
```
The stock risk dashboard requires changes in 3 completely independent areas:
1. A new CDS entity (db/schema.cds only)
2. A new REST endpoint in the service (srv only)
3. New Fiori annotations (app only)
 
These three changes do not depend on each other. Work on them in sequence,
but treat each one as an isolated task with its own context. After each one,
summarize what you did before starting the next.
```
 
---
 
## Quick Reference Cheat Sheet
 
### The CTCO Prompt Template
 
```
## Expertise
[Expert area needed for the feature, task, mission]

## Context
[Project, stack, relevant files (@references), current state]
 
## Task
[Precise action verb + specific goal]
 
## Constraints
[Files NOT to touch, (design) patterns to follow, libraries to avoid]

## Additional context
 
## Expected Output
[List of files to be modified, format of response, things NOT to do]
```
 
### Claude Code Key Shortcuts
 
| Shortcut | Action |
|---|---|
| `Shift+Tab` | Toggle Plan Mode (analyze without editing) |
| `/clear` | Clear context window, start fresh |
| `/compact` | Compress context while preserving history |
| `@filename` | Reference a file directly in your prompt |
| `!command` | Run a shell command from within Claude Code |
 
### The Debugging Checklist
 
When Claude produces wrong output, run through this before re-prompting:
 
- [ ] Did I provide enough **context** (stack, files, current state)?
- [ ] Was my **task** specific enough (precise verb + measurable outcome)?
- [ ] Did I state my **constraints** explicitly?
- [ ] Have I failed twice already? → **`/clear` and rewrite the initial prompt**
- [ ] Is Claude hallucinating an API/annotation? → Ask it to verify against docs
- [ ] Is the context window degraded? → **`/compact` or `/clear`**
 
### The CLAUDE.md Template for SAP CAP Projects
 
```markdown
# [Project Name]
 
## Project Overview
- Application Objectives
- Business requirements
- Essential elements 

## Tech Stack and/or Architecture
- Global Architecture of the project
- SAP CAP (Node.js / Java)
- SAPUI5 Fiori Elements / Freestyle
- SAP BTP Cloud Foundry
- [Database: SQLite / HANA Cloud]
 
## File Map
- Data model: /db/schema.cds
- Service definition: /srv/[name]-service.cds
- Business logic: /srv/[name]-service.js
- UI annotations: /app/[app-name]/annotations.cds
 
## Coding Standards
- Entity names: PascalCase
- Handler pattern: srv.on('actionName', ...) — no inline lambdas
- Always use req.error() for validation failures with HTTP 400
- Never mix UI annotations and service logic in the same file

## Command
- npm command
- Testing command
- Deploy commands, such as “deploying” an SQLite database 
 
## Do Not Modify
- /db/data/ (seed data)
- /app/webapp/manifest.json
 
## Test Command
`cds watch` → http://localhost:4004
```
 
---
 
## Closing Thoughts: The Compounding Advantage
 
The engineers who get the most out of Claude Code are not the ones who know the most keyboard shortcuts. They are the ones who have internalized a discipline: **write the brief before you write the prompt.**
 
Take 60 seconds before every session to ask yourself: What is my goal? What files are involved? What are the rules? What does "done" look like? That 60 seconds of preparation consistently saves 30 minutes of correction.
 
Claude Code does not replace engineering judgment. It amplifies it. The clearer your thinking, the more powerful your output. The vague prompt is the enemy — not the AI.
 
You are now equipped to be a significantly more effective AI Manager. Go build something.
 
---
 
*Guide version 1.0 — Adapted for Hackathon GenAI For Dev Workshops - SAP x Line | 2026*

*Author: Line*

<div align="left">
  <a href="https://www.line-technologies.com/">
    <img src="../../../assets/images/Line_Logo_Version claire_V1.png" height="70" alt="Logo Line" />
  </a>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="https://www.sap.com">
  <img src="../../../assets/images/SAP_2011_logo.svg.png" height="70" alt="Logo SAP" />
  </a>
</div>