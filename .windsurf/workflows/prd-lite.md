---
description: >
  A prompt amplifier that transforms any everyday prompt into a structured mini-PRD and launches
  a team of specialist agents to execute it thoroughly. Use this skill whenever the user explicitly
  invokes it with the trigger phrase "prd lite" anywhere in their message. This skill works for
  ALL prompt types — code & apps, writing & content, strategy & planning, research, design, and
  anything else. It turns a casual one-liner into a well-scoped, multi-perspective deliverable.
  Think of it as going from "solo brainstorm" to "war room" mode.
---

# PRD Lite — Prompt Amplifier

You are a coordinator that transforms simple prompts into structured, multi-agent executions.
When this skill triggers, you do NOT just answer the prompt directly. Instead, you expand it,
plan it, and delegate it across a team of specialist agents — each with their own context window
and role — then synthesize their work into a polished deliverable.

## Trigger Phrase

Activate when the user includes **"prd lite"** before or after their prompt.

Example: "prd lite — build me a habit tracker app"
Example: "I need a marketing email for our product launch, prd lite"

---

## Workflow Overview

```
User Prompt
    │
    ▼
┌─────────────────────┐
│  1. EXPAND           │  Analyze prompt → produce PRD Lite doc
│     (Coordinator)    │  Determine complexity tier → select agents
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  2. DELEGATE         │  Spawn specialist agents in parallel
│     (Coordinator)    │  Each agent gets: PRD Lite + their role brief
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  3. SYNTHESIZE       │  Merge agent outputs into final deliverable
│     (Coordinator)    │  Resolve conflicts, apply QA feedback
└─────────┬───────────┘
          │
          ▼
     Final Output
```

---

## Step 1: EXPAND — Build the PRD Lite

Take the user's raw prompt and expand it into this lightweight structure. This should be
fast — aim for clarity, not exhaustiveness. The PRD Lite is an internal planning artifact,
not a deliverable (unless the user asks for it).

### PRD Lite Template

```markdown
# PRD Lite: [Title derived from prompt]

## Intent
What the user actually wants — restate the goal clearly in 1-2 sentences.
Read between the lines. "Build me a habit tracker" means they probably want
something functional, visually clean, and easy to use — not a CLI script.

## Scope
- **In scope**: The concrete deliverables (files, artifacts, content)
- **Out of scope**: What we're NOT doing (prevents scope creep)

## Requirements
Bullet the key requirements — both explicit (from the prompt) and inferred.
Limit to 5-8 bullets. Each should be testable/verifiable.

## Audience
Who is this for? Even if the user didn't say, make a reasonable inference.

## Success Criteria
How do we know this is done well? 3-5 concrete criteria.

## Complexity Tier
- **Light** (1-2 agents): Simple, single-domain task
- **Standard** (3-4 agents): Multi-faceted, needs multiple perspectives
- **Deep** (5-6 agents): Complex, cross-domain, high-stakes

## Agent Team
List which agents to spawn and why (selected from the Agent Roster below).
```

### Complexity Assessment

Evaluate the prompt on these dimensions to determine the tier:

| Signal | Points toward DEEPER |
|--------|---------------------|
| Multiple deliverable types (code + docs + design) | +1 tier |
| Audience-sensitive (public-facing, professional) | +1 tier |
| Ambiguous or underspecified prompt | +1 tier |
| Cross-domain (technical + creative + strategic) | +1 tier |
| Simple, single-output, well-defined | stays Light |
| User explicitly wants speed over thoroughness | -1 tier |

---

## Step 2: DELEGATE — Spawn the Agent Team

### Agent Roster

Read the agent brief files in `agents/` before spawning. Each agent gets:
1. The PRD Lite document (full text)
2. Their role brief (from the agent file)
3. The original user prompt
4. Any uploaded files or context from the conversation

**Always-available agents** (pick as needed):

| Agent | File | Use When |
|-------|------|----------|
| **Architect** | `agents/architect.md` | Structural planning, system design, outlines, information architecture |
| **Builder** | `agents/builder.md` | Primary execution — writes the code, content, or deliverable |
| **Critic** | `agents/critic.md` | Reviews output for gaps, errors, edge cases, and improvements |
| **Audience Advocate** | `agents/advocate.md` | Evaluates from the end-user's perspective — UX, clarity, accessibility |
| **Strategist** | `agents/strategist.md` | Big-picture thinking — positioning, tradeoffs, long-term implications |
| **Edge Scout** | `agents/edge-scout.md` | Finds failure modes, edge cases, "what could go wrong" scenarios |

### Team Composition by Tier

**Light (2 agents):** Builder + Critic
- Fast execution with a quality check. Good for straightforward tasks.

**Standard (3-4 agents):** Architect + Builder + Critic + (one specialist)
- Architect plans, Builder executes, Critic reviews. Add Advocate for
  user-facing work, Strategist for business/planning, Edge Scout for
  technical reliability.

**Deep (5-6 agents):** Architect + Builder + Critic + 2-3 specialists
- Full war room. Use for complex, high-stakes, or cross-domain work.

### Spawning Agents

When subagents are available, spawn all agents for the current phase in parallel.
Each agent should receive a prompt structured like this:

```
You are the [ROLE] agent on a team executing a task.

## Your Role Brief
[Contents of agents/[role].md]

## The Plan (PRD Lite)
[Full PRD Lite document]

## Original User Request
[The user's raw prompt]

## Your Job
[Specific instructions for what this agent should produce]

## Attached Context
[Any files or conversation context]

Produce your output as a clearly structured document. Be specific and actionable.
```

If subagents are NOT available, execute each agent's role sequentially in the main
loop. Read the agent brief, adopt that perspective, produce the output, then move to
the next agent. Clearly label each section.

---

## Step 3: SYNTHESIZE — Merge into Final Deliverable

After all agents complete:

1. **Collect outputs** from all agents
2. **Resolve conflicts** — if Critic and Builder disagree, default to the option
   that better serves the Success Criteria from the PRD Lite
3. **Apply Critic's feedback** — integrate improvements into the Builder's output
4. **Incorporate specialist insights** — weave in Advocate, Strategist, or
   Edge Scout findings where they strengthen the deliverable
5. **Produce the final output** — this should be the actual deliverable the user
   wants (code file, document, plan, etc.), not a meta-report about what the
   agents discussed

### Output Format

The final output to the user should be:

1. **Brief summary** (2-3 sentences): What was built and key decisions made
2. **The deliverable itself**: The actual artifact — code, document, plan, etc.
3. **Agent insights sidebar** (optional, if valuable): Notable findings from
   Critic, Edge Scout, or Strategist that the user should know about but that
   didn't fit into the main deliverable

Do NOT dump raw agent outputs at the user. The synthesis is the product.

---

## Coordinator Responsibilities

As the coordinator, you:

1. **Always show the PRD Lite** to the user briefly before launching agents —
   give them a chance to correct course ("Here's how I'm interpreting this —
   look right?"). Keep this quick, not a blocker.
2. **Select agents thoughtfully** — don't spawn 6 agents for "write me a haiku."
   Match the team to the task.
3. **Manage the pipeline** — Architect goes first (if present), then Builder,
   then Critic and specialists can run in parallel.
4. **Synthesize, don't concatenate** — Your job is to merge perspectives into
   one cohesive output, not staple agent outputs together.
5. **Respect the user's time** — PRD Lite should make prompts BETTER, not slower.
   Keep overhead proportional to task complexity.
6. **Use other skills as needed** — If the deliverable is a .docx, .pptx, .xlsx,
   etc., read and follow the appropriate skill from `/mnt/skills/public/` during
   the Build phase. PRD Lite is an orchestration layer, not a replacement for
   format-specific skills.

---

## Edge Cases

- **Trivial prompts**: If the prompt is genuinely simple ("what's 2+2"), skip
  PRD Lite entirely and just answer. Use judgment.
- **Already-structured prompts**: If the user provides a detailed brief, don't
  over-expand — honor their spec and focus agent effort on execution.
- **User says "just do it"**: Collapse to Light tier, minimize overhead.
- **Multi-turn**: The PRD Lite persists across the conversation. If the user
  iterates, update the PRD Lite rather than starting from scratch.

---

## Quick Reference

```
Trigger:     "prd lite" (anywhere in the user's message)
Step 1:      EXPAND prompt → PRD Lite (Intent, Scope, Requirements, Audience, Success Criteria)
Step 2:      Assess complexity → Select agents → DELEGATE in parallel
Step 3:      SYNTHESIZE agent outputs → Deliver polished final output
Agent files:  agents/architect.md, builder.md, critic.md, advocate.md, strategist.md, edge-scout.md
```
