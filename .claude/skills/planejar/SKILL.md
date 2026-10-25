---
name: planejar
description: Transforma uma spec Aprovada em plano de implementação em docs/plans/NNN-<feature>.md, com tasks de 30–90 min ligadas a critérios de aceite e testes. Use depois que a spec está com Status Aprovada e antes de qualquer implementação. Não use sem spec Aprovada, não implemente nada e não use para escrever a spec (para isso, entrevista-spec).
disable-model-invocation: true
---

# Planejar

## Conceito (para você, dono do projeto)
O plano diz COMO e em que ORDEM construir o que a spec pede. Cada task é um
pedaço pequeno (30–90 min) que prova um critério da spec com um teste. Assim
você sempre sabe por que uma task existe e quando ela está pronta. O plano
não é código: é o mapa antes da viagem.

## Passos
1. Confira o Status da spec. Se não for "Aprovada", PARE e diga o que falta
   (sugira /entrevista-spec). Não escreva plano.
2. Leia a spec, CLAUDE.md, docs/adr/ e docs/erros/ (para não repetir erro
   já registrado) e docs/templates/plan.md.
3. Confirme no Context7 (resolve-library-id e query-docs) toda API,
   configuração ou versão de biblioteca que o plano citar. Sem confirmação,
   diga "não sei" e registre em Riscos.
4. Se houver 2–3 caminhos técnicos, apresente as opções com prós e contras
   e uma recomendação. O dono decide.
5. Monte docs/plans/NNN-<feature>.md pelo template (mesmo NNN da spec,
   Status: Rascunho, Data de hoje, link para a spec).
6. Escreva as tasks:
   - 30–90 min cada; maior que isso, divida.
   - Marque [back], [front] ou [ambos].
   - Cada task tem "Cobre: RF-xx/CA-x" e o teste que a prova.
   - Ordem: domínio → persistência → API → UI.
   - Marque com 🎓 as boas para o dono fazer à mão (pequenas, didáticas,
     de baixo risco).
7. Preencha a Rastreabilidade. Todo RF/CA da spec precisa aparecer; liste
   explicitamente qualquer critério SEM task ou SEM teste.
8. Liste o que a feature exige e acione as skills correspondentes:
   modelagem-dados, diagramas, contrato-api, modelo-ameacas e
   casos-de-teste. Para cada uma: "exige" ou "não se aplica", com o motivo.
   Se a skill ainda não existir, avise e anote como pendência.
9. Decisão de arquitetura nova vira ADR (docs/templates/adr.md), proposta
   ao dono.
10. Atualize docs/produto/roadmap.md (se não existir, proponha a estrutura
    e mostre antes) e o README.md de docs/plans/.
11. MOSTRE o plano inteiro e peça aprovação. Só salve depois do "sim".
    Mudar Status para Aprovado também exige um "sim" explícito.
12. Termine aqui. Implementação é outra etapa.

## Proibido
- Planejar sem spec Aprovada.
- Escrever ou alterar código, ou implementar qualquer task.
- Inventar API, versão ou configuração sem confirmar no Context7.
- Assumir requisito fora da spec (vai para "Perguntas em aberto" da spec).
- Task sem "Cobre" ou sem teste; task acima de 90 min.
- Escolher stack ou biblioteca sem apresentar opções ao dono.
- Salvar arquivo sem mostrar o conteúdo e receber aprovação.
- Editar ADR já aceito.
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).

## Como verificar
- A spec tinha Status "Aprovada" antes de começar.
- docs/plans/NNN-<feature>.md existe, usa o template e aponta para a spec.
- Todo RF/CA da spec aparece na Rastreabilidade; lacunas estão listadas.
- Toda task tem tag [back|front|ambos], "Cobre", teste e duração de 30–90 min.
- A ordem das tasks respeita domínio → persistência → API → UI.
- APIs citadas têm confirmação do Context7 ou estão em Riscos.
- roadmap.md e os READMEs tocados foram atualizados.
- Nenhum arquivo de código foi criado ou alterado.
