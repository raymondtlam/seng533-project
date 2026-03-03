#!/bin/bash
set -euo pipefail

# --- Repo root ---
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# --- Paths ---
YCSB_DIR="$REPO_ROOT/YCSB"
WORKLOAD_DIR="$REPO_ROOT/experimentFiles/workloads"
RESULTS_DIR="$REPO_ROOT/results/raw"

mkdir -p "$RESULTS_DIR"

THREADS_LIST=(1 2 4 8 16 20 32 40 64)
TRIALS=(1 2 3 4 5)

RECORDCOUNT=1000000
LOAD_OPS=1000000
RUN_OPS=1000000

WORKLOAD_FILES=(
  "workloadA.properties"
  "workloadB.properties"
  "workloadC.properties"
)

# Move into YCSB directory
cd "$YCSB_DIR"

for wf in "${WORKLOAD_FILES[@]}"; do
  wl_name="$(basename "$wf" .properties)"

  for t in "${THREADS_LIST[@]}"; do
    for trial in "${TRIALS[@]}"; do

      echo "=== $wl_name | threads=$t | trial=$trial ==="

      # Reset DB between trials
      docker exec -i mongo mongosh --quiet --eval 'db.getSiblingDB("ycsb").dropDatabase()' > /dev/null

      # Load phase
      ./bin/ycsb load mongodb -s \
        -P "$WORKLOAD_DIR/base.properties" \
        -P "$WORKLOAD_DIR/$wf" \
        -p recordcount="$RECORDCOUNT" \
        -p operationcount="$LOAD_OPS" \
        > "$RESULTS_DIR/load_${wl_name}_t${t}_trial${trial}.txt"

      # Run phase
      ./bin/ycsb run mongodb -s \
        -P "$WORKLOAD_DIR/base.properties" \
        -P "$WORKLOAD_DIR/$wf" \
        -threads "$t" \
        -p operationcount="$RUN_OPS" \
        > "$RESULTS_DIR/run_${wl_name}_t${t}_trial${trial}.txt"

    done
  done
done

echo "All experiments completed. Results are in: $RESULTS_DIR/"