# 🍎 Manual de Configuração do Terminal no Mac

> Guia passo a passo para deixar o terminal do Mac pronto para desenvolvimento: bonito, rápido e integrado com **Git/GitHub** e **Claude Code**.

**Última atualização:** 18/11/2026 (v1.2, concluído) · **Testado em:** macOS em Apple Silicon · **Shell:** zsh

---

## 📋 Índice

1. [Visão geral e checklist](#1--visão-geral-e-checklist)
2. [Base do sistema](#2--base-do-sistema)
3. [Terminal e aparência](#3--terminal-e-aparência)
4. [Git e GitHub](#4--git-e-github)
5. [Claude Code](#5--claude-code)
6. [Linguagens e ferramentas](#6--linguagens-e-ferramentas)
7. [Script de instalação automática](#7--script-de-instalação-automática)
8. [Solução de problemas](#8--solução-de-problemas)
9. [Referências](#9--referências)

---

## 1. 🧭 Visão geral e checklist

Ordem recomendada. Cada etapa depende da anterior.

| # | Etapa | Tempo | Status |
|---|-------|-------|--------|
| 1 | Xcode Command Line Tools (2.1) | ~5 min | ✅ |
| 2 | Homebrew: verificar, instalar ou atualizar (2.2) | ~3 min | ✅ |
| 3 | Xcode: verificar versão e atualizar via `mas` (2.3) | variável | ✅ |
| 4a | Terminal: prompt simples com cores (Roxo) (3.1) | ~5 min | ✅ |
| 4b | Terminal: visual moderno com Starship, Roxo (3.2 a 3.4) | ~10 min | ✅ |
| 5 | Git + GitHub (SSH e `gh`) (seção 4) | ~10 min | ✅ |
| 6 | Claude Code (seção 5) | ~5 min | ✅ |
| 7 | Linguagens e extras: Node, Python, Docker, VS Code (seção 6) | variável | ✅ |

> 💡 **Legenda dos blocos neste manual**
> - 💻 Comando para colar no terminal
> - ✅ Como verificar se deu certo
> - ⚠️ Atenção / erro comum

### 📍 Onde paramos (para retomar depois)

| Item | Estado |
|------|--------|
| Xcode 27.2, Homebrew 7.0.14, `mas` 7.0.0 | ✅ Atualizados, `brew doctor` sem avisos |
| MacPorts quebrado no PATH | ✅ Linha desativada no `~/.zprofile` (ver 8.1). O Git do Homebrew vem primeiro |
| Claude Code 2.1.327 | ✅ Instalado (nativo), atualizações automáticas, `claude doctor` sem problemas |
| Git: nome, e-mail, branch `main`, cores | ✅ Configurados |
| `gh` 2.105.0 | ✅ Instalado |
| Chave SSH `id_ed25519`, `~/.ssh/config`, Keychain e login no GitHub | ✅ Configurados; `ssh -T git@github.com` autentica |
| Prompt Roxo | Escolhido: 141 · 117 · 211 |
| Visual moderno (Starship 1.27.0, JetBrains Mono Nerd Font, plugins) | ✅ Aplicado e funcionando (seção 3.2 a 3.4) |

**Para retomar:** o manual está completo e todas as etapas foram verificadas neste Mac. Resta, opcionalmente, rodar o script da seção 7 (`setup-mac.sh`), que já foi gerado mas ainda não foi executado, e guardar uma cópia deste manual. Backups feitos até aqui: `~/.zshrc.bak`, `~/.zshrc.bak2`, `~/.zshrc.bak3`, `~/.zprofile.bak`.

---

## 2. 🧱 Base do sistema

### 2.1 Xcode Command Line Tools

Instala compiladores e o `git` básico que o Homebrew exige.

💻
```bash
xcode-select --install
```

✅ Verificar:
```bash
xcode-select -p
# esperado: /Library/Developer/CommandLineTools
# ou /Applications/Xcode.app/Contents/Developer (se o Xcode completo estiver instalado)
```

> 💡 Se o comando `xcode-select --install` responder que as ferramentas **já estão instaladas**, pode pular esta etapa. Para atualizar, use *Ajustes do Sistema → Geral → Atualização de Software*.

**📝 Retornos esperados**

| Comando | Situação | Retorno |
|---------|----------|---------|
| `xcode-select --install` | Já instalado | `xcode-select: note: Command line tools are already installed. Use "Software Update" in System Settings or the softwareupdate command line interface to install updates` → **pode pular** |
| `xcode-select --install` | Não instalado | Abre uma janela do macOS pedindo para instalar → clique em *Instalar* e aguarde |
| `xcode-select -p` | Só Command Line Tools | `/Library/Developer/CommandLineTools` |
| `xcode-select -p` | Xcode completo instalado | `/Applications/Xcode.app/Contents/Developer` ✅ *(retorno real deste Mac)* |

> Qualquer um dos dois caminhos de `xcode-select -p` está correto. O Xcode completo já inclui as Command Line Tools.

### 2.2 Homebrew

Gerenciador de pacotes do macOS. Base para quase tudo que vem depois (inclusive o `mas`, usado na seção 2.3).

#### Passo A: verificar se já está instalado e qual versão

💻
```bash
command -v brew && brew --version || echo "Homebrew NÃO instalado"
```

- Mostrou o caminho e a versão → **já instalado**, vá para o **Passo C (atualizar)**.
- Mostrou `Homebrew NÃO instalado` → vá para o **Passo B (instalar)**.

📝 **Retorno esperado (instalado):** o caminho do `brew` (em Apple Silicon: `/opt/homebrew/bin/brew`) e a linha da versão, por exemplo `Homebrew 7.0.14` ✅ *(versão real deste Mac; a sua pode ser mais nova)*.

#### Passo B: instalar (somente se não estiver instalado)

💻
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

⚠️ **Apple Silicon (M1/M2/M3/M4):** ao final, o instalador mostra comandos para adicionar o brew ao PATH ("Next steps"). Normalmente:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

> **Mac Intel:** o brew fica em `/usr/local/bin` e normalmente já está no PATH, então esse ajuste costuma não ser necessário.

#### Passo C: atualizar (somente se já estiver instalado)

💻
```bash
brew update      # atualiza o próprio Homebrew e a lista de pacotes
brew upgrade     # atualiza os pacotes já instalados
brew cleanup     # remove versões antigas
```

📝 **Retornos esperados**

| Comando | Retorno | Significado |
|---------|---------|-------------|
| `brew update` | `Already up-to-date.` ✅ *(real)* | Homebrew e lista de pacotes já atualizados |
| `brew update` | `Updated N taps...` e lista de fórmulas novas | Atualizou agora; é normal |
| `brew upgrade` | Sem saída | Nenhum pacote para atualizar |
| `brew upgrade` | Lista de pacotes sendo baixados e instalados | Pode demorar alguns minutos |
| `brew cleanup` | Sem saída, ou lista do que foi removido | Limpeza de versões antigas |

> 💡 Os comandos podem ser encadeados: `brew update && brew upgrade && brew cleanup`. O `&&` só avança se o anterior der certo.

#### Passo D: verificar a saúde da instalação

✅
```bash
brew --version
brew doctor
```

📝 **Retorno esperado:** `Your system is ready to brew.` ✅ *(retorno real deste Mac)*

⚠️ Se aparecer `Warning:`, leia a mensagem inteira. Muitos avisos são só informativos, mas os de **PATH** ou **permissões** devem ser corrigidos antes de seguir.

### 2.3 Xcode: verificar versão e atualizar

> ⚠️ **Requer o Homebrew (seção 2.2) concluído**, pois o `mas` é instalado por ele.
> Esta etapa só vale se você usa o **Xcode completo**. Para Git, Node, Python e Claude Code, as Command Line Tools (2.1) já bastam.

#### Passo A: ver a versão instalada

💻
```bash
xcodebuild -version
```

📝 **Retorno esperado:** duas linhas, a versão e o build. Exemplo real deste Mac ✅:

```
Xcode 27.2
Build version 27B52
```

#### Passo B: instalar o `mas` (Mac App Store CLI), se necessário

💻
```bash
command -v mas && mas version || brew install mas
```

📝 **Retornos esperados**
- **Já instalado:** o caminho e a versão. Em Apple Silicon o caminho é `/opt/homebrew/bin/mas` (atenção ao `/bin/`), e a versão foi `7.0.0` ✅ *(real)*.
- **Não instalado:** o `brew install mas` roda e instala. Depois, confirme com `mas version`.

> ⚠️ **Cuidado com `||` e `&&`:** `command -v mas || mas version` para no primeiro comando se ele funcionar, então a versão nem é exibida. Por isso o roteiro usa `&&` antes de `mas version`.

#### Passo C: verificar se há atualização

💻
```bash
mas outdated
```

- O Xcode aparece na lista → há atualização (mostra a versão instalada e a nova). Vá para o Passo D.
- O Xcode **não** aparece → está atualizado. Pule o Passo D.

📝 **Retorno real deste Mac ✅:** a lista trouxe apenas dois apps da Microsoft, e **não** o Xcode → Xcode 27.2 atualizado. Apps de outras empresas na lista não afetam esta configuração. Para atualizá-los: `mas upgrade` (todos) ou pela App Store.

> `mas` exige estar logado na App Store. Se tiver dúvida, abra a App Store uma vez para confirmar o login.

#### Passo D: atualizar (se houver atualização)

💻
```bash
mas upgrade 497799835    # 497799835 = ID do Xcode na App Store
```

⚠️ O download é grande (vários GB). Use boa conexão e tenha espaço livre.

#### Passo E: finalizar

💻
```bash
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch
xcodebuild -version
```

⚠️ **Observações**
- Cada versão do Xcode exige um macOS mínimo. Se o `mas outdated` não mostrar o Xcode, talvez seja preciso atualizar o macOS antes (`softwareupdate --list`).
- Se o Xcode não veio da App Store, o `mas` não o enxerga. Alternativa: `brew install xcodesorg/made/xcodes`, depois `xcodes installed` e `xcodes list` (pede Apple ID).

---

## 3. 🎨 Terminal e aparência

> **Terminal usado:** Terminal padrão do macOS, com **zsh**.
> Duas opções de visual: **A (simples)**, sem instalar nada, e **B (moderna)**, opcional, para depois (seções 3.2 a 3.6).

### 3.0 Diagnóstico antes de configurar

💻
```bash
echo $SHELL
cat ~/.zshrc
cp ~/.zshrc ~/.zshrc.bak
```

📝 **Retornos esperados**

| Comando | Retorno | Significado |
|---------|---------|-------------|
| `echo $SHELL` | `/bin/zsh` ✅ *(real)* | O shell é o zsh, então o arquivo de configuração é o `~/.zshrc` |
| `cat ~/.zshrc` | `export PATH="$HOME/.local/bin:$PATH"` ✅ *(real)* | Só uma linha, que coloca `~/.local/bin` no PATH. É onde ferramentas como o Claude Code costumam se instalar |
| `cp ~/.zshrc ~/.zshrc.bak` | Sem saída | Backup criado. Para desfazer qualquer mudança: `cp ~/.zshrc.bak ~/.zshrc` |

⚠️ Se o seu `~/.zshrc` tiver tokens ou chaves de API, não cole o conteúdo em lugares públicos.

### 3.1 Opção A: prompt simples (sem instalar nada)

Mostra usuário, pasta e branch do Git, com cores à sua escolha. Também ativa cores no `ls` e cria o atalho `ll`.

Exemplo do visual: `usuario ~/projetos/meu-projeto (main) %`

#### Passo A: escolher o esquema de cores

O prompt usa **códigos de cor de 0 a 255**, que ficam iguais em qualquer tema do Terminal. (As cores com nome, como `green`, mudam conforme o tema, e por isso podem parecer sem graça.)

| # | Esquema | Usuário | Pasta | Git | Estilo |
|---|---------|---------|-------|-----|--------|
| 1 | **Oceano** | `45` | `111` | `222` | Ciano, azul claro e areia |
| 2 | **Pôr do sol** | `209` | `215` | `211` | Laranja, âmbar e rosa |
| 3 | **Roxo** ⭐ *(escolhido)* | `141` | `117` | `211` | Lilás, azul claro e rosa |
| 4 | **Menta suave** | `114` | `110` | `180` | Verde suave, azul e bege |
| 5 | **Nord** | `109` | `110` | `150` | Tons frios e acinzentados |

> 💡 As cores exatas variam um pouco conforme o tema e o monitor. Para ver a paleta completa e escolher outros números, cole no Terminal:
>
> ```zsh
> for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i} $i%f  "; (( (i+1) % 8 == 0 )) && echo; done
> ```

#### Passo B: testar sem salvar

Cole no Terminal. Vale só para essa janela; ao fechá-la, tudo volta ao normal. Os números abaixo são do esquema 3 (**Roxo**), o escolhido neste manual; para outro visual, troque pelos números do esquema desejado.

💻
```zsh
PROMPT_COR_USER=141
PROMPT_COR_PASTA=117
PROMPT_COR_GIT=211

autoload -Uz vcs_info
setopt prompt_subst
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
PROMPT='%F{$PROMPT_COR_USER}%n%f %F{$PROMPT_COR_PASTA}%~%f%F{$PROMPT_COR_GIT}${vcs_info_msg_0_}%f %# '
export CLICOLOR=1
alias ll='ls -lahG'
```

📝 **Esperado:** o prompt muda para `usuario pasta %` com as cores escolhidas. Dentro de uma pasta com repositório Git, aparece também a branch, como ` (main)` ✅ *(funcionou neste Mac)*.

#### Passo C: salvar de forma permanente (primeira vez)

💻
```bash
cp ~/.zshrc ~/.zshrc.bak
cat >> ~/.zshrc <<'EOF'

# >>> prompt simples >>>
# Cores do prompt (0-255). Troque os 3 números para mudar o visual.
PROMPT_COR_USER=141
PROMPT_COR_PASTA=117
PROMPT_COR_GIT=211

autoload -Uz vcs_info
setopt prompt_subst
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
PROMPT='%F{$PROMPT_COR_USER}%n%f %F{$PROMPT_COR_PASTA}%~%f%F{$PROMPT_COR_GIT}${vcs_info_msg_0_}%f %# '
export CLICOLOR=1
alias ll='ls -lahG'
# <<< prompt simples <<<
EOF

source ~/.zshrc
```

✅ Verificar: abra uma nova janela do Terminal. O prompt colorido deve aparecer sem precisar colar nada.

#### Passo D: trocar de esquema depois

**Jeito rápido:** abra o arquivo, troque os 3 números das variáveis `PROMPT_COR_*` e recarregue.

```bash
nano ~/.zshrc        # salvar: Ctrl+O, Enter; sair: Ctrl+X
source ~/.zshrc
```

**Se você salvou antes a versão antiga** (com `green`, `blue` e `yellow`), substitua o bloco inteiro:

```bash
cp ~/.zshrc ~/.zshrc.bak2
sed -i '' '/# >>> prompt simples >>>/,/# <<< prompt simples <<</d' ~/.zshrc
```

Depois repita o `cat >> ~/.zshrc` do Passo C com os números do novo esquema.

#### Voltar atrás

```bash
cp ~/.zshrc.bak ~/.zshrc && source ~/.zshrc
```

#### Tema e fonte do Terminal

**Tema (fundo e cores gerais):** *Terminal → Ajustes (⌘,) → Perfis*. Temas prontos: **Pro**, **Ocean**, **Homebrew**, **Red Sands**, **Novel**. Clique para ver o efeito e em **Padrão** para fixar. Há também temas da comunidade (Catppuccin, Dracula, Nord) em arquivos `.terminal`, que se importam pelo menu **⋯ → Importar**. Confira a origem antes de importar.

**Fonte:** *Perfis → Texto → Fonte → Alterar…*
- Sem instalar nada: **SF Mono** (tamanho 13 ou 14) ou **Menlo**.
- Instalando **JetBrains Mono** com ícones (serve também para a Opção B):

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

Se o brew não achar o nome, use `brew search jetbrains`. Na lista de fontes, digite "JetBrains" na busca.

---

## Opção B: visual moderno com Starship (cores do Roxo)

> 📍 **Status:** ✅ aplicado e funcionando neste Mac (Starship 1.27.0, `zsh-autosuggestions` 0.7.1, `zsh-syntax-highlighting` 0.8.0). Substitui o prompt simples da Opção A.
> **Pré-requisito:** o Terminal precisa usar uma fonte Nerd Font (3.2), senão os ícones aparecem como quadradinhos.

### 3.2 Fonte com ícones (Nerd Font)

💻
```bash
brew install --cask font-jetbrains-mono-nerd-font
```

Depois, no Terminal: **Ajustes (⌘,) → Perfis → Texto → Fonte → Alterar…**, digite "JetBrains" na busca e escolha **JetBrainsMono Nerd Font**, tamanho 13 ou 14.

> Se o brew não achar o nome, use `brew search jetbrains`. Alternativa: `font-meslo-lg-nerd-font` (escolher `MesloLGS Nerd Font`).

### 3.3 Starship com as cores do Roxo

#### Passo A: instalar Starship e plugins

💻
```bash
command -v starship && starship --version || echo "Starship NÃO instalado"
brew install starship zsh-autosuggestions zsh-syntax-highlighting
```

O Homebrew pula o que já estiver instalado.

#### Passo B: criar a configuração `~/.config/starship.toml`

💻
```bash
mkdir -p ~/.config
[ -f ~/.config/starship.toml ] && cp ~/.config/starship.toml ~/.config/starship.toml.bak
cat > ~/.config/starship.toml <<'EOF'
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
```

📝 Cores (códigos 0-255): lilás `141` (Node, Python e o `❯`), azul claro `117` (pasta), rosa `211` (Git), cinza `244` (duração) e vermelho `203` (o `❯` quando o último comando falha).

#### Passo C: ativar no `~/.zshrc` (substitui o prompt simples)

💻
```bash
cp ~/.zshrc ~/.zshrc.bak3
sed -i '' '/# >>> prompt simples >>>/,/# <<< prompt simples <<</d' ~/.zshrc
cat >> ~/.zshrc <<'EOF'

# >>> prompt moderno (starship) >>>
export CLICOLOR=1
alias ll='ls -lahG'

eval "$(starship init zsh)"

source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
# <<< prompt moderno (starship) <<<
EOF
source ~/.zshrc
```

⚠️ A ordem importa: o `zsh-syntax-highlighting` deve ser o último.

#### Passo D: verificar

Abra uma **nova janela** do Terminal e entre numa pasta com repositório Git:

```bash
cd ~/Desktop/meu-projeto
```

📝 **Esperado:** uma linha com pasta e branch (com ícones) e o `❯` lilás na linha de baixo. Ao digitar, sugestões em cinza aparecem (aceite com →). ✅ *Confirmado neste Mac.*

> Retorno real do Passo A: `/opt/homebrew/bin/starship` e `starship 1.27.0`. Os avisos `Warning: ... is already installed and up-to-date` do `brew install` são só informativos.

#### Voltar atrás

```bash
cp ~/.zshrc.bak3 ~/.zshrc && source ~/.zshrc
```

### 3.4 Plugins do zsh

Já instalados e ativados no Passo A e no Passo C da seção 3.3:

| Plugin | O que faz |
|--------|-----------|
| `zsh-autosuggestions` | Sugere comandos em cinza enquanto você digita; a seta → aceita |
| `zsh-syntax-highlighting` | Colore o comando digitado (válido e inválido em cores diferentes) |

### 3.5 Ferramentas de linha de comando que melhoram o dia a dia

| Ferramenta | Substitui | Instalar |
|------------|-----------|----------|
| `eza` | `ls` | `brew install eza` |
| `bat` | `cat` | `brew install bat` |
| `ripgrep` | `grep` | `brew install ripgrep` |
| `fzf` | busca interativa | `brew install fzf` |
| `jq` | leitura de JSON | `brew install jq` |

Aliases sugeridos (colar no `~/.zshrc`):

```bash
alias ls="eza --icons"
alias ll="eza -l --icons --git"
alias cat="bat"
```

### 3.6 (Opcional) iTerm2

💻
```bash
brew install --cask iterm2
```

---

## 4. 🐙 Git e GitHub

> 📍 **Estado neste Mac:** identidade do Git ✅ · branch `main` ✅ · `gh` 2.105.0 ✅ · chave SSH criada ✅.
> ✅ **Concluído:** `~/.ssh/config` criado, chave carregada no Keychain e cadastrada no GitHub com `gh auth login`.

### 4.1 Verificar o que já existe

💻
```bash
command -v git && git --version
command -v gh && gh --version || echo "gh NÃO instalado"
git config --global --list
ls ~/.ssh
```

📝 **Retornos esperados**

| Comando | Retorno | Significado |
|---------|---------|-------------|
| `command -v git` | `/opt/homebrew/bin/git` ✅ *(real)* | Git do Homebrew em primeiro lugar (ver 8.1 se aparecer `/opt/local`) |
| `gh --version` | `gh version 2.105.0` ✅ *(real)* | GitHub CLI instalado |
| `git config --global --list` | `user.name`, `user.email`, `init.defaultbranch=main` e `color.*` ✅ *(real)* | Identidade e padrões já configurados |
| `ls ~/.ssh` | `id_ed25519  id_ed25519.pub  known_hosts` ✅ *(real)* | Já existe uma chave SSH |

Se algo faltar: `brew install git gh`.

### 4.2 Identidade e padrões (só se ainda não estiverem configurados)

💻 *(troque pelo seu nome e e-mail do GitHub)*
```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu-email@exemplo.com"
git config --global init.defaultBranch main
```

Opcionais:

```bash
git config --global pull.rebase false
git config --global core.editor "nano"
```

### 4.3 Chave SSH

**Passo A: verificar se já existe** (`ls ~/.ssh`, no 4.1). Se aparecer `id_ed25519` e `id_ed25519.pub`, **pule o Passo B**.

**Passo B: criar, somente se não existir**

💻
```bash
ssh-keygen -t ed25519 -C "seu-email@exemplo.com"
```

⚠️ **Não rode isso se a chave já existe:** com o mesmo nome, ela seria sobrescrita. Pressione Enter para aceitar o caminho padrão e defina uma senha (passphrase) se quiser.

> A `id_ed25519.pub` (pública) pode ser mostrada. **Nunca** compartilhe a `id_ed25519` (privada).

### 4.4 Configurar o SSH e o Keychain do Mac

**Diagnóstico**

💻
```bash
ssh -T git@github.com
ssh-add -l
ls -la ~/.ssh/config
```

📝 **Retorno deste Mac, antes da configuração ⏳**

```
git@github.com: Permission denied (publickey).
The agent has no identities.
ls: /Users/<usuario>/.ssh/config: No such file or directory
```

| Saída | Significado |
|-------|-------------|
| `Permission denied (publickey)` | O GitHub não reconhece a chave: ela não está cadastrada na conta |
| `The agent has no identities` | Nenhuma chave carregada no agente SSH |
| `No such file or directory` | Não há `~/.ssh/config` |

**Criar o `~/.ssh/config`** (só se o arquivo não existir; se existir, acrescente o bloco com `>>`):

💻
```bash
cat > ~/.ssh/config <<'EOF'
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
chmod 600 ~/.ssh/config
```

**Carregar a chave no agente e no Keychain**

💻
```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
ssh-add -l
```

📝 **Esperado:** o `ssh-add -l` lista a chave (`256 SHA256:... (ED25519)`). Se a chave tiver senha, ela é pedida uma vez.

✅ **Retorno real deste Mac:**

```
Identity added: /Users/<usuario>/.ssh/id_ed25519 (seu-email@exemplo.com)
256 SHA256:... seu-email@exemplo.com (ED25519)
```

### 4.5 Login no GitHub via `gh` (cadastra a chave)

💻
```bash
gh auth login
```

Respostas:

| Pergunta | Resposta |
|----------|----------|
| Where do you use GitHub? | `GitHub.com` |
| Preferred protocol for Git operations? | `SSH` |
| Upload your SSH public key to your GitHub account? | `~/.ssh/id_ed25519.pub` |
| How would you like to authenticate? | `Login with a web browser` (copie o código de uso único e entre na conta) |

⚠️ Se o GitHub disser **`Key is already in use`**, a chave está cadastrada em **outra conta**. Gere uma chave nova só para esta conta (por exemplo `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github2`) e ajuste o `IdentityFile` no `~/.ssh/config`.

### 4.6 Verificar

✅
```bash
gh auth status
ssh -T git@github.com
```

📝 **Esperado**

```
✓ Logged in to github.com account seu-usuario
Hi seu-usuario! You've successfully authenticated, but GitHub does not provide shell access.
```

O aviso do `ssh -T` ("does not provide shell access") é normal.

✅ **Retorno real deste Mac, depois do `gh auth login`:** `Hi <usuario>! You've successfully authenticated, but GitHub does not provide shell access.` Antes do login, o mesmo comando dava `Permission denied (publickey)`.

### 4.7 Primeiro teste

```bash
gh repo clone usuario/repositorio
```

⚠️ **Erro comum:** `Permission denied (publickey)` → a chave não foi cadastrada. Rode `gh ssh-key add ~/.ssh/id_ed25519.pub`.

---

## 5. 🤖 Claude Code

Assistente de código da Anthropic que roda direto no terminal.

### 5.1 Verificar, instalar ou atualizar

#### Passo A: verificar se já está instalado e qual versão

💻
```bash
command -v claude && claude --version || echo "Claude Code NÃO instalado"
```

📝 **Retorno esperado (instalado):** o caminho e a versão. Exemplo real deste Mac ✅:

```
/Users/<usuario>/.local/bin/claude
2.1.327 (Claude Code)
```

- Mostrou caminho e versão → **já instalado**, vá para o **Passo C**.
- Mostrou `Claude Code NÃO instalado` → vá para o **Passo B**.

> 💡 O caminho `~/.local/bin` é o do instalador nativo. É por isso que o `~/.zshrc` pode ter a linha `export PATH="$HOME/.local/bin:$PATH"`.

#### Passo B: instalar (somente se não estiver instalado)

💻
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

> Alternativa via Homebrew: `brew install --cask claude-code`
> Confirme o método atual de instalação na documentação oficial (seção Referências).

⚠️ Depois de instalar, abra uma nova janela do Terminal e repita o Passo A.

#### Passo C: atualizar (se já estiver instalado)

💻
```bash
claude update
```

📝 Com as atualizações automáticas ativas, isso costuma indicar que você já está na versão mais recente. Para ver se elas estão ativas, use o `claude doctor` (Passo D).

#### Passo D: diagnóstico

💻
```bash
claude doctor
```

📝 **Retorno esperado:** um resumo da instalação. Exemplo real deste Mac ✅:

```
Running: native (2.1.327)
Platform: darwin-arm64
Config install method: native
Auto-updates: enabled
Auto-update channel: latest
✔ No installation issues found.
```

| Linha | Significado |
|-------|-------------|
| `Running: native` / `Config install method: native` | Instalado pelo instalador nativo |
| `Auto-updates: enabled` | Atualiza sozinho em segundo plano |
| `Auto-update channel: latest` | Recebe sempre a versão mais recente |
| `✔ No installation issues found.` | Nenhum problema encontrado |

⚠️ Se aparecer aviso de PATH ou de mais de uma instalação do `claude`, resolva antes de seguir. Mantenha uma só.

### 5.2 Primeiro uso e login

```bash
cd ~/caminho/do/seu/projeto
claude
```

Na primeira execução ele abre o navegador para você entrar com sua conta Claude.

✅ Verificar:
```bash
claude --version
claude doctor
```

### 5.3 Boas práticas

- Crie um arquivo `CLAUDE.md` na raiz do projeto com convenções, comandos de build/teste e contexto. O Claude lê automaticamente.
- Use dentro de um repositório Git, assim você revisa e reverte mudanças com facilidade.
- Comandos úteis dentro da sessão: `/help`, `/clear`, `/init` (gera um `CLAUDE.md` inicial).

---

## 6. 🧰 Linguagens e ferramentas

| Ferramenta | Estado neste Mac | Como verificar |
|------------|------------------|----------------|
| Node.js 24 (`node@24`, Homebrew) | ✅ Instalado | `node --version` |
| Python 3.12 (`python@3.12`, Homebrew) | ✅ Instalado | `python3 --version` |
| Docker Desktop | ✅ Verificado: Docker 29.9.3, Compose v5.7.0, `hello-world` OK | `docker --version` |
| VS Code | ✅ Verificado: 1.147.0 (arm64), comando `code` em `/usr/local/bin` | `code --version` |
| Gerenciador de versões (`fnm`, `uv`) | Não usa. Opcional (6.4) | |

> 📝 **Retornos reais:** Docker (6.2) e VS Code (6.3) verificados neste Mac.

### 6.1 Node.js e Python (Homebrew)

Neste Mac, os dois são "keg-only" do Homebrew: não entram no PATH sozinhos. O `~/.zprofile` tem estas linhas:

```bash
export PATH="/opt/homebrew/opt/node@24/bin:$PATH"
export PATH="/opt/homebrew/opt/python@3.12/libexec/bin:$PATH"
```

✅ Verificar:
```bash
which -a node python3
node --version
python3 --version
```

📝 **Esperado:** o primeiro `node` em `/opt/homebrew/opt/node@24/bin/node` e o primeiro `python3` em `/opt/homebrew/opt/python@3.12/libexec/bin/python3` (já confirmado neste Mac ✅).

### 6.2 Docker Desktop

✅ Verificar:
```bash
docker --version
docker compose version
docker run --rm hello-world
```

📝 **Esperado:** as versões do Docker e do Compose e, no `hello-world`, a mensagem `Hello from Docker!`.

✅ **Retornos reais deste Mac:**

```
Docker version 29.9.3, build 5457199
Docker Compose version v5.7.0
...
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

Na primeira vez, o `hello-world` baixa a imagem (`Unable to find image 'hello-world:latest' locally` e `Pull complete`). Isso é normal e só acontece uma vez. A linha `(arm64v8)` confirma a imagem para Apple Silicon.

⚠️ O comando `docker` só funciona com o **Docker Desktop aberto**. Se aparecer `Cannot connect to the Docker daemon`, abra o aplicativo e espere o ícone da baleia parar de animar.

Para instalar, se faltar: `brew search --cask docker` mostra o nome atual do pacote (hoje costuma ser `docker-desktop`) e `brew install --cask <nome>` instala. O instalador do Docker Desktop adiciona o PATH dele ao `~/.zprofile` (`~/.docker/bin`).

### 6.3 VS Code

✅ Verificar:
```bash
command -v code && code --version
```

- Mostrou o caminho e a versão → o comando `code` está disponível.

✅ **Retorno real deste Mac:**

```
/usr/local/bin/code
1.147.0
8a14f0cc1b08d531eb83255ea3764ae22aa932b5
arm64
```

O caminho `/usr/local/bin/code` indica que o comando foi criado pelo **Shell Command** do próprio VS Code (instalação feita pelo site, não pelo Homebrew). As três linhas depois do caminho são a versão, o identificador do build e a arquitetura (`arm64` = Apple Silicon).

- Não mostrou nada, mas o app existe → abra o VS Code, pressione `⇧⌘P` e rode **Shell Command: Install 'code' command in PATH**.

Para instalar, se faltar:

```bash
brew install --cask visual-studio-code
```

⚠️ Se você instalou o VS Code baixando do site, **não** rode o `brew install --cask`: o Homebrew reclama que o app já existe em `/Applications`.

### 6.4 Gerenciador de versões (opcional, não instalado)

Não é necessário agora: o Homebrew já fornece Node 24 e Python 3.12. Vale considerar quando você precisar de **versões diferentes por projeto**:

| Para | Ferramenta | Instalar |
|------|------------|----------|
| Node.js | `fnm` | `brew install fnm` |
| Python | `uv` | `brew install uv` |

Exemplo de uso:

```bash
# fnm: adicionar ao ~/.zshrc
eval "$(fnm env --use-on-cd --shell zsh)"
fnm install 24

# uv
uv python install 3.12
```

⚠️ Se adotar o `fnm`, remova do `~/.zprofile` a linha do `node@24`, para não haver duas fontes de Node no PATH.

---

## 7. ⚙️ Script de instalação automática

O arquivo **`setup-mac.sh`** (entregue junto com este manual) reúne as etapas confirmadas neste Mac. Ele é **idempotente**: pode ser executado mais de uma vez e só instala ou altera o que falta. Antes de mexer em um arquivo de configuração, cria um backup com data e hora (`.bak.AAAAMMDD-HHMMSS`).

💻
```bash
chmod +x setup-mac.sh
./setup-mac.sh
```

Para configurar o Git sem perguntas, ou aceitar as perguntas opcionais automaticamente:

```bash
GIT_NAME="Seu Nome" GIT_EMAIL="voce@exemplo.com" ./setup-mac.sh
ASSUME_YES=1 ./setup-mac.sh
```

| Etapa do script | Seção do manual | O que faz |
|-----------------|-----------------|-----------|
| 1. Command Line Tools | 2.1 | Verifica; se faltar, abre o instalador do macOS e pede para rodar de novo |
| 2. Homebrew | 2.2 | Instala se faltar, garante o `brew shellenv` no `~/.zprofile` e roda `brew update` |
| 3. MacPorts | 8.1 | Se achar a linha ativa no `~/.zprofile`, pergunta antes de comentá-la |
| 4. Pacotes | 3.2, 3.3 | `git`, `gh`, `starship`, os dois plugins do zsh e a fonte JetBrains Mono Nerd Font |
| 5. Git | 4.2 | Define nome, e-mail e branch `main`, **só se ainda não estiverem definidos** |
| 6. Chave SSH | 4.3, 4.4 | Usa a chave existente (nunca sobrescreve), cria o `~/.ssh/config` e carrega no Keychain |
| 7. GitHub | 4.5, 4.6 | Roda `gh auth login` só se não estiver logado e testa o `ssh -T` |
| 8. Starship | 3.3 | Cria o `starship.toml` com as cores do Roxo, **só se o arquivo não existir** |
| 9. `~/.zshrc` | 3.3 | Remove o bloco do prompt simples, se houver, e adiciona o bloco do Starship e dos plugins |
| 10. Claude Code | 5.1 | Instala pelo instalador oficial, se não estiver instalado |
| 11. Docker e VS Code | 6.2, 6.3 | Só verifica o Docker (não instala sozinho). Instala o VS Code se não achar o app nem o comando `code` |

⚠️ **O que o script não faz sozinho**
- Escolher a fonte no Terminal (**Ajustes → Perfis → Texto → Fonte**). É uma configuração manual.
- Atualizar o Xcode (seção 2.3) e rodar `brew upgrade`. Fazem parte da manutenção, não da instalação.
- Instalar Node, Python ou um gerenciador de versões (seção 6), nem o Docker Desktop.

> 📝 **Status do teste:** a lógica de edição dos arquivos (MacPorts, `starship.toml`, `~/.zshrc`, `~/.ssh/config`) foi testada em um ambiente isolado e confirmou a idempotência. As etapas que dependem do seu Mac (Homebrew, `gh auth login`, Keychain, instalador do Claude Code) **ainda não foram executadas pelo script**. Na primeira execução, acompanhe a saída e, em caso de dúvida, volte ao passo a passo manual.

---

## 8. 🩺 Solução de problemas

| Sintoma | Causa provável | Solução |
|---------|----------------|---------|
| `brew: command not found` | PATH não configurado (Apple Silicon) | Rodar o `shellenv` da seção 2.2 |
| `Permission denied (publickey)` | Chave SSH não cadastrada | `gh ssh-key add ~/.ssh/id_ed25519.pub` |
| Ícones quebrados no prompt | Fonte não é Nerd Font | Revisar seção 3.1 |
| `claude: command not found` | PATH do instalador | Abrir novo terminal ou `source ~/.zshrc` |
| `which -a git` mostra `/opt/local/bin/git` primeiro | MacPorts na frente do Homebrew no PATH | Ver seção 8.1 |
| `port`: `OS platform mismatch` | MacPorts instalado antes de uma atualização grande do macOS | Ver seção 8.1 |

### 8.1 Conflito de PATH com o MacPorts (caso real)

**Sintomas**
- `which -a git` (ou `curl`) lista `/opt/local/bin/...` antes de `/opt/homebrew/bin/...`.
- O comando `port` falha com `Current platform "darwin 27" does not match expected platform "darwin 24"` e `OS platform mismatch`.

**Causa:** o MacPorts foi instalado numa versão anterior do macOS e adicionou `/opt/local/bin` ao PATH no `~/.zprofile`, **depois** do Homebrew. Cada `export PATH=` coloca o novo caminho na frente, então o MacPorts passou a ter prioridade. Após a atualização do macOS, ele parou de funcionar, mas os programas dele continuaram no PATH.

**1. Diagnóstico**

💻
```bash
ls /opt/local/bin/port 2>/dev/null && echo "MacPorts presente" || echo "MacPorts ausente"
which -a git curl python3 node
ls /opt/local/bin | wc -l
grep -n "opt/local" ~/.zprofile
```

> ⚠️ Não use `port version` para checar se existe: se ele estiver quebrado, o comando falha e parece que "não foi encontrado".

**2. Correção reversível:** desativar só a linha do MacPorts, sem apagar nada

💻
```bash
cp ~/.zprofile ~/.zprofile.bak
sed -i '' '/\/opt\/local\/bin:\/opt\/local\/sbin/ s/^/# /' ~/.zprofile
grep -n "opt/local" ~/.zprofile
```

📝 **Esperado:** a linha do `export PATH="/opt/local/bin:/opt/local/sbin:$PATH"` aparece começando com `# ` ✅ *(real: linha 12)*.

**3. Verificar em uma janela nova do Terminal** (a janela antiga guarda o PATH anterior)

💻
```bash
which -a git curl
git --version
```

📝 **Retorno real após a correção ✅**

```
/opt/homebrew/bin/git
/usr/bin/git
/usr/bin/curl
git version 2.56.1
```

Agora o Git do Homebrew vem primeiro e o `curl` é o do sistema, sem nenhum caminho em `/opt/local`.

**Desfazer:** `cp ~/.zprofile.bak ~/.zprofile`

> Os arquivos do MacPorts continuam em `/opt/local`. Se não for mais usá-lo, a remoção completa é opcional e deve seguir o guia oficial do MacPorts (wiki de desinstalação). Não é necessária para o restante deste manual.

---

## 9. 🔗 Referências

- Homebrew: https://brew.sh
- GitHub CLI: https://cli.github.com
- Docs do GitHub (SSH): https://docs.github.com/pt/authentication
- Starship: https://starship.rs
- Claude Code: https://docs.claude.com

---

*Manual vivo: atualize a data no topo e o status do checklist a cada revisão.*
