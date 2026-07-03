# ─── P10K INSTANT PROMPT ──────────────────────────────────────────────────────
# Must stay at the top. Anything requiring console input goes above this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ─── OH-MY-ZSH ───────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
DEFAULT_USER="ridget"

# Homebrew completions (hardcoded to avoid subshell on every startup)
FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"
autoload -Uz compinit
compinit

plugins=(git brew macos zsh-autosuggestions zsh-syntax-highlighting web-search)

source $ZSH/oh-my-zsh.sh

# ─── SECRETS & TOKENS ─────────────────────────────────────────────────────────
[[ -f ~/.secrets ]] && source ~/.secrets

# ─── EDITOR ───────────────────────────────────────────────────────────────────
alias vim="nvim"
export VISUAL="nvim"
export EDITOR="$VISUAL"

# ─── PATH ─────────────────────────────────────────────────────────────────────
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
export PATH="/opt/homebrew/opt/libxslt/bin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"

# ─── TOOLCHAIN (mise, direnv) ─────────────────────────────────────────────────
eval "$(mise activate zsh)"
eval "$(direnv hook zsh)"

# ─── GO ───────────────────────────────────────────────────────────────────────
export GOPATH="$HOME/.go"
export PATH="$PATH:$GOPATH/bin"

# ─── FZF ──────────────────────────────────────────────────────────────────────
eval "$(fzf --zsh)"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Theme
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"
export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_compgen_path() {
    fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
    fd --type=d --hidden --exclude .git . "$1"
}

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}

source ~/fzf-git.sh/fzf-git.sh

# ─── CLI TOOLS (bat, eza, zoxide) ─────────────────────────────────────────────
export BAT_THEME=tokyonight_night
eval "$(zoxide init zsh)"

# ─── PACKAGE MANAGERS (pnpm, cargo) ───────────────────────────────────────────
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
export PATH="$HOME/.cargo/bin:$PATH"

# ─── EMACS ────────────────────────────────────────────────────────────────────
export PATH="$HOME/.emacs.d/bin:$PATH"
export LIBRARY_PATH="/opt/homebrew/lib/gcc/current:$LIBRARY_PATH"
alias e="/opt/homebrew/opt/emacs-plus@30/bin/emacsclient -t -a ''"

# ─── ALIASES ──────────────────────────────────────────────────────────────────
# Navigation
alias ..="cd .."
alias ...="cd ../.."

# Git (extending oh-my-zsh git plugin)
alias gcom="git checkout main"
alias gdc="git diff --cached"
alias gca="git commit --amend"
alias gcan="git commit --amend --no-edit"
alias lg="lazygit"

# Claude
alias cc="claude ."

# Direnv
alias da="direnv allow"

# Devbox
alias dsu="devbox services up"
alias dsh="devbox shell"

# pnpm
alias ptu="pnpm test -- -u"
alias plw="pnpm lint --write"

# Python (ruff)
alias rf="ruff format"
alias rcf="ruff check --fix"

# ─── P10K CONFIG ──────────────────────────────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ─── MACHINE-SPECIFIC ─────────────────────────────────────────────────────────
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
export PATH="$HOME/.local/bin:$PATH"

# The next line was added by hotel, leave it at the bottom of this file
source /Users/thomas.ridge/.config/hotel/config.zsh

# ---  gopath
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/thomas.ridge/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# bun completions
[ -s "/Users/thomas.ridge/.bun/_bun" ] && source "/Users/thomas.ridge/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
