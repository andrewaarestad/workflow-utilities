# Claude Agent Modes and Specialties

This directory contains agent configuration files that define specialized roles and working modes for Claude. These configurations can be combined to create domain-expert agents with specific working styles tailored to your development workflow.

## Overview

The agent system is built on two dimensions:

- **Specialties** (`specialties/`) - Domain expertise and role-based knowledge (e.g., frontend, backend, security)
- **Modes** (`modes/`) - Working styles and methodologies (e.g., planner, implementer, reviewer)

By combining a specialty with a mode, you create an agent with both deep domain knowledge and a clear operational approach.

## Using Agents

### 1. With the `work_ticket_with_role` Slash Command

The most common way to use these configurations is through the `work_ticket_with_role` slash command, which creates an agent to work on a Jira ticket with a specific role:

```
/work_ticket_with_role IN-123 backend implementer
```

**Syntax:** `/work_ticket_with_role [ticket-number] [specialty] [mode] [optional-instructions]`

**Arguments:**
- `ticket-number` - Jira ticket ID (e.g., IN-123)
- `specialty` - Domain expertise from `specialties/` folder (without .md extension)
- `mode` - Working style from `modes/` folder (without .md extension)
- `optional-instructions` - Any additional context or instructions

**What happens:**
1. The command loads the Jira ticket
2. Reads and internalizes the specialty and mode configurations
3. Creates a comprehensive plan following the mode's approach
4. Executes the plan with the specialty's domain expertise
5. Creates a worktree, implements changes, runs tests, and creates a PR

### 2. Through Subagents

You can spawn subagents with specific configurations for focused tasks:

```
Please create a subagent with backend specialty and researcher mode to investigate our database performance issues
```

This is useful when:
- You need parallel work on different aspects of a problem
- You want isolated exploration without affecting the main conversation context
- You need a specialist's perspective without committing to full implementation

### 3. Direct Instructions in REPL

You can directly instruct Claude to adopt a role by referencing the configuration files:

```
Please act as a frontend specialist in reviewer mode. Read the configurations from .claude/agents/specialties/frontend.md and .claude/agents/modes/reviewer.md, then review this pull request.
```

This approach gives you maximum flexibility and works well for:
- Ad-hoc reviews or consultations
- Quick questions from a specific perspective
- Situations where you don't need the full workflow

## Available Specialties

### Technical Roles

- **`backend`** - APIs, business logic, cloud infrastructure, data security
- **`frontend`** - User interfaces, modern frameworks, performance, accessibility
- **`data`** - Database design, query optimization, data pipelines, search systems
- **`ops`** - Monitoring, incident response, observability, system reliability
- **`security`** - Vulnerability assessment, authentication, encryption, threat modeling
- **`qa-specialist`** - Testing strategies, edge cases, regression detection, quality assurance
- **`scientist`** - ML algorithms, data processing, experimentation, model deployment

### Business & Leadership Roles

- **`product-owner`** - Product vision, requirements, user experience, prioritization
- **`engineering-manager`** - Architecture, technical strategy, risk management, tech debt
- **`ceo`** - Business strategy, market positioning, vision, competitive analysis

## Available Modes

- **`planner`** - Creates structured plans, defines architecture, clarifies requirements
  - Use when: Starting a new feature, need architectural direction, unclear requirements
  
- **`implementer`** - Executes plans, writes production code, follows patterns
  - Use when: Plan is clear, need focused execution, building features
  
- **`researcher`** - Investigates options, compares alternatives, reduces uncertainty
  - Use when: Exploring new technologies, evaluating approaches, gathering information
  
- **`reviewer`** - Assesses quality, identifies issues, ensures standards compliance
  - Use when: Code review, quality audit, checking for problems
  
- **`refiner`** - Improves existing code, optimizes performance, enhances clarity
  - Use when: Refactoring, performance tuning, code cleanup
  
- **`tester`** - Validates correctness, finds edge cases, ensures robustness
  - Use when: Testing features, finding bugs, validating behavior

## Common Combinations

### Development Workflow

1. **Planning Phase**
   - `backend planner` or `frontend planner` - Design the architecture
   - `security planner` - Assess security requirements

2. **Research Phase**
   - `backend researcher` - Investigate third-party APIs or libraries
   - `scientist researcher` - Explore ML algorithms and approaches

3. **Implementation Phase**
   - `backend implementer` - Build the API and business logic
   - `frontend implementer` - Implement the UI components

4. **Quality Assurance**
   - `qa-specialist tester` - Comprehensive testing
   - `security reviewer` - Security audit
   - `backend reviewer` or `frontend reviewer` - Code review

5. **Optimization Phase**
   - `backend refiner` - Optimize performance and clean up code
   - `data refiner` - Optimize queries and data access patterns

### Specialized Scenarios

- **`engineering-manager planner`** - High-level technical strategy and roadmap planning
- **`data implementer`** - Building database schemas and data pipelines
- **`ops implementer`** - Setting up monitoring and alerting infrastructure
- **`product-owner planner`** - Defining feature requirements and user stories
- **`scientist implementer`** - Implementing ML models and experiments
- **`ceo planner`** - Strategic business and product planning

## Configuration Details

### How Configurations Work

Each configuration file is treated as an **extension to Claude's system prompt**. When loaded:

1. The specialty defines your domain expertise, mental models, and key questions
2. The mode defines your working style, responsibilities, and approach
3. Both are internalized and applied throughout the entire task

This means the agent doesn't just reference these files—it actually operates according to their principles.

### File Structure

Each configuration file contains:

- **Role/Mode Overview** - High-level description and purpose
- **Core Responsibilities** - Primary duties and focus areas
- **Key Expertise Areas** - Specific technologies, patterns, and domains
- **Working Style** - Approach to problems and decision-making
- **Key Questions** - The mental framework for approaching tasks

## Creating Custom Configurations

You can add your own specialty or mode files:

1. Create a new `.md` file in `specialties/` or `modes/`
2. Follow the same structure as existing files
3. Use the filename (without .md) when invoking the agent

Example: Create `specialties/mobile.md` for mobile development, then use:
```
/work_ticket_with_role IN-456 mobile implementer
```

## Best Practices

### Choosing the Right Combination

- **Match the specialty to the domain** - Use frontend for UI work, backend for API work
- **Match the mode to the task phase** - Use planner before implementer, reviewer after
- **Consider the complexity** - Use researcher mode when there are unknowns

### Working with Multiple Agents

- Use **planner mode first** to create the roadmap
- Spawn **implementer agents** for parallel workstreams
- Use **reviewer agents** to validate before merging
- Engage **refiner agents** for optimization passes

### Iterative Approach

1. Start with `[specialty] planner` to understand the problem
2. Switch to `[specialty] researcher` if unknowns exist
3. Use `[specialty] implementer` for execution
4. Validate with `qa-specialist tester` and `[specialty] reviewer`
5. Polish with `[specialty] refiner`

## Tips

- The specialty determines **what you know**, the mode determines **how you work**
- Modes can be combined with any specialty
- For complex tickets, consider running the workflow multiple times with different combinations
- Engineering managers and product owners work best in planner mode
- Security specialists should be consulted in both planner and reviewer modes
- The `work_ticket_with_role` command provides the most comprehensive workflow

## See Also

- `/work_ticket_with_role` command documentation
- Individual specialty and mode files for detailed role descriptions
