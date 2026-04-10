> [!IMPORTANT]
> **Welcome to the AI For Dev Hackathon!**
>
> *   **Features Are Subject to Change:** Since AI tools and platforms are evolving rapidly, some interfaces or features may vary slightly.
> *   **For Educational Use Only:** This environment is designed exclusively for learning, experimentation, and this serious game. It is not intended for production use.
> *   **Potential Instability:** When using “preview” versions of tools and connecting between multiple systems (MCP, Joule, CAP), you may experience occasional instability. The exercises are designed to work with the platform as it currently stands. If you get stuck, don't hesitate to ask an instructor for help!

# Hackathon AI For Dev - SAP x Line

<table>
  <tr>
    <td align="center"><img src="assets/images/Line_Logo_Version claire_V1.png" width="200" alt="Line"></td>
    <td align="center"><img src="assets/images/SAP_2011_logo.svg.png" width="200" alt="SAP"></td>
  </tr>
</table>

## Workshop Schedule (Format)
This workshop is designed to be highly collaborative. To tackle the challenge of this Hackathon, you will be divided into two teams working in parallel, before merging your work:

* **Team 1:** AI for App Dev (Claude Code). Your mission will be to generate the complete business application (SAP CAP backend and Fiori frontend) by guiding an AI agent specialized in coding.
* **Team 2:** AI for Agents (Joule Studio). Your mission will be to create and configure intelligent assistants capable of interacting in natural language to perform business actions.
* **Convergence Activity:** The Docking. The two teams will come together in a final phase to explain their work on the two previous activities and to be able to prepare the report. Also, if time allows us, the teams will be able to explore the possibilities of connecting the business application to the Joule assistant, thereby creating a unified and intelligent solution.

## The Use Case (Serious Game)
Over time, the supplier database has expanded significantly and now includes a “long tail” of suppliers with little or no activity. This degrades data quality and increases operational risks (poor supplier selection, outdated data, more complex controls). Your goal is to build an innovative solution to identify, analyze, and clean this database using the latest generative AI capabilities.

Final Presentation: At the end of the workshop, the unified group will present its final solution. Be sure to take notes as you go! Document your most effective prompts and workarounds, and take screenshots of your application and your interactions with Joule.

## Learning Objectives
* **Applied Prompt Engineering:** Learn how to formulate and structure effective prompts (using a CLAUDE.md context file and specifications) to guide the generation of complex code.
* **Full-Stack SAP Generation:** Understand how AI can accelerate the creation of a CAP data model (CDS) and a user interface (Fiori Elements).
* **Conversational Design:** Learn how to configure Skills and Agents in the SAP Joule Studio environment.
* **Ecosystem Integration:** Discover how to link a standard CAP application with an enterprise virtual assistant within SAP BTP.

## Operational Objectives
* **Fiori App (via Claude Code):** Identify inactive suppliers, assign a risk/cleanliness score, add graphical indicators, and perform cleanup actions (block/close).
* **Joule Skill:** Automate the blocking/unblocking of a supplier directly from a chat with Joule.
* **Joule Agent:** Get contextual recommendations on a supplier’s status.

## Exercises

- [Workshop Overview - Use Case Introduction](exercises)
- [Hands-on Tutorial 1 – Agent IA for coding](exercises/Hands-on%20Tutorial%201%20–%20Agent%20IA%20for%20coding/)
    - [Step by Step Explanation](exercises/Hands-on%20Tutorial%201%20–%20Agent%20IA%20for%20coding/README.md)
    - [Sprint 1 - Application Initialization](exercises/Hands-on%20Tutorial%201%20–%20Agent%20IA%20for%20coding/CodeBase/sprint1)
    - [Sprint 2 - Insights and KPIs](exercises/Hands-on%20Tutorial%201%20–%20Agent%20IA%20for%20coding/CodeBase/sprint2)
    - [Sprint 3 - Navigation & Object Page](exercises/Hands-on%20Tutorial%201%20–%20Agent%20IA%20for%20coding/CodeBase/sprint3)
    - [Sprint 4 - Business Action](exercises/Hands-on%20Tutorial%201%20–%20Agent%20IA%20for%20coding/CodeBase/sprint4)

- [Hands-on Tutotial 2 – Joule Studio ](exercises/Hands-on%20Tutorial%202%20–%Joule%20Studio/)
    - [Sprint 1: Blocking / unlocking skill](exercises/Hands-on%20Tutorial%202%20–%Joule%20Studio/README.md#sprint-1--skill-de-blocage--déblocage-fournisseur)
    - [Sprint 2: Supplier evaluation skill](exercises/Hands-on%20Tutorial%202%20–%Joule%20Studio/README.md#sprint-2--skill-dévaluation-fournisseur)
    - [Sprint 3: Decisional Joule Agent](exercises/Hands-on%20Tutorial%202%20–%Joule%20Studio/README.mdsprint-3--agent-joule-décisionnel)

- [Hands-on Tutotial 3 – Joule Studio & CAP App](exercises/Hands-on%20Tutorial%203%20–%Joule%20Studio%20&%20CAP%20App/)
    - [Connecting CAP Application to S/4HANA backend system](exercises/Hands-on%20Tutotial%203%20–%20Joule%20Studio%20&%20CAP%20App/#1-switch-from-mock-data-to-real-s4hana-data-using-btp-destination)
    - [Joule & CAP — Bridging Two Worlds](exercises/Hands-on%20Tutotial%203%20–%20Joule%20Studio%20&%20CAP%20App/#2-joule--cap--bridging-two-worlds)

## Documentation & Useful Resources
During this workshop, you’ll find valuable resources in the documentation folder to help you with your prompts:
* [Functional Specifications for Use Cases (Templates & Examples)]()
* [A Guide to Prompts for Maximizing Claude Code's Effectiveness]()
* [Sample CLAUDE.md File for Initial Setup]()
* [Code base for each sprint]()

## Requirements & Prerequisites - already in place

During this hackathon, the environments were set up in advance to maximize the time allocated to creating and exploring AI solutions.

However, if you wish to recreate this use case at home or at your company, here are the necessary prerequisites:
1.  **Developpement environnement**:
    - SAP Business Application Studio (BAS) with the appropriate plan.
    - Active access to Joule.
2.  **Actions & Destinations**:
    - Active SAP BTP configuration.
    - Pre-built SAP Build Action projects (e.g., Sales Order (A2X) - v4) to access the SAP Cloud ERP system.
    - BTP Destinations correctly configured and accessible in SAP BAS.
3.  **Joule Studio in SAP Build**:
    - The Agent Builder must be enabled and accessible on your tenant.
3.  **Third-Party AI Tools (Claude Code / Cline)**:
    - A local or cloud installation of Claude Code / Cline.
    - A instance of Claude Sonnet 4.6 Anthropic model in SAP AI Core
    - At least one Claude Pro account or a valid, provisioned Anthropic API key 

---
 
*Guide version 1.0 — Adapted for LVMH Hackathon GenAI For Dev Workshops - SAP x Line | 2026*

*Author: Line*