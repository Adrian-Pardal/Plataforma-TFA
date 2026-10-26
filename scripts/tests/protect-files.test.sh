#!/usr/bin/env bash
# protect-files.test.sh — testes do hook protect-files.sh (escrita em ADR Aceito).
# Monta um projeto temporário com um ADR Aceito e roda o hook com o diretório do processo em "/",
# diferente do "cwd" do JSON: assim um caminho relativo só funciona se o hook o resolver com o cwd.
# Uso: scripts/tests/protect-files.test.sh   (sai com 1 se algum caso falhar)
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOOK="$RAIZ/.claude/hooks/protect-files.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
falhas=0

ADR_REL="docs/adr/0009-exemplo.md"
mkdir -p "$TMP/docs/adr"
ORIGINAL=$'# ADR 0009\n\n- **Status:** Aceito\n- **Data:** 2026-01-01\n\nTexto da decisão.'
printf '%s\n' "$ORIGINAL" > "$TMP/$ADR_REL"

caso() {   # caso <código esperado> <descrição> <file_path> <conteúdo novo do Write>
  local esperado="$1" descricao="$2" caminho="$3" conteudo="$4" obtido
  jq -n --arg p "$caminho" --arg c "$conteudo" --arg d "$TMP" \
    '{tool_name: "Write", tool_input: {file_path: $p, content: $c}, cwd: $d}' \
    | (cd / && "$HOOK") >/dev/null 2>&1
  obtido=$?
  if [[ "$obtido" == "$esperado" ]]; then
    echo "  ok    ($esperado) $descricao"
  else
    echo "  FALHA (esperado $esperado, veio $obtido) $descricao" >&2
    falhas=$((falhas + 1))
  fi
}

SO_STATUS="${ORIGINAL/'- **Status:** Aceito'/'- **Status:** Substituído por 0010'}"
OUTRA_LINHA="${SO_STATUS/Texto da decisão./Texto alterado.}"

echo "▶ protect-files: Write em ADR Aceito"
caso 0 "caminho relativo, só troca o Status"        "$ADR_REL"      "$SO_STATUS"
caso 0 "caminho absoluto, só troca o Status"        "$TMP/$ADR_REL" "$SO_STATUS"
caso 2 "caminho relativo, altera outra linha"       "$ADR_REL"      "$OUTRA_LINHA"
caso 2 "caminho absoluto, altera outra linha"       "$TMP/$ADR_REL" "$OUTRA_LINHA"

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
