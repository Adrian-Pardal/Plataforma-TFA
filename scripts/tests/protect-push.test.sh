#!/usr/bin/env bash
# protect-push.test.sh — testes do hook protect-push.sh.
# Uso: scripts/tests/protect-push.test.sh   (sai com 1 se algum caso falhar)
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOOK="$RAIZ/.claude/hooks/protect-push.sh"
falhas=0

caso() {   # caso <código esperado: 0 liberado | 2 bloqueado> <comando>
  local esperado="$1" cmd="$2" obtido
  jq -n --arg c "$cmd" --arg d "$RAIZ" '{tool_input: {command: $c}, cwd: $d}' | "$HOOK" >/dev/null 2>&1
  obtido=$?
  if [[ "$obtido" == "$esperado" ]]; then
    echo "  ok    ($esperado) $cmd"
  else
    echo "  FALHA (esperado $esperado, veio $obtido) $cmd" >&2
    falhas=$((falhas + 1))
  fi
}

echo "▶ protect-push: comandos que devem passar (0)"
caso 0 'ls -la'
caso 0 'git status'
caso 0 'git push origin feat/x'
caso 0 'git push -u origin feat/x'
caso 0 'git push --set-upstream origin hotfix/y'
caso 0 'git push origin HEAD:refs/heads/fix/a'
caso 0 'git push origin feat/x --dry-run'
caso 0 'git push -o ci.skip origin feat/x'
caso 0 'git push --push-option=ci.skip origin feat/x'

echo "▶ protect-push: comandos que devem ser bloqueados (2)"
caso 2 'git push origin main'
caso 2 'git push origin develop'
caso 2 'git push origin HEAD:main'
caso 2 'git push origin feat/x:main'
caso 2 'git push --force origin feat/x'
caso 2 'git push -f origin feat/x'
caso 2 'git push -fu origin feat/x'
caso 2 'git push --force-with-lease origin feat/x'
caso 2 'git push origin +feat/x'
caso 2 'git push --delete origin feat/x'
caso 2 'git push -d origin feat/x'
caso 2 'git push origin :feat/x'
caso 2 'git push --mirror origin'
caso 2 'git push --all origin'
caso 2 'git push --tags origin'
caso 2 'git push origin v1.0'
caso 2 'git push origin foo'
caso 2 'git push upstream feat/x'
caso 2 'cd /tmp && git push origin main'
caso 2 'git push origin feat/x; git push origin main'

echo "▶ protect-push: opções que trocam o destino ou o programa do push (2)"
caso 2 'git push --repo=https://exemplo.com/x.git feat/x'
caso 2 'git push --repo https://exemplo.com/x.git feat/x'
caso 2 'git push --repo=https://exemplo.com/x.git origin feat/x'
caso 2 'git push --repo https://exemplo.com/x.git origin feat/x'
caso 2 'git push --receive-pack=evil origin feat/x'
caso 2 'git push --exec evil origin feat/x'

echo "▶ protect-push: redirecionamentos do shell não são argumentos do git (ERR-001)"
caso 0 'git push -u origin feat/x 2>&1'
caso 0 'git push origin feat/x > /tmp/log 2>&1'
caso 2 'git push origin main 2>&1'
# Este caso já passava antes da correção. Ele garante que a correção não trata ">" entre aspas
# como redirecionamento: isso descartaria o "main" e liberaria o push.
caso 2 'git push origin ">" main'

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
