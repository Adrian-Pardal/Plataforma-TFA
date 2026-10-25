#!/usr/bin/env bash
# protect-push.sh — hook PreToolUse (Bash).
# Bloqueia "git push" perigoso: remoto que não é origin, destino fora dos prefixos permitidos, force, delete, mirror, all, tags.
# Saída: 0 = liberado (ou não é push) · 2 = bloqueado (o stderr é mostrado ao Claude e o comando NÃO roda).
set -uo pipefail   # sem -e de propósito: cada ramo decide seu próprio código de saída

bloquear() { echo "🚫 protect-push: $1" >&2; exit 2; }

# Só estes prefixos de branch podem receber push. Isso exclui main, develop, nomes soltos ("foo") e tags ("v1.0").
PREFIXOS_OK='feat/|fix/|docs/|test/|refactor/|chore/|hotfix/'
prefixo_ok() { [[ "$1" =~ ^($PREFIXOS_OK). ]]; }

command -v jq >/dev/null || bloquear "jq não encontrado; não consegui ler o comando, então bloqueio por segurança."
ENTRADA=$(cat)
CMD=$(jq -r '.tool_input.command // empty' <<<"$ENTRADA") || bloquear "entrada JSON inválida."
[[ -n "$CMD" ]] || exit 0

CWD=$(jq -r '.cwd // empty' <<<"$ENTRADA")
[[ -n "$CWD" ]] || CWD="${CLAUDE_PROJECT_DIR:-.}"

# Um comando pode juntar vários ("cd x && git push ..."): separa em um segmento por linha.
CMD="${CMD//&&/$'\n'}"; CMD="${CMD//||/$'\n'}"; CMD="${CMD//;/$'\n'}"; CMD="${CMD//|/$'\n'}"

analisar_push() {   # $1 = pasta onde o git roda; demais = argumentos depois de "push"
  local DIR="$1"; shift
  local REMOTO="" ; local -a REFS=()
  local A
  while [[ $# -gt 0 ]]; do
    A="$1"; shift
    case "$A" in
      --force|--force-with-lease*|--force-if-includes) bloquear "push forçado ($A) não é permitido." ;;
      --mirror|--all|--tags|--delete|--prune) bloquear "'git push $A' não é permitido (pode apagar ou sobrescrever coisas no remoto)." ;;
      --repo=*|--receive-pack=*|--exec=*|--push-option=*) ;;
      --repo|--receive-pack|--exec|--push-option|-o) shift ;;     # opções que carregam um valor
      --*) ;;                                                     # outras opções longas (--dry-run, --set-upstream...)
      -?*)                                                        # opções curtas, possivelmente juntas (-fu, -df)
        [[ "$A" == *f* ]] && bloquear "push forçado ($A) não é permitido."
        [[ "$A" == *d* ]] && bloquear "'git push $A' (delete) não é permitido." ;;
      *) if [[ -z "$REMOTO" ]]; then REMOTO="$A"; else REFS+=("$A"); fi ;;
    esac
  done

  local ATUAL; ATUAL=$(git -C "$DIR" branch --show-current 2>/dev/null)

  # Sem remoto explícito, o git usa o configurado para a branch (padrão: origin).
  if [[ -z "$REMOTO" ]]; then
    REMOTO=$(git -C "$DIR" config "branch.$ATUAL.remote" 2>/dev/null) || REMOTO=""
    [[ -n "$REMOTO" ]] || REMOTO="origin"
  fi
  [[ "$REMOTO" == "origin" ]] || bloquear "só é permitido dar push para 'origin' (você usou '$REMOTO')."

  # Sem branch explícita, o git envia a branch atual.
  if [[ ${#REFS[@]} -eq 0 ]]; then
    prefixo_ok "$ATUAL" || bloquear "'git push' sem destino estando na branch '${ATUAL:-(nenhuma)}'. Só são permitidas branches com prefixo ${PREFIXOS_OK//|/ }."
    return 0
  fi

  local R DEST
  for R in "${REFS[@]}"; do
    [[ "$R" == +* ]] && bloquear "refspec com '+' ($R) é push forçado."
    if [[ "$R" == *:* ]]; then
      [[ "$R" == :* ]] && bloquear "refspec '$R' apaga a branch no remoto."
      DEST="${R##*:}"
    else
      DEST="$R"
    fi
    DEST="${DEST#refs/heads/}"
    [[ "$DEST" == "HEAD" ]] && DEST="$ATUAL"      # "git push origin HEAD" envia para a branch atual
    prefixo_ok "$DEST" || bloquear "destino '$DEST' (de '$R') não é permitido. Só são permitidas branches com prefixo ${PREFIXOS_OK//|/ } (tags e main/develop ficam com o dono)."

  done
  return 0
}

while IFS= read -r SEG; do
  SEG="${SEG//\"/}"; SEG="${SEG//\'/}"          # tira aspas; não precisamos de parsing perfeito, só dos argumentos
  read -ra TOK <<<"$SEG"
  [[ ${#TOK[@]} -gt 0 ]] || continue

  i=0
  while [[ $i -lt ${#TOK[@]} && "${TOK[$i]}" == *=* ]]; do i=$((i+1)); done   # pula "VAR=valor git push"
  [[ "${TOK[$i]:-}" == "git" ]] || continue
  i=$((i+1))

  # Opções globais do git antes do subcomando: "git -C pasta push", "git -c k=v push".
  DIR="$CWD"
  while [[ $i -lt ${#TOK[@]} && "${TOK[$i]}" == -* ]]; do
    case "${TOK[$i]}" in
      -C) DIR="${TOK[$((i+1))]:-$DIR}"; [[ "$DIR" == /* ]] || DIR="$CWD/$DIR"; i=$((i+2)) ;;
      -c|--git-dir|--work-tree|--namespace) i=$((i+2)) ;;
      *) i=$((i+1)) ;;
    esac
  done

  [[ "${TOK[$i]:-}" == "push" ]] || continue
  analisar_push "$DIR" "${TOK[@]:$((i+1))}"
done <<<"$CMD"

exit 0
