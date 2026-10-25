# SKILL PLANEJAR
`/planejar` — gera o plano de implementação a partir de uma spec Aprovada

Última verificação: 2026-10-25 · Testado com: Claude Code (ainda não executada)

## PARA QUE SERVE
Garante que nenhuma implementação começa sem plano aprovado (CLAUDE.md §2)
e que cada task prova um critério da spec.

## QUANDO FAZER
Depois de aprovar uma spec e antes de implementar.

## PRÉ-REQUISITOS
Spec em docs/specs/ com Status "Aprovada"; Context7 configurado
(ver ferramentas/context7.md).

## PASSO A PASSO
1. Digite `/planejar` (opcional: número ou nome da feature).
2. Escolha entre as opções técnicas apresentadas.
3. Revise o plano mostrado e aprove o salvamento.

## COMO CONFERIR QUE DEU CERTO
`ls docs/plans/` mostra `NNN-<feature>.md`; a tabela de Rastreabilidade
não tem linha sem task ou sem teste.

## SE DER ERRADO
Plano indesejado: apague o arquivo novo (ou `git restore`) e rode de novo.

## VER TAMBÉM
docs/templates/plan.md · ferramentas/skill-entrevista-spec.md
