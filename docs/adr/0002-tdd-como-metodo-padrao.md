# ADR 0002: Adotar TDD como método padrão de implementação e exigir 100% dos testes passando no CI

- **Status:** Aceito
- **Data:** 2026-10-28
- **Substitui:** nenhum

## Contexto
O ADR 0001 define o fluxo spec → plano → tasks → TDD → revisão → CI e deixa
este ADR como o registro do TDD. Fatos que forçam a decisão:
- Uma IA de código escreve testes fracos, que passam sem provar nada, quando
  o teste é escrito depois do código que ele deveria cobrar.
- Sem teste vermelho primeiro, ninguém sabe se o teste consegue falhar.
- O dono é estudante e quer entender o código: o teste é a descrição
  executável do comportamento esperado.
- O CLAUDE.md já exige `scripts/verify.sh test` antes de encerrar uma tarefa
  e proíbe desativar teste ou enfraquecer verificação.

## Decisão
Toda implementação segue TDD, uma task por vez: escrever o teste a partir de
um critério de aceite da spec, vê-lo **falhar** (vermelho), escrever o mínimo
de código para passar (verde) e só então refatorar. O CI só aprova com 100%
dos testes passando (não confundir com 100% de cobertura). Teste desativado ou
isolado (`.only`) só existe com entrada em `docs/DEBT.md`, e o `verify.sh`
falha se houver um sem `DEBT-NNN`.

## Alternativas
1. **Testes depois do código**
   - Prós: mais natural para quem está começando; o código sai mais rápido.
   - Contras: o teste tende a copiar o que o código já faz, inclusive os
     erros; nunca se vê o teste falhar; pular o teste "só desta vez" é fácil.
   - **Descartada** porque é o cenário de teste fraco que o ADR 0001 quer evitar.
2. **Só testes E2E (ponta a ponta)**
   - Prós: testa o que o usuário vê; poucos testes para manter.
   - Contras: lentos e frágeis; quando falham, não dizem onde está o erro; a
     lógica de cada construto e das médias fica sem teste rápido.
   - **Descartada** como método único. Testes E2E continuam bem-vindos como
     complemento, no `verify.sh full`.
3. **TDD com testes de unidade e integração, e CI exigindo 100% passando** (escolhida)
   - Prós: cada critério de aceite ganha um teste que já se viu falhar; o erro
     aparece perto da causa; feedback rápido.
   - Contras: mais lento no começo; exige disciplina; o dono precisa aprender
     o ciclo vermelho-verde-refatorar.

## Consequências
**Positivas:**
- Cada critério de aceite da spec tem um teste, e o histórico de commits mostra
  o teste antes do código (o `auditor-spec` confere isso na revisão).
- Mudanças futuras ficam mais seguras, porque o CI barra o que quebra.

**Negativas:**
- Tarefas simples levam mais tempo e consomem mais do limite do plano.
- Teste mal escrito também passa: o TDD reduz esse risco, mas não o elimina.
- "100% passando" não mede cobertura; ela fica para o `verify.sh full`.

**Daqui para frente:**
- Manter `scripts/verify.sh` e o hook `stop-verify` como guardas desta regra.
- Registrar em `docs/DEBT.md` qualquer teste desativado.
- Escolher o framework de testes no ADR da stack (Fase 5).
