#!/usr/bin/env bash
# Verification for the local Kubernetes deployment.
# Checks nodes, pods, the live HTTP page, and the HPA. Prints [PASS]/[FAIL]
# per check and a summary line. Exits non-zero if any check fails.

PASSED=0
FAILED=0

pass() { echo "[PASS] $1"; PASSED=$((PASSED + 1)); }
fail() { echo "[FAIL] $1"; FAILED=$((FAILED + 1)); }

echo "== Kubernetes cluster deployment — verification =="

# 1. All 3 nodes Ready
READY_NODES=$(kubectl get nodes --no-headers 2>/dev/null | grep -c " Ready " || true)
if [ "$READY_NODES" -eq 3 ]; then
  pass "All 3 nodes are Ready"
else
  fail "Expected 3 Ready nodes, found $READY_NODES"
fi

# 2. At least 3 zaintech-web pods Running in namespace zaintech
RUNNING_PODS=$(kubectl get pods -n zaintech -l app=zaintech-web --no-headers 2>/dev/null | grep -c "Running" || true)
if [ "$RUNNING_PODS" -ge 3 ]; then
  pass "$RUNNING_PODS zaintech-web pods are Running"
else
  fail "Expected at least 3 Running pods, found $RUNNING_PODS"
fi

# 3. HTTP page served on localhost:30080 with the company name
PAGE=$(curl -s --max-time 10 http://localhost:30080 || true)
if echo "$PAGE" | grep -q "Zain Tech Automation Solutions"; then
  pass "http://localhost:30080 serves the Zain Tech Automation Solutions page"
else
  fail "Page at http://localhost:30080 did not contain the expected content"
fi

# 4. HPA exists in namespace zaintech
if kubectl get hpa zaintech-web -n zaintech >/dev/null 2>&1; then
  pass "HPA zaintech-web exists in namespace zaintech"
else
  fail "HPA zaintech-web not found in namespace zaintech"
fi

echo ""
echo "Passed: $PASSED  Failed: $FAILED"

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
