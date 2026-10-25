#!/usr/bin/env bash
# protect-files.sh — hook PreToolUse do Claude Code.
# Bloqueia (exit 2) a escrita em arquivos sensíveis e em ADR aceito, e a leitura de segredos pelo Bash.
# Entrada: JSON no stdin. Saída: 0 = deixa seguir · 2 = bloqueia (stderr vira o motivo).
set -uo pipefail   # sem -e de propósito: cada ramo decide seu próprio código de saída

bloquear() { echo "🚫 protect-files: $1" >&2; exit 2; }

# Falhar "fechado": se não dá para ler a entrada com segurança, bloqueia.
command -v jq >/dev/null || bloquear "jq não encontrado; hook bloqueando por segurança. Instale o jq (sudo apt install jq)."
ENTRADA=$(cat)
TOOL=$(jq -r '.tool_name // empty' <<<"$ENTRADA") || bloquear "entrada JSON inválida; hook bloqueando por segurança."
CWD=$(jq -r '.cwd // empty' <<<"$ENTRADA")
CWD="${CWD:-$PWD}"

# --- Regras de caminho --------------------------------------------------------
# Caminho sensível (exceto ADR): escreve o motivo em stdout e retorna 0 se for.
# Em modo "leitura" só valem .env* e secrets/ (chaves .pem/.key só são protegidas contra escrita).
motivo_sensivel() {   # $1 = caminho · $2 = "leitura" (opcional)
  local base="${1##*/}"
  case "/$1/" in */secrets/*) echo "pasta secrets/"; return 0 ;; esac
  case "$base" in
    .env.example) return 1 ;;                       # modelo sem segredos: liberado
    .env|.env.*)  echo "arquivo de ambiente ($base)"; return 0 ;;
    *.pem|*.key)  [[ "${2:-}" == leitura ]] || { echo "chave/certificado ($base)"; return 0; } ;;
  esac
  return 1
}
eh_adr() { [[ "$1" =~ (^|/)docs/adr/[0-9]{4}-[^/]*\.md$ ]]; }   # README.md não casa
adr_aceito() {   # caminho relativo é resolvido a partir do cwd da sessão
  local p="$1"; [[ "$p" == /* ]] || p="$CWD/$p"
  [[ -f "$p" ]] && grep -qE '^- \*\*Status:\*\* Aceito[[:space:]]*$' "$p"
}

# --- Edit / Write / MultiEdit -------------------------------------------------
# A única mudança permitida num ADR aceito: trocar o Status para "Substituído por NNNN".
troca_de_status_permitida() {   # $1 = caminho do ADR
  local re_novo='^(- )?\*\*Status:\*\* Substituído por [0-9]{4}$' re_velho='^(- )?\*\*Status:\*\* Aceito$'
  case "$TOOL" in
    Edit)
      local velho novo
      velho=$(jq -r '.tool_input.old_string // empty' <<<"$ENTRADA")
      novo=$(jq -r '.tool_input.new_string // empty' <<<"$ENTRADA")
      [[ "$velho" =~ $re_velho && "$novo" =~ $re_novo ]] ;;
    Write)
      # Permitido só se o arquivo novo for IGUAL ao atual, exceto pela linha de Status.
      local atual novo lin_atual lin_novo
      atual=$(<"$1")
      novo=$(jq -r '.tool_input.content // empty' <<<"$ENTRADA")
      lin_atual=$(grep -m1 -E '^- \*\*Status:\*\* Aceito[[:space:]]*$' "$1")
      lin_novo=$(grep -m1 -E '^- \*\*Status:\*\* ' <<<"$novo")
      [[ "$lin_novo" =~ $re_novo ]] && [[ "${atual/"$lin_atual"/"$lin_novo"}" == "$novo" ]] ;;
    *) return 1 ;;   # MultiEdit: sem exceção (formato não confirmado na doc)
  esac
}

verificar_arquivo() {
  local caminho="$1" motivo
  if motivo=$(motivo_sensivel "$caminho"); then
    bloquear "edição bloqueada: $motivo. Edite este arquivo você mesmo, fora do Claude."
  fi
  if eh_adr "$caminho" && adr_aceito "$caminho"; then
    troca_de_status_permitida "$caminho" && return 0
    bloquear "$caminho é um ADR Aceito e não se edita. Crie um novo ADR que o substitua; no antigo, troque SÓ a linha de Status para 'Substituído por NNNN' (com Edit)."
  fi
}

# --- Bash (segunda barreira) --------------------------------------------------
# Confere UM caminho já "limpo". $1 = caminho · $2 = escrita | leitura · $3 = texto original (para a mensagem)
checar_caminho() {
  local motivo
  if motivo=$(motivo_sensivel "$1" "$2"); then
    if [[ "$2" == leitura ]]; then
      bloquear "o comando leria $motivo ('$3'): o segredo entraria na conversa. Peça ao dono para informar só o que precisa (ex.: os NOMES das variáveis)."
    fi
    bloquear "o comando escreveria em $motivo ('$3'). Quem cria/edita este arquivo é o dono, fora do Claude."
  fi
  if [[ "$2" == escrita ]] && eh_adr "$1" && adr_aceito "$1"; then
    bloquear "o comando alteraria o ADR Aceito '$3'. Para marcá-lo como substituído, use Edit só na linha de Status."
  fi
}

verificar_alvo_bash() {   # $1 = argumento do comando (relativo, absoluto ou com glob) · $2 = escrita | leitura
  local tok=${1//\'/} f abs re_glob='[*?[]'
  tok=${tok//\"/}
  [[ -z "$tok" ]] && return 0
  checar_caminho "$tok" "$2" "$tok"                 # o texto como foi escrito
  if [[ "$tok" =~ $re_glob ]]; then                 # e, se tem glob, cada arquivo que ele expande
    abs="$tok"; [[ "$abs" == /* ]] || abs="$CWD/$tok"
    while IFS= read -r f; do checar_caminho "$f" "$2" "$tok"; done < <(compgen -G "$abs" || true)
  fi
}

tem_sed_inplace() { local a; for a in "$@"; do [[ "$a" =~ ^(-[A-Za-z]*i|--in-place) ]] && return 0; done; return 1; }

analisar_bash() {
  local cmd="$1" alvo seg i verbo arg modo
  local -a t
  # (a) escrita por redirecionamento > e >> (ignora 2>&1, pois o alvo não pode começar com &)
  while IFS= read -r alvo; do
    verificar_alvo_bash "$alvo" escrita
  done < <(grep -oE '[0-9]*>>?[[:space:]]*[^[:space:]<>|;&]+' <<<"$cmd" | sed -E 's/^[0-9]*>>?[[:space:]]*//')

  # (b) leitura por redirecionamento de entrada: cmd < .env (não confunde com << e <<<)
  while IFS= read -r alvo; do
    verificar_alvo_bash "$alvo" leitura
  done < <(grep -oE '(^|[^<])<[[:space:]]*[^[:space:]<>|;&(]+' <<<"$cmd" | sed -E 's/^[^<]*<[[:space:]]*//')

  # (c) verbos de escrita/leitura: separa por ; && || | e olha o 1º comando de cada pedaço
  while IFS= read -r seg; do
    read -ra t <<<"$seg"
    i=0
    # pula prefixos: VAR=valor, sudo, env, command, nohup, time
    while [[ $i -lt ${#t[@]} && "${t[$i]}" =~ ^([A-Za-z_][A-Za-z0-9_]*=.*|sudo|env|command|nohup|time)$ ]]; do i=$((i + 1)); done
    [[ $i -ge ${#t[@]} ]] && continue
    verbo="${t[$i]##*/}"
    case "$verbo" in
      tee|cp|mv|rm) modo=escrita ;;
      sed) tem_sed_inplace "${t[@]:$((i + 1))}" || continue; modo=escrita ;;
      cat|less|more|head|tail|grep|source|.) modo=leitura ;;
      *) continue ;;
    esac
    for arg in "${t[@]:$((i + 1))}"; do
      [[ "$arg" == -* ]] && continue
      verificar_alvo_bash "$arg" "$modo"
    done
  done < <(sed -E 's/(&&|\|\||;|\|)/\n/g' <<<"$cmd")
}

# --- Programa principal -----------------------------------------------------------
case "$TOOL" in
  Edit|Write|MultiEdit)
    ARQ=$(jq -r '.tool_input.file_path // empty' <<<"$ENTRADA")
    [[ -n "$ARQ" ]] && verificar_arquivo "$ARQ"
    ;;
  Bash)
    CMD=$(jq -r '.tool_input.command // empty' <<<"$ENTRADA")
    [[ -n "$CMD" ]] && analisar_bash "$CMD"
    ;;
esac
exit 0
