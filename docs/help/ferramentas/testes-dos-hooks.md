# NOME
testes-dos-hooks — rodar os testes dos hooks e do verify.sh

Última verificação: 2026-10-25 · Testado com: bash 5, jq

## PARA QUE SERVE
Os hooks em `.claude/hooks/` e o `scripts/verify.sh` protegem o projeto
(push perigoso, ADR aceito, teste desativado). Os testes em
`scripts/tests/*.test.sh` garantem que essas proteções continuam
funcionando depois de cada mudança. Cada teste sai com 0 se tudo passou
e com 1 se algum caso falhou.

## QUANDO FAZER
Sempre que mudar um hook ou o `verify.sh`, antes do commit.

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
| verify.test.sh         | detecção de teste desativado/isolado (`it.only`, `xit`, `fit`...) no verify.sh |

## COMO CONFERIR QUE DEU CERTO
A última linha é `✔ todos os casos passaram` e o código de saída é 0
(`echo $?`).

## SE DER ERRADO
Linhas `FALHA (esperado X, veio Y)` mostram o caso. Se o hook foi mudado
de propósito, corrija o hook, não o teste, a menos que o teste esteja
errado. Para voltar atrás: `git restore .claude/hooks/<hook>.sh`.

## VER TAMBÉM
- `docs/help/ferramentas/skills.md`
