# Skills do projeto

Skills ficam em `.claude/skills/<nome>/SKILL.md`. Esta página é o índice.
**Ao criar uma skill nova, adicione a linha aqui no mesmo commit.**

- **Documentação de cada skill:** o próprio `SKILL.md` (conceito, passos,
  "Proibido" e "Como verificar"). Skills NÃO ganham página em docs/help.
- **Como usar (manual × automática):** [help/ferramentas/skills.md](help/ferramentas/skills.md).

Fases do fluxo: spec, plano, implementação, revisão, fechamento, sessão,
transversal.

| Skill | Fase | Tipo | Quando usar |
|-------|------|------|-------------|
| [entrevista-spec](../.claude/skills/entrevista-spec/SKILL.md) | spec | manual | Ao começar uma feature nova ou retomar uma spec em Rascunho |
| [planejar](../.claude/skills/planejar/SKILL.md) | plano | manual | Com a spec Aprovada, antes de implementar |
| [implementar-tdd](../.claude/skills/implementar-tdd/SKILL.md) | implementação | manual | Para cada task do plano aprovado, uma por vez (`/implementar-tdd 3`) |
| [registrar-adr](../.claude/skills/registrar-adr/SKILL.md) | transversal | automática | Ao decidir stack, banco, biblioteca importante, padrão, autenticação, modelo de dados ou método de trabalho |
| [registrar-erro](../.claude/skills/registrar-erro/SKILL.md) | transversal | automática | Depois de corrigir ou entender um bug, erro da IA, problema de ambiente ou falha de produção (com causa raiz descoberta) |
| [handoff](../.claude/skills/handoff/SKILL.md) | sessão | manual | Ao encerrar uma sessão de trabalho (`/handoff`) |

Última revisão de skills: 2026-10-25 (base; próxima a partir de 2027-01-25)
