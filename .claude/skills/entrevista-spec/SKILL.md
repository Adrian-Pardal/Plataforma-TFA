---
name: entrevista-spec
description: Entrevista o dono do projeto, uma pergunta por mensagem, e escreve a spec de uma feature em docs/specs/NNN-<feature>.md com critérios Dado/Quando/Então. Use ao começar uma feature nova ou ao retomar uma spec em Rascunho. Não use para escrever código, plano ou escolher stack, nem para mudar uma spec já Aprovada (abra uma nova).
disable-model-invocation: true
---

# Entrevista de spec

## Conceito (para você, dono do projeto)
Spec é o "contrato" do que será construído, escrito antes do código. Se um
requisito não está na spec, ninguém pode assumir que existe. Por isso esta
skill pergunta em vez de supor: tudo que você não decidir vira "Perguntas
em aberto", e não uma suposição minha.

## Regras da entrevista
- UMA pergunta por mensagem. Espere a resposta antes da próxima.
- Em escolhas, dê 2–3 opções com prós e contras e uma recomendação.
  Quem decide é o dono.
- Nunca assuma requisito. Dúvida sem decisão vai para "Perguntas em aberto".
- Resposta vaga: explique o impacto da vagueza e peça uma decisão.
- Linguagem simples; o dono é estudante e quer entender.

## Roteiro (nesta ordem)
1. Problema
2. Usuários
3. Fluxo principal
4. Regras
5. Casos de borda
6. Dados e LGPD
7. Casos de abuso: como alguém mal-intencionado usaria a feature.
   Cada caso vira um critério de aceite.
8. Não funcionais
9. Fora de escopo
10. Critério de pronto

## Passos
1. Leia CLAUDE.md, docs/specs/, docs/adr/ e docs/templates/spec.md.
   Se existirem, leia também docs/produto/ e docs/requisitos/.
2. Diga em 2–3 linhas o que já existe e qual é o próximo NNN
   (maior número em docs/specs/ + 1, com 3 dígitos).
3. Conduza o roteiro, uma pergunta por mensagem.
4. Monte a spec pelo template (Status: Rascunho, Data de hoje). Cada RF
   tem critérios Dado/Quando/Então: sucesso, erro e cada caso de abuso.
5. MOSTRE a spec inteira e espere aprovação antes de salvar.
6. Na primeira vez (arquivos não existem), crie também
   docs/produto/visao.md, docs/produto/personas.md e
   docs/requisitos/requisitos-nao-funcionais.md. Não há template: proponha a
   estrutura, mostre cada arquivo e espere aprovação.
7. Atualize o README.md de cada pasta tocada (índice com link e status).
8. Pergunte se pode mudar o Status para Aprovada. Só mude com um "sim"
   explícito, e nunca com Perguntas em aberto que bloqueiem a feature.
9. Ao aprovar, acione as skills: regras-negocio, casos-de-uso e glossario;
   e lgpd se a feature coletar dado pessoal. Se alguma ainda não existir,
   avise e anote como pendência; não improvise o trabalho dela.
10. Decisão de arquitetura que surgir vira ADR (docs/templates/adr.md),
    proposta ao dono; não decida sozinho.

## Proibido
- Escrever código, escolher stack ou biblioteca sem perguntar.
- Assumir requisito que o dono não disse.
- Salvar arquivo sem mostrar o conteúdo e receber aprovação.
- Mudar Status para Aprovada sem pedido explícito.
- Editar ADR já aceito (crie outro que o substitua).
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).

## Como verificar
- docs/specs/NNN-<feature>.md existe, usa o template e todo RF tem
  critérios Dado/Quando/Então.
- Cada caso de abuso discutido aparece como critério de aceite.
- Nenhum requisito sem origem numa resposta do dono; dúvidas estão em
  "Perguntas em aberto".
- READMEs das pastas tocadas listam o novo arquivo.
- Se a spec foi aprovada: o Status mudou só depois do "sim" do dono.
