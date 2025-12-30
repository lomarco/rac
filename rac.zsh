typeset -gr RAC_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/rac"
export RAC_DEBUG=false

_debug() {
  [[ "$RAC_DEBUG" = true ]] || return 0
  print -P "%F{yellow}$*%f" >&2
}

_err() {
  print -P "%F{red}$*%f" >&2
}

_compile_plugin() {
  zcompile -U **/*.(zsh|sh|plugin.zsh|zsh-theme|zshplugin|zsh.plugin)(.N) 2>/dev/null
}

_path-contains() {
  setopt localoptions nonomatch nocshnullglob nonullglob;
  [ -e "$1"/*"$2"(.,@[1]) ]
}

_install_pkg() {
  local pkg="$1"
  local dir="$2"
  _debug "Installing $pkg..."
  git clone --depth 1 --single-branch "https://github.com/$pkg.git" "$dir"
  _compile_plugin $dir
  # TODO: Add not only github urls
}

_load_pkg() {
  local pkg="$1"
  local dir="$RAC_CACHE/${pkg##*/}"
  local plugin_name=${pkg%/*}
  [[ ! -d $dir ]] && _install_pkg $pkg $dir

  _debug "Loading $plugin_name..."
  if [[ -f "${plugin_name}" ]]; then
    source "${plugin_name}"
  elif [[ -f "${plugin_name}/init.zsh" ]]; then
    source "${plugin_name}/init.zsh"
  elif [[ -f "${plugin_name}.zsh-theme" ]]; then
    source "${plugin_name}.zsh-theme"
  elif [[ -f "${plugin_name}.theme.zsh" ]]; then
    source "${plugin_name}.theme.zsh"
  elif [[ -f "${plugin_name}.zshplugin" ]]; then
    source "${plugin_name}.zshplugin"
  elif [[ -f "${plugin_name}.zsh.plugin" ]]; then
    source "${plugin_name}.zsh.plugin"
  elif _path-contains "${plugin_name}" ".plugin.zsh" ; then
    for script (${plugin_name}/*\.plugin\.zsh(N)) source "${script}"
  elif _path-contains "${plugin_name}" ".zsh" ; then
    for script (${plugin_name}/*\.zsh(N)) source "${script}"
  elif _path-contains "${plugin_name}" ".sh" ; then
    for script (${plugin_name}/*\.sh(N)) source "${script}"
  else
    if [[ -d ${dir:-$plugin_name} ]]; then
      _err "Failed to load ${dir:-$plugin_name}"
    else
      _err "Failed to load ${dir:-$plugin_name}"
    fi
  fi
}

rac() {
  local pkgs=("$@")
  [[ $# -eq 0 ]] && { echo "Error: arguments required" >&2; return 1; }

  while [[ $1 == --* ]]; do
    case $1 in
      --debug|-d) $RAC_DEBUG=true; shift ;;
      --help|-h) echo "TODO..."; return 0 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done
  pkgs=("$@")  # Rebuild pkgs after options

  for pkg in "${pkgs[@]}"; do
    _load_pkg "$pkg" &
  done
  wait
}

# _install_rac() {
#   local pkgs=(
#     "zsh-users/zsh-autosuggestions"
#     "zdharma-continuum/fast-syntax-highlighting" 
#     "romkatv/powerlevel10k"
#   )
#   
#   for pkg in "${pkgs[@]}"; do
#     local dir="$RAC_DIR/${pkg##*/}"
#     [[ -d $dir/.git ]] && (cd $dir && git pull --ff-only --depth=1) || git clone --depth=1 --single-branch "https://github.com/$pkg.git" "$dir" &
#   done
#   wait && zcompile -U $RAC_DIR/**/*.zsh(N) $RAC_DIR/**/*.plugin.zsh(N) $RAC_DIR/**/*.zsh-theme(N)
# }
#
# source $RAC_DIR/powerlevel10k/powerlevel10k.zsh-theme
# source $RAC_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh
# source $RAC_DIR/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
#
# rac-update() {
#   rm -rf ~/.cache/rac/ && _install_rac
# }
