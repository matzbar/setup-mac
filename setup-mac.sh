#!/usr/bin/env bash
#
# setup-mac.sh: configuração do terminal no Mac (Apple Silicon ou Intel)
# Acompanha o manual-terminal-mac.md
#
# Idempotente: pode ser executado mais de uma vez. Só instala ou altera o que falta.
# Antes de alterar um arquivo de configuração, cria um backup com data e hora.
#
# Uso:
#   chmod +x setup-mac.sh
#   ./setup-mac.sh
#
# Variáveis opcionais:
#   GIT_NAME="Seu Nome" GIT_EMAIL="voce@exemplo.com" ./setup-mac.sh
#   ASSUME_YES=1 ./setup-mac.sh     # responde "sim" às perguntas opcionais
#
# O que faz, em ordem:
#   1. Verifica as Command Line Tools
#   2. Instala ou atualiza o Homebrew
#   3. Avisa sobre conflito de PATH com o MacPorts (e oferece corrigir)
#   4. Instala git, gh, starship, plugins do zsh e a fonte JetBrains Mono Nerd Font
#   5. Configura a identidade do Git
#   6. Cria a chave SSH (se não existir), o ~/.ssh/config e carrega no Keychain
#   7. Faz o login no GitHub (gh auth login) se ainda não estiver logado
#   8. Cria o ~/.config/starship.toml (cores do esquema Roxo), se não existir
#   9. Adiciona o bloco do Starship e dos plugins ao ~/.zshrc
#  10. Instala o Claude Code, se não estiver instalado
#  11. Instala o Codex (OpenAI) pelo Homebrew, se não estiver instalado
#  12. Verifica o Docker e o VS Code (instala só o VS Code, se faltar)

set -euo pipefail

# ---------- Mensagens ----------
if [[ -t 1 ]]; then
  C_B=$'\033[1m'; C_G=$'\033[32m'; C_Y=$'\033[33m'; C_R=$'\033[31m'; C_0=$'\033[0m'
else
  C_B=""; C_G=""; C_Y=""; C_R=""; C_0=""
fi
info() { printf '\n%s==>%s %s\n' "$C_B" "$C_0" "$*"; }
ok()   { printf '%s  ✓%s %s\n' "$C_G" "$C_0" "$*"; }
warn() { printf '%s  !%s %s\n' "$C_Y" "$C_0" "$*"; }
die()  { printf '%s  ✗%s %s\n' "$C_R" "$C_0" "$*" >&2; exit 1; }

# ---------- Utilitários ----------
ask_yes() {
  [[ "${ASSUME_YES:-0}" == "1" ]] && return 0
  [[ -t 0 ]] || return 1
  local ans
  read -r -p "  ? $1 [s/N] " ans
  [[ "$ans" =~ ^[sSyY]$ ]]
}

# sed -i difere entre macOS (BSD) e Linux (GNU)
sed_inplace() {
  if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi
}

backup_file() {
  local f="$1" b
  [[ -f "$f" ]] || return 0
  b="$f.bak.$(date +%Y%m%d-%H%M%S)"
  cp "$f" "$b"
  ok "Backup criado: $b"
}

find_brew() {
  local b
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$b" ]]; then echo "$b"; return 0; fi
  done
  return 1
}

brew_formula() {
  local p
  for p in "$@"; do
    if brew list --formula "$p" >/dev/null 2>&1; then ok "$p já instalado"
    else info "Instalando $p"; brew install "$p"; fi
  done
}

brew_cask() {
  local p
  for p in "$@"; do
    if brew list --cask "$p" >/dev/null 2>&1; then ok "$p já instalado"
    else info "Instalando $p"; brew install --cask "$p"; fi
  done
}

# ---------- Etapas ----------
step_xcode() {
  info "1. Command Line Tools"
  if xcode-select -p >/dev/null 2>&1; then
    ok "Ferramentas de desenvolvimento: $(xcode-select -p)"
  else
    warn "Instalando as Command Line Tools (uma janela do macOS vai abrir)."
    xcode-select --install || true
    die "Conclua a instalação na janela do macOS e rode este script de novo."
  fi
}

step_homebrew() {
  info "2. Homebrew"
  local brew_bin
  if ! brew_bin="$(find_brew)"; then
    warn "Homebrew não encontrado. Instalando..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew_bin="$(find_brew)" || die "O Homebrew não foi instalado."
  fi
  eval "$("$brew_bin" shellenv)"
  ok "$(brew --version | head -n1)"

  touch "$HOME/.zprofile"
  if ! grep -q 'brew shellenv' "$HOME/.zprofile"; then
    printf '\neval "$(%s shellenv)"\n' "$brew_bin" >> "$HOME/.zprofile"
    ok "Homebrew adicionado ao ~/.zprofile"
  fi

  brew update >/dev/null && ok "Homebrew atualizado (brew update)"
  warn "Para atualizar os pacotes instalados, rode depois: brew upgrade"
}

step_macports() {
  info "3. Conflito de PATH com o MacPorts"
  local zp="$HOME/.zprofile"
  if grep -qE '^[[:space:]]*export PATH="/opt/local/bin' "$zp" 2>/dev/null; then
    warn "O ~/.zprofile coloca /opt/local/bin (MacPorts) no PATH, à frente do Homebrew."
    if ask_yes "Comentar essa linha? (com backup, reversível)"; then
      backup_file "$zp"
      sed_inplace '/\/opt\/local\/bin:\/opt\/local\/sbin/ s/^/# /' "$zp"
      ok "Linha do MacPorts comentada. Abra uma nova janela do Terminal para valer."
    else
      warn "Mantido. Veja a seção 8.1 do manual se o git ou o curl se comportarem de forma estranha."
    fi
  else
    ok "Nenhuma linha ativa do MacPorts no ~/.zprofile"
  fi
}

step_packages() {
  info "4. Pacotes (Homebrew)"
  brew_formula git gh starship zsh-autosuggestions zsh-syntax-highlighting
  brew_cask font-jetbrains-mono-nerd-font
  warn "Escolha a fonte no Terminal: Ajustes > Perfis > Texto > Fonte > JetBrainsMono Nerd Font."
}

step_git() {
  info "5. Identidade do Git"
  local name email
  name="$(git config --global user.name || true)"
  email="$(git config --global user.email || true)"

  if [[ -z "$name" ]]; then
    name="${GIT_NAME:-}"
    if [[ -z "$name" ]]; then
      [[ -t 0 ]] || die "Defina GIT_NAME=\"Seu Nome\" para configurar o Git sem terminal interativo."
      read -r -p "  Seu nome para os commits: " name
    fi
    git config --global user.name "$name"
  fi
  if [[ -z "$email" ]]; then
    email="${GIT_EMAIL:-}"
    if [[ -z "$email" ]]; then
      [[ -t 0 ]] || die "Defina GIT_EMAIL=\"voce@exemplo.com\" para configurar o Git sem terminal interativo."
      read -r -p "  Seu e-mail do GitHub: " email
    fi
    git config --global user.email "$email"
  fi
  if [[ -z "$(git config --global init.defaultBranch || true)" ]]; then
    git config --global init.defaultBranch main
  fi
  ok "Git: $(git config --global user.name) <$(git config --global user.email)>, branch padrão $(git config --global init.defaultBranch)"
}

step_ssh() {
  info "6. Chave SSH"
  local key="$HOME/.ssh/id_ed25519" cfg="$HOME/.ssh/config" email
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if [[ -f "$key" ]]; then
    ok "Chave existente (não será sobrescrita): $key"
  else
    email="$(git config --global user.email || true)"
    warn "Criando uma chave ed25519. Você pode definir uma senha (passphrase)."
    ssh-keygen -t ed25519 -C "$email" -f "$key"
  fi

  if grep -qs '^Host github.com' "$cfg"; then
    ok "~/.ssh/config já tem a entrada do github.com"
  else
    backup_file "$cfg"
    [[ -s "$cfg" ]] && printf '\n' >> "$cfg"
    cat >> "$cfg" <<'EOF'
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
    chmod 600 "$cfg"
    ok "~/.ssh/config atualizado"
  fi

  if ssh-add --apple-use-keychain "$key" >/dev/null 2>&1; then
    ok "Chave carregada no agente e no Keychain"
  else
    warn "Não consegui carregar a chave agora. Rode: ssh-add --apple-use-keychain $key"
  fi
}

step_github() {
  info "7. GitHub"
  local out
  if gh auth status >/dev/null 2>&1; then
    ok "gh já está autenticado"
  else
    warn "Abrindo o login do GitHub. Escolha: GitHub.com > SSH > enviar a chave pública > navegador."
    gh auth login
  fi
  out="$(ssh -T -o StrictHostKeyChecking=accept-new git@github.com 2>&1 || true)"
  if grep -q 'successfully authenticated' <<<"$out"; then
    ok "SSH com o GitHub funcionando"
  else
    warn "O SSH ainda não autenticou no GitHub: $out"
  fi
}

step_starship_config() {
  info "8. Configuração do Starship (cores do Roxo)"
  local cfg="$HOME/.config/starship.toml"
  mkdir -p "$HOME/.config"
  if [[ -f "$cfg" ]]; then
    ok "$cfg já existe (mantido, nada foi alterado)"
    return 0
  fi
  cat > "$cfg" <<'EOF'
add_newline = true
command_timeout = 1000

format = """
$directory$git_branch$git_status$nodejs$python$cmd_duration
$character"""

[directory]
style = "bold 117"
truncation_length = 3

[git_branch]
style = "bold 211"

[git_status]
style = "bold 211"

[nodejs]
style = "bold 141"

[python]
style = "bold 141"

[cmd_duration]
style = "244"

[character]
success_symbol = "[❯](bold 141)"
error_symbol = "[❯](bold 203)"
EOF
  ok "Criado $cfg"
}

step_zshrc() {
  info "9. ~/.zshrc"
  local rc="$HOME/.zshrc" begin='# >>> prompt moderno (starship) >>>'
  touch "$rc"
  if grep -qF "$begin" "$rc"; then
    ok "O bloco do Starship já está no ~/.zshrc"
    return 0
  fi
  backup_file "$rc"
  if grep -qF '# >>> prompt simples >>>' "$rc"; then
    sed_inplace '/# >>> prompt simples >>>/,/# <<< prompt simples <<</d' "$rc"
    ok "Bloco do prompt simples removido"
  fi
  cat >> "$rc" <<'EOF'

# >>> prompt moderno (starship) >>>
export CLICOLOR=1
alias ll='ls -lahG'

eval "$(starship init zsh)"

source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
# <<< prompt moderno (starship) <<<
EOF
  ok "Bloco do Starship e dos plugins adicionado ao ~/.zshrc"
}

step_claude() {
  info "10. Claude Code"
  if command -v claude >/dev/null 2>&1; then
    ok "Claude Code já instalado: $(claude --version 2>/dev/null | head -n1)"
  else
    warn "Instalando o Claude Code (instalador oficial)."
    curl -fsSL https://claude.ai/install.sh | bash
  fi
}

step_codex() {
  info "11. Codex (OpenAI)"
  if command -v codex >/dev/null 2>&1; then
    ok "Codex já instalado: $(codex --version 2>/dev/null | head -n1)"
    warn "Para atualizar: codex update (ou brew upgrade --cask codex)"
  else
    info "Instalando o Codex (Homebrew cask)"
    brew install --cask codex
  fi
}

step_extras() {
  info "12. Docker e VS Code"
  if command -v docker >/dev/null 2>&1 || [[ -d "/Applications/Docker.app" ]]; then
    ok "Docker encontrado"
  else
    warn "Docker Desktop não encontrado. Instale pelo site ou veja: brew search --cask docker"
  fi

  if command -v code >/dev/null 2>&1 || [[ -d "/Applications/Visual Studio Code.app" ]]; then
    ok "VS Code encontrado"
    command -v code >/dev/null 2>&1 || warn "Comando 'code' ausente: no VS Code, ⇧⌘P > Shell Command: Install 'code' command in PATH"
  else
    info "Instalando o VS Code"
    brew install --cask visual-studio-code
  fi
}

summary() {
  info "Resumo"
  printf '  %-14s %s\n' "Homebrew:" "$(brew --version | head -n1)"
  printf '  %-14s %s\n' "Git:" "$(git --version)"
  printf '  %-14s %s\n' "GitHub CLI:" "$(gh --version | head -n1)"
  printf '  %-14s %s\n' "Starship:" "$(starship --version | head -n1)"
  if command -v claude >/dev/null 2>&1; then
    printf '  %-14s %s\n' "Claude Code:" "$(claude --version 2>/dev/null | head -n1)"
  fi
  printf '\n'
  ok "Concluído. Abra uma nova janela do Terminal para ver o prompt novo."
  warn "Se os ícones aparecerem como quadradinhos, escolha a fonte JetBrainsMono Nerd Font no Terminal."
}

usage() {
  sed -n '2,29p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

main() {
  case "${1:-}" in
    -h|--help) usage; exit 0 ;;
  esac
  [[ "$(uname -s)" == "Darwin" ]] || die "Este script é para macOS."
  [[ "$(uname -m)" == "arm64" ]] || warn "Mac Intel detectado: o script deve funcionar, mas foi testado em Apple Silicon."

  step_xcode
  step_homebrew
  step_macports
  step_packages
  step_git
  step_ssh
  step_github
  step_starship_config
  step_zshrc
  step_claude
  step_codex
  step_extras
  summary
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
