# rac - Rapidus Addon Curator

*A minimalist, lightning-fast Zsh plugin manager.*

## About

Most Zsh plugin managers are bloated. They try to do too much - dependency graphs, deferred loading, configuration injection - and in the process, they slow down your shell.
The reality is, most users never use even 80% of these features.
`rac` is deliberately minimal. All it does is **download plugins** and **update plugins**.

## Why rac

- **Minimal footprint** - a single portable script. No external dependencies except `git` and native `zsh`.
- **Predictable behavior** - you always know what is being sourced, and from where.
- **No lock-in** - plugins are simply git repositories cloned locally. You can delete or edit them at will.
- **Transparent updates** - `git pull` for every repo, nothing more, nothing less.

## Installation

Just put this in your `.zshrc` configuration:
```bash
RAC_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rac"
[[ -d $RAC_HOME ]] || git clone --depth 1 https://github.com/lomarco/rac.git $RAC_HOME
source $RAC_HOME/rac.zsh
```

## Usage

`rac` is intentionally minimal. There are only two commands you need to know.

```bash
rac load zsh-users/zsh-autosuggestions
rac update
rac pull
```

## Benchmarks
Rac:
```bash
$ hyperfine -N -w 10 -r 50 "zsh -i -c exit"
Benchmark 1: zsh -i -c exit
  Time (mean ± σ):      67.8 ms ±   6.3 ms    [User: 40.1 ms, System: 27.0 ms]
  Range (min … max):    59.8 ms …  85.8 ms    50 runs
```

Zinit turbo:
```bash
$ hyperfine -N -w 10 -r 50 "zsh -i -c exit"
Benchmark 1: zsh -i -c exit
  Time (mean ± σ):      74.5 ms ±   6.2 ms    [User: 46.3 ms, System: 28.6 ms]
  Range (min … max):    65.8 ms …  96.5 ms    50 runs
```

## Philosophy

> "Do less. Do it fast. Do it right."

This project exists because most plugin managers forget what shell startup should feel like - *instantaneous*.  
With `rac`, there is no magic, no hidden async loading, and no sprawling plugin syntax to remember. It respects your shell and your time.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) for details.
