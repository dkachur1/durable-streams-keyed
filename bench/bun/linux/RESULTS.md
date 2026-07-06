# Linux head-to-head (same kernel, same container)

Both servers built and run inside **one Linux container** (aarch64, kernel
6.8.0, 6 vCPU) on the same host — the definitive same-machine comparison, with
Rust's `#[cfg(target_os = "linux")]` zero-copy paths **compiled in** (which the
macOS runs could not do). Harness: the same `oha` (1.14.0) + same params as
`../bench-keyed.sh` — N=2000, K=50, ~200 B, c=64, 6 s × 3 (medians).

Toolchain in-container: `rustc 1.89.0`, `bun 1.3.14`, `oha 1.14.0`,
prisma/streams @ `b891877` (v0.1.11).

## Results (medians)

| system | scenario | rps | p50 (ms) | p99 (ms) | cpu% | body |
|---|---|--:|--:|--:|--:|--:|
| **Rust (ours)** | keyed `?key=` | **41,113** | 1.33 | 5.01 | 300 | 8 KB |
| **Rust (ours)** | full read | **18,000** | 3.37 | 8.45 | 150 | 400 KB |
| Bun (uncapped) | keyed `?key=` | 5,787 | 9.93 | 22.78 | 100 | 8 KB |
| Bun (uncapped) | full read | 803 | 77.14 | 144.18 | 133 | 400 KB |
| Bun (stock cap) | keyed `?key=` | 7,029 | 8.72 | 14.85 | 100 | 8 KB |
| Bun (stock cap) | full read | 1,732 | 35.72 | 52.55 | 117 | 200 KB* |

\*Bun's stock 1000-record read cap returns only half the 2000-append stream;
the uncapped row (`DS_READ_MAX_RECORDS=4000`) is the apples-to-apples one.

## What the Linux run establishes (and corrects vs macOS)

- **Keyed read: Rust ~7.1× Bun's rps** (41,113 vs 5,787) and ~7.5× lower p50 —
  a much bigger gap than the ~2.5× seen on macOS.
- **Rust keyed uses *less* CPU per request than Bun** on Linux (300%/41k =
  0.0073 vs 100%/5.8k = 0.0173 → ~2.4× leaner). This **reverses** the macOS
  finding that "Bun wins CPU-efficiency" — that was a macOS-fallback artifact
  (no zero-copy read path), not a real property.
- **Full read: Rust ~22× Bun's rps** (18,000 vs 803) — the native zero-copy vs
  interpreted gap, now measured on the same kernel.
- Keyed filtering correct + zero-config on both (exact 8 KB = 1/50 of 400 KB).

## Harness caveat (why there are no result JSONs here)

The medians above are captured from the run's stdout. The per-scenario `oha`
parsing worked (oha 1.14.0); the final results-file assembly step still failed
under the container's **jq 1.6** (a jq incompatibility beyond the `label`
keyword, which is already quoted), so `out/*.json` came out empty. The numbers
are unaffected — they're the real medians the harness printed. Fixing this fully
means shipping a newer jq into the image (a follow-up, not a numbers issue).

Reproduce: `bench/bun/linux/build-and-run.sh` (builds the image, runs the three
suites). Numbers are laptop-Docker relative, not dedicated-hardware absolutes.
