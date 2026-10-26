# NOME
lefthook — instalar os hooks do git, conferir e o que fazer se um commit for recusado

Última verificação: 2026-10-25 · Testado com: lefthook 2.2.2, gitleaks 8.30.1

## PARA QUE SERVE
O `lefthook.yml` (na raiz) faz o git conferir três coisas antes de aceitar
um commit:
- **verify-quick:** roda `scripts/verify.sh quick` (compila/tipa/lint, só o que existir).
- **segredos:** roda `gitleaks git --staged` e olha só o que está em stage.
- **conventional-commits:** a primeira linha da mensagem precisa ser
  `tipo(escopo opcional): descrição`, com tipo `feat`, `fix`, `docs`,
  `test`, `refactor`, `chore`, `ci`, `build` ou `perf`. O `!` depois do
  tipo marca quebra de compatibilidade. Mensagens que começam com `Merge `
  ou `Revert "` (geradas pelo git) também passam. Rodapés como `Task: T3`
  ficam depois de uma linha em branco e são aceitos.

Sem a instalação, o git ignora o `lefthook.yml` e nada disso roda.

## QUANDO FAZER
- Uma vez em cada clone novo do repositório.
- De novo se a pasta `.git/hooks` for apagada ou se o `lefthook.yml` mudar.
- Depois de trocar de versão do Node no nvm (veja `instaladas.md`): o
  `lefthook` global some do PATH até ser reinstalado.

## PRÉ-REQUISITOS
- `lefthook` e `gitleaks` instalados (`lefthook version`, `gitleaks version`).
  Instalação e atualização: `ferramentas/instaladas.md`.
- Estar na raiz do projeto.

## PASSO A PASSO
1. Instale os hooks no clone.
   ```bash
   lefthook install
   ```
2. Confira que os hooks foram criados.
   ```bash
   ls -l .git/hooks/pre-commit .git/hooks/commit-msg
   ```
3. Teste a validação de mensagem com um arquivo de mensagem qualquer.
   ```bash
   printf 'feat: teste\n' > /tmp/msg-teste && lefthook run commit-msg /tmp/msg-teste
   ```

## COMO CONFERIR QUE DEU CERTO
- Os dois arquivos do passo 2 existem e são executáveis.
- `lefthook run pre-commit` termina com `✔️ segredos` e `✔️ verify-quick`.
- Um commit normal mostra o quadro `🥊 lefthook` com os três itens aprovados.
- Para testar tudo de uma vez: `scripts/tests/lefthook.test.sh`.

## SE DER ERRADO

### Um commit foi recusado
Leia a mensagem do hook: o item que falhou aparece com ❌ e o texto de ajuda.
O commit NÃO foi feito; seus arquivos continuam em stage. Corrija e
repita o `git commit`.

| Item que falhou | O que significa | O que fazer |
|---|---|---|
| `verify-quick` | `scripts/verify.sh quick` deu erro | Leia o erro acima, corrija o código e commite de novo. |
| `segredos` | O gitleaks achou algo que parece senha, token ou chave | Tire o segredo do arquivo (use `.env`, que não vai para o git) e `git add` de novo. Se for falso positivo, não ignore sozinho: veja `docs/DEBT.md` e fale com o dono. |
| `conventional-commits` | A primeira linha da mensagem fora do padrão | Reescreva. Exemplo: `feat(pesquisa): cria cadastro de construto`. |

Se um segredo **já foi commitado** (ou enviado ao remoto), apagar o
arquivo não basta: o segredo continua no histórico. Troque a credencial
(gere uma nova e revogue a antiga) antes de qualquer outra coisa.

### Outros problemas
- **`gitleaks: command not found`:** o commit é bloqueado de propósito
  (falha segura). Confira o PATH (`which gitleaks`; ele fica em
  `~/.local/bin`) e veja `ferramentas/instaladas.md`.
- **`lefthook: command not found`:** o git avisa e o commit passa sem
  nenhuma verificação. Reinstale o lefthook (`instaladas.md`) e rode
  `lefthook install` de novo.
- **Hooks não rodam:** repita o passo 2. Se os arquivos não existem,
  rode `lefthook install`.
- **Voltar atrás (remover os hooks deste clone):** `lefthook uninstall`.

> **Não contorne o hook.** `git commit --no-verify` e `LEFTHOOK=0` pulam
> as verificações. O CLAUDE.md proíbe enfraquecer hooks: corrija a causa.

## VER TAMBÉM
- `ferramentas/instaladas.md` (instalar e atualizar lefthook e gitleaks)
- `ferramentas/testes-dos-hooks.md` (testes automáticos do `lefthook.yml`)
- `lefthook.yml` na raiz do projeto
