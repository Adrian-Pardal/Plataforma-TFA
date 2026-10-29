---
id: ERR-001
titulo: protect-push bloqueia git push com redirecionamento de saída
status: corrigido
categoria: bug
severidade: baixa
detectado-em: local
data: 2026-10-28
issue: nenhuma
pr: nenhum
recorrencias: 1
---

# ERR-001: protect-push bloqueia git push com redirecionamento de saída

## Sintoma
`git push -u origin chore/help-protecao-branches 2>&1 | tail -4` foi recusado:
"🚫 protect-push: destino '2>&1' (de '2>&1') não é permitido." O comando não rodou.

## Como reproduzir
1. Rodar `jq -n --arg c 'git push origin feat/x > /tmp/log 2>&1' --arg d "$PWD" '{tool_input:{command:$c},cwd:$d}' | .claude/hooks/protect-push.sh`
2. Sai com código 2 e "destino '>' ... não é permitido", embora `feat/x` seja permitido.
3. Mesmo efeito com `2>&1` sozinho (destino '2>&1').

## Causa raiz (5 porquês)
1. Por quê o push foi bloqueado? O hook tratou `2>&1` (ou `>`) como destino do push e ele não tem prefixo permitido.
2. Por quê? Em `validar_opcoes`, todo argumento que não começa com `-` e vem depois do remoto vai para `REFS`.
3. Por quê `2>&1` chegou lá? O hook separa o comando só por `&&`, `||`, `;` e `|` e depois por espaços; não distingue redirecionamento de argumento do git.
4. Por quê não distingue? O hook foi escrito assumindo que as palavras depois de `push` são sempre argumentos do git ("não precisamos de parsing perfeito"), mas o shell consome os redirecionamentos antes de o git rodar.
5. Por quê ninguém viu? A suíte `protect-push.test.sh` cobre opções e destinos, mas nenhum caso tem sintaxe de shell em volta do comando (causa raiz: falta de teste com redirecionamento).

## Correção
Em `.claude/hooks/protect-push.sh`, a função `tirar_redirecionamentos` descarta, antes de montar `REFS`, os tokens de redirecionamento (`>`, `>>`, `<`, `2>`, `2>&1`, `&>`) e o alvo deles quando vem separado. Ela roda antes de tirar as aspas, para que `">"` entre aspas continue sendo argumento do git e seja bloqueado. Commit da correção: o último desta branch (`fix/protect-push-redirecionamento`).

## Teste de regressão
`scripts/tests/protect-push.test.sh`, casos: `git push -u origin feat/x 2>&1` (0), `git push origin feat/x > /tmp/log 2>&1` (0) e `git push origin main 2>&1` (2). O terceiro já passava antes da correção e garante que ela não libera `main`. Um quarto caso, `git push origin ">" main` (2), também já passava e garante que `">"` entre aspas não é tratado como redirecionamento.

## Prevenção
Cobrir no teste a sintaxe de shell em volta do comando. Se voltar (2ª ocorrência), propor regra automática (ver skill registrar-erro, passo 7).

## Lição para a IA
Ao escrever hook que lê `tool_input.command`, tratar redirecionamentos como parte da sintaxe do shell, não como argumentos, e testá-los.

## Ocorrências
- 2026-10-28 — primeira ocorrência, ao dar push de `chore/help-protecao-branches` com `2>&1` (PR #1 em andamento).
