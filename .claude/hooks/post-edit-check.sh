#!/usr/bin/env bash
# post-edit-check.sh — hook PostToolUse (Edit|Write|MultiEdit).
# Depois de editar código ou arquivo de build, roda "scripts/verify.sh quick" e devolve o erro ao Claude se falhar.
# Saída: 0 = ok (ou nada a verificar) · 2 = falhou (o stderr é mostrado ao Claude; a edição já foi feita).
set -uo pipefail   # sem -e de propósito: cada ramo decide seu próprio código de saída

falhar() { echo "🚫 post-edit-check: $1" >&2; exit 2; }

command -v jq >/dev/null || falhar "jq não encontrado; não consegui decidir se há algo a verificar."
ENTRADA=$(cat)
ARQ=$(jq -r '.tool_input.file_path // empty' <<<"$ENTRADA") || falhar "entrada JSON inválida."
[[ -n "$ARQ" ]] || exit 0

# Só código e arquivos de build. Qualquer outra coisa (.md, .json comum, .sh...) sai com 0 sem rodar nada.
BASE="${ARQ##*/}"
case "${BASE,,}" in
  *.java|*.kt|*.ts|*.tsx|*.js|*.jsx) ;;                                                   # código
  pom.xml|build.gradle|build.gradle.kts|settings.gradle*|package.json|tsconfig*.json) ;; # build
  *) exit 0 ;;
esac

# Raiz do projeto: $CLAUDE_PROJECT_DIR; se não existir, o cwd que veio no JSON.
DIR="${CLAUDE_PROJECT_DIR:-$(jq -r '.cwd // empty' <<<"$ENTRADA")}"
VERIFY="$DIR/scripts/verify.sh"
[[ -x "$VERIFY" ]] || falhar "$VERIFY não encontrado ou sem permissão de execução."

# Roda de dentro da raiz, juntando stdout e stderr para poder mostrar o final.
SAIDA=$(cd "$DIR" && "$VERIFY" quick 2>&1)
CODIGO=$?

if [[ $CODIGO -ne 0 ]]; then
  {
    echo "🚫 post-edit-check: 'scripts/verify.sh quick' falhou (código $CODIGO) depois de editar $ARQ."
    echo "Últimas 40 linhas da saída:"
    tail -n 40 <<<"$SAIDA"
    echo "Corrija a causa (não enfraqueça a verificação) e edite de novo."
  } >&2
  exit 2
fi
exit 0
