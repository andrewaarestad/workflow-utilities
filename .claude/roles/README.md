# Multi-Agent Role Definitions

This directory contains role definitions that can be used to build multi-agent development workflows. Each role represents a specialized perspective that mimics real-world team members.

## Available Roles

### Product & Business Roles
- **[product-owner.md](./product-owner.md)** - Product vision, requirements, and user experience
- **[ceo.md](./ceo.md)** - Business strategy, market positioning, and long-term vision

### Engineering Leadership
- **[engineering-manager.md](./engineering-manager.md)** - Technical architecture, implementation guidance, and quality/delivery balance

### Technical Specialists
- **[frontend-specialist.md](./frontend-specialist.md)** - User interface implementation, modern web frameworks, and UX
- **[backend-specialist.md](./backend-specialist.md)** - APIs, business logic, and cloud infrastructure
- **[data-specialist.md](./data-specialist.md)** - Database design, query optimization, and data pipelines
- **[scientist.md](./scientist.md)** - Algorithms, ML models, and research implementation

### Operations & Quality
- **[qa-specialist.md](./qa-specialist.md)** - Testing, quality assurance, and regression prevention
- **[ops-specialist.md](./ops-specialist.md)** - Monitoring, incident response, and system reliability
- **[security-specialist.md](./security-specialist.md)** - Security vulnerabilities, best practices, and threat modeling

## How to Use These Roles

### As Subagent Prompts

Include role definitions when spawning specialized agents:

```python
# Read the role definition
with open('.claude/roles/backend-specialist.md') as f:
    backend_role = f.read()

# Use in a subagent prompt
prompt = f"""
{backend_role}

Task: Design an API endpoint for fetching user obituaries with pagination.
Requirements: RESTful, efficient, supports filtering by date range.
"""
```

### As Context for Custom Prompts

Reference roles to guide thinking:

```markdown
Approach this problem from the perspective of a [security-specialist].
Review the authentication flow for potential vulnerabilities.
```

### In Multi-Agent Workflows

Chain multiple roles for comprehensive analysis:

```python
# Step 1: Product Owner defines requirements
# Step 2: Engineering Manager plans architecture
# Step 3: Backend Specialist implements API
# Step 4: Security Specialist reviews implementation
# Step 5: QA Specialist tests edge cases
```

### As Discussion Participants

Simulate team discussions by having roles ask their key questions:

```markdown
Product Owner: "What problem are we solving for users?"
Engineering Manager: "What are the long-term architectural implications?"
Backend Specialist: "What's the most efficient API design?"
Security Specialist: "What's the attack surface?"
```

## Role Structure

Each role definition includes:

- **Role Overview** - High-level description of the role's purpose
- **Core Responsibilities** - Key duties and focus areas
- **Key Expertise Areas** - Technical and domain knowledge
- **Working Style** - Approach to problem-solving and decision-making
- **Key Questions This Role Asks** - Typical concerns and considerations

## Best Practices

### 1. Use the Right Role for the Task

Match the role to the type of decision or work:
- **Design decisions** → Product Owner, Engineering Manager, Frontend Specialist
- **API design** → Backend Specialist, Data Specialist
- **Performance optimization** → Backend Specialist, Frontend Specialist, Ops Specialist
- **Security review** → Security Specialist
- **Testing strategy** → QA Specialist

### 2. Combine Roles for Complex Tasks

For major features or decisions, consult multiple perspectives:
- Product Owner (requirements) → Engineering Manager (architecture) → Specialists (implementation)

### 3. Keep Roles Focused

Each role should stay within their expertise. Don't have the Frontend Specialist make database schema decisions.

### 4. Update Roles as Needed

These definitions should evolve with your team and tech stack. Keep them current.

## Example Workflows

### Feature Development
1. **Product Owner** - Define requirements and acceptance criteria
2. **Engineering Manager** - Plan technical approach and identify risks
3. **Frontend Specialist** - Design UI implementation
4. **Backend Specialist** - Design API and business logic
5. **Data Specialist** - Design database schema and queries
6. **Security Specialist** - Review for vulnerabilities
7. **QA Specialist** - Create test plan and validate implementation

### Bug Investigation
1. **QA Specialist** - Reproduce and document the bug
2. **Ops Specialist** - Check logs and system metrics
3. **Engineering Manager** - Assess impact and prioritize
4. **Backend/Frontend Specialist** - Diagnose root cause
5. **Security Specialist** - Check if bug has security implications
6. **QA Specialist** - Verify fix and check for regressions

### Architecture Review
1. **Engineering Manager** - Present proposed architecture
2. **Backend Specialist** - Review API and infrastructure design
3. **Data Specialist** - Review data model and access patterns
4. **Security Specialist** - Identify security concerns
5. **Ops Specialist** - Review monitoring and deployment strategy
6. **Frontend Specialist** - Ensure frontend needs are met
7. **CEO** - Validate alignment with business goals

## Integration with Claude Code

These roles are designed to work seamlessly with:
- Claude Code agent framework
- Custom slash commands in `.claude/commands/`
- Task-based agent workflows
- Multi-turn conversations with role context

## Contributing

When adding or modifying roles:
1. Keep the structure consistent with existing roles
2. Focus on practical, actionable guidance
3. Include concrete examples in "Key Questions"
4. Update this README with any new roles

---

**Note:** These roles are personas to guide decision-making and ensure comprehensive consideration of different aspects of software development. They are not meant to replace human judgment or create unnecessary overhead.
