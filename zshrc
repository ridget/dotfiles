# ─── P10K INSTANT PROMPT ──────────────────────────────────────────────────────
# Must stay at the top. Anything requiring console input goes above this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ─── OH-MY-ZSH ───────────────────────────────────────────────────────────────
export ZSH="/Users/ridget/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
DEFAULT_USER="ridget"

# Homebrew completions (hardcoded to avoid subshell on every startup)
FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"
autoload -Uz compinit
compinit

plugins=(git brew macos zsh-autosuggestions zsh-syntax-highlighting web-search z)

source $ZSH/oh-my-zsh.sh

# ─── SECRETS & TOKENS ─────────────────────────────────────────────────────────
[[ -f ~/.secrets ]] && source ~/.secrets

# ─── EDITOR ───────────────────────────────────────────────────────────────────
alias vim="$HOMEBREW_PREFIX/opt/neovim/bin/nvim"
alias nvim="$HOMEBREW_PREFIX/opt/neovim/bin/nvim"
export VISUAL=vim
export EDITOR="$VISUAL"

# ─── PATH ─────────────────────────────────────────────────────────────────────
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
export PATH="/opt/homebrew/opt/libxslt/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"

# ─── TOOLCHAIN (mise, direnv) ─────────────────────────────────────────────────
eval "$(/Users/ridget/.local/bin/mise activate zsh)"
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
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
eval "$(zoxide init zsh)"

# ─── PACKAGE MANAGERS (pnpm, cargo) ───────────────────────────────────────────
export PNPM_HOME="/Users/ridget/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
export PATH="$HOME/.cargo/bin:$PATH"

# ─── EMACS ────────────────────────────────────────────────────────────────────
export PATH="$HOME/.emacs.d/bin:$PATH"
export LIBRARY_PATH="/opt/homebrew/lib/gcc/current:$LIBRARY_PATH"
alias e="emacsclient -c -a ''"

# ─── ERLANG/ELIXIR (KERL) ─────────────────────────────────────────────────────
export KERL_BUILD_DOCS=yes
export KERL_INSTALL_MANPAGES=yes
export wxUSE_MACOSX_VERSION_MIN=11.3
export EGREP=egrep
export CC=clang
export CPP="clang -E"
export KERL_USE_AUTOCONF=0
export KERL_CONFIGURE_OPTIONS="--disable-debug \
                               --disable-hipe \
                               --disable-sctp \
                               --disable-silent-rules \
                               --enable-darwin-64bit \
                               --enable-dynamic-ssl-lib \
                               --enable-kernel-poll \
                               --enable-shared-zlib \
                               --enable-smp-support \
                               --enable-threads \
                               --enable-wx \
                               --with-wx \
                               --enable-webview \
                               --with-ssl=/opt/local \
                               --with-wx-config=/opt/homebrew/bin/wx-config \
                               --without-javac \
                               --without-jinterface \
                               --without-odbc"

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

# Hotel (Culture Amp)
alias hsc="hotel services up cerbos"
alias hse="hotel setup ensure"

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
alias claude="$HOME/.local/bin/claude"
