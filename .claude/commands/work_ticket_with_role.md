---
argument-hint: [ticket-number] [agent-specialty] [agent-mode] [optional-instructions...]
description: Work on a Jira ticket with specified agent configuration and optional custom instructions
---

## Work Jira Ticket
You are an experienced software developer tasked with addressing a development ticket. Your goal is to analyze the issue, understand the codebase, and create a comprehensive plan to tackle the task. Follow these steps carefully:

### Stage 1: Planning

1. First, fetch the Jira ticket using the Jira tool script. The ticket number should be provided below in the extra_info. If the ticket cannot be loaded from Jira, stop.

   **IMPORTANT - Exact tool usage:**
   - Tool location: `.claude/tools/jira.sh`
   - Command syntax: `.claude/tools/jira.sh get <TICKET-ID>`
   - Example: `.claude/tools/jira.sh get IN-11`
   
   Do NOT try to use `node` or look for `.js` files. The tool is a bash script (`.sh`) and must be called with the `get` command followed by the ticket ID.
   
   If you need help understanding the tool's capabilities, you can run `.claude/tools/jira.sh help`, but for fetching a ticket, always use: `.claude/tools/jira.sh get <TICKET-ID>`

The extra_info may also contain user-provided additional information. Incorporate it into the plan, and prioritize it over any conflicting instructions from Jira.

Identify whether the ticket is for a bug or a feature, and use that information when creating the branch name later.

If the ticket is unclear, ask the user for more information before proceeding. If the ticket is a bug, be sure that there is a clear indication of what the error is. If the error is too generic and no steps to reproduce or stack trace is provided, more information is needed before continuing in the planning steps.

<extra_info>
Ticket Number: $1
Agent Specialty: $2
Agent Mode: $3

All Arguments (including any optional user instructions): $ARGUMENTS
</extra_info>

2. Next, validate the input arguments:
   - The ticket number ($1) must follow the Jira ticket format (IN-XXX where XXX is a number)
   - The agent specialty ($2) must match an existing file in `.claude/agents/specialties/` (without the .md extension)
   - The agent mode ($3) must match an existing file in `.claude/agents/modes/` (without the .md extension)

   If any validation fails, inform the user of the error and stop. Do not proceed with invalid inputs.

3. Load the specialty and mode configuration into your operational context:
   - Read the file `.claude/agents/specialties/$2.md`
   - Read the file `.claude/agents/modes/$3.md`

   IMPORTANT: Treat the contents of these files as extensions to your system prompt. The specialty file defines your domain expertise and approach to technical problems. The mode file defines your workflow methodology and interaction style. Internalize both configurations and apply them throughout the entire task execution. These are not just reference documents - they fundamentally shape how you operate for this ticket.

4. Next, examine the relevant parts of the codebase.

Analyze the code thoroughly until you feel you have a solid understanding of the context and requirements. Be sure to focus specifically on the issue mentioned in the ticket. Do not expand the scope of work to include additional related things unless the user directs you to do so.

5. Create a comprehensive plan and todo list for addressing the issue. Consider the following aspects:

- Required code changes
- Potential impacts on other parts of the system
- Necessary tests to be written or updated
- Documentation updates
- Performance considerations
- Security implications
- Backwards compatibility (if required)
- Testing and verification plan

6. Think deeply about all aspects of the task. Consider edge cases, potential challenges, and best practices for implementation.

7. Present your plan in the following format:

<plan>
[Your comprehensive plan goes here. Include a high-level overview followed by a detailed breakdown of the steps.]
</plan>

Remember, your task is to create a plan, not to implement the changes. Focus on providing a thorough, well-thought-out strategy for addressing the ticket. Then ASK FOR APPROVAL BEFORE YOU START WORKING on the TODO LIST.

If the user approves the plan, proceed to Stage 2.

### Stage 2: Preparation

1. Before starting work, create a new worktree and branch from the latest main branch for this feature. The branch name should be descriptive and relate to the issue. 

Use the following naming convention for the branch: [feat,bug]/[ticket-ID]/brief-description

To create the worktree, an alias command called "wt" is available for you to use. You must use it to create the worktree. Create the worktree using the following command: `wt [branch-name] origin/main`. If creating the worktree fails, stop.

The "wt" command will create the worktree inside the ".worktrees" folder of the monorepo root and change directory to it.

2. Note that after creating the worktree with this command, you MUST check the current directory by running `pwd` to see if you are in the worktree directory or not. If not, change directory to the worktree folder. Then, prepare the worktree for development by running `npm install`

### Stage 3: Execution

1. Once the worktree is ready and you are in the worktree directory, proceed with executing the plan. Be sure to address all aspects of the plan that were created, including TODOs. Be sure that the test and verification plan has been completed, or if there are portions of the test plan which need to be done by human developers/QAs, that these aspects have been noted.

2. Before creating the pull request, run ALL of the PR check scripts to ensure all tests and linting pass. Read the PR checks workflow to see what checks are run. 

If any checks fail, fix the issues before proceeding. Do not create a pull request with failing checks.

The only reason the PR checks should fail on GitHub before you create your PR is due to unforeseen environmental differences. Even those should be anticipated by you and accounted for.

3. Create a pull request in github using the github CLI. Be sure to include a summary of the changes, the test plan, and any remaining human tests as a checklist.

Name the pull request with the following naming convention: [ticket-ID]: brief-description

4. Update the status of the Jira ticket to "In Review" or "In Pull Request", whichever is available.

   **IMPORTANT - Exact tool usage for status updates:**
   - Tool location: `.claude/tools/jira.sh`
   - Command syntax: `.claude/tools/jira.sh update-status <TICKET-ID> "<STATUS>"`
   - Example: `.claude/tools/jira.sh update-status IN-11 "In Pull Request"`
   
   Note: Status names are case-sensitive and must match exactly. If you're unsure of available statuses, run `.claude/tools/jira.sh transitions <TICKET-ID>` to see available options.