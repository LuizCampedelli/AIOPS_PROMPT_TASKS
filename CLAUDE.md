# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a prompt engineering challenge/assignment repository for an AIOps course. It does not contain runnable code — the deliverables are AI prompts applying specific prompt frameworks to realistic DevOps/SRE scenarios set in a fictional company.

There are no build, test, or lint commands.

## Fictional Context: Hill Valley Tech

All scenarios take place at **Hill Valley Tech**, a fictional company with five production systems:

| System | Role |
|--------|------|
| **Chronos** | API gateway and core platform — entry point for all company traffic |
| **Ledger** | PostgreSQL data warehouse — historical transactions and events |
| **Reactor** | Async processing via message queues |
| **Beacon** | Observability platform — metrics, logs, alerts (used by on-call) |
| **Lift** | Beta product being developed separately |

Key team members:
- **Doc Brown** (CTO) — technical direction
- **Jennifer Parker** (PM) — product prioritization
- **Lorraine Baines** (SRE Lead) — on-call, runbooks, incident procedures
- **George McFly** (Senior Engineer) — wrote much of the legacy system
- **Goldie Wilson** (CEO) — cost and growth lens
- **Strickland** (Head of Security/Compliance) — internal standards for new code

## Repository Structure

- `README.md` — Scenario description and assignment instructions
- `RTF/` — Prompts and questions using the **RTF (Role, Task, Format)** framework
  - `PROMPT_RTF_DOCKER.md` — Role definition fragment for a senior DevOps/Docker specialist
  - `QUESTION01.md` — Challenge: Dockerfile for the Lift service (Python/Flask on port 8080)

## Assignment Format

Each question requires:
1. **A prompt** applying the specified framework (e.g., RTF) executed against an AI model
2. **The model's output** recorded
3. **A justification** showing how each framework component appeared in the prompt

**Question 08** is an exception: the framework is chosen freely from five options covered in the course, with explicit comparison against two alternatives.

## Prompt Frameworks in Use

The primary framework used in this directory is **RTF**:
- **R**ole — persona the model should adopt
- **T**ask — what the model must do
- **F**ormat — how the output should be structured

Other frameworks from the course chapter may be used in future questions or in Question 08.
