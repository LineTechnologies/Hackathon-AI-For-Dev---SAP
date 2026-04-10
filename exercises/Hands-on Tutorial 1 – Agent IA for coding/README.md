# Hands-on Tutorial - Create CAP application using AI Agentics

## Introduction & Short Description
Welcome to this Hands-on Tutorial! In this exercise, you will learn how to leverage GenAI agents—specifically **Claude Code**—to bootstrap, develop, and iterate on an SAP CAP (Node.js) and Fiori Elements (UI5) application. You will follow a guided use case, transitioning from functional business specifications to a fully working prototype across 4 progressive sprints.

You can follow this step-by-step hands-on to fully realize the guided use case. We recommend that you follow the first steps, if necessary, to set up Claude Code, optimize it and discover tips on its use. Then, to write the specifications, use the Project Accelerator and perform the iterations by yourself to take control of the tools and assimilate this new development method.

> [!IMPORTANT]
> This practical tutorial is based on the use of Claude Code to illustrate iterative processes. If you use another programming agent (like Cline), the approach remains the same. Only the installation step differs due to the specific interfaces of each tool, but the fundamental concepts—MCP servers, project rules, and planning/execution modes — remain the same.

## Repository Structure & The "Red Thread"
To help you navigate this tutorial successfully, we have structured this folder as a comprehensive toolkit. The AI-assisted development lifecycle relies heavily on good inputs and context. Here is how the folders guide you through the process:

* **`specifications/` (Your Compass):** AI agents need clear, structured instructions to generate accurate code. In this folder, you will find `templates/` to draft your own business requirements, as well as `examples/` of ready-to-use specifications. These documents are the primary inputs for your AI agent.
* **`documentations/` (Your AI Guides):** This is the **"red thread"** of your learning journey. It contains all the necessary resources to master the AI tools:
    * `ClaudeCodeGuide.md`: Instructions for installing and setting up the agent.
    * `PromptingGuide.md`: Best practices, tips, and strategies to interact effectively with the AI and get the best results.
    * `CLAUDE_TEMPLATE.md`: A highly optimized configuration file template to initialize your agent's technical knowledge.
* **`CodeBase/` (Your Safety Net):** Divided into `sprint1` through `sprint4`, this folder contains the reference code and assets resulting from each successful sprint. If your AI gets stuck or you encounter blocking errors, you can always peek into these folders or copy their contents to catch up and proceed to the next stage.

---

## Table of Contents
1. [Take charge of the use case and draft the functional specifications](#1-take-charge-of-the-use-case-and-draft-the-functional-specifications)
2. [Sprint 1 - Project Initialization](#2-sprint-1---project-initialization)
3. [Set up Claude code](#3-set-up-claude-code)
4. [First Prompt Claude Code](#4-first-prompt-claude-code)
5. [Sprints & Iterations: Adding Features](#5-sprints--iterations-adding-features)

--- 

## 1. Take charge of the use case and draft the functional specifications

First, take the time to thoroughly familiarize yourself with the use case, the stated business requirements, and the various proposed sprints. To do so, feel free to refer to the context of the Serious Game and all related documents.

The goal of this phase is to draft detailed functional specifications. Why is this crucial? Because these specifications will serve as a true “compass” for your AI Agents. By providing them with this reference document as input (in their context or “pipeline”), you ensure that you guide them precisely throughout the development sprints.

To help you get started, we’ve provided specification templates. These will guide you on the best format to use when organizing your ideas. You’ll also find concrete examples of specifications already written specifically for this use case. Feel free to use them as a reference to understand the level of detail expected before the coding phase.

To make this process easier, we strongly encourage you to use generative AI tools such as Claude, Gemini, or Joule. These assistants are highly effective at generating or structuring documents and have excellent technical expertise in SAP CAP and Fiori UI5 environments.

Our tips for effectively guiding the AI during the writing process:
* Be thorough: Write prompts that describe your requirements in as much detail as possible and clearly define the exact scope of the application.
* Provide context: Directly provide the AI with the source documents (the requirements document, the sprint breakdown chart, as well as the templates and examples provided).
* Iterate: Don’t hesitate to interact with the tool to refine the document until you have complete specifications ready to be converted into code.

## 2. Sprint 1 - Project Initialization

Once you have created and drafted your functional specifications, we can begin developing the application. To do this, we will use and explore the Project Accelerator tool available in SAP Business Application Studio.

### 2.1 Principles of the Accelerator Project
The Accelerator project is a tool integrated into BAS that allows you to generate a CAP or RAP application framework from a paper or Figma mockup, a description, or a business document in DOCX or MD format. This tool accelerates the creation and development of an application, but its sole purpose is to initiate the project. It cannot be used iteratively to generate code for adding features or fixing bugs. For that, we are exploring AI agents for “coding”.

### 2.2 Steps for using the Project Accelerator 
| #    | Steps    | Captures |
| :--: | :--- |  :-----   |
| 0 | Open SAP Business Application Studio and create a devspace named “Full-Stack Application Using Productivity Tools,” which is a prerequisite for creating the CAP/ Fiori application. |  |
| 1 | In the cockpit BTP, let's access to instance and click on SAP Business Application Studio. <br> Then, let click in the button in the right area of the window and select Buisness Application Studio. | ![Command result](./images/PA_Step1.png) <br> ![Command result](./images/PA_Step1_bis.png) |
| 2 | Now, you can create your devspace by choosing the project type "Full-Stack Application Using Productivity Tools Dev Space" and indicating the name of the DevSpace. | ![Create DevSpace](images/create_devspace.png) |
| 3 | After that, select the Joule buton in the left sidebar. <br> trhen, choice the command /fiori-gen-spec-app and enter a short description of the application that you want to create. | ![Command result](./images/PA_Step2.png) |
| 4 | Click on the button "Launch SAP Fiori Tools - Project Accelerator". If everything works, you should see the new Project Accelerator window. |  ![Command result](./images/PA_Step3.png) |
| 5 | After that, give your Business requirements in the text area, or select a file such as your figma / paper mockup or your business requirement in .docx or .md format. <br> Click on "Generate" to start the initialization of the application. |  ![Command result](./images/PA_Step4.png) |
| 6 | After the process, you can see the generated project (here a CAP project). You can modify some rules and options with the no-code approach (like switch to the flexible display format), and you can preview the application. |  ![Command result](./images/PA_Step5.png) |
| 7 | If everything went well, you should see the app! |  ![Command result](./images/PA_Step6.png)|


## 3. Set up Claude code

We now have an initialized, functional app that can be previewed. We will now use Claude Code to iterate on the project and code by adding, modifying, and reviewing it.

### 3.1 Claude Code Installation

First, we’ll install Claude Code in our DevSpace. For instructions, please refer to the following document [Claude Code Setup Guide](exercises/..) or the official Anthropic documentation.

**Note :** You can also use Cline as an AI agent for development, but this tool is not covered or used in this hands-on.

### 3.2 Add MCP server
To optimized Claude Code and give it more specific knowledge, tools, etc. So we are going to add the UI5, Fiori and CAP MCP Server to Claude Code.

*UI5 MCP server:*
https://www.npmjs.com/package/@ui5/mcp-server

```bash
# Setup
$ claude mcp add ui5-server -- npx -y @ui5/mcp-server
```
![Command result](./images/UI5_MCP_cmd.png)

Or you can modify the general configuration of Claude Code (File : ~/.claude.json) with :
```json
{
  "mcpServers": {
    "ui5-server": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "@ui5/mcp-server"
      ]
    }
  }
}
```

*Fiori MCP server:*
https://www.npmjs.com/package/@sap-ux/fiori-mcp-server
```bash
# Setup
$ claude mcp add fiori-server -- npx -y @sap-ux/fiori-mcp-server
```

*CAP (NodeJs) MCP server:*
https://www.npmjs.com/package/@cap-js/mcp-server
```bash
# Setup
$ claude mcp add cap-server -- npx -y @cap-js/mcp-server
```

### 3.3 Set up and customize Claude Code

After installing Claude Code and adding MCP servers to it to expand its knowledge of CAP, Fiori, and UI5, we will finalize its configuration before starting our code iterations.

To get started, launch Claude Code via the extension or in your terminal and type the command /init. This command instructs Claude to analyze your project's current structure and generate a seed file.

Once the process is complete, a `CLAUDE.md` file will appear in the root directory of your project. This file acts as the “memory” and “brain” of your AI agent. It is read at the start of each new session to immediately give the agent a comprehensive overview of the application and its rules.

The goal now is to customize this file so that it matches our specifications and development guidelines exactly, and to provide Claude with the most detailed guidance possible.

Here are the key sections we recommend adding or modifying in your CLAUDE.md file:

**1. Project Overview:** <br>
Improve the default description. Briefly detail the “What” (a Vendor Management application) and the “Why” (cleaning up the vendor database). The clearer the business context is for the AI, the more relevant its technical choices will be.

**2. Reference Documents & Specifications:** <br>
It is crucial to add a section telling Claude Code where to find your functional specification documents (which you drafted in the previous step). For example, tell it: “To learn about the features of each sprint, always refer to the specifications.md file.” This way, the agent will know exactly what to base its decisions on without you having to repeat it at every prompt.

**3. Development Guidelines (Coding Guidelines):** <br>
Add a section listing your company’s technical constraints. For example: the requirement to use a specific version of Node.js, the prohibition on modifying certain SAP system files, or your naming conventions for CAP (CDS) entities.

**4. Rules for using MCP servers:** <br>
We previously connected MCP servers to Claude Code. For it to use them correctly, we need to provide it with instructions. The official AI ecosystem documentation often explains how to add these rules to an AGENTS.md file (used by other tools like Cline). In our case with Claude Code, the CLAUDE.md file serves as the central hub for everything.

Here are the rules to add to CLAUDE.md, as specified in the MCP server documentation : 
```markdown
## Development Guidelines for Claude (SAP CAP / Fiori / UI5 Project)

You are an expert developer in SAP technologies (CAP Node.js, Fiori Elements, UI5). You have access to MCP servers to consult SAP documentation and tools. You must Stricly adhere to the following rules.

### Guidelines for UI5

Use the `get_guidelines` tool of the UI5 MCP server to retrieve the latest coding standards and best practices for UI5 development.

### Rules for creation or modification of SAP Fiori elements apps

- When asked to create an SAP Fiori elements app check whether the user input can be interpreted as an application organized into one or more pages containing table data or forms, these can be translated into a SAP Fiori elements application, else ask the user for suitable input.
- The application typically starts with a List Report page showing the data of the base entity of the application in a table. Details of a specific table row are shown in the ObjectPage. This first Object Page is therefore based on the base entity of the application.
- An Object Page can contain one or more table sections based on to-many associations of its entity type. The details of a table section row can be shown in an another Object Page based on the associations target entity.
- The data model must be suitable for usage in a SAP Fiori elements frontend application. So there must be one main entity and one or more navigation properties to related entities.
- Each property of an entity must have a proper datatype.
- For all entities in the data model provide primary keys of type UUID.
- When creating sample data in CSV files, all primary keys and foreign keys MUST be in UUID format (e.g., `550e8400-e29b-41d4-a716-446655440001`).
- When generating or modifying the SAP Fiori elements application on top of the CAP service use the Fiori MCP server if available.
- When attempting to modify the SAP Fiori elements application like adding columns you must not use the screen personalization but instead modify the code of the project, before this first check whether an MCP server provides a suitable function.

### 3.4 Rules and Guidelines for CAP

- You MUST search for CDS definitions, like entities, fields and services (which include HTTP endpoints) with cds-mcp, only if it fails you MAY read \*.cds files in the project.
- You MUST search for CAP docs with cds-mcp EVERY TIME you create, modify CDS models or when using APIs or the `cds` CLI from CAP. Do NOT propose, suggest or make any changes without first checking it.
```

> [!TIP]
> **Keep the file concise!**
> Don’t copy all your specifications directly into CLAUDE.md, as this file is constantly reloaded and could overload the agent’s memory (and consume too many tokens). Instead, use short instructions that link to other reference files.

To save you time and give you a concrete starting point, feel free to refer to this document [CLAUDE.md Template](documentations/CLAUDE_TEMPLATE.md). It is a pre-filled CLAUDE.md file template that has been specially adapted for our use case!

Your AI agent is now fully configured and ready to use. You’ve just given it everything it needs to understand your project. We can now move on to code iteration.

> [!NOTE]
> Further Reading (Optional):
> If you're curious and want to deepen your understanding of Claude Code and its advanced customization capabilities, you can check out this supplementary document: 
> - [Claude Code Guide](documentations/ClaudeCodeGuide.md): guide d'installation, de mise en place et de première utilisation de Claude Code (non exhaustif) 
> - [Prompting Guide](documentations/PromptingGuide.md): guide sur comment prompter pour améliorer les performances et les rendus de Claude Code 
> It includes additional tips as well as direct links to Anthropic's official documentation.

## 4. First Prompt Claude Code

To get started, we recommend that you review the current codebase of your project generated by the Project Accelerator. It is crucial to ensure that the foundation is solid and that the initial requirements for our Sprint 1 are in place.

**1. Project Audit** <br>
Ask Claude Code to audit your current project, specifying that he should verify whether all the features expected for Sprint 1 have been implemented.

Example prompt:
```txt
I generated the application using the Project Accelerator and want to make sure that all the features for the first sprint are in place.
Expected features: 
- ...
- ...
To do this, can you perform a complete audit of my current SAP CAP/Fiori project? You can also refer to the specifications file and let me know if all Sprint 1 requirements have been correctly implemented.
```

**2. Analysis of the generated report**
Following this request, Claude Code will review your files and prepare a detailed report for you. It will clearly outline what has been successfully implemented, what is missing, and what could be improved or modified to comply with SAP development best practices.

**3. Planning and Implementing Corrections**
If the report reveals that elements are missing (for example, a field in schema.cds or an interface annotation), you can ask it to plan and implement the necessary changes directly.

Exemple de prompt :
```txt
Thank you for the audit. Can you plan and implement the changes to add the missing elements from Sprint 1?
```

## 5. Sprints & Iterations: Adding Features

In this section of the hands-on, you will iterate via Claude Code to improve the application and meet the needs of functional stakeholders.

If you encounter problems or are unable to add certain complex features, you can always refer to the code base of each sprint. We have carried out the exercise beforehand to allow you to visualize or track our experiments, errors, and successes with these tools.

### Advice & Tips

> [!TIP]
> - Focus on setting up the business logic and user interface. Use mock data representatives exactly the business needs of the application. You can then migrate to an S/4HANA backend for example.
> - Do not hesitate to use GenAI tools such as Gemini, Claude, ChatGPT to get into technical details with Claude Code, or to detail and improve your specification or to find new ideas to integrate.

### Sprint 1: 

First, the goal of the initial sprint is to refine your ideas regarding the definition of requirements by drafting an initial functional specification document.Next, after finalizing the specifications, you can use the Project Accelerator to set up the AI agent tools and run a test to refine your initial output using Claude Code.

#### Steps
1. Understanding the use case and requirements
2. Write the functional specification for the first sprint.
3. Create your DevSpace in BAS and get your project started using the Project Accelerator and your specifications
4. Set up Claude Code
5. Review and iterate using Claude Code to finalize this first sprint

> [!TIP]
> - You can use the provided specification template as a guide.
> - You also have access to specification examples if you want to compare, refactor, add features or remove them.
> - Didn’t take much time to write the specifications, there is little time in comparison with the number of possible features. The goal is to understand and learn how to use this tool to meet business needs.


### Sprint 2:

This second sprint aims to add new data in the application such as scores, statuses, etc. And also a banner of KPIs integrated into the List Report. Of course you can also imagine other features to integrate. 

> [!NOTE]
> Adding the KPIs header is more complex for Claude Code, do not hesitate to iterate several times, ask him to plan the tasks properly, go into certain details or even give him errors from the navigation console. 

### Sprint 3:

The objective of this sprint is to work on the object page, integrating many additional information. You should know that this object page has already been initiated by the Project Accelerator (at least during our tests). Thus, it is interesting to carry out the same approach as for sprint 1, by auditing what has already been done upstream and identifying the elements to be added. You can also very well ask again to start from 0.

> [!NOTE]
> As for the KPI part on sprint 2, adding graph sections is more complex to integrate with the data schema. Did not hesitate to ask other AI, to iterate several times with Claude Code and to give him console errors. If errors persist on a chart or other addition, move to the next sprint to add the business rules and have the maximum content on your application.


### Sprint 4:

Finally, sprint 4 is the last big step of adding functionality. Its objective is to add business rules to manage blockages, closures, action summaries, etc. It is in this sprint that we will define high value-added business rules.

Also, you will be able to make adjustments on the rendering of the application.

Have a good workshop and have fun with Joule Studio!

> [Let's start !](/exercises/Hands-on%20Tutorial%201%20–%20Agent%20IA%20for%20coding/)  

---
 
*Guide version 1.0 — Adapted for LVMH Hackathon GenAI For Dev Workshops - SAP x Line | 2026*

*Author: Line*

<div align="left">
  <a href="https://www.line-technologies.com/">
    <img src="../../assets/images/Line_Logo_Version claire_V1.png" height="70" alt="Logo Line" />
  </a>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="https://www.sap.com">
  <img src="../../assets/images/SAP_2011_logo.svg.png" height="70" alt="Logo SAP" />
  </a>
</div>