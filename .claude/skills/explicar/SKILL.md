---
name: explicar
description: Explica um arquivo, trecho, conceito, erro ou stack trace (sem argumento, o git diff atual) começando pelo para quê e depois o como, ligando a Java/OO, nomeando o padrão envolvido e terminando com 2 perguntas para checar o entendimento. Use quando o dono quiser entender o código ou um erro. Não use para corrigir, implementar ou alterar arquivos.
disable-model-invocation: true
argument-hint: "<arquivo, trecho, conceito ou erro>"
disallowed-tools: Edit Write NotebookEdit
---

# Explicar

Alvo pedido: $ARGUMENTS

## Conceito (para você, dono do projeto)
Entender é mais importante do que ter o código pronto. Esta skill só
explica: começa pelo "para quê" (o problema que o código resolve), depois
mostra o "como", e termina testando se você entendeu. Ela não mexe em
nenhum arquivo.

## Passos
1. Entenda o alvo. Se $ARGUMENTS estiver vazio, use `git diff`; se também
   estiver vazio, pergunte o que explicar. Classifique: arquivo/trecho,
   conceito, ou erro/stack trace.
2. Leia o necessário (Read, Grep) e o CLAUDE.md. Antes de afirmar algo sobre
   API, configuração ou versão de biblioteca, confirme no Context7; sem
   confirmação, diga "não sei".
3. Se for ERRO ou STACK TRACE, ensine a lê-lo ANTES de propor correção, passo
   a passo:
   a. o tipo da exceção e a mensagem;
   b. a cadeia "Caused by" (a causa mais funda costuma ser a verdadeira);
   c. a primeira linha da pilha que está no código do projeto;
   d. o que aquela linha fazia e por que falhou.
   Só então descreva a correção possível, em texto, sem aplicá-la.
4. PARA QUÊ: em 1–3 frases, o problema que isso resolve.
5. COMO: o funcionamento, em passos curtos, apontando arquivo:linha.
6. LIGUE A JAVA/OO: relacione a classes, objetos, encapsulamento, interface,
   herança ou composição, polimorfismo. Se o código não for Java, mostre o
   equivalente em Java.
7. NOMEIE O PADRÃO (ex.: Repository, Service, DTO, Factory, Strategy,
   Builder, MVC) e diga por que ele existe. Se não houver padrão claro,
   escreva "nenhum padrão claro"; não force um.
8. Se for algo que o dono provavelmente nunca fez (não aparece em outro lugar
   do repositório ou ele disse que é novo), mostre um exemplo pequeno de
   código (até ~15 linhas), marcado como exemplo.
9. Termine com EXATAMENTE 2 perguntas para checar o entendimento (peça
   explicação com as palavras dele, não sim/não). Espere as respostas e só
   então comente o que acertou e o que faltou.

## Proibido
- Alterar qualquer arquivo (Edit, Write e NotebookEdit estão desativados;
  também não use Bash com cat, echo, sed, tee ou redirecionamento).
- Aplicar correção: só descreva.
- Propor correção de erro sem antes ensinar a ler o stack trace.
- Inventar API ou comportamento de biblioteca.
- Forçar um padrão que não existe no código.
- Usar jargão sem explicar o termo.
- Dar a resposta das 2 perguntas antes de o dono responder.

## Como verificar
- A explicação começa pelo "para quê" e só depois vai ao "como".
- Há a ligação com Java/OO e o padrão nomeado (ou "nenhum padrão claro").
- Em erro: o stack trace foi lido em passos antes de qualquer correção.
- Se era novidade, há um exemplo curto de código.
- Terminou com exatamente 2 perguntas.
- `git status` não mostra nenhuma mudança feita pela skill.
