# NOME
ci — o que o CI do GitHub Actions faz, como ler uma falha e como atualizar as actions

Última verificação: 2026-10-28 · Testado com: actionlint 1.7.12, gh 2.103.2

## PARA QUE SERVE
O arquivo `.github/workflows/ci.yml` roda em todo pull request e em todo
push na `main` e na `develop`. Ele tem dois jobs, e o nome de cada check no
GitHub é o próprio nome do job:

- **`seguranca`** (roda primeiro): o gitleaks varre todos os commits em busca
  de segredos; em PR, o dependency review reprova se o PR trouxer uma
  dependência com vulnerabilidade conhecida.
- **`verificar`** (só começa se `seguranca` passar): instala Java e Node
  somente se existirem `pom.xml` e `package.json`, instala `shellcheck` e
  `actionlint` e roda `scripts/verify.sh full`. Qualquer teste falhando ou
  desativado sem `DEBT-NNN` reprova.

Regras do arquivo: permissões mínimas por job (`contents: read`), actions de
terceiros fixadas pelo SHA completo (a versão fica no comentário) e um
`concurrency` que cancela a execução antiga de um PR quando chega um push novo.
Estão comentados, para entrar depois, o job `codeql`, o deploy e o espelhamento.

O `.github/dependabot.yml` abre PRs semanais para a `develop` atualizando as
actions (commit `chore(deps): ...`). Maven e npm estão comentados.

## QUANDO FAZER
- **Ler uma falha:** quando o check `seguranca` ou `verificar` ficar vermelho.
- **Conferir os workflows antes do commit:** sempre que mudar algo em
  `.github/workflows/` (passo 1).
- **Proteger as branches:** uma vez, depois de a `develop` existir (passo 3).
- **Atualizar as actions:** o Dependabot abre o PR sozinho; você só revisa e
  pede o merge (veja `merge-de-pr.md`).

## PRÉ-REQUISITOS
- `actionlint` instalado localmente. Sem ele, o `scripts/verify.sh full` avisa
  "actionlint não instalado, pulado" e segue; o CI sempre o instala.
- Para a proteção de branch: a branch `develop` criada no GitHub.

## PASSO A PASSO
1. Valide os workflows na sua máquina (roda junto com o `full`).
   ```bash
   scripts/verify.sh full
   ```
   Para instalar o actionlint, baixe o script do commit fixado e a versão
   fixada para `~/.local/bin` (é o mesmo que o CI faz).
   ```bash
   bash <(curl -sSfL https://raw.githubusercontent.com/rhysd/actionlint/914e7df21a07ef503a81201c76d2b11c789d3fca/scripts/download-actionlint.bash) 1.7.12 ~/.local/bin
   actionlint -version
   ```
2. Veja uma execução que falhou e o log só do trecho que quebrou.
   ```bash
   gh run list --limit 5
   gh run view <id> --log-failed
   ```
3. Proteja a `main` e a `develop` exigindo os checks `seguranca` e `verificar`
   e PR. O passo a passo, pela API, está em `protecao-de-branches.md`. Os
   nomes dos checks aparecem só depois da primeira execução do workflow.
4. Para atualizar uma action na mão: pegue o SHA da versão nova e troque o SHA
   e o comentário juntos.
   ```bash
   gh api repos/actions/checkout/releases/latest --jq .tag_name
   gh api repos/actions/checkout/commits/<tag> --jq .sha
   ```
   Normalmente o Dependabot faz isso por você.

## COMO CONFERIR QUE DEU CERTO
- Local: `scripts/verify.sh full` termina com `✔ actionlint sem alertas` (ou
  com o aviso de que ele foi pulado) e saída 0.
- No GitHub: `gh run list --limit 1` mostra `completed success`, e o PR exibe
  os dois checks, `seguranca` e `verificar`, em verde.

## SE DER ERRADO
- **gitleaks achou um segredo:** trate como vazado. Revogue a credencial primeiro;
  só depois remova do código. Falso positivo: registre em `.gitleaksignore`
  (com a impressão digital do achado) e explique no PR.
- **dependency review reprovou:** troque a dependência por uma versão sem a
  vulnerabilidade. Ele só funciona com o grafo de dependências ativo
  (já é o padrão em repositório público).
- **`verificar` falhou só no CI:** rode `scripts/verify.sh full` local; as
  diferenças comuns são `shellcheck`/`actionlint` ausentes aqui e versão de
  Java/Node diferente. Não desative teste para passar (regra do CLAUDE.md §3).
- **Dependabot reclama da branch:** crie a `develop` ou tire o
  `target-branch` do `dependabot.yml`. Atualizações de segurança do Dependabot
  ignoram o `target-branch` e vão para a `main`.
- **Voltar atrás numa mudança do workflow:** `git revert <commit>` em um PR.

## VER TAMBÉM
- `docs/help/ferramentas/protecao-de-branches.md`
- `docs/help/ferramentas/merge-de-pr.md`
- `docs/help/ferramentas/instaladas.md`
- `docs/help/ferramentas/testes-dos-hooks.md`
- `docs/adr/0001-fluxo-spec-driven-com-claude.md` (decisão que cobre estas ferramentas)
