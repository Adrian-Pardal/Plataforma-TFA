#!/usr/bin/env bash
# protect-merge.test.sh — testes do hook protect-merge.sh (usa um "gh" falso; não chama o GitHub).
# Uso: scripts/tests/protect-merge.test.sh   (sai com 1 se algum caso falhar)
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOOK="$RAIZ/.claude/hooks/protect-merge.sh"
FALSO="$(mktemp -d)"; trap 'rm -rf "$FALSO"' EXIT
falhas=0

# gh falso: "gh pr view ..." imprime $FAKE_BASE; se for "erro", falha como o gh real sem rede ou sem PR.
# As aspas simples são de propósito: o $1 e o ${FAKE_BASE} devem ser lidos pelo gh falso, não aqui.
# shellcheck disable=SC2016
printf '%s\n' '#!/usr/bin/env bash' \
  '[[ "$1 $2" == "pr view" ]] || exit 9' \
  '[[ "${FAKE_BASE:-develop}" != erro ]] || exit 1' \
  'echo "${FAKE_BASE:-develop}"' > "$FALSO/gh"
chmod +x "$FALSO/gh"

caso() {   # caso <esperado: 0 liberado | 2 bloqueado> <destino do PR> <comando>
  local esperado="$1" base="$2" cmd="$3" obtido
  jq -n --arg c "$cmd" --arg d "$RAIZ" '{tool_input: {command: $c}, cwd: $d}' \
    | PATH="$FALSO:$PATH" FAKE_BASE="$base" "$HOOK" >/dev/null 2>&1
  obtido=$?
  if [[ "$obtido" == "$esperado" ]]; then
    echo "  ok    ($esperado) [$base] $cmd"
  else
    echo "  FALHA (esperado $esperado, veio $obtido) [$base] $cmd" >&2
    falhas=$((falhas + 1))
  fi
}

echo "▶ protect-merge: devem passar (0)"
caso 0 develop 'ls -la'
caso 0 develop 'gh pr view 12'
caso 0 develop 'gh api repos/o/r/pulls/12'
caso 0 develop 'gh pr merge 12 --merge'
caso 0 develop 'gh pr merge --merge 12'
caso 0 develop 'gh pr merge 12 -m'
caso 0 develop 'gh pr merge 12 --merge --delete-branch'
caso 0 develop 'gh pr merge 12 -dm'
caso 0 develop 'gh pr merge --merge'
caso 0 develop 'gh pr merge https://github.com/o/r/pull/12 --merge'
caso 0 develop 'gh pr merge 12 --merge --subject "feat: x" --body "texto --squash"'
caso 0 develop 'gh pr merge 12 --merge -R dono/repo'
caso 0 develop 'gh pr merge 12 --merge --match-head-commit abc123'
caso 0 develop 'gh pr merge 1 --merge; gh pr merge 2 --merge'

echo "▶ protect-merge: destino errado ou consulta falhou (2)"
caso 2 main    'gh pr merge 12 --merge'
caso 2 main    'gh pr merge --merge'
caso 2 main    'gh pr merge feat/x --merge'
caso 2 release 'gh pr merge 12 --merge'
caso 2 erro    'gh pr merge 12 --merge'
caso 2 main    'cd /tmp && gh pr merge 12 --merge'

echo "▶ protect-merge: opções proibidas e estratégia (2)"
caso 2 develop 'gh pr merge 12 --squash'
caso 2 develop 'gh pr merge 12 -s'
caso 2 develop 'gh pr merge 12 --rebase'
caso 2 develop 'gh pr merge 12 -r'
caso 2 develop 'gh pr merge 12 --merge --squash'
caso 2 develop 'gh pr merge 12 -ds'
caso 2 develop 'gh pr merge 12 --merge --admin'
caso 2 develop 'gh pr merge 12 --merge --auto'
caso 2 develop 'gh pr merge 12 --admin --merge'
caso 2 develop 'gh pr merge 12 --auto=true --merge'
caso 2 develop 'gh pr merge 12'
caso 2 develop 'gh pr merge'
caso 2 develop 'GH_TOKEN=x gh pr merge 12 --squash'
caso 2 develop '/usr/bin/gh pr merge 12 --rebase'

echo "▶ protect-merge: merge por gh api (2)"
caso 2 develop 'gh api -X PUT repos/o/r/pulls/12/merge'
caso 2 develop 'gh api repos/o/r/pulls/12/merge -f merge_method=squash'
caso 2 develop "gh api graphql -f query='mutation { mergePullRequest(input: {pullRequestId: \"X\"}) { clientMutationId } }'"
caso 2 develop "gh api graphql -f query='mutation { enablePullRequestAutoMerge(input: {pullRequestId: \"X\"}) { clientMutationId } }'"

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
