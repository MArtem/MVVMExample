# Model Selection Rule

<!-- Rule ID: QC.MODEL.ROUTING v1.1 -->

## Authority

This is the sole active rule for choosing a model and reasoning level. It supersedes earlier routing matrices, estimates, benchmark summaries, and model-selection guidance. The current routes are GPT-6 Luna, Sol, and Astra, subject to actual availability in the user's Codex selector.

## Official Product And Usage Baseline

For ChatGPT/Codex subscription work, route by the current official product roles and the actual task risk, not by API token prices or an averaged benchmark score:

- Luna is the efficient route for narrow, repeatable tasks with clear constraints and direct verification.
- Sol is the everyday route for coding, analysis, and work requiring sound judgment and completeness.
- Astra is the strongest route for broad, ambiguous, multi-step, or high-stakes work where deeper reasoning materially reduces expected error or rework.

For the same billing surface and comparable token mix, the relative per-token cost is Luna < Sol < Astra. This is **not** a guarantee about total cost per completed task: a stronger model may use fewer turns or output tokens. Choose the least costly route that meets the task's quality/risk floor, not the cheapest model regardless of consequences. Confirm current availability and numerical limits in official product documentation when they matter.

ChatGPT Plus usage is not a fixed token-price conversion. It varies with the selected model, context size, reasoning, tools, retrieval, caching, and whether work is local or cloud. Current plan limits are published as ranges, may share a five-hour window, and may also have weekly limits. Do not convert them into a guaranteed task count or a fixed total-task percentage.

API pricing is a separate billing surface and applies only when work uses an API key. Never use API input/output prices alone to predict ChatGPT Plus consumption. Consult the current official [Codex pricing and usage documentation](https://learn.chatgpt.com/docs/pricing) when a numeric limit or price affects a decision; do not copy volatile pricing tables into this durable rule.

Do not route from an unversioned average of heterogeneous coding benchmarks. Prefer the official product roles above, the risk triggers below, deterministic verification, and project-specific evaluation evidence when it exists.

Practical iOS interpretation:

| Model | Default scope | Do not use as the primary route for |
| --- | --- | --- |
| `GPT-6 Luna` | fully specified mechanical edits, extraction, localization, formatting, and small reversible changes with direct checks | unknown bugs, broad architecture, irreversible migration, security/privacy decisions, or ambiguous cross-project work |
| `GPT-6 Sol` | everyday iOS implementation, bounded refactors, tests, routine review, and reproduced bugs; many risk-bearing tasks with explicit contracts and verification | the hardest cross-cutting decisions where ambiguity or failure cost makes Astra's stronger reasoning material |
| `GPT-6 Astra` | complex architecture, unknown high-impact defects, difficult Swift concurrency or migration, security/privacy, broad audits, and high-risk final review when Sol's error/rework risk is material | routine bounded work when Luna or Sol meets the same quality bar |

Default effort: `medium` when available. Use `low` for directly checkable mechanical work; use `high` or a higher selector-supported level when ambiguity, irreversible consequences, broad impact, or difficult diagnosis justifies its cost. Select only levels actually offered for the selected model. More reasoning does not substitute for evidence or tool permission.

## Operating Modes

The user selects one persistent mode: `качество`, `сбалансированный`, or `эконом`. The mode sets the economy target; it never lowers correctness, safety, maintainability, or evidence requirements. If no mode is stated, use `качество`.

- `качество`: prefer Astra when its additional judgment materially reduces error or rework; otherwise use Sol, or Luna for directly verified mechanical work.
- `сбалансированный`: Sol is the normal default for bounded implementation; Astra protects demanding, ambiguous or high-impact work; Luna handles narrow, easily checked work.
- `эконом`: use Luna for clear, low-risk work with direct checks; otherwise Sol remains the default, with Astra still required when the risk floor demands it.

## Command-Time Decision Rule

After every user request or command, assess the **currently selected** model and reasoning level against the requested block.

1. If the current route can meet the required quality and risk floor, report `Смена модели: не требуется` and proceed immediately. Do not propose a cheaper or stronger model merely as an optimization.
2. If the current route is not adequate, do **not** inspect, plan, edit, run tools, or begin the requested task. Report `Смена модели: требуется: <model>, <level>` and wait for the user to switch or explicitly direct an exception.
3. A required-switch proposal states: current route; target route; concrete risk that the current route cannot safely cover; expected quality/rework gain; relative token/limit cost; the smallest viable alternative; and what remains unverified if the user elects to continue unchanged.

An explicit user or task instruction may select a model and reasoning level for that named task or
implementation plan. That override is authoritative within its stated scope and duration; it does
not rewrite this global default or impose the selected model on unrelated future tasks. The task
record must carry the selected route and its duration so later work does not infer a permanent
global change from a scoped override.

Codex cannot change the primary selector. A one-off model selection does not change the operating mode. Never change either silently.

## Execution Economy Heuristics

- For normal bounded work, prefer one Sol session that owns discovery, planning, implementation, correction, and reporting end-to-end, with deterministic tools providing the evidence.
- Do not require a `Luna -> Sol -> Astra` pipeline for every task. Each handoff reloads context and can cost more than it saves.
- Use Luna for an isolated, fully specified low-risk block with direct verification. Do not start a separate Luna discovery pass when Sol would need to reread the same repository context.
- Use Astra at boundaries where stronger judgment materially reduces expected rework or harm: highly ambiguous requirements, unknown high-impact defects, difficult concurrency or migration, security/privacy, public contracts, CI/signing, broad architecture, or irreversible consequences.
- Astra may plan or review a high-risk block while Sol implements a stable approved plan. Keep Astra as the end-to-end implementer when splitting ownership would lose critical context or make rework more likely.
- Add an independent review only when correlated misunderstanding is a material risk. Keep it bounded to the task contract, acceptance criteria, affected-component map, diff, and tool evidence; do not automatically reload the whole repository.
- A model-written self-review is useful but is not independent evidence. Build, tests, static gates, hashes, and other deterministic outputs remain the source of verification claims.
- Estimate economy from total task cost, including context reloads, tool calls, failed attempts, and rework. Do not promise fixed savings percentages.

When evidence is weak or a change affects concurrency, persistence, security, navigation ownership, public contracts, or multiple dependent files, do not assume the cheaper route remains economical; assess whether Sol is sufficient or Astra is required before implementation.

## Reporting

Every required header states factual model, reasoning level, operating mode, and either `Смена модели: не требуется` or `Смена модели: требуется: …`. Meaningful results identify the model used. Context handoffs preserve the active mode and the current model decision.

## Context Transfer Rule

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
