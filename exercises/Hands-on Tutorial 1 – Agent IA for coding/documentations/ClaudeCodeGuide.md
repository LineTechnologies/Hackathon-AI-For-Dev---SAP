# Claude Code Setup Guide

[Claude Code documentation](https://code.claude.com/docs/en/quickstart)

## 1. Install Claude Code in BAS and first setup
Open a terminal
```bash
# Install claude code
$ curl -fsSL https://claude.ai/install.sh | bash
# Start claude code
$ claude

# After a project accelerator, use this command to allow claude code to "understand" your project
> /init
# After the command, CLAUDE.md file is created
```

### Install the Claude Code Extension
To avoid using Claude Code in the terminal, you can add an extension in SAP BAS to get a more user-friendly and easier-to-use interface.

To do that : 
1. Find the extension bouton in the left sidebar
2. Click on extension
3. Reseach "Claude code"
4. Install "Claude Code for VS Code"

## 2. Basic Configuration (to begin)

Modes : Ask before; Plan
Commands

Switch and select the best model
Effort
Thinking

General Setting

![alt text](../img/ClaudeCodeExtension.png)

## 3. Best practices & documentations

* [Anthropic - Best practices](https://code.claude.com/docs/en/best-practices)
* [Anthropic - How extend Claude Code](https://code.claude.com/docs/en/features-overview#match-features-to-your-goal)
* [Anthropic - Documentation for Claude Code in Visual Studio Code](https://code.claude.com/docs/en/vs-code)
* [Anthropic - For more details . How Works Claude Code](https://code.claude.com/docs/en/how-claude-code-works)

## 4. Notes on Claude Code usage

Caution: Claude Code is not infallible. It can make errors that compromise your project's stability. Be aware that it may autonomously alter or delete code, which could break your application. It might also take a flawed technical approach, resulting in unworkable solutions. Always review its changes carefully.

To mitigate these risks and ensure a smooth experience, we highly recommend following these steps : 
* Commit working code frequently: Save your progress in Git every time you reach a stable, functional state. At the end of a sprint, a new feature, a schema change, a new handler, etc.
* Time-box your troubleshooting: Limit yourself to a maximum of 3 or 4 prompts to fix a single bug. If the issue persists, revert to your last stable Git commit.

*In Claude Code:*
![alt text](../img/image.png)

*With Git :* 
```bash
$ git status
$ git restore .
$ git clean -fd
```
* 
* Provide precise context: Be as detailed and specific as possible in your prompts. Clear instructions allow Claude Code to understand the context and plan its actions accurately.
* Review before accepting: Always inspect the generated code carefully. If you notice anything strange or illogical, reject the changes and adjust your prompt.   

## Optimized Claude Code

### Add MCP server

SAP has officially released its own MCP servers specifically for Claude and other AI agents. This enables Claude Code to access the fullest range of information on Fiori and CAP development.

Add MCP server for CAP
```bash
# Global install
$ npm i -g @cap-js/mcp-server
# Add to claude
$ claude mcp add cds-mcp -- npx -y @cap-js/mcp-server
```

Add MCP server for Fiori
```bash
# Global install
$ npm i -g @sap-ux/fiori-mcp-server
# Add to Claude Code 
$ claude mcp add fiori-server -- npx -y @sap-ux/fiori-mcp-server
```

You can now test whether Claude Code has access to the Cap and Fiori MCP server by using the following command:
```bash
$ claude mcp list
# Result : 
Checking MCP server health...

claude.ai Gmail: https://gmail.mcp.claude.com/mcp - ! Needs authentication
claude.ai Google Calendar: https://gcal.mcp.claude.com/mcp - ! Needs authentication
cds-mcp: npx -y @cap-js/mcp-server - ✓ Connected
fiori-server: npx -y @sap-ux/fiori-mcp-server - ✓ Connected
```

### Add Skills
In Claude Code, Skills are Markdown files (typically located in a .claude/skills/ folder) that act as smart macros that can be invoked using “slash commands” (e.g., /create-fiori-app).


## Other documentations
This section provides resources to help you extend the capabilities of Claude Code, as well as best practices to improve your ability to use it effectively.

**1. Official Resources:**
* [Claude Code Documentation (Quickstart, Best Practices, Workflows).](https://code.claude.com/docs/en/quickstart)

**2. How Claude Code Works?**
These resources explain the "under the hood" mechanics of how the AI interacts with a local codebase.

* [Claude Code Overview](https://code.claude.com/docs/en/overview): This is the fundamental guide. It explains Claude's "agentic loop"—how it reads the codebase, plans an approach, edits multiple files, and runs commands to verify its work.

* [Security & Sandboxing](https://www.anthropic.com/engineering/claude-code-sandboxing): An excellent engineering blog post explaining how Claude Code isolates file systems and network access to safely execute code and terminal commands without breaking the user's machine.

**3. How to Prompt Claude Code?**
These guides focus on the syntax and methodology of writing highly effective instructions for the AI.

* [Prompting Best Practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices): The definitive guide from Anthropic. It teaches crucial techniques like using XML tags (e.g., <context>, <instructions>) to structure complex prompts, giving clear success criteria, and telling Claude what to do instead of what not to do.

* [Common Code Workflows](https://code.claude.com/docs/en/common-workflows): This page is a goldmine for your workshop. It gives exact prompt examples for tasks like: "find functions in [file] that are not covered by tests" or "trace the login process from front-end to database."

**4. Community & Advanced Resources:**
* [GitHub Public Repository - The performance optimization system for AI agent harnesses](https://github.com/affaan-m/everything-claude-code)
* [GitHub Public Repository - A curated list of awesome skills, hooks, slash-commands, agent orchestrators, applications, and plugins for Claude Code](https://github.com/hesreallyhim/awesome-claude-code)

**5. Best Practices for Developers & Dev Teams**
* [Using the CLAUDE.md File](https://code.claude.com/docs/en/overview): (Found in the customization section). This explains how a team can drop a CLAUDE.md file in the root of their project to force the AI to follow specific coding standards, architectural rules, and preferred libraries across all team members.
* [Model Context Protocol (MCP)](https://code.claude.com/docs/en/mcp): Essential for enterprise teams. It explains how to securely connect Claude Code to external dev tools (like Jira for tickets, Sentry for logs, or internal PostgreSQL databases) so the AI has full context of the team's environment.

**6. Use Cases with Claude Code for "Coding"**

* [How Anthropic Teams Use Claude Code (Whitepaper PDF)](https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf): A highly relevant case study detailing real-world coding scenarios: fast prototyping with "auto-accept" mode, complex infrastructure debugging, test-driven development workflows, and helping newcomers explore massive legacy codebases.

* [Building a C Compiler with Parallel Claudes](https://www.anthropic.com/engineering/building-c-compiler): A fascinating use case showing how developers can spawn multiple autonomous Claude Code agents (subagents) to work on different bugs in parallel.