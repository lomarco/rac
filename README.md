# rac - Rapidus Addon Curator

*A minimalist, lightning-fast Zsh plugin manager.*

## About

<table>
<tr>
<td>
Most Zsh plugin managers are bloated. They try to do too much - dependency graphs, deferred loading, configuration injection - and in the process, they slow down your shell.
The reality is, most users never use even 80% of these features.
`rac` is deliberately minimal. All it does is **download plugins** and **update plugins**.
</td>
</tr>
</table>

## Benchmarks

| Manager    | Startup Time | Lines of Code |
|------------|--------------|---------------|
| **rac**    | **67.8ms**   | **~200**      |
| zinit-turbo| 74.5ms       | **~11,000**   |

*AMD Ryzen 5 3550H, 3 plugins, hyperfine -r 50. See [benchmark.sh](benchmark.sh)*

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
```

### Zshrc example
```bash
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

RAC_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rac"
[[ -d $RAC_HOME ]] || git clone --depth 1 https://github.com/lomarco/rac.git $RAC_HOME \
  zcompile -U $RAC_HOME/rac.zsh
source $RAC_HOME/rac.zsh

rac load "romkatv/powerlevel10k" \
  "zsh-users/zsh-autosuggestions" \
  "zdharma-continuum/fast-syntax-highlighting"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) for details.
