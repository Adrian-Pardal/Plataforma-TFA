# NOME
context7 — conferir e atualizar a versão do servidor MCP do Context7

Última verificação: 2026-10-25 · Testado com: @upstash/context7-mcp 4.4.4, Node 24.22.1

## PARA QUE SERVE
O `.mcp.json` fixa o servidor em `@upstash/context7-mcp@4.4.4`. A versão
não muda sozinha. Se ninguém olhar, o projeto fica numa versão antiga,
possivelmente com falha corrigida depois. O Dependabot trabalha com
manifestos de gerenciadores de pacote (como `package.json`); não há um
ecossistema para o `.mcp.json`, então a conferência é manual.

## QUANDO FAZER
Uma vez por mês (junto com manutencao/mensal.md) ou quando souber de
uma correção importante do Context7.

## PRÉ-REQUISITOS
- Árvore git limpa (`git status` sem alterações).
- Node >= 20.18.1 (campo `engines` do pacote; aqui: 24.22.1).
- Internet.

## PASSO A PASSO
1. Veja a versão fixada hoje.
   ```bash
   grep context7-mcp .mcp.json
   ```
2. Veja a última versão publicada no npm.
   ```bash
   npm view @upstash/context7-mcp version
   ```
   Se for igual à fixada, pare aqui.
3. Leia as notas de versão no GitHub oficial
   (https://github.com/upstash/context7/releases). As do servidor têm a
   tag `@upstash/context7-mcp@<versão>`. Procure mudança que quebra
   (palavras como "breaking", opções removidas) e o Node mínimo.
4. Confirme o Node mínimo da versão nova.
   ```bash
   npm view @upstash/context7-mcp@<nova> engines
   ```
5. Crie uma branch para a troca.
   ```bash
   git switch -c chore/context7-<nova>
   ```
6. Troque `4.4.4` pela versão nova no `.mcp.json` (no editor, ou peça
   ao Claude). Mantenha a versão fixada, sem `latest`.
7. Teste o comando antes de abrir o Claude.
   ```bash
   npx -y @upstash/context7-mcp@<nova> --version
   ```
8. Abra o `claude` na pasta do projeto, aprove o servidor se pedir e
   rode `/mcp`.
9. Se tudo funcionou, registre a mudança no git.
   ```bash
   git add .mcp.json
   ```
   ```bash
   git commit -m "chore: atualiza Context7 para <nova>"
   ```
10. Envie a branch e abra o PR para a `develop`.
    ```bash
    git push -u origin chore/context7-<nova>
    ```
    ```bash
    gh pr create --base develop --title "chore: atualiza Context7 para <nova>" --body "Atualiza @upstash/context7-mcp de 4.4.4 para <nova>. Testado com /mcp."
    ```

## COMO CONFERIR QUE DEU CERTO
- O passo 7 imprime a versão nova.
- No `/mcp`, `context7` aparece como conectado, com as ferramentas
  `resolve-library-id` e `query-docs`.
- Peça ao Claude algo como "use o Context7 para ver a doc de <biblioteca>"
  e confirme que ele chama `query-docs`.

## SE DER ERRADO
- Antes do commit: desfaça a troca e reconecte.
  ```bash
  git restore .mcp.json
  ```
  Depois rode `/mcp` e reconecte o servidor.
- Depois do commit: `git revert <hash-do-commit>`.
- Não faça merge do PR enquanto o `/mcp` não mostrar o servidor conectado.

## VER TAMBÉM
- manutencao/mensal.md
- CLAUDE.md, seção 5 (Anti-alucinação)
- Hoje não usamos chave de API (ela é opcional). Se passar a usar, vai
  só por variável de ambiente (`CONTEXT7_API_KEY`), nunca no arquivo, e
  isso ganha página nova aqui.
