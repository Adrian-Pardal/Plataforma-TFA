# SKILLS
`/<nome>` — como usar as skills do projeto (manual × automática)

Última verificação: 2026-10-25 · Testado com: Claude Code

## PARA QUE SERVE
Skills são roteiros que o Claude segue em tarefas repetidas (entrevistar a
spec, planejar, implementar em TDD). Esta página explica como usá-las.
A documentação de cada skill NÃO fica em docs/help: fica em docs/skills.md
e no próprio SKILL.md.

## QUANDO FAZER
Ao começar uma etapa do fluxo (CLAUDE.md §2) ou ao criar uma skill nova.

## PRÉ-REQUISITOS
Claude Code aberto na raiz do projeto. As skills ficam em
.claude/skills/<nome>/SKILL.md.

## PASSO A PASSO
1. Skill MANUAL (`disable-model-invocation: true`): só roda se você digitar
   `/<nome>`, com argumento quando houver (ex.: `/implementar-tdd 3`).
2. Skill AUTOMÁTICA (sem esse campo): o Claude pode carregá-la sozinho
   quando a descrição combina com o pedido. Também aceita `/<nome>`.
3. Para ver o índice: abra .claude/skills/README.md.
4. Skill nova ou alterada: pode ser preciso reiniciar a sessão para
   aparecer no menu `/`.

## COMO CONFERIR QUE DEU CERTO
Ao digitar `/`, o nome da skill aparece no menu.

## SE DER ERRADO
Skill não aparece: confira se o arquivo é .claude/skills/<nome>/SKILL.md e
reinicie a sessão. Alteração indesejada: `git restore`.

## VER TAMBÉM
docs/skills.md · .claude/skills/README.md · CLAUDE.md §6
