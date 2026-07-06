# Bun (prisma/streams) benchmark

Prisma's Bun server ([prisma/streams](https://github.com/prisma/streams),
Apache-2.0, commit `b891877`, v0.1.11) benchmarked against our Rust server with
the same `oha` harness. **Definitive same-Linux-kernel numbers: `linux/RESULTS.md`.**

## Run

```bash
git clone https://github.com/prisma/streams prisma-streams
cd prisma-streams && bun install
# local mode — single SQLite, no auth, no object store:
DS_LOCAL_DATA_ROOT=<dir> bun run src/local/cli.ts start \
  --name <name> --hostname 127.0.0.1 --port 4900
```
```bash
./bench-bun-keyed.sh <label>                            # stock (default cap = 1000 records)
DS_READ_MAX_RECORDS=4000 ./bench-bun-keyed.sh <label>   # uncapped, for full-stream parity
```

Mirrors `../bench-keyed.sh` (same params); stream URL is `/v1/stream/<name>`.

## Notes

- Keyed reads (`Stream-Key` + `?key=`) work **zero-config** on the default profile — no schema setup, same as ours.
- Bun caps reads at 1000 records by default, so a stock `full_read` returns half a 2000-append stream — use the uncapped run to compare full reads.

Raw JSON: `results-bun-keyed*.json`, `results-bun-base.json`.
