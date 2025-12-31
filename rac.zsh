#!/bin/env zsh

typeset -gr RAC_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/rac"
RAC_DEBUG=false

_debug() {
  [[ "$RAC_DEBUG" = true ]] || return 0
  print -P "%F{yellow}$*%f" >&2
}

_err() {
  print -P "%F{red}$*%f" >&2
}

_compile_plugin() {
  local dir="${1:-.}"
  zcompile -U "${PWD%/}/$dir"/**/*.(zsh|sh|plugin.zsh|zsh-theme|zshplugin|zsh.plugin)(.N) 2>/dev/null
}

_path_contains() {
  setopt localoptions nonomatch nocaseglob nullglob
  [[ -n ${(M)${1}/*${2}(N)} ]]
}

_install_pkg() {
  local pkg="$1"
  local dir="$2"
  _debug "Installing $pkg to $dir..."
  mkdir -p "$(dirname "$dir")"
  git clone --depth 1 --single-branch "https://github.com/$pkg.git" "$dir" || {
    _err "Failed to clone $pkg"
    return 1
  }
  _compile_plugin "$dir"
}

_load_pkg() {
  local pkg="$1"
  local repo_name="${pkg##*/}"
  local dir="$RAC_CACHE/$repo_name"
  
  [[ ! -d "$dir" ]] && _install_pkg "$pkg" "$dir"

  _debug "Loading $repo_name from $dir..."
  
  local plugin_files=(
    "$dir/$repo_name.zsh"
    "$dir/init.zsh"
    "$dir/$repo_name.zsh-theme"
    "$dir/$repo_name.theme.zsh"
    "$dir/$repo_name.zshplugin"
    "$dir/$repo_name.zsh.plugin"
  )
  
  for file in "${plugin_files[@]}"; do
    [[ -f "$file" ]] && { source "$file"; return 0; }
  done
  
  local patterns=( ".plugin.zsh" ".zsh" ".sh" )
  for pattern in "${patterns[@]}"; do
    if _path_contains "$dir" "$pattern"; then
      for script ($dir/*${pattern}(N)); do
        _debug "Sourcing $script"
        source "$script"
      done
      return 0
    fi
  done
  
  _err "Failed to load plugin: $repo_name"
  return 1
}

rac() {
  local pkgs=()
  [[ $# -eq 0 ]] && { 
    _err "Error: arguments required"
    echo "Usage: rac [options] package1 package2..."
    echo "Options: --debug|-d, --help|-h"
    return 1 
  }
  while [[ $# -gt 0 && $1 =~ ^- ]]; do
    case $1 in
      --debug|-d) RAC_DEBUG=true; shift ;;
      --help|-h) 
        echo "rac - rapidus addon curator"
        echo "Usage: rac [options] package1 package2..."
        echo "Options:"
        echo "  --debug, -d    Enable debug output"
        echo "  --help, -h     Show this help"
        echo "Examples:"
        echo "  rac --debug zsh-users/zsh-autosuggestions"
        echo "  rac zsh-users/zsh-autosuggestions zdharma-continuum/fast-syntax-highlighting"
        return 0 ;;
      --*) _err "Unknown option: $1"; return 1 ;;
      -*) _err "Unknown option: $1"; return 1 ;;
    esac
  done
  
  pkgs=("$@")

  [[ ${#pkgs[@]} -eq 0 ]] && {
    _err "Error: packages required after flags"
    echo "Usage: rac [options] package1 package2..."
    return 1
  }

  _debug "Loading ${#pkgs[@]} packages..."
  for pkg in "${pkgs[@]}"; do
    _load_pkg "$pkg"
  done
}
