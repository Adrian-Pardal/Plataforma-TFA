#!/usr/bin/env bash
# stop-verify.sh — hook Stop.
# Quando o Claude tenta encerrar, se há mudança em código/build no working tree, roda "scripts/verify.sh test".
# Saída: 0 = pode encerrar · 2 = testes falharam (o stderr volta ao Claude e ele continua trabalhando).
set -uo pipefail   # sem -e de propósito: cada ramo decide seu próprio código de saída

falhar() { echo "🚫 stop-verify: $1" >&2; exit 2; }

command -v jq >/dev/null || falhar "jq não encontrado; não consegui ler a entrada do hook."
ENTRADA=$(cat)

# Anti-loop: se o Claude já está continuando por causa de um bloqueio deste hook, deixa encerrar.
# Sem isso: testes falham -> exit 2 -> Claude continua -> tenta parar -> hook roda de novo -> ... para sempre.
ATIVO=$(jq -r '.stop_hook_active // false' <<<"$ENTRADA") || falhar "entrada JSON inválida."
[[ "$ATIVO" == "true" ]] && exit 0

DIR="${CLAUDE_PROJECT_DIR:-$(jq -r '.cwd // empty' <<<"$ENTRADA")}"
[[ -n "$DIR" && -d "$DIR" ]] || falhar "não consegui descobrir a raiz do projeto."

# -uall lista cada arquivo novo (sem isso, uma pasta nova inteira apareceria como "?? pasta/").
STATUS=$(git -C "$DIR" status --porcelain -uall 2>/dev/null) || exit 0   # fora de um repositório git: nada a decidir

# Há mudança em código ou build? (mesmas extensões do post-edit-check.sh)
HA_CODIGO=0
while IFS= read -r LINHA; do
  [[ -n "$LINHA" ]] || continue
  CAMINHO="${LINHA:3}"                # tira os 2 códigos de status + espaço
  CAMINHO="${CAMINHO##* -> }"         # renomeação: "antigo -> novo", vale o novo
  CAMINHO="${CAMINHO%\"}"             # nomes com caracteres especiais vêm entre aspas
  BASE="${CAMINHO##*/}"
  case "${BASE,,}" in
    *.java|*.kt|*.ts|*.tsx|*.js|*.jsx) HA_CODIGO=1; break ;;
    pom.xml|build.gradle|build.gradle.kts|settings.gradle*|package.json|tsconfig*.json) HA_CODIGO=1; break ;;
  esac
done <<<"$STATUS"
[[ $HA_CODIGO -eq 1 ]] || exit 0

VERIFY="$DIR/scripts/verify.sh"
[[ -x "$VERIFY" ]] || falhar "$VERIFY não encontrado ou sem permissão de execução."

SAIDA=$(cd "$DIR" && "$VERIFY" test 2>&1)
CODIGO=$?

if [[ $CODIGO -ne 0 ]]; then
  {
    echo "Os testes não estão 100% verdes. Investigue a causa e corrija antes de encerrar; só altere um teste se ele estiver errado."
    echo "Últimas 60 linhas de 'scripts/verify.sh test' (código $CODIGO):"
    tail -n 60 <<<"$SAIDA"
  } >&2
  exit 2
fi
exit 0
