---
name: revisar
description: Revisa a branch atual contra a base (develop; main se for hotfix/), roda scripts/verify.sh test, dispara os subagentes revisor-codigo e auditor-spec em paralelo, consolida os achados numa tabela por gravidade e pergunta antes de corrigir. Use ao fim de uma feature, antes do PR. Não use para implementar, corrigir sozinho ou aprovar a feature, nem com testes vermelhos.
disable-model-invocation: true
---

# Revisar

## Conceito (para você, dono do projeto)
Revisão é uma segunda leitura crítica do que mudou, feita antes de juntar o
código. Aqui ela olha duas coisas: se o código está bom (clareza, segurança,
testes) e se ele entrega exatamente o que a spec pediu, nem mais nem menos.
A revisão só aponta; quem decide o que corrigir é você.

## Passos
1. Descubra o escopo:
   - Branch atual: `git branch --show-current`.
   - Base: `develop`; se a branch começar com `hotfix/`, `main`. Confirme com
     `git rev-parse --verify <base>`. Se a base não existir, PARE e pergunte
     qual usar.
   - `git diff --stat <base>...HEAD` e `git log <base>..HEAD --oneline`.
     Diff vazio: PARE e avise.
   - Ache a spec e o plano relacionados em docs/specs/ e docs/plans/ (pelo
     nome da branch, commits ou plano). Se não achar, pergunte.
2. Rode `scripts/verify.sh test` e MOSTRE a saída. Se não estiver 100% verde,
   PARE aqui: informe a causa e não prossiga com a revisão.
3. Dispare EM PARALELO, numa única mensagem, os subagentes revisor-codigo
   (qualidade do diff) e auditor-spec (cada RF/CA da spec tem código e teste;
   nada além da spec). Passe a base, o escopo e o caminho da spec. Se algum
   não existir, avise e pergunte como seguir; não simule a revisão dele.
4. Acione as skills que existirem: solid, clean-code, revisao-seguranca e,
   se o diff tocar a interface, acessibilidade. As que não existirem, avise
   e anote como pendência.
5. Confira se os documentos da fase foram atualizados: tasks do plano
   marcadas, Status da spec, ADR para decisão de arquitetura, READMEs/índices,
   docs/help para ferramenta nova, docs/DEBT.md e docs/erros/ quando couber.
6. Consolide os achados numa tabela. Antes de listar, confirme cada um lendo
   o trecho citado; descarte o que não se sustentar. Sem duplicatas.

   | Gravidade | Arquivo:linha | Problema | Sugestão |
   |-----------|---------------|----------|----------|

   🔴 bloqueia (não pode juntar) · 🟡 deveria corrigir · 🔵 sugestão.
7. PERGUNTE antes de corrigir qualquer coisa: quais achados o dono quer
   corrigir. Sem resposta, não altere nada.
8. Termine pedindo que o dono EXPLIQUE com as próprias palavras um trecho do
   diff, que você escolhe e cita (arquivo:linha). Depois comente o que ele
   acertou e o que faltou.

## Proibido
- Corrigir, editar ou commitar durante a revisão sem pedir e receber ok.
- Seguir com a revisão se `scripts/verify.sh test` não estiver 100% verde.
- Dizer que revisou ou que "está tudo certo" sem mostrar a saída do verify
  e a tabela.
- Listar achado sem arquivo:linha, ou sem ter lido o trecho.
- Simular a opinião de um subagente ou skill que não existe.
- Aprovar a feature: quem aprova é o dono.
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).

## Como verificar
- A base usada existe e o `git diff --stat` foi mostrado.
- A saída de `scripts/verify.sh test` está 100% verde e foi exibida.
- Os dois subagentes rodaram em paralelo (ou a ausência foi comunicada).
- A tabela tem gravidade, arquivo:linha, problema e sugestão em cada linha.
- Nenhum arquivo foi alterado antes da resposta do dono (`git status`).
- A revisão terminou pedindo a explicação de um trecho do diff.
