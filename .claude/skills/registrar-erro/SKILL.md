---
name: registrar-erro
description: Registra um erro relevante em docs/erros/ERR-NNN-<titulo>.md, com causa raiz (5 porquês), correção, teste de regressão, prevenção e lição para a IA; se o erro já existe, incrementa a recorrencias em vez de duplicar. Use depois de corrigir (ou entender) um bug, erro da IA, problema de ambiente ou falha de produção. Não use para dúvida, ajuste trivial ou erro sem causa raiz descoberta (investigue antes).
---

# Registrar erro

## Conceito (para você, dono do projeto)
Registrar erro é transformar um tropeço em aprendizado permanente. Cada
ERR-NNN guarda o que aconteceu, por que aconteceu (causa raiz, não só o
sintoma) e como impedir que volte. Se o mesmo erro reaparece, registrar de
novo não basta: ele exige uma defesa automática (regra, hook ou CI).

## Passos
1. Confirme que o erro é relevante e que a causa raiz foi descoberta. Sem
   causa raiz, PARE e continue a investigação; não registre por suposição.
2. Procure em docs/erros/ (README e arquivos) se o erro já existe. Compare
   sintoma e causa raiz.
3. Se já existe: some 1 em `recorrencias` (campo do cabeçalho YAML),
   acrescente a data e issue/PR em "Ocorrências" e atualize o que mudou.
   NÃO crie arquivo novo. Vá ao passo 7.
4. Se não existe: o próximo número é o maior ERR-NNN + 1 (3 dígitos). Crie
   docs/erros/ERR-NNN-<titulo-curto>.md pelo template docs/templates/erro.md.
   `recorrencias` começa em 1.
5. Preencha tudo com evidência da sessão (saídas, commits). Campos do
   cabeçalho: categoria (bug, erro-ia, ambiente, producao), severidade
   (baixa, media, alta, critica), detectado-em (local, ci, revisao, producao).
   Status: `corrigido` quando correção e teste existem; `aberto` se a causa
   raiz é conhecida mas a correção está pendente; `aceito` só por decisão do
   dono. Não use `investigando` para registrar: investigue antes. Causa raiz
   em 5 porquês; o que não souber, escreva "não sei". Se há código envolvido,
   o teste de regressão é obrigatório e deve existir e falhar sem a correção.
6. MOSTRE o arquivo inteiro e espere aprovação antes de salvar. Depois
   atualize a tabela de docs/erros/README.md (ID | Título | Categoria |
   Severidade | Status | Data | Recorrências); remova a linha "nenhum erro
   registrado ainda" na primeira vez.
7. Segunda ocorrência (`recorrencias` passou a 2 ou mais): exija uma prevenção
   AUTOMÁTICA, uma destas: regra no CLAUDE.md, hook ou passo do CI. Proponha
   2–3 opções com prós e contras; o dono decide. O CLAUDE.md tem limite de 60
   linhas: se a opção for ele, mostre antes o que enxugar. Registre a escolha
   em "Prevenção".
8. Se a prevenção for decisão de arquitetura, acione registrar-adr.

## Proibido
- Registrar sem causa raiz.
- Registrar sem teste de regressão quando houver código envolvido (sem
  código, escreva "não se aplica" com o motivo).
- Duplicar um erro que já existe: atualize o existente.
- Inventar causa, sintoma ou saída que a sessão não mostrou.
- Aceitar "tenha mais cuidado" como prevenção na segunda ocorrência.
- Salvar sem mostrar o conteúdo e receber aprovação.
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).

## Como verificar
- Existe um único arquivo ERR-NNN para o erro, com número sequencial.
- O cabeçalho YAML e todas as seções do template estão preenchidos; a causa
  raiz tem 5 porquês.
- Com código envolvido: o teste de regressão existe e está citado.
- docs/erros/README.md lista o erro com categoria, severidade, status e
  recorrências.
- Em recorrência: `recorrencias` subiu e a prevenção automática está escolhida.
