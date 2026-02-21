#!/bin/bash

# ============================================================================
# Lab 1a Recording Wrapper
# Runs gates + verification and records everything to timestamped log
# ============================================================================

set -e

ARTIFACTS_DIR="artifacts"
mkdir -p "$ARTIFACTS_DIR"

LOG_FILE="$ARTIFACTS_DIR/lab1a_$(date -u +%Y%m%d_%H%M%S).log"

echo "Recording to: $LOG_FILE"
echo ""

(
  echo "==============================="
  echo "Lab 1a Execution"
  echo "UTC Start: $(date -u)"
  echo "==============================="
  echo ""

  echo "----- Running run_all_gates.sh -----"
  ./scripts/run_all_gates.sh
  echo ""

  echo "----- Running verify_secrets_and_iam.sh -----"
  REGION=ap-northeast-1 \
  INSTANCE_ID=i-0c561eedd069dfe6e \
  SECRET_ID=lab1a/rds/mysql \
  DB_ID=arcanum-rds01 \
  ./scripts/verify_secrets_and_iam.sh

  echo ""
  echo "==============================="
  echo "UTC End: $(date -u)"
  echo "==============================="
) 2>&1 | tee "$LOG_FILE"

echo ""
echo "Finished. Log saved to: $LOG_FILE"