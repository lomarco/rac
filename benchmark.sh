#!/usr/bin/env bash
# benchmark.sh - Zsh plugin manager startup benchmark
# Usage: ./benchmark.sh [rac|zinit|oh-my-zsh|antigen]

set -euo pipefail

PLUGINS=(
  "romkatv/powerlevel10k"
  "zsh-users/zsh-autosuggestions" 
  "zdharma-continuum/fast-syntax-highlighting"
  "zsh-users/zsh-syntax-highlighting"
)
TEST_DIR="$(mktemp -d)"
ZDOTDIR="$TEST_DIR"
ZSHRC="$ZDOTDIR/.zshrc"
RUNS=50
WARMUP=10

cd "$TEST_DIR"

print_header() {
  printf "\n=== %s ===\n" "$1"
  printf "Hardware: %s\n" "$(uname -m) $(uname -s) $(zsh --version)"
  printf "Plugins: %s\n" "${PLUGINS[*]}"
  printf "Runs: %s (warmup: %s)\n\n" "$RUNS" "$WARMUP"
}

setup_rac() {
  print_header "RAC Benchmark"
  
  cat > "$ZSHRC" << 'EOF'
RAC_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rac"
[[ ! -f "$RAC_HOME/rac" ]] && git clone --depth 1 https://github.com/lomarco/rac.git "$RAC_HOME"
source "$RAC_HOME/rac"
rac load romkatv/powerlevel10k zsh-users/zsh-autosuggestions zdharma-continuum/fast-syntax-highlighting zsh-users/zsh-syntax-highlighting
EOF
}

setup_zinit() {
  print_header "Zinit Turbo Benchmark"
  
  mkdir -p "$HOME/.local/share/zinit"
  git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.local/share/zinit/bin" || true
  
  cat > "$ZSHRC" << 'EOF'
source ~/.local/share/zinit/bin/zinit.zsh
zinit light-mode for \
  romkatv/powerlevel10k \
  zsh-users/zsh-autosuggestions \
  zdharma-continuum/fast-syntax-highlighting \
  zsh-users/zsh-syntax-highlighting
EOF
}

run_benchmark() {
  local manager="$1"
  setup_"$manager"
  
  hyperfine \
    --warmup "$WARMUP" \
    --runs "$RUNS" \
    --prepare "rm -rf ~/.cache/* $HOME/.local/share/rac/*" \
    "zsh -i -c 'exit'"
}

cleanup() {
  rm -rf "$TEST_DIR"
}

main() {
  if [[ $# -eq 0 ]]; then
    printf "Usage: %s [rac|zinit|all]\n" "$0"
    printf "Available: rac, zinit\n"
    exit 1
  fi
  
  case "$1" in
    rac)    run_benchmark rac ;;
    zinit)  run_benchmark zinit ;;
    all)
      run_benchmark rac
      run_benchmark zinit
      ;;
    *) printf "Unknown manager: %s\n" "$1"; exit 1 ;;
  esac
}

trap cleanup EXIT
main "$@"
