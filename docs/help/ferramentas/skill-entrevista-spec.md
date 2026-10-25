# SKILL ENTREVISTA-SPEC
`/entrevista-spec` — conduz a entrevista e gera a spec de uma feature

Última verificação: 2026-10-25 · Testado com: Claude Code (ainda não executada)

## PARA QUE SERVE
Garante que toda feature começa com spec aprovada (CLAUDE.md §2). Sem ela,
o Claude tende a supor requisitos.

## QUANDO FAZER
Ao começar cada feature nova.

## PRÉ-REQUISITOS
Árvore git limpa e docs/templates/spec.md presente.

## PASSO A PASSO
1. Abra o Claude Code na raiz do projeto.
2. Digite `/entrevista-spec` (opcional: nome da feature).
3. Responda uma pergunta por vez; decida nas opções.
4. Revise a spec mostrada e aprove o salvamento.

## COMO CONFERIR QUE DEU CERTO
`ls docs/specs/` mostra `NNN-<feature>.md` com Status "Rascunho" ou "Aprovada".

## SE DER ERRADO
Spec indesejada: `git restore` / apague o arquivo novo e rode de novo.

## VER TAMBÉM
docs/templates/spec.md · docs/adr/0001-fluxo-spec-driven-com-claude.md
