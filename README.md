# 🍎 setup-mac

Manual e script para configurar o terminal do Mac do zero: **Homebrew, zsh com Starship, Git/GitHub por SSH, Claude Code e Codex**, Docker e VS Code.

Tudo foi montado e verificado passo a passo em um Mac com Apple Silicon, com os retornos esperados de cada comando.

## O que tem aqui

| Arquivo | Para que serve |
|---------|----------------|
| [`manual-terminal-mac.md`](manual-terminal-mac.md) | Passo a passo completo, com retornos esperados e solução de problemas |
| [`setup-mac.sh`](setup-mac.sh) | Script que reproduz as etapas do manual, de forma idempotente |

## Começando

Leia o manual primeiro. Se preferir automatizar:

```bash
git clone git@github.com:SEU-USUARIO/setup-mac.git
cd setup-mac
chmod +x setup-mac.sh
./setup-mac.sh
```

Para configurar o Git sem perguntas, ou aceitar as perguntas opcionais automaticamente:

```bash
GIT_NAME="Seu Nome" GIT_EMAIL="voce@exemplo.com" ./setup-mac.sh
ASSUME_YES=1 ./setup-mac.sh
```

## O que o script faz

1. Verifica as Command Line Tools
2. Instala ou atualiza o Homebrew
3. Avisa sobre conflito de PATH com o MacPorts e oferece corrigir
4. Instala `git`, `gh`, `starship`, os plugins do zsh e a fonte JetBrains Mono Nerd Font
5. Configura a identidade do Git
6. Cria a chave SSH (se não existir), o `~/.ssh/config` e carrega a chave no Keychain
7. Faz o login no GitHub (`gh auth login`) se ainda não estiver logado
8. Cria o `~/.config/starship.toml` com as cores do esquema Roxo, se não existir
9. Adiciona o bloco do Starship e dos plugins ao `~/.zshrc`
10. Instala o Claude Code, se não estiver instalado
11. Instala o Codex (OpenAI) pelo Homebrew, se não estiver instalado
12. Verifica o Docker e o VS Code

O que o script **não** faz: escolher a fonte no Terminal (é manual), atualizar o Xcode e rodar `brew upgrade`.

## Segurança

- **Leia o script antes de rodar.** Ele altera arquivos de configuração do seu usuário.
- Antes de modificar `~/.zshrc`, `~/.zprofile` ou `~/.ssh/config`, ele cria um backup com data e hora (`.bak.AAAAMMDD-HHMMSS`).
- Ele **nunca sobrescreve** uma chave SSH existente nem um `starship.toml` existente.
- Duas etapas usam os instaladores oficiais baixados por `curl` (Homebrew e Claude Code). Confira as URLs no script.
- Nenhum dado pessoal está gravado no repositório: nome e e-mail do Git são pedidos na hora.

## Status do teste

- **Executado de ponta a ponta** em um Mac com Apple Silicon que já estava configurado: as 12 etapas rodaram sem erro, reconheceram o que já existia e **não alteraram nada** (idempotência confirmada).
- A lógica de edição dos arquivos (MacPorts, `starship.toml`, `~/.zshrc`, `~/.ssh/config`) também foi testada em ambiente isolado.
- **Ainda não exercitado:** os caminhos de *instalação do zero* (instalar o Homebrew, gerar uma chave SSH nova, `gh auth login`, instalar pacotes e o Claude Code), porque neste Mac tudo já estava instalado. Num Mac novo, acompanhe a saída na primeira execução.

Os exemplos de cores e caminhos usam nomes genéricos (`usuario`, `meu-projeto`).

## Contribuindo

Sugestões e correções são bem-vindas: abra uma *issue* ou um *pull request*. Se um comando se comportar de forma diferente na sua versão do macOS, descreva o retorno que apareceu.

## Licença

MIT. Veja o arquivo [`LICENSE`](LICENSE).
