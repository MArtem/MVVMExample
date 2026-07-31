# Model Selection Rule

## Authority

This is the sole active rule for choosing a model and reasoning level. It supersedes earlier routing matrices, estimates, and model-selection guidance. `GPT-5.5` is a comparison baseline only, not an available route.

## Accepted Capability And Cost Baseline

Relative to GPT-5.5 on the official coding evaluations, the accepted aggregate capability baseline is: Sol `106.4%`, Terra `103.5%`, and Luna `100.6%`. For equal token volumes, relative API cost is Sol `100%`, Terra `50%`, Luna `20%`. These figures guide selection; they do not guarantee a task outcome or total token use.

Practical iOS interpretation:

| Model | Default scope | Do not use as the primary route for |
| --- | --- | --- |
| `GPT-5.6 luna` | fully specified mechanical edits, localization, formatting, simple models, and small reversible changes | architecture, large repository reasoning, Swift 6 concurrency, persistence, unknown bugs, or security-sensitive work |
| `GPT-5.6 tera` | normal SwiftUI/UIKit, MVVM, feature work, bounded refactors, tests, routine reviews, and reproduced bugs | a task whose risk or ambiguity makes failure/rework materially more expensive than Sol |
| `GPT-5.6 sol` | architecture, Swift 6 concurrency, migration/sync, privacy/security, performance, unknown production bugs, broad refactors, and high-risk final review | routine bounded work when Terra can meet the same quality bar |

Default effort: `medium`. Use `low` only for deterministic mechanical work. Use `high` for Sol when ambiguity, irreversible consequence, broad impact, or difficult diagnosis requires it.

## Operating Modes

The user selects one persistent mode: `качество`, `сбалансированный`, or `эконом`. The mode sets the economy target; it never lowers correctness, safety, maintainability, or evidence requirements. If no mode is stated, use `качество`.

- `качество`: prefer Sol when its additional judgment can materially reduce error or rework.
- `сбалансированный`: Terra is the normal default for bounded implementation; Sol protects high-risk work; Luna is limited to mechanical work.
- `эконом`: use Luna only when its mechanical scope is explicit and easily checked; otherwise Terra remains the default.

## Command-Time Decision Rule

After every user request or command, assess the **currently selected** model and reasoning level against the requested block.

1. If the current route can meet the required quality and risk floor, report `Смена модели: не требуется` and proceed immediately. Do not propose a cheaper or stronger model merely as an optimization.
2. If the current route is not adequate, do **not** inspect, plan, edit, run tools, or begin the requested task. Report `Смена модели: требуется: <model>, <level>` and wait for the user to switch or explicitly direct an exception.
3. A required-switch proposal states: current route; target route; concrete risk that the current route cannot safely cover; expected quality/rework gain; relative token/limit cost; the smallest viable alternative; and what remains unverified if the user elects to continue unchanged.

Codex cannot change the primary selector. A one-off model selection does not change the operating mode. Never change either silently.

## Planning Heuristics

Use these total-task estimates only for a bounded proposal, not as a guarantee:

| Route | Typical completed-task limit vs GPT-5.5 | Suitable condition |
| --- | --- | --- |
| Sol | `75–100%` | fewer failed attempts/rework offsets its higher per-token rate |
| Terra | `40–55%` | normal task with clear scope, ownership, and checks |
| Luna | `15–35%` | small mechanical task with direct verification; may rise to `40–70%` if it causes rework |

When evidence is weak, requirements are ambiguous, or a change affects concurrency, persistence, security, navigation ownership, public contracts, or multiple dependent files, assume the lower-cost estimate is invalid and require Sol.

## Reporting

Every required header states factual model, reasoning level, operating mode, and either `Смена модели: не требуется` or `Смена модели: требуется: …`. Meaningful results identify the model used. Context handoffs preserve the active mode and the current model decision.

## Context Transfer Rule

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
