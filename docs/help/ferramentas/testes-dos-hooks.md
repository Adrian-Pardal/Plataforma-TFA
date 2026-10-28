# NOME
testes-dos-hooks — rodar os testes dos hooks e do verify.sh

Última verificação: 2026-10-25 · Testado com: bash 5, jq

## PARA QUE SERVE
Os hooks em `.claude/hooks/` e o `scripts/verify.sh` protegem o projeto
(push e merge perigosos, ADR aceito, teste desativado). Os testes em
`scripts/tests/*.test.sh` garantem que essas proteções continuam
funcionando depois de cada mudança. Cada teste sai com 0 se tudo passou
e com 1 se algum caso falhou.

O `scripts/verify.sh test` e o `full` já rodam todos os
`scripts/tests/*.test.sh` e falham se algum falhar. O `full` também roda o
`shellcheck` nos hooks e scripts, se ele estiver instalado
(`sudo apt install shellcheck`), e o `actionlint` nos workflows (veja
`instaladas.md`); sem eles, avisa e segue.

## QUANDO FAZER
Sempre que mudar um hook ou o `verify.sh`, antes do commit. Para rodar
só um teste, use o passo 1; para rodar tudo, `scripts/verify.sh test`.

## PRÉ-REQUISITOS
- `jq` instalado (os hooks também precisam dele).
- Estar na raiz do projeto.

## PASSO A PASSO
1. Rode o teste do hook que você mudou.
   ```bash
   scripts/tests/protect-push.test.sh
   ```
   Troque o nome pelo teste que quiser rodar (tabela abaixo).

| Teste                  | O que cobre                                       |
|------------------------|---------------------------------------------------|
| protect-push.test.sh   | `git push` liberado ou bloqueado (hook protect-push) |
| protect-merge.test.sh  | `gh pr merge` e `gh api` de merge: só destino develop e só `--merge`; sem `--squash`/`--rebase`/`--admin`/`--auto` (usa um gh falso, não chama o GitHub) |
| protect-files.test.sh  | Write em ADR Aceito, com caminho relativo e absoluto (hook protect-files) |
| lefthook.test.sh       | `lefthook.yml`: mensagens do commit-msg e segredo staged no pre-commit (precisa de lefthook e gitleaks; sem eles, pula) |
| verify.test.sh         | detecção de teste desativado/isolado (`it.only`, `xit`, `fit`...), shellcheck e actionlint (só no modo full) no verify.sh |

## COMO CONFERIR QUE DEU CERTO
A última linha é `✔ todos os casos passaram` e o código de saída é 0
(`echo $?`).

## SE DER ERRADO
Linhas `FALHA (esperado X, veio Y)` mostram o caso. Se o hook foi mudado
de propósito, corrija o hook, não o teste, a menos que o teste esteja
errado. Para voltar atrás: `git restore .claude/hooks/<hook>.sh`.

## VER TAMBÉM
- `docs/help/ferramentas/skills.md`
- `docs/help/ferramentas/merge-de-pr.md`
