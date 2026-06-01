# Justification — RTF Framework for TASK01

## Framework Used: R-T-F

**R**ole — **T**ask — **F**ormat

---

## Why RTF fits this scenario

This task is a **direct generation task**: produce a working Dockerfile and project scaffold for a known service, with fully specified inputs (port, dependencies, env vars, folder structure). There is no data to analyze, no binary decision to make, and no reasoning chain to prescribe — just a concrete, bounded deliverable.

RTF is optimal for this profile because each of its three components maps directly to what a generation task needs:

| Concern | What the model needs | RTF component |
|---------|----------------------|---------------|
| Calibrate expertise and code quality | A persona that brings security best-practices and production patterns | **Role** |
| Define what to build | A clear, bounded specification with all required constraints | **Task** |
| Control output shape | Exact file names, folder structure, and documentation required | **Format** |

No other slot is needed: there are no external artifacts to inject (unlike an incident postmortem), no sequential reasoning to guide (unlike a root-cause analysis), and no transformation narrative to construct (unlike a before/after change proposal).

---

## How each component appears in the prompt

### Role

```
Act as an specialized senior devops engineer, focused in docker,
kubernetes, python as script language.
```

**What it does:** establishes the technical persona before any instruction is given. A "senior DevOps engineer focused on Docker and Kubernetes" carries implicit knowledge the prompt never has to spell out — multi-stage builds to keep runtime images lean, non-root users for least-privilege execution in pods, slim base images to reduce attack surface, and env vars declared but never baked in. The output confirms this: the Dockerfile uses `python:3.12-slim`, a multi-stage build separating the compiler from the runtime, and a dedicated `appuser`.

---

### Task

```
Create a dockerfile, to enable the python script, in api/flask, in port 8080,
using dependencies in requirements.txt, declared bellow, adding two environment
variables, DATABASE_URL & API_KEY.

requirements.txt content:
  Flask==3.0.0
  gunicorn==21.2.0
  requests==2.31.0
  python-dotenv==1.0.0
  psycopg2-binary==2.9.9

In production, the service will run in gunicorn --bind 0.0.0.0:8080 --workers 4 app:app
```

**What it does:** defines the concrete action and bundles all constraints the model needs to act — the runtime (Flask on port 8080), the dependency list (which revealed that `psycopg2-binary` requires `gcc` at build time, motivating the multi-stage build), the two required env vars, and the exact production entrypoint. The production command was critical: it told the model that `gunicorn` is the process manager and defined the exact `CMD` instruction.

---

### Format

```
Create a complete python script and dockerfile, that will apply this script,
script format bellow, add variables of the project and explanation in the top
of file, create an EXPLANATION.md, inside RTF Folder, with the guidelines to
apply the project files.

Project script format:
lift/
├── app.py
├── requirements.txt
├── lib/
│   ├── auth.py
│   └── storage.py
└── tests/
    └── test_app.py
```

**What it does:** specifies *what to deliver* and *how to structure it*. The folder tree gave the model the exact module layout (including `lib/auth.py` and `lib/storage.py`), which it replicated in both the `COPY` instructions of the Dockerfile and the scaffolded Python files. The requirement for a header comment block in each file ("add variables of the project and explanation in the top of file") produced the documented preamble visible in the Dockerfile. The `EXPLANATION.md` instruction produced the deployment guide with Docker and Kubernetes examples.

---

## Prompt steps — how the three components work in sequence

```
1. Role   → sets the cognitive frame before any instruction
              "I am a senior DevOps engineer" → activates production-grade defaults

2. Task   → delivers the specification within that frame
              "build this Flask service on port 8080 with these deps and vars"

3. Format → locks the output contract
              "deliver these files, in this structure, with this documentation"
```

The ordering matters: **Role before Task** means the model interprets every constraint through a senior engineer's lens, not a generic one. **Format last** means it shapes the output without constraining how the model reasons toward it.

---

## Evidence in the output

The Dockerfile produced confirms that each RTF component had a concrete effect:

| RTF Component | Instruction | Effect visible in output |
|---------------|-------------|--------------------------|
| Role | "senior devops engineer, docker, kubernetes" | Multi-stage build, non-root `appuser`, `python:3.12-slim`, env vars documented not hardcoded |
| Task | `psycopg2-binary` in requirements | Stage 1 installs `gcc` for compilation; Stage 2 copies only the installed packages |
| Task | `gunicorn --bind 0.0.0.0:8080 --workers 4 app:app` | `CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "app:app"]` verbatim |
| Format | Folder structure with `lib/` | `COPY lib/ lib/` instruction in Dockerfile; scaffolded `auth.py` and `storage.py` |
| Format | "explanation in the top of file" | Header comment block with build/run instructions at the top of the Dockerfile |
| Format | "create an EXPLANATION.md" | Deployment guide with local Docker and Kubernetes patterns, liveness probes, and test instructions |
