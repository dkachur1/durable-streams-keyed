# Benchmarks

Both servers in one Linux container, same kernel, same `oha` harness
(N=2000, K=50, ~200 B, 6 s × 3). Laptop-Docker relative, not dedicated-hardware
absolutes.

| scenario | Rust (ours) | Bun | Rust |
|---|--:|--:|:--:|
| keyed read `?key=` (one conversation) | **41,113 rps** · 1.3 ms | 5,787 rps · 9.9 ms | **~7×** |
| full read | **18,000 rps** · 3.4 ms | 803 rps · 77 ms | **~22×** |
| keyed CPU / request | 0.007 | 0.017 | ~2.4× leaner |

Keyed read returns **50× less data** (8 KB vs 400 KB — exactly 1/K, correct
server-side filtering).

## Run

```bash
bun/linux/build-and-run.sh     # Rust vs Bun, one Linux container (the table above)
./bench-keyed.sh <label>       # keyed vs full on the host (needs oha + a built server)
```

Details in `bun/linux/RESULTS.md`; raw JSON in `results/` and `bun/`.
