#!/bin/env zsh
setopt KSH_ARRAYS

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

  local plugin_files=(
    "$dir/$repo_name.zsh"
    "$dir/init.zsh"
    "$dir/$repo_name.zsh-theme"
    "$dir/$repo_name.theme.zsh"
    "$dir/$repo_name.zshplugin"
    "$dir/$repo_name.zsh.plugin"
  )
  
  for file in "${plugin_files[@]}"; do
    [[ -f "$file" ]] && { _debug "Sourcing $file"; source "$file"; return 0; }
  done
  
  local patterns=( ".plugin.zsh" ".zsh" ".sh" )
  for pattern in "${patterns[@]}"; do
    if _path_contains "$dir" "$pattern"; then
      for script ($dir/*${pattern}(N)); do
        _debug "Fallback sourcing $script"
        source "$script"
      done
      return 0
    fi
  done
  
  _err "Failed to load plugin: $repo_name"
  return 1
}

_rac_load() {
  local pkgs=("$@")
  _debug "Packages: (${#pkgs[@]}): ${pkgs[@]}"
  for pkg in "${pkgs[@]}"; do
    _load_pkg "$pkg"
  done
}

_rac_update() {
  ;
}

_rac_updateall() {
  ;
}

rac() {
  local pkgs=("$@")
  [[ $# -eq 0 ]] && { 
    _err "Error: arguments required"
    echo "Usage: rac [options] package1 package2..."
    echo "Options: --debug|-d, --help|-h"
    return 1 
  }
  
  local i=0
  local new_pkgs=()
  local commands=()

  while [[ $i -lt ${#pkgs[@]} ]]; do
    case "${pkgs[$i]}" in
      load|update|update-all)
        command="${pkgs[$i]}"
        ((i++))
        ;;
      --debug|-d)
        RAC_DEBUG=true
        ((i++))
        ;;
      --help|-h)
        echo "rac - rapidus addon curator"
        echo ""
        echo "Usage: rac <command> [flags] [options] [packages...]"
        echo ""
        echo "Commands:"
        echo "  load             Load plugin"
        echo "  update           Update plugin"
        echo "  update-all       Update all plugins"
        echo ""
        echo "Flags:"
        echo "  --debug, -d      Enable debug output"
        echo "  --help, -h       Show this help"
        echo ""
        echo "Examples:"
        echo "  rac load zsh-users/zsh-autosuggestions"
        echo "  rac update --debug zdharma-continuum/fast-syntax-highlighting"
        echo "  rac update-all"
        echo "  rac --debug zsh-users/zsh-autosuggestions zdharma-continuum/fast-syntax-highlighting"
        return 0
        ;;
      --*|-*)
        _err "Unknown option: ${pkgs[$i]}"
        return 1
        ;;
      *)
        new_pkgs+=("${pkgs[$i]}")
        ((i++))
        ;;
    esac
  done
  
  pkgs=("${new_pkgs[@]}")

  [[ -z "$command" ]] && {
    _err "Error: command required (load, update, update-all)"
    echo "Usage: rac <command> [flags] [packages...]"
    echo "Try 'rac --help' for more information"
    return 1
  }

  _debug "Start $command..."
  case "$command" in
    load) _rac_load ${pkgs[@]};;
    update) _rac_update "${pkgs[@]}";;
    update-all) _rac_updateall "${pkgs[@]}";;
  esac
}
