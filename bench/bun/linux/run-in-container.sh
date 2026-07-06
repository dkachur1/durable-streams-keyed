#!/usr/bin/env bash
# Runs inside the Linux container. Benches BOTH servers with the same oha
# harness, same defaults (CONN=64 DUR=6s REPEATS=3 N=2000 K=50 APPENDSIZE=200),
# sequentially on the same kernel, then copies result JSONs to /out.
set -eu
export DUR="${DUR:-6s}" REPEATS="${REPEATS:-3}"
mkdir -p /out

echo "############ uname ############"
uname -a
nproc
echo "rustc: $(rustc --version)"; echo "bun: $(bun --version)"; echo "oha: $(oha --version)"

echo "############ RUST keyed (with Linux zero-copy compiled) ############"
BIN=/app/durable-streams-server PORT=4712 /app/bench-keyed.sh linux-rust || echo "rust bench failed"

echo "############ BUN keyed (uncapped, DS_READ_MAX_RECORDS=4000 for full-stream parity) ############"
REPO=/app/prisma-streams PORT=4900 DS_READ_MAX_RECORDS=4000 \
  /app/bench-bun-keyed.sh linux-bun-uncapped || echo "bun uncapped bench failed"

echo "############ BUN keyed (stock, default read cap) ############"
REPO=/app/prisma-streams PORT=4900 \
  /app/bench-bun-keyed.sh linux-bun-stock || echo "bun stock bench failed"

echo "############ collecting ############"
cp -f /tmp/ds-bench/results-linux-rust.json /out/ 2>/dev/null || true
cp -f /tmp/ds-bun-bench/results-linux-bun-uncapped.json /out/ 2>/dev/null || true
cp -f /tmp/ds-bun-bench/results-linux-bun-stock.json /out/ 2>/dev/null || true
echo "wrote:"; ls -la /out
