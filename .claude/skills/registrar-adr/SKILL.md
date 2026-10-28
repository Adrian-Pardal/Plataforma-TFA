---
name: registrar-adr
description: Registra uma decisão de arquitetura como ADR em docs/adr/NNNN-titulo-curto.md pelo template, com no mínimo 2 alternativas, começando Proposto e virando Aceito só com o ok do dono; se a decisão contradiz um ADR Aceito, cria um novo que o substitui. Use ao decidir stack, banco, biblioteca importante, padrão, autenticação, modelo de dados ou método de trabalho. Não use para detalhe local e fácil de desfazer, nem para editar o conteúdo de um ADR já Aceito.
---

# Registrar ADR

## Conceito (para você, dono do projeto)
ADR (Architecture Decision Record) é uma página curta que guarda uma decisão
importante e o porquê dela. Daqui a meses você (ou eu, em outra sessão) não
vai lembrar por que escolheu X em vez de Y; o ADR lembra. ADR Aceito não se
edita: se a decisão mudar, escreve-se outro que o substitui, e o histórico
fica inteiro.

## Quando vale um ADR
Sim: stack, banco de dados, biblioteca importante, padrão de arquitetura,
autenticação, modelo de dados, método de trabalho.
Não: nome de variável, ajuste de estilo, correção de bug, escolha pequena e
fácil de desfazer. Nesses casos, diga que não vale e pare.

## Passos
1. Decida com o dono se vale ADR (lista acima).
2. Leia docs/adr/README.md e os ADRs existentes. O próximo número é o maior
   NNNN existente + 1, com 4 dígitos (nunca reutilize número). O arquivo é
   docs/adr/NNNN-titulo-curto.md.
3. Veja se a decisão contradiz algum ADR Aceito. Se sim, o novo ADR terá
   "Substitui: ADR NNNN" (passo 8).
4. Levante o Contexto com o dono: fatos que forçaram a decisão, não opinião.
5. Monte as Alternativas: 2 ou 3, cada uma com prós e contras, e uma
   recomendação. MÍNIMO 2, obrigatório. Confirme no Context7 qualquer
   versão, API ou configuração de biblioteca citada. O dono decide.
6. Escreva o ADR pelo template docs/templates/adr.md, com Status: Proposto
   e a Data de hoje. MOSTRE o arquivo inteiro e espere aprovação antes de
   salvar. Depois de salvo, adicione a linha no índice docs/adr/README.md.
7. Peça o ok do dono para aceitar. Só com um "sim" explícito troque o Status
   do novo ADR para Aceito (com Edit) e atualize o índice.
8. Se o ADR substitui outro, SÓ depois que o novo estiver Aceito, no antigo:
   com Edit, troque apenas a linha de Status, de "- **Status:** Aceito" para
   "- **Status:** Substituído por NNNN". Nada mais no antigo muda. Atualize o
   Status dele no índice.
9. Se a decisão afeta spec ou plano existentes, avise o dono; não os edite
   sozinho.

## Proibido
- Editar qualquer coisa de um ADR Aceito além da linha de Status.
- Usar Write ou MultiEdit num ADR Aceito, ou contornar o hook protect-files.
- Salvar ADR com menos de 2 alternativas, ou sem prós e contras.
- Marcar Aceito sem o "sim" explícito do dono.
- Decidir pelo dono ou escolher stack sem apresentar opções.
- Apagar ADR ou reutilizar número.
- Salvar sem mostrar o conteúdo e receber aprovação.
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).

## Como verificar
- docs/adr/NNNN-titulo-curto.md existe, com número sequencial e o template.
- A seção Alternativas tem pelo menos 2 itens, cada um com prós e contras.
- Status correto: Proposto até o "sim" do dono, depois Aceito.
- docs/adr/README.md lista o ADR novo com Status e Data.
- Se substitui: o novo diz "Substitui: ADR NNNN"; no antigo, `git diff` mostra
  UMA linha mudada (o Status); o índice reflete os dois.
