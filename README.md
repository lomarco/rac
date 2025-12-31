# rac - Rapidus Addon Curator

## Benchmarks
Rac:
``` bash
$ hyperfine -N -w 10 -r 50 "zsh -i -c exit"
Benchmark 1: zsh -i -c exit
  Time (mean ± σ):      67.8 ms ±   6.3 ms    [User: 40.1 ms, System: 27.0 ms]
  Range (min … max):    59.8 ms …  85.8 ms    50 runs
```

Zinit turbo:
``` bash
$ hyperfine -N -w 10 -r 50 "zsh -i -c exit"
Benchmark 1: zsh -i -c exit
  Time (mean ± σ):      74.5 ms ±   6.2 ms    [User: 46.3 ms, System: 28.6 ms]
  Range (min … max):    65.8 ms …  96.5 ms    50 runs
```
