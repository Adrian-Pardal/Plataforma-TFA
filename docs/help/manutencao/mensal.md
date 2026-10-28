# NOME
mensal — manutenção mensal do ambiente de desenvolvimento

Última verificação: 2026-10-25 · Testado com: WSL2 (Ubuntu), Claude Code 2.1.310, Docker 29.7.2

## PARA QUE SERVE
Mantém o WSL, os pacotes do sistema, o Claude Code e o disco em dia, e
lembra de conferir o Context7. Rotina do guia 1.0.8.

## QUANDO FAZER
Uma vez por mês, com o trabalho salvo e commitado (o passo 3 desliga
o WSL).

## PRÉ-REQUISITOS
- Acesso ao PowerShell no Windows e ao terminal do WSL.
- Nada importante aberto no WSL.

## PASSO A PASSO
1. **No PowerShell do Windows:** atualize o WSL.
   ```powershell
   wsl --update
   ```
2. Veja a versão instalada.
   ```powershell
   wsl --version
   ```
3. Reinicie o WSL para a atualização valer (encerra todas as
   distribuições).
   ```powershell
   wsl --shutdown
   ```
   **Atenção:** o Docker some junto, até você abrir o Docker Desktop de
   novo. Abra-o e espere ficar pronto **antes do passo 9**.
4. **No terminal do WSL:** atualize a lista de pacotes do apt.
   ```bash
   sudo apt update
   ```
5. Instale as atualizações (inclui o `gh`, que vem do repositório do GitHub).
   ```bash
   sudo apt upgrade
   ```
6. Confira o Claude Code (diagnóstico somente leitura).
   ```bash
   claude doctor
   ```
7. Se estiver desatualizado, atualize.
   ```bash
   claude update
   ```
8. Veja o espaço em disco. Olhe a coluna `Use%` e o `Avail`: se restar
   **menos de 10% livre** (`Use%` acima de 90%), limpe antes de seguir.
   ```bash
   df -h /
   ```
9. Veja quanto o Docker usa (o Docker Desktop precisa estar aberto).
   ```bash
   docker system df
   ```
10. Limpe o que o Docker não usa mais (pede confirmação).
    ```bash
    docker system prune
    ```
11. Compare a versão do Context7 com a fixada.
    ```bash
    npm view @upstash/context7-mcp version
    grep context7-mcp .mcp.json
    ```
    Se forem diferentes, siga ferramentas/context7.md.

## COMO CONFERIR QUE DEU CERTO
- `wsl --version` mostra a versão nova.
- `apt list --upgradable` não lista nada importante.
- `claude doctor` termina sem avisos.
- `df -h /` mostra mais de 10% livre.
- `docker system df` responde (se der erro de conexão, o Docker Desktop
  não está aberto).

## SE DER ERRADO
- `wsl --update` falhou: tente `wsl --update --web-download` (baixa do
  GitHub em vez da Microsoft Store).
- `apt upgrade` quebrou algo: leia a mensagem de erro e registre em
  docs/erros (use /registrar-erro). Não rode `apt` com `-y` às cegas.
- `docker system prune` não tem desfazer. Ele remove contêineres parados,
  redes sem uso, imagens sem tag e cache de build; **não** toca em
  volumes (só com `--volumes`, e não use sem saber o que há neles).
  Imagens voltam com `docker pull`.

## VER TAMBÉM
- ferramentas/context7.md
- ferramentas/instaladas.md
