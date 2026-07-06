#!/usr/bin/env bash
# Host-side driver: assemble a tight build context, build the Linux image, run
# both benches inside one container, drop result JSONs in ./out.
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$HERE/../../.." && pwd)"          # durable-streams-keyed/
CTX=/tmp/ds-linux-ctx
OUT="$HERE/out"
IMAGE=ds-linux-bench

rm -rf "$CTX"; mkdir -p "$CTX/server-src" "$OUT"

# vendored patched Rust source WITHOUT its 400MB target/
rsync -a --exclude target "$REPO_ROOT/vendor/durable-streams-0.1.2/" "$CTX/server-src/"
# harness scripts
cp "$REPO_ROOT/bench/bench-keyed.sh"        "$CTX/"
cp "$REPO_ROOT/bench/bun/bench-bun-keyed.sh" "$CTX/"
cp "$REPO_ROOT/bench/bun/bench-bun-base.sh"  "$CTX/"
cp "$HERE/run-in-container.sh"              "$CTX/"
cp "$HERE/Dockerfile"                        "$CTX/"

echo "### building $IMAGE (this compiles Rust + oha + bun install; first build is slow)"
docker build -t "$IMAGE" "$CTX"

echo "### running benches in container"
docker run --rm -v "$OUT:/out" "$IMAGE"

echo "### results in $OUT"
ls -la "$OUT"
