#!/usr/bin/env bash
set -euo pipefail

# ── configuration ──────────────────────────────────────────────────────────────
PGHOST="ledger-db.internal.hvt.io"
PGPORT="5432"
PGDATABASE="ledger_prod"
PGUSER="backup_user"
BACKUP_DIR="/var/backups/ledger"
S3_BUCKET="hvt-ledger-backups"
S3_PREFIX="daily"
RETENTION_DAYS=30
LOG_FILE="/var/log/ledger-backup.log"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H%M%SZ")
FILENAME="ledger_prod_${TIMESTAMP}.sql.gz"
LOCAL_PATH="${BACKUP_DIR}/${FILENAME}"
S3_URI="s3://${S3_BUCKET}/${S3_PREFIX}/${FILENAME}"

# ── helpers ────────────────────────────────────────────────────────────────────
log() {
  printf '[%s] %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$*" | tee -a "${LOG_FILE}"
}

die() {
  log "ERROR: $*"
  exit 1
}

# ── pre-flight checks ──────────────────────────────────────────────────────────
[[ -d "${BACKUP_DIR}" ]]  || die "Backup directory ${BACKUP_DIR} does not exist."
[[ -n "${PGPASSWORD:-}" ]] || die "PGPASSWORD is not set — check AWS Secrets Manager injection."
command -v pg_dump &>/dev/null || die "pg_dump not found in PATH."
command -v aws    &>/dev/null || die "aws CLI not found in PATH."

log "Starting backup: ${PGDATABASE} → ${FILENAME}"

# ── dump + compress ────────────────────────────────────────────────────────────
pg_dump \
  --host="${PGHOST}" \
  --port="${PGPORT}" \
  --username="${PGUSER}" \
  --no-password \
  --format=plain \
  "${PGDATABASE}" \
  | gzip -9 > "${LOCAL_PATH}" \
  || die "pg_dump/gzip pipeline failed."

log "Dump complete: $(du -sh "${LOCAL_PATH}" | cut -f1) written to ${LOCAL_PATH}"

# ── upload to S3 ───────────────────────────────────────────────────────────────
aws s3 cp "${LOCAL_PATH}" "${S3_URI}" \
  --region us-east-1 \
  || die "S3 upload to ${S3_URI} failed."

log "Uploaded successfully: ${S3_URI}"

# ── remove local file after confirmed upload ───────────────────────────────────
rm -f "${LOCAL_PATH}"
log "Local file removed: ${LOCAL_PATH}"

# ── enforce 30-day retention in S3 ────────────────────────────────────────────
CUTOFF=$(date -u -d "${RETENTION_DAYS} days ago" +"%Y-%m-%dT%H%M%SZ")
log "Pruning objects older than ${RETENTION_DAYS} days (cutoff: ${CUTOFF})..."

aws s3 ls "s3://${S3_BUCKET}/${S3_PREFIX}/" --region us-east-1 \
  | awk '{print $4}' \
  | grep -E '^ledger_prod_[0-9]{4}-[0-9]{2}-[0-9]{2}T' \
  | while IFS= read -r KEY; do
      FILE_TS="${KEY#ledger_prod_}"   # ledger_prod_2026-04-01T120000Z.sql.gz → 2026-04-01T120000Z.sql.gz
      FILE_TS="${FILE_TS%.sql.gz}"    # → 2026-04-01T120000Z
      if [[ "${FILE_TS}" < "${CUTOFF}" ]]; then
        aws s3 rm "s3://${S3_BUCKET}/${S3_PREFIX}/${KEY}" --region us-east-1 \
          && log "Deleted expired backup: ${KEY}"
      fi
    done

log "Backup job finished successfully."
exit 0
