---
name: implementar-tdd
description: Implementa UMA task de um plano aprovado em TDD (vermelho, verde, refatorar), com commits por fase, verificação final com scripts/verify.sh test e push da branch de trabalho. Use para executar a task indicada, por exemplo /implementar-tdd 3. Não use sem plano aprovado, para mais de uma task por vez, nem para planejar ou escrever spec.
disable-model-invocation: true
argument-hint: "<número da task>"
---

# Implementar com TDD

Task pedida: $ARGUMENTS

## Conceito (para você, dono do projeto)
TDD é escrever o teste ANTES do código. Três fases: VERMELHO (o teste
falha, provando que ele realmente testa algo), VERDE (o menor código que o
faz passar) e REFATORAR (limpar sem mudar o comportamento). Cada fase vira
um commit, então o histórico mostra o raciocínio. Assim você vê o teste
falhar pelo motivo certo antes de confiar nele.

## Passos
0. Pré-condições. Pare e avise se algo faltar:
   - Existe plano em docs/plans/ com Status "Aprovado" ou "Em execução".
   - A task $ARGUMENTS existe no plano e ainda não está marcada.
   - A branch atual tem prefixo feat/, fix/, docs/, test/, refactor/,
     chore/ ou hotfix/ (nunca main ou develop).
   - Leia a task, o critério (RF-xx/CA-x) na spec e CLAUDE.md. Antes de usar
     API de biblioteca, confirme no Context7.
1. Explique em 2 linhas o que vai fazer.
2. Se o critério não tem caso de teste CT-xx, acione casos-de-teste.
   Se a skill ainda não existir, avise e peça ao dono como proceder.
3. VERMELHO:
   - Escreva o teste a partir do critério.
   - Para o teste compilar, só é permitido um esqueleto vazio (assinatura sem
     lógica). Declare-o ao dono.
   - Rode o teste e MOSTRE que falha pelo motivo certo (a asserção, não
     erro de import, sintaxe ou configuração).
   - Commit: "test(<escopo>): <comportamento esperado>".
4. VERDE:
   - Escreva o código MÍNIMO para passar. Rode e MOSTRE a saída.
   - Commit: "feat(<escopo>): ..." (ou "fix(<escopo>): ..." se for correção).
5. REFATORAR sem mudar comportamento (testes continuam verdes). Se houve
   mudança, commit: "refactor(<escopo>): ...".
6. VERIFICAÇÃO FINAL OBRIGATÓRIA: rode `scripts/verify.sh test` e MOSTRE a
   saída. Se não estiver 100% verde, descubra a causa:
   - código errado → corrija o código;
   - teste errado → corrija o teste e explique por quê;
   - requisito mudou → PARE e pergunte ao dono.
   Repita até 100% verde.
7. Marque a task no plano ([x]) e commite só o plano:
   "docs(plans): marca T<n> concluída".
8. Dê push da branch de trabalho: `git push origin <branch>` (ou -u na
   primeira vez). Se o push for bloqueado, mostre a mensagem e pare.
9. Explique em 3–5 linhas o que mudou e por quê.

## Gatilhos
- Regra de cálculo (ex.: médias) → acione teste-propriedades.
- Antes de migration → acione migration-segura.
- Rota nova ou alterada → acione teste-seguranca.
- Task marcada 🎓 → ofereça escrever SÓ o teste, deixando o código ao dono.
- Se a skill acionada ainda não existir, avise e anote como pendência.

## Regras de commit
- Todo commit da task (test, feat/fix, refactor e o docs(plans)) termina com
  o rodapé `Task: T<n>` (o número da task), numa linha própria separada da
  mensagem por uma linha em branco. Exemplo:

  ```
  test(respostas): rejeita resposta fora da escala Likert

  Task: T3
  ```

  É por esse rodapé que o auditor-spec liga cada commit à sua task e confere
  se o teste veio antes do código.
- Em cada commit, adicione só os arquivos da task (`git add <arquivos>`;
  nunca `git add .` ou `-A`).
- Nunca use --no-verify.

## Proibido
- Escrever código de produção antes do teste (fora o esqueleto vazio).
- Desativar, apagar ou enfraquecer teste, assert, linter ou cobertura
  para passar.
- Usar .only ou skip sem entrada em docs/DEBT.md.
- Encerrar com teste vermelho.
- Mexer em arquivos fora da task.
- Implementar mais de uma task por vez.
- Push para main/develop, push forçado ou de branch sem prefixo permitido.
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).
- Dizer que testou sem mostrar a saída.

## Como verificar
- Há commits distintos test(...), feat/fix(...) e, se houve, refactor(...).
- Todos os commits da task (inclusive o docs(plans)) têm o rodapé `Task: T<n>`
  (confira com `git log -n 4 --format=%B`).
- A saída do vermelho mostrada falhava pela asserção esperada.
- A saída final de `scripts/verify.sh test` está 100% verde e foi exibida.
- `git show --stat` de cada commit só lista arquivos da task.
- A task está marcada no plano e a branch foi enviada ao origin.
- Nenhum teste foi alterado/removido sem explicação.
