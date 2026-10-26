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

# Projeto falso com scripts/tests/*.test.sh e scripts/*.sh próprios.
TMP2="$(mktemp -d)"
trap 'rm -rf "$TMP" "$TMP2"' EXIT

caso_scripts() {   # caso_scripts <esperado> <modo> <descrição> <conteúdo do teste> <conteúdo do script>
  local esperado="$1" modo="$2" descricao="$3" teste="$4" script="$5" obtido
  rm -rf "$TMP2/scripts"; mkdir -p "$TMP2/scripts/tests"
  printf '%s\n' "$teste" > "$TMP2/scripts/tests/a.test.sh"; chmod +x "$TMP2/scripts/tests/a.test.sh"
  printf '%s\n' "$script" > "$TMP2/scripts/b.sh"
  VERIFY_RAIZ="$TMP2" "$VERIFY" "$modo" >/dev/null 2>&1
  obtido=$?
  if [[ "$obtido" == "$esperado" ]]; then
    echo "  ok    ($esperado) $descricao"
  else
    echo "  FALHA (esperado $esperado, veio $obtido) $descricao" >&2
    falhas=$((falhas + 1))
  fi
}

TESTE_OK=$'#!/usr/bin/env bash\nexit 0'
TESTE_RUIM=$'#!/usr/bin/env bash\nexit 1'
SCRIPT_OK=$'#!/usr/bin/env bash\necho "oi"'
SCRIPT_RUIM=$'#!/usr/bin/env bash\ncd $1'   # SC2086/SC2164: shellcheck reclama

echo "▶ verify.sh: roda scripts/tests/*.test.sh nos modos test e full"
caso_scripts 0 test "test: teste de script que passa"  "$TESTE_OK"   "$SCRIPT_OK"
caso_scripts 1 test "test: teste de script que falha"  "$TESTE_RUIM" "$SCRIPT_OK"
caso_scripts 1 full "full: teste de script que falha"  "$TESTE_RUIM" "$SCRIPT_OK"

echo "▶ verify.sh: shellcheck só no modo full"
caso_scripts 0 test "test: não roda shellcheck"        "$TESTE_OK" "$SCRIPT_RUIM"
if command -v shellcheck >/dev/null; then
  caso_scripts 0 full "full: script limpo passa"       "$TESTE_OK" "$SCRIPT_OK"
  caso_scripts 1 full "full: shellcheck reprova"       "$TESTE_OK" "$SCRIPT_RUIM"
else
  echo "  • shellcheck não instalado: casos do modo full pulados"
fi

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
