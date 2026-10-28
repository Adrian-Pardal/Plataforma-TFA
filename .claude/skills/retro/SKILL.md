---
name: retro
description: Faz a retrospectiva do fim de uma feature: pergunta ao dono, uma por vez, onde a IA errou, o que se repetiu, o que faltou na spec, o tamanho das tasks e o que ele aprendeu; propõe mudanças concretas (diff) em CLAUDE.md, skills, hooks ou CI e aplica só o aprovado; sugere 1–3 tópicos de estudo. A cada 3 meses, também revisa as skills sem uso ou parecidas. Use ao fim de uma feature, depois da revisão. Não use no meio de uma task nem para corrigir código.
disable-model-invocation: true
---

# Retro

## Conceito (para você, dono do projeto)
Retrospectiva é parar e perguntar "o que aprendemos e o que muda?" antes da
próxima feature. Sem ela, os mesmos erros voltam. O resultado não é um texto
bonito: é mudança concreta (uma regra, um passo de skill, um hook) que você
aprova uma a uma, e algo que você aprendeu.

## Passos
1. Leia o material da feature: spec, plano, handoffs recentes, docs/erros/,
   docs/DEBT.md e `git log` da branch. Resuma em 3–4 linhas o que viu. Não
   responda as perguntas pelo dono.
2. Pergunte, UMA por mensagem, nesta ordem, esperando cada resposta:
   a. Onde a IA errou ou alucinou?
   b. O que se repetiu (erro, retrabalho, pergunta)?
   c. O que faltou na spec?
   d. As tasks tinham bom tamanho (30–90 min)? Mostre commits por task
      como dado, sem concluir por ele.
   e. O que você aprendeu?
3. Se um erro descrito não está em docs/erros/, ofereça registrar-erro. Se
   ele já existe e voltou, lembre que a 2ª ocorrência exige prevenção
   automática.
4. Proponha mudanças CONCRETAS, cada uma com: arquivo, diff (antes/depois),
   a evidência que a motiva (resposta do dono, ERR-NNN, commit) e o efeito.
   Alvos: CLAUDE.md, skills, hooks (.claude/hooks, settings.json) ou CI.
   Decisão de arquitetura vira ADR (acione registrar-adr).
5. Mantenha o CLAUDE.md curto (limite de 60 linhas). Toda linha acrescentada
   precisa de uma linha removida ou fundida. Mostre a contagem antes e depois.
   Prefira skill, hook ou CI quando a regra não precisa estar sempre no
   contexto.
6. Pergunte quais propostas aprovar. Aplique SÓ as aprovadas (com Edit/Write,
   mostrando o conteúdo antes), uma por vez. O resto fica registrado como
   não aplicado.
7. Acione atualizar-docs para alinhar os documentos. Se a skill não existir,
   avise e anote como pendência.
8. Sugira 1–3 tópicos de estudo ligados ao que o dono errou ou aprendeu, com
   o motivo de cada um. Não invente links: diga o que pesquisar e, para
   biblioteca, confirme no Context7.
9. Revisão trimestral de skills:
   - Veja em docs/skills.md a linha "Última revisão de skills: AAAA-MM-DD".
     Se não existir, proponha criá-la com a data de hoje (base) e pule.
   - Se passaram 3 meses ou mais, liste as skills SEM USO (nenhuma menção
     em docs/handoff/ nem em PRs: `gh pr list --state all`, só leitura; sem
     `gh`, use só os handoffs e diga isso) e as de DESCRIÇÃO PARECIDA
     (compare o campo description de cada SKILL.md).
   - Para cada uma, proponha fundir ou remover, com o motivo. Remova ou funda
     SOMENTE com a aprovação explícita do dono. Atualize o índice e a data em
     docs/skills.md.

## Proibido
- Responder as perguntas pelo dono ou fazer mais de uma por mensagem.
- Aplicar qualquer mudança sem aprovação explícita.
- Remover ou fundir skill sem aprovação explícita.
- Aumentar o CLAUDE.md além de 60 linhas.
- Enfraquecer teste, linter, cobertura ou hook como "melhoria".
- Editar ADR já Aceito (crie outro que o substitua).
- Proposta sem diff ou sem evidência.
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).

## Como verificar
- As 5 perguntas foram feitas uma por vez e respondidas pelo dono.
- Cada proposta tem arquivo, diff e evidência; só as aprovadas foram aplicadas.
- `wc -l CLAUDE.md` é no máximo 60 e foi mostrado.
- Nenhuma skill foi removida sem aprovação (`git status`).
- Há 1–3 tópicos de estudo, cada um com motivo.
- Se houve revisão trimestral, a data em docs/skills.md foi atualizada.
