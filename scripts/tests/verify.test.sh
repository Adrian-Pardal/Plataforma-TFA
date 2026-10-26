#!/usr/bin/env bash
# verify.test.sh — testes da detecção de testes desativados/isolados do verify.sh.
# Cria um projeto falso numa pasta temporária e aponta VERIFY_RAIZ para ele.
# Uso: scripts/tests/verify.test.sh   (sai com 1 se algum caso falhar)
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VERIFY="$RAIZ/scripts/verify.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
falhas=0

caso() {   # caso <código esperado> <descrição> <conteúdo do arquivo de teste>
  local esperado="$1" descricao="$2" conteudo="$3" obtido
  mkdir -p "$TMP/src/test"
  printf '%s\n' "$conteudo" > "$TMP/src/test/a.test.ts"
  VERIFY_RAIZ="$TMP" "$VERIFY" test >/dev/null 2>&1
  obtido=$?
  if [[ "$obtido" == "$esperado" ]]; then
    echo "  ok    ($esperado) $descricao"
  else
    echo "  FALHA (esperado $esperado, veio $obtido) $descricao" >&2
    falhas=$((falhas + 1))
  fi
}

echo "▶ verify.sh: testes desativados ou isolados"
caso 0 "teste normal passa"                       "it('x', () => {});"
caso 1 "it.only reprova"                          "it.only('x', () => {});"
caso 1 "xit reprova"                              "xit('x', () => {});"
caso 1 "fit reprova"                              "fit('x', () => {});"
caso 1 "fdescribe reprova"                        "fdescribe('x', () => {});"
caso 0 "fit com DEBT na linha anterior passa"     $'// DEBT-001\nfit(\'x\', () => {});'
caso 0 "benefit( não é falso positivo"            "const b = benefit(2);"

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
