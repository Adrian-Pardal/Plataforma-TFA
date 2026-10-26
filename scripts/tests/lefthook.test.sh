#!/usr/bin/env bash
# lefthook.test.sh — testes do lefthook.yml: commit-msg (Conventional Commits) e pre-commit (segredos).
# Sem lefthook (ou sem gitleaks, para a parte de segredos) instalado, avisa e pula essa parte.
# Uso: scripts/tests/lefthook.test.sh   (sai com 1 se algum caso falhar)
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
falhas=0

if ! command -v lefthook >/dev/null; then
  echo "• lefthook não instalado: testes pulados"
  exit 0
fi

resultado() {   # resultado <esperado> <obtido> <descrição>
  if [[ "$1" == "$2" ]]; then
    echo "  ok    ($1) $3"
  else
    echo "  FALHA (esperado $1, veio $2) $3" >&2
    falhas=$((falhas + 1))
  fi
}

caso_msg() {   # caso_msg <esperado: 0 aceita | 1 recusa> <mensagem completa>
  printf '%s\n' "$2" > "$TMP/msg"
  (cd "$RAIZ" && lefthook run commit-msg "$TMP/msg") >/dev/null 2>&1
  resultado "$1" "$?" "$(head -n 1 <<<"$2")"
}

echo "▶ lefthook commit-msg: mensagens aceitas (0)"
for tipo in feat fix docs test refactor chore ci build perf; do
  caso_msg 0 "$tipo: descrição"
done
caso_msg 0 "fix(pesquisa): descrição"
caso_msg 0 "feat!: quebra compatibilidade"
caso_msg 0 "refactor(api)!: renomeia rota"
caso_msg 0 $'feat(construto): cria cadastro\n\nCorpo explicando.\n\nTask: T3'
caso_msg 0 $'chore: ajusta\n\nTask: T3\nRefs: ADR-0001'
caso_msg 0 $'# comentário do git\nfeat: depois de comentário'
caso_msg 0 "Merge branch 'feat/x' into develop"
caso_msg 0 'Revert "feat: cria cadastro"'

echo "▶ lefthook commit-msg: mensagens recusadas (1)"
caso_msg 1 "adiciona coisa"
caso_msg 1 "feat:sem espaço"
caso_msg 1 "Feat: maiúscula"
caso_msg 1 "feature: tipo desconhecido"
caso_msg 1 "style: tipo fora da lista"
caso_msg 1 "feat(): escopo vazio"
caso_msg 1 "feat: "
caso_msg 1 "Merged branch x"
caso_msg 1 "Revert sem aspas"
caso_msg 1 $'\nfeat: linha em branco antes'

echo "▶ lefthook pre-commit: verify quick e segredos em arquivos staged"
if ! command -v gitleaks >/dev/null; then
  echo "  • gitleaks não instalado: casos de segredo pulados"
else
  REPO="$TMP/repo"
  mkdir -p "$REPO/scripts"
  git -C "$REPO" init -q
  cp "$RAIZ/lefthook.yml" "$REPO/lefthook.yml"
  cp "$RAIZ/scripts/verify.sh" "$REPO/scripts/verify.sh"
  git -C "$REPO" add lefthook.yml scripts/verify.sh

  printf '%s\n' "# nada secreto aqui" > "$REPO/ok.md"
  git -C "$REPO" add ok.md
  (cd "$REPO" && lefthook run pre-commit) >/dev/null 2>&1
  resultado 0 "$?" "arquivo staged sem segredo passa"

  # Token falso montado em pedaços para o próprio teste não parecer um segredo ao gitleaks.
  TOKEN="ghp_"; TOKEN+="R8sK2mQ9xV4nB7tL1wZ5cY3hD6fJ0aGpEuXo"
  printf 'token = "%s"\n' "$TOKEN" > "$REPO/config.txt"
  git -C "$REPO" add config.txt
  (cd "$REPO" && lefthook run pre-commit) >/dev/null 2>&1
  resultado 1 "$?" "arquivo staged com segredo é recusado"
fi

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
