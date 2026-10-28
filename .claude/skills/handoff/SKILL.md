---
name: handoff
description: Cria o handoff da sessão em docs/handoff/AAAA-MM-DD-<assunto>.md pelo template, com onde estamos, feito, em andamento, próximo passo concreto, ADRs criados, problemas e o resultado de scripts/verify.sh test rodado na hora, além da branch e dos commits sem push. Use ao encerrar uma sessão de trabalho. Não use para planejar, implementar ou registrar erro, e nunca para afirmar que está tudo funcionando sem a saída do verify.
disable-model-invocation: true
---

# Handoff

## Conceito (para você, dono do projeto)
O Claude não lembra de uma sessão para outra. O handoff é o bilhete que
deixamos para a próxima: onde paramos, o que falta e qual é o primeiro
passo. Um bom handoff deixa a próxima sessão começar em 2 minutos, e só
afirma o que foi comprovado agora.

## Passos
1. Pegue a data de hoje com `date +%F` (não adivinhe). O <assunto> é uma
   expressão curta em minúsculas, com hífens, escolhida com o dono.
2. Leia CLAUDE.md (§2, fluxo), o último handoff em docs/handoff/, a spec e o
   plano em andamento, docs/DEBT.md e docs/erros/README.md.
3. Levante o estado do git e mostre a saída:
   - `git branch --show-current`
   - `git status -sb` (alterações não commitadas)
   - `git log @{u}..HEAD --oneline` (commits sem push). Se a branch não tem
     upstream, diga isso e que todos os commits dela estão sem push.
4. Rode `scripts/verify.sh test` AGORA e MOSTRE a saída. Registre o resultado
   (passou ou falhou) com data e hora. Se falhou, escreva "falhou" e a causa
   conhecida; não corrija durante o handoff sem o dono pedir.
5. Monte docs/handoff/AAAA-MM-DD-<assunto>.md pelo template:
   - Onde estamos: feature, fase do fluxo, branch atual e commits sem push.
   - Feito: o concluído, com commits.
   - Em andamento: o ponto EXATO (arquivo, teste, fase do TDD).
   - Próximo passo: a primeira ação concreta (comando, task ou arquivo).
   - Decisões: ADRs criados nesta sessão, com link.
   - Problemas: bloqueios, ERR-NNN, dúvidas em aberto.
   - Estado da verificação: a saída do passo 4, resumida.
6. Mantenha em ~40 linhas. Corte o que a próxima sessão não precisa.
7. MOSTRE o arquivo inteiro e espere aprovação antes de salvar.
8. Atualize docs/handoff/README.md (índice com data, assunto e link). Se não
   existir, proponha o conteúdo, mostre e crie após aprovação.
9. Pergunte se o dono quer commitar o handoff. Não faça push sem pedido.

## Proibido
- Escrever "tudo funcionando", "passou" ou equivalente sem a saída de
  scripts/verify.sh test rodado na hora.
- Reaproveitar o resultado de uma execução anterior.
- Omitir alterações não commitadas ou commits sem push.
- Inventar estado, causa ou próximo passo vago ("continuar o trabalho").
- Passar de ~40 linhas ou incluir segredos.
- Salvar sem mostrar o conteúdo e receber aprovação.
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).

## Como verificar
- O arquivo docs/handoff/AAAA-MM-DD-<assunto>.md existe e segue o template.
- A data bate com `date +%F` e o arquivo tem ~40 linhas ou menos.
- "Onde estamos" traz a branch e os commits sem push (ou "nenhum").
- "Estado da verificação" traz a saída real do verify, com data e hora.
- "Próximo passo" é uma ação concreta que alguém executa sem perguntar.
- docs/handoff/README.md lista o novo handoff.
