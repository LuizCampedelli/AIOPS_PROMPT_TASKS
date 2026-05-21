# Explanation — Questão 02: RTF Framework Applied to Ledger Backup Script

## Model Used

Claude Sonnet 4.6 (claude-sonnet-4-6) — 2026-05-21

---

## How Role, Task, and Format Appear in the Prompt

### Role

> *"Act as a specialized senior DevOps engineer, focused in AWS, with SRE background, using shell script as bash coding language..."*

The Role anchors the model's persona and constrains its decisions:
- **Senior DevOps + SRE background** → the model applies production-grade defensive patterns: `set -euo pipefail`, pre-flight checks (`command -v`, directory existence, env var validation), and explicit exit codes.
- **AWS-focused** → the model defaults to AWS-native tooling (`aws s3 cp`, IAM role for credentials, `--region us-east-1`) rather than generic cloud abstractions.
- **Bash specialist** → the model writes idiomatic bash (functions, `[[ ]]` conditionals, `IFS= read -r`, `awk`, `tee`) rather than Python or another language.

Without the Role, the model might produce a more generic or less defensive script — for instance, omitting the pre-flight guard on `PGPASSWORD` or using Python boto3 instead of the AWS CLI.

---

### Task

> *"Create a script to dump using pg_dump, compressing using gzip, to backup the database: ledger_prod, upload the backup file to the S3 bucket using the name hvt-ledger-backups, using AWS CLI command aws s3 cp, use the lifecycle of 30 days in retention, always removing the older ones, log the execution in /var/log/ledger-backup.log with timestamp, exit code in case of fail."*

The Task maps directly to each section of the generated script:

| Task Requirement | Script Implementation |
|---|---|
| `pg_dump` | `pg_dump --host --port --username --format=plain` |
| Compress with `gzip` | Piped directly: `pg_dump ... \| gzip -9 > file.sql.gz` |
| Upload to `hvt-ledger-backups` | `aws s3 cp "${LOCAL_PATH}" "${S3_URI}"` |
| Use `aws s3 cp` explicitly | `aws s3 cp` (not sync/multipart/SDK) |
| 30-day retention, remove older | `aws s3 ls` → parse timestamps → `aws s3 rm` for files older than cutoff |
| Log to `/var/log/ledger-backup.log` | `log()` helper with `tee -a "${LOG_FILE}"` on every step |
| Timestamp in log | `printf '[%s] %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"` |
| Exit code on failure | `die()` calls `exit 1`; `set -euo pipefail` catches unhandled failures |

The Task's specificity (exact database name, bucket name, log path, retention period) allowed the model to hard-code correct values instead of using placeholders.

---

### Format

> *"Create the bash script that will create the dump following the instruction in the Task. Add the step-by-step in EXPLANATION.md inside the TASK02 folder."*

The Format directive produced two concrete output artifacts:
1. **`ledger_backup.sh`** — a self-contained, executable bash script ready to be deployed and registered as a cron job.
2. **`EXPLANATION.md`** (this file) — a step-by-step account of the script's logic and the RTF justification.

The Format also implicitly shaped the script's internal structure: because the output must be a *deployable script* (not pseudocode or a tutorial), the model included shebang line, configuration block, helper functions, and a logical top-to-bottom flow a cron daemon can execute directly.

---

## Script Step-by-Step

1. **Configuration block** — all environment-specific values (host, port, db, user, paths, bucket, region, retention) are declared at the top for easy maintenance.
2. **Timestamp + filename** — a UTC ISO-8601 timestamp is baked into the filename (`ledger_prod_2026-05-21T143000Z.sql.gz`), making backups sortable and the retention logic reliable.
3. **`log()` helper** — writes `[ISO-timestamp] message` to both stdout and the log file via `tee -a`.
4. **`die()` helper** — logs an error message and exits with code `1`, satisfying the "exit code on failure" requirement.
5. **Pre-flight checks** — validates that the backup directory exists, `PGPASSWORD` is set (injected by AWS Secrets Manager via the instance's IAM role), and both `pg_dump` and `aws` are available in PATH.
6. **Dump + compress** — streams `pg_dump` output through `gzip -9` directly into the local file. No intermediate uncompressed file is written, keeping disk usage minimal (~12 GB for a compressed dump).
7. **S3 upload** — uses `aws s3 cp` with explicit `--region us-east-1`. The IAM role on the EC2 instance provides credentials; no static keys are used.
8. **Local cleanup** — removes the local `.sql.gz` file after a confirmed upload to free the 80 GB working directory.
9. **30-day retention** — lists objects under the `daily/` prefix, extracts the embedded timestamp from each filename, and deletes any file whose timestamp precedes the 30-day cutoff. Comparison is purely lexicographic on the ISO-8601 string, which is correct for UTC timestamps in this format.
10. **Success log + exit 0** — records job completion and exits cleanly so cron does not send spurious failure emails.

---

## Cron Registration (suggested)

```cron
0 2 * * * /usr/local/bin/ledger_backup.sh >> /var/log/ledger-backup.log 2>&1
```

Run daily at 02:00 UTC on the `ledger-db.internal.hvt.io` instance, with all output appended to the existing log file.
