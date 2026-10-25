#!/usr/bin/env bash
# verify.sh — verificação única do projeto.
# Uso: scripts/verify.sh quick | test | full
set -euo pipefail   # -e: para no 1º erro · -u: variável não definida é erro · pipefail: erro em pipe conta

# --- 1. Configuração ---------------------------------------------------------
# RAIZ é a pasta do projeto. VERIFY_RAIZ permite apontar para outra pasta (usado nos testes do script).
RAIZ="${VERIFY_RAIZ:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MODO="${1:-}"

# Modo inválido: mostra o uso e sai com 64 (convenção "uso incorreto da linha de comando").
case "$MODO" in
  quick|test|full) ;;
  *) echo "Uso: scripts/verify.sh quick | test | full" >&2; exit 64 ;;
esac

# --- 2. Testes desativados ou isolados (só nos modos test e full) -----------
# Regex (ERE do bash): @Disabled, @Ignore, it/test/describe .skip( .only( .skip.each( .only.each(,
# test.fixme( (Playwright) e xit( xdescribe( xtest(.
# Não pega @DisabledOnOs & cia (desativação condicional, não permanente).
PADRAO_DESATIVADO='@Disabled([^A-Za-z0-9_]|$)|@Ignore([^A-Za-z0-9_]|$)|(^|[^A-Za-z0-9_$])(it|test|describe)\.(skip|only)(\.each)?\(|(^|[^A-Za-z0-9_$])test\.fixme\(|(^|[^A-Za-z0-9_$])x(it|describe|test)\('
PADRAO_DEBT='DEBT-[0-9]{3}'   # a exceção da regra do CLAUDE.md: comentário DEBT-NNN

verificar_testes_desativados() {
  echo "▶ procurando testes desativados ou isolados"
  local achados=0 arq linha anterior n
  while IFS= read -r -d '' arq; do
    n=0
    anterior=""
    while IFS= read -r linha || [[ -n "$linha" ]]; do
      n=$((n + 1))
      # Achou o padrão E não há DEBT-NNN nesta linha nem na anterior → é violação.
      if [[ "$linha" =~ $PADRAO_DESATIVADO ]] && ! [[ "$linha" =~ $PADRAO_DEBT || "$anterior" =~ $PADRAO_DEBT ]]; then
        echo "  ${arq#"$RAIZ"/}:$n:$linha" >&2
        achados=$((achados + 1))
      fi
      anterior="$linha"
    done < "$arq"
  # Só arquivos de teste; ignora node_modules, target, dist e .git (-prune nem entra nelas).
  done < <(find "$RAIZ" \( -name node_modules -o -name target -o -name dist -o -name .git \) -prune -o \
      -type f \( -path '*/src/test/*' -o -name '*Test.java' -o -name '*IT.java' \
      -o -name '*.test.ts' -o -name '*.test.tsx' -o -name '*.spec.ts' -o -name '*.spec.tsx' \
      -o -name '*.test.js' -o -name '*.spec.js' \) -print0)

  if [[ $achados -gt 0 ]]; then
    echo "✖ $achados teste(s) desativado(s)/isolado(s) sem comentário DEBT-NNN (na mesma linha ou na anterior)." >&2
    echo "  Reative/remova, ou registre em docs/DEBT.md e marque com // DEBT-NNN." >&2
    exit 1
  fi
  echo "✔ nenhum teste desativado ou isolado"
}

# --- 3. Execução de comandos -------------------------------------------------
# Roda "$@" dentro de uma pasta. Se falhar, o set -e encerra o script com o MESMO código de erro.
rodar() {
  local dir="$1"; shift
  echo "▶ [$dir] $*"
  (cd "$RAIZ/$dir" && "$@")
}

# --- 4. Uma função por ferramenta -------------------------------------------
rodar_maven() {
  local dir="$1" cmd_mvn="mvn"
  if [[ -f "$RAIZ/$dir/mvnw" ]]; then cmd_mvn="./mvnw"; fi   # prefere o wrapper do projeto
  case "$MODO" in
    quick) rodar "$dir" "$cmd_mvn" compile ;;
    test)  rodar "$dir" "$cmd_mvn" test ;;
    full)
      rodar "$dir" "$cmd_mvn" verify
      if grep -q 'pitest' "$RAIZ/$dir/pom.xml" 2>/dev/null; then   # PIT só se estiver no pom.xml
        rodar "$dir" "$cmd_mvn" test-compile org.pitest:pitest-maven:mutationCoverage
      else
        echo "• [$dir] PIT não configurado no pom.xml, pulado"
      fi ;;
  esac
}

rodar_gradle() {
  local dir="$1"
  case "$MODO" in
    quick) rodar "$dir" ./gradlew classes ;;
    test)  rodar "$dir" ./gradlew test ;;
    full)  rodar "$dir" ./gradlew check ;;
  esac
}

# npm: roda só os scripts que existem no package.json.
npm_tem_script() {   # npm_tem_script <dir> <script>
  (cd "$RAIZ/$1" && node -e 'process.exit(((require("./package.json").scripts) || {})[process.argv[1]] ? 0 : 1)' "$2")
}

rodar_npm() {
  local dir="$1" scripts s
  case "$MODO" in
    quick) scripts=(typecheck lint) ;;
    test)  scripts=(typecheck lint test) ;;
    full)  scripts=(typecheck lint test test:coverage test:mutation test:e2e build) ;;
  esac
  for s in "${scripts[@]}"; do
    # No full, test:coverage já roda os testes: pular "test" evita rodá-los duas vezes.
    if [[ "$MODO" == "full" && "$s" == "test" ]] && npm_tem_script "$dir" "test:coverage"; then
      echo "• [$dir] 'test' pulado: test:coverage já executa os testes"
      continue
    fi
    if npm_tem_script "$dir" "$s"; then
      rodar "$dir" npm run "$s"
    else
      echo "• [$dir] script npm '$s' não existe, pulado"
    fi
  done
}

# --- 5. Programa principal -----------------------------------------------------
if [[ "$MODO" == "test" || "$MODO" == "full" ]]; then
  verificar_testes_desativados
fi

detectou=0
for dir in . backend frontend; do                       # raiz, backend/ e frontend/
  [[ -d "$RAIZ/$dir" ]] || continue
  if [[ -f "$RAIZ/$dir/mvnw" || -f "$RAIZ/$dir/pom.xml" ]]; then detectou=1; rodar_maven "$dir"; fi
  if [[ -f "$RAIZ/$dir/gradlew" ]]; then detectou=1; rodar_gradle "$dir"; fi
  if [[ -f "$RAIZ/$dir/package.json" ]]; then detectou=1; rodar_npm "$dir"; fi
done

if [[ $detectou -eq 0 ]]; then
  echo "⚠ nenhuma stack detectada (Maven, Gradle ou npm em ., backend/, frontend/); nada a executar." >&2
  exit 0
fi
echo "✔ verify.sh $MODO passou"
