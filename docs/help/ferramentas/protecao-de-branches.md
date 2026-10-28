# NOME
protecao-de-branches — regras do GitHub que protegem a develop e a main, e como conferir, refazer ou afrouxar

Última verificação: 2026-10-28 · Testado com: gh 2.103.2

## PARA QUE SERVE
Garante que nada entra na `develop` ou na `main` sem passar por PR e pelos
checks do CI. As regras ficam no GitHub, não no repositório: se alguém
apagar a regra, o código continua igual e a proteção some sem aviso.

Regras ativas nas duas branches:
- PR obrigatório, sem exigir aprovação (o dono é o único autor).
- Checks `seguranca` e `verificar` obrigatórios.
- Branch atualizada com a base antes do merge (`strict`).
- Sem push direto, sem force push, sem apagar a branch.
- Vale também para administrador (`enforce_admins`).

Fora das branches: `develop` é a branch padrão; alertas do Dependabot,
atualizações automáticas de segurança, secret scanning e proteção de push
de segredos estão ligados.

## QUANDO FAZER
- Ao criar o repositório ou recriá-lo (refazer tudo).
- Se renomear um job do CI: o nome do check muda e a regra passa a
  esperar um check que nunca aparece (todo PR fica travado).
- De vez em quando, para conferir que as regras continuam ativas.

## PRÉ-REQUISITOS
- `gh auth status` logado com o escopo `repo` e permissão de admin.
- Conferir os endpoints em https://docs.github.com/en/rest antes de rodar.

## PASSO A PASSO
1. Tornar a `develop` a branch padrão.
   ```bash
   gh api -X PATCH repos/Adrian-Pardal/Plataforma-TFA -f default_branch=develop
   ```
2. Proteger a `develop` e a `main` com as mesmas regras.
   ```bash
   for b in develop main; do
     gh api -X PUT "repos/Adrian-Pardal/Plataforma-TFA/branches/$b/protection" --input - <<'JSON'
   {
     "required_status_checks": {"strict": true,
       "checks": [{"context": "seguranca"}, {"context": "verificar"}]},
     "enforce_admins": true,
     "required_pull_request_reviews": {"required_approving_review_count": 0},
     "restrictions": null,
     "allow_force_pushes": false,
     "allow_deletions": false
   }
   JSON
   done
   ```
3. Ligar Dependabot e a proteção de segredos.
   ```bash
   gh api -X PUT repos/Adrian-Pardal/Plataforma-TFA/vulnerability-alerts
   gh api -X PUT repos/Adrian-Pardal/Plataforma-TFA/automated-security-fixes
   gh api -X PATCH repos/Adrian-Pardal/Plataforma-TFA --input - <<'JSON'
   {"security_and_analysis": {
     "secret_scanning": {"status": "enabled"},
     "secret_scanning_push_protection": {"status": "enabled"}}}
   JSON
   ```

## COMO CONFERIR QUE DEU CERTO
```bash
for b in develop main; do
  gh api "repos/Adrian-Pardal/Plataforma-TFA/branches/$b/protection" \
    --jq '{checks: [.required_status_checks.checks[].context], strict: .required_status_checks.strict, enforce_admins: .enforce_admins.enabled, force_push: .allow_force_pushes.enabled, apagar: .allow_deletions.enabled}'
done
```
Esperado, nas duas: `checks` com `seguranca` e `verificar`, `strict` e
`enforce_admins` `true`, `force_push` e `apagar` `false`.

Alertas do Dependabot ligados:
```bash
gh api repos/Adrian-Pardal/Plataforma-TFA/vulnerability-alerts -i | head -1
```
Esperado: `HTTP/2.0 204 No Content`.

No navegador: https://github.com/Adrian-Pardal/Plataforma-TFA/settings/branches
e https://github.com/Adrian-Pardal/Plataforma-TFA/settings/security_analysis.

## SE DER ERRADO
- **PR travado esperando um check que não existe:** o nome do job mudou.
  Refaça o passo 2 com o nome novo.
- **Preciso de uma saída de emergência (ex.: CI fora do ar):** remova a
  proteção, faça o que precisa e refaça o passo 2 em seguida. Pelo
  navegador: Settings → Branches → apagar a regra. Pela API:
  ```bash
  gh api -X DELETE repos/Adrian-Pardal/Plataforma-TFA/branches/develop/protection
  ```
- **Push recusado por segredo:** o GitHub achou um segredo no commit.
  Remova-o do commit e, se for real, revogue a credencial. Só use o
  desbloqueio pela URL que o GitHub mostra se for falso positivo.

## VER TAMBÉM
- `ferramentas/ci.md` (nomes dos checks)
- `ferramentas/merge-de-pr.md` (merge de PR e hook protect-merge)
