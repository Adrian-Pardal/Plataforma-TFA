# NOME
merge-de-pr — pedir ao Claude o merge de um PR na develop e entender o que o hook bloqueia

Última verificação: 2026-10-28 · Testado com: gh 2.103.2, bash 5, jq

## PARA QUE SERVE
Define quando o Claude pode fazer merge de PR (ADR 0003). Regra: só na
`develop`, só quando você pedir explicitamente no chat, com CI verde e
`/revisar` sem 🔴/🟡, sempre por merge commit. Merge na `main` é só seu.

Três travas sustentam a regra:
1. a regra no `CLAUDE.md` (§6);
2. `Bash(gh pr merge *)` na lista `ask` do `.claude/settings.json`: o Claude
   Code pergunta a você antes de rodar;
3. o hook `.claude/hooks/protect-merge.sh`, que roda antes e bloqueia:
   - PR cujo destino não seja `develop` (consulta com `gh pr view --json baseRefName`;
     se a consulta falhar, bloqueia);
   - qualquer comando sem `--merge`, e `--squash`, `--rebase`, `--admin`, `--auto`;
   - merge por `gh api` (`.../pulls/N/merge`, `mergePullRequest`, `enablePullRequestAutoMerge`).

## QUANDO FAZER
Sempre que quiser que o Claude integre um PR na `develop`. Você precisa
pedir; ele não faz sozinho.

## PRÉ-REQUISITOS
- `gh` instalado e autenticado (`gh auth status`).
- O PR mira a `develop`, o CI está verde e a `/revisar` não tem 🔴/🟡.
- Recomendado: branch protection da `main` ativa no GitHub (PR obrigatório,
  CI exigido). É ela a garantia real; o hook analisa texto e não pega tudo
  (por exemplo, comando montado por variável ou `gh api -F query=@arquivo`).

## PASSO A PASSO
1. Confira o PR e o CI.
   ```bash
   gh pr view 12 --json baseRefName,mergeable,statusCheckRollup
   gh pr checks 12
   ```
2. Peça no chat: "faça o merge do PR 12 na develop".
3. O Claude roda o comando abaixo e o Claude Code pede a sua confirmação.
   ```bash
   gh pr merge 12 --merge
   ```
4. Responda "sim" só se tudo do passo 1 estiver certo.

## COMO CONFERIR QUE DEU CERTO
```bash
gh pr view 12 --json state,mergeCommit
```
`state` deve ser `MERGED`. Na `develop`, o histórico mostra um merge commit.

## SE DER ERRADO
- **Hook bloqueou (`🚫 protect-merge: ...`):** a mensagem diz o motivo. Se o
  destino for `main`, o merge é seu, pelo site ou pelo seu terminal.
- **Hook bloqueou um comando legítimo:** corrija o hook e inclua o caso em
  `scripts/tests/protect-merge.test.sh`; não apague a trava.
- **Merge errado na `develop`:** reverta pelo botão "Revert" do PR no GitHub
  (abre um novo PR de reversão). Não use push forçado.
- **Desfazer a mudança do hook:** `git restore .claude/hooks/protect-merge.sh`.

## VER TAMBÉM
- `docs/adr/0003-merge-de-pr-na-develop-pelo-claude.md`
- `docs/help/ferramentas/testes-dos-hooks.md`
