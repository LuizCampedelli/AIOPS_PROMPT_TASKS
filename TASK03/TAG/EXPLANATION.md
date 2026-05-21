# Explanation — Questao 03: TAG Framework Applied to Cloud Cost Reduction Report

## Model Used

Claude Opus 4.6 (claude-opus-4-6) — 2026-05-21

Chosen for its strong analytical reasoning over structured numerical data. The task requires cross-referencing a 12-row cost table, calculating percentages, estimating savings ranges, and producing a coherent executive narrative — capabilities where Opus excels compared to smaller models.

---

## How Task, Action, and Goal Appear in the Prompt

### Task

> *"Analyze the following AWS monthly cost breakdown for Hill Valley Tech and produce an executive cost-reduction report."*

The Task defines **what** the model must do and provides the raw material — the full CSV with 12 AWS services, their categories, monthly costs, utilization percentages, and contextual notes. By framing the task as "analyze and produce a report," the model understands it must both interpret data and generate a structured document, not just list numbers. The Task also anchors the company context (Hill Valley Tech, production systems) so the model avoids generic advice and ties recommendations to the specific workloads described.

---

### Action

> *"1. Calculate the total monthly spend and the 15% target savings... 2. Identify every optimization opportunity... 3. Estimate monthly savings in USD and as a percentage... 4. Classify implementation effort... 5. Assess risks and prerequisites... 6. Rank all opportunities by savings impact... 7. Sum projected savings and confirm whether the 15% target is achievable."*

The Action is the most detailed component — a **7-step procedure** that prescribes exactly how the model should process the data. Each step maps to a distinct section of the output:

| Action Step | Output Section |
|---|---|
| Step 1: Calculate total and 15% target | Executive Summary header (USD 41,800 total, USD 6,270 target) |
| Step 2: Identify optimization opportunities | 10 numbered opportunities in the prioritized table |
| Step 3: Estimate savings in USD and % | "Est. Savings" and "% of Total Bill" columns |
| Step 4: Classify effort (Low/Medium/High) | "Effort" column with defined thresholds |
| Step 5: Assess risks and prerequisites | "Risk / Prerequisites" column |
| Step 6: Rank by impact (highest first) | Table ordered by descending savings |
| Step 7: Sum and confirm feasibility | Savings Summary table and Feasibility Assessment section |

Without the Action's explicit steps, the model might produce a vague list of ideas instead of a structured, quantified, prioritized analysis. The effort classification rubric (Low < 1 day, Medium 1-5 days, High > 5 days) prevents subjective or inconsistent labeling.

---

### Goal

> *"Deliver a clear, executive-ready report that the CEO (Goldie Wilson) can present to the board, showing a prioritized roadmap to achieve at least 15% cloud cost reduction (USD 6,270/month) without degrading production SLAs."*

The Goal defines **why** this analysis exists and **who** consumes it. This shaped the output in three critical ways:

1. **Audience calibration** — "executive-ready" and "CEO can present to the board" pushed the model to use summary tables, dollar figures, and percentages rather than technical deep-dives. The report leads with an executive summary, not a CLI command.
2. **Success criterion** — "at least 15% / USD 6,270" gave the model a concrete threshold to validate against. The Feasibility Assessment section explicitly confirms the target is reachable by Phase 2.
3. **Constraint** — "without degrading production SLAs" forced the model to include risk assessments and to flag items like RDS right-sizing (brief failover) or NAT consolidation (HA impact) rather than blindly maximizing savings.

Without the Goal, the model could produce a technically valid but board-inappropriate analysis — too granular, missing the feasibility verdict, or recommending aggressive cuts that risk downtime.

---

## Summary

The TAG framework structures this prompt as a pipeline: the **Task** provides the raw data and context, the **Action** prescribes the analytical steps, and the **Goal** constrains the output format, audience, and success criteria. Together, they ensure the model produces a complete, quantified, board-ready report rather than a generic list of AWS cost tips.
