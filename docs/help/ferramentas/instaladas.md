# NOME
instaladas — ver a versão e atualizar Java, Node, lefthook, gitleaks, gh e actionlint

Última verificação: 2026-10-28 · Testado com: Java 25.0.4.1+1-tem, SDKMAN 5.24.0, nvm 0.40.8, Node 24.22.1, lefthook 2.2.2, gitleaks 8.30.1, gh 2.103.2, actionlint 1.7.12

## PARA QUE SERVE
Cada ferramenta vem de um lugar diferente e se atualiza de um jeito
diferente. Aqui está o caminho de cada uma. `sdk` e `nvm` são funções do
shell: só existem em terminal interativo, não em scripts.

## QUANDO FAZER
Uma vez por mês (depois do mensal.md) ou quando precisar de uma versão
nova. Não troque de versão principal de Java ou Node sem spec/ADR.

## PRÉ-REQUISITOS
- Árvore git limpa e internet.
- Terminal do WSL aberto normalmente (carrega SDKMAN e nvm).

## PASSO A PASSO

### Java (SDKMAN)
1. Veja a versão em uso.
   ```bash
   sdk current java
   ```
2. Atualize o próprio SDKMAN e veja o que está desatualizado.
   ```bash
   sdk selfupdate
   sdk upgrade
   ```
3. Liste as versões disponíveis, instale a escolhida e torne-a padrão.
   ```bash
   sdk list java
   sdk install java <identificador>
   sdk default java <identificador>
   ```

### Node (nvm)
1. Veja as versões.
   ```bash
   node -v
   nvm -v
   ```
2. Para atualizar o nvm, rode o instalador da versão que o README oficial
   (github.com/nvm-sh/nvm) indica; hoje v0.40.8.
   ```bash
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash
   ```
3. Para uma versão nova do Node, instale a LTS levando junto os pacotes
   globais (é o que mantém o lefthook).
   ```bash
   nvm ls-remote --lts
   nvm install --reinstall-packages-from=current 'lts/*'
   ```
   O alias `default` aponta para `lts/*`, então a nova LTS vira a padrão.

### lefthook (npm global dentro do nvm)
1. Veja a versão.
   ```bash
   lefthook version
   ```
2. Atualize. (Comando padrão do npm: a documentação do lefthook só mostra
   a instalação por projeto, `--save-dev`.)
   ```bash
   npm install -g lefthook@latest
   ```
   O npm pode mostrar um aviso sobre `allowScripts`. Pode ignorar se o
   `lefthook version` do passo 1 funcionar e mostrar a versão nova.
3. Reaplique os hooks em cada repositório que usa lefthook.
   ```bash
   lefthook install
   ```
O lefthook global fica preso à versão do Node no nvm: ao trocar de
versão do Node ele some do PATH. Use `--reinstall-packages-from` (passo 3
do Node) ou reinstale com `npm install -g lefthook`.

### gitleaks (binário em ~/.local/bin)
> **Modo de manutenção.** O README oficial diz que o gitleaks só recebe
> correções de segurança, e o mantenedor passou a focar no Betterleaks
> (github.com/betterleaks/betterleaks). **Reavaliado em 2026-10-25:
> mantido; trocar pelo Betterleaks quando parar de receber correções.**

1. Veja a versão.
   ```bash
   gitleaks version
   ```
2. Veja se há release nova.
   ```bash
   gh release view -R gitleaks/gitleaks --json tagName,publishedAt
   ```
3. Baixe o binário Linux x64 da versão nova (pasta temporária), extraia e
   substitua. Troque `<versão>` pelo número, sem o `v`.
   ```bash
   gh release download -R gitleaks/gitleaks --pattern 'gitleaks_<versão>_linux_x64.tar.gz' --dir /tmp/gitleaks-novo
   tar -xzf /tmp/gitleaks-novo/gitleaks_<versão>_linux_x64.tar.gz -C /tmp/gitleaks-novo
   cp ~/.local/bin/gitleaks ~/.local/bin/gitleaks.anterior
   install -m 0755 /tmp/gitleaks-novo/gitleaks ~/.local/bin/gitleaks
   ```

### gh (repositório oficial do GitHub no apt)
O `gh` vem do repositório oficial do GitHub cadastrado no apt
(`https://cli.github.com/packages`), e não do repositório do Ubuntu, que
tem versão antiga. Não existe `gh upgrade`.
1. Veja a versão e a origem.
   ```bash
   gh --version
   apt-cache policy gh
   ```
2. Atualize.
   ```bash
   sudo apt update
   sudo apt install gh
   ```

### actionlint (binário em ~/.local/bin; opcional)
Valida os workflows de `.github/workflows` dentro do `scripts/verify.sh full`.
Sem ele o `full` apenas avisa e segue; o CI sempre o instala. O CI usa a versão
fixada em `.github/workflows/ci.yml`: ao atualizar aqui, atualize lá também.
1. Veja a versão e se há release nova.
   ```bash
   actionlint -version
   gh release view -R rhysd/actionlint --json tagName,publishedAt
   ```
2. Instale ou atualize para a versão escolhida (script do commit fixado, como no
   CI). Troque `<versão>` pelo número, sem o `v`.
   ```bash
   cp ~/.local/bin/actionlint ~/.local/bin/actionlint.anterior
   bash <(curl -sSfL https://raw.githubusercontent.com/rhysd/actionlint/914e7df21a07ef503a81201c76d2b11c789d3fca/scripts/download-actionlint.bash) <versão> ~/.local/bin
   ```
   (Na primeira instalação o `cp` não encontra o arquivo: ignore o erro.)

## COMO CONFERIR QUE DEU CERTO
- Java: `java -version` mostra a versão escolhida.
- Node: `node -v`, e `npm ls -g --depth=0` ainda lista `lefthook`.
- lefthook: `lefthook version` imprime a versão e `which lefthook` aponta
  para a pasta do Node atual no nvm.
- gitleaks: `gitleaks version` imprime a versão nova.
- gh: `gh --version` mostra a versão nova e `apt-cache policy gh` lista
  `cli.github.com` como origem.
- actionlint: `actionlint -version` imprime a versão e `scripts/verify.sh full`
  mostra `✔ actionlint sem alertas`.

## SE DER ERRADO
- Java: volte para a anterior com `sdk default java <identificador-anterior>`
  (anote o de `sdk current java` antes de começar).
- Node: `nvm use <anterior>` e `nvm alias default <anterior>`.
  Versões antigas continuam instaladas até você rodar `nvm uninstall`.
- lefthook: `npm install -g lefthook@<versão-anterior>`.
- gitleaks: `mv ~/.local/bin/gitleaks.anterior ~/.local/bin/gitleaks`.
- gh: `apt-cache policy gh` lista as versões disponíveis; instale uma
  específica com `sudo apt install gh=<versão>`.
- actionlint: `mv ~/.local/bin/actionlint.anterior ~/.local/bin/actionlint`.

## VER TAMBÉM
- manutencao/mensal.md
- ferramentas/context7.md
- ferramentas/ci.md (o CI instala o actionlint e o shellcheck por conta própria)
- CLAUDE.md, seção 4 (o gitleaks roda no commit; o `verify.sh` não checa segredos)
