# ADR 0003: Permitir que o Claude faça merge de PR na develop, só sob pedido explícito

- **Status:** Aceito
- **Data:** 2026-10-28
- **Substitui:** nenhum

## Contexto
- Hoje o push para `main` e `develop` é bloqueado (hook `protect-push` e
  `deny`), e o merge de PR é sempre manual.
- Em PRs pequenos, revisados e com CI verde, o merge na `develop` é uma tarefa
  repetitiva; mas merge é difícil de desfazer e `main` é o que vai para produção.
- O `gh pr merge` tem opções que mudam o risco: `--squash`, `--rebase`,
  `--admin` (ignora regras de proteção) e `--auto` (faz o merge depois, sem
  novo pedido). Confirmado em `gh pr merge --help` (gh 2.103.2).
- O `gh api` também faz merge (`PUT .../pulls/N/merge` e mutations do GraphQL),
  o que contornaria um bloqueio só no `gh pr merge`.

## Decisão
O Claude pode rodar `gh pr merge --merge` em PR cujo destino seja a `develop`,
somente quando o dono pedir explicitamente no chat, com CI verde e `/revisar`
sem 🔴/🟡. Merge na `main` é só do dono. Três travas sustentam isso:
1. regra no CLAUDE.md;
2. `Bash(gh pr merge *)` na lista `ask` do `settings.json` (o dono confirma);
3. hook `protect-merge.sh`, que consulta o destino com `gh pr view --json baseRefName`
   e bloqueia destino diferente de `develop`, consulta que falhe, qualquer
   estratégia que não seja `--merge`, `--squash`, `--rebase`, `--admin`, `--auto`
   e os merges por `gh api` (REST `/pulls/N/merge` e GraphQL).

## Alternativas
1. **Só o dono faz o merge**
   - Prós: risco mínimo; o dono acompanha cada integração.
   - Contras: o dono vira gargalo em tarefas repetitivas.
   - **Descartada** porque, com as três travas, o risco restante é pequeno.
2. **O Claude faz merge na develop quando o dono pedir** (escolhida)
   - Prós: menos trabalho manual; o dono continua decidindo e confirmando.
   - Contras: mais uma peça (hook e testes) para manter; o hook não vê
     comandos montados dinamicamente (variáveis, arquivos); merge errado na
     `develop` ainda precisa de revert.
3. **O Claude faz merge sozinho quando CI e revisão passam (auto-merge)**
   - Prós: zero trabalho manual.
   - Contras: tira do dono a decisão de quando integrar.
   - **Descartada** por contrariar "só quando eu pedir".

## Consequências
**Positivas:** integração na `develop` mais rápida; histórico sempre com merge commit.

**Negativas:** o hook é uma defesa por análise de texto, não é à prova de tudo.
A garantia real para a `main` é a branch protection no GitHub.

**Daqui para frente:**
- Configurar a branch protection da `main` no GitHub (PR obrigatório, CI exigido).
- Documentar em `docs/help/ferramentas/merge-de-pr.md` e manter os testes do hook.
- Rever este ADR se o fluxo passar a usar outro modo de merge.
