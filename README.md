# rac - Rapidus Addon Curator
## Benchmarks

Rac:
~ < hyperfine -N -w 10 -r 50 "zsh -i -c exit"
Benchmark 1: zsh -i -c exit
  Time (mean ± σ):      70.5 ms ±   4.9 ms    [User: 41.6 ms, System: 29.0 ms]
  Range (min … max):    63.3 ms …  93.6 ms    50 runs

Zinit turbo:
~< hyperfine -N -w 10 -r 50 "zsh -i -c exit"
Benchmark 1: zsh -i -c exit
  Time (mean ± σ):      74.5 ms ±   6.2 ms    [User: 46.3 ms, System: 28.6 ms]
  Range (min … max):    65.8 ms …  96.5 ms    50 runs
