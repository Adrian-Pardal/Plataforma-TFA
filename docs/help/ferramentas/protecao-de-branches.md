# NOME
protecao-de-branches — regras do GitHub que protegem a develop e a main, e como conferir, refazer ou afrouxar

Última verificação: 2026-10-28 · Testado com: gh 2.103.2

## PARA QUE SERVE
Garante que nada entra na `develop` ou na `main` sem passar por PR e pelos
checks do CI. As regras ficam no GitHub, não no repositório: se alguém
apagar a regra, o código continua igual e a proteção some sem aviso.

Regras ativas nas duas branches:
- PR obrigatório, sem exigir aprovação (o dono é o único autor). É o PR
  obrigatório que impede o push direto na branch.
- Checks `seguranca` e `verificar` obrigatórios.
- `strict`: o PR precisa estar atualizado com a branch de destino antes do
  merge. Se a `develop` andou, é preciso atualizar o PR e esperar o CI de novo.
- Sem push direto, sem force push, sem apagar a branch.
- `enforce_admins`: as regras valem também para administrador. Sem isso, o
  dono do repositório (que é admin) conseguiria burlar a proteção.

Fora das branches: `develop` é a branch padrão; alertas do Dependabot,
atualizações automáticas de segurança, secret scanning e proteção de push
de segredos estão ligados.

## QUANDO FAZER
- Ao criar o repositório ou recriá-lo (refazer tudo).
- Se renomear um job do CI: o nome do check muda e a regra passa a
  esperar um check que nunca aparece (todo PR fica travado).
- De vez em quando, para conferir que as regras continuam ativas.

## PRÉ-REQUISITOS
- `gh auth status` logado como dono do repositório, com o escopo `repo`.
- As branches `develop` e `main` já existem no remoto (`git ls-remote --heads origin`).
- O CI já rodou ao menos uma vez: os nomes `seguranca` e `verificar` só
  existem depois disso (veja `ci.md`).
- Repositório público (ou privado com GitHub Advanced Security): secret
  scanning e proteção de push de segredos não funcionam sem isso. O PATCH do
  passo 3 pode falhar ou ignorar esses campos.
- Endpoints conferidos em
  https://docs.github.com/en/rest/branches/branch-protection#update-branch-protection

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
   O `PUT` substitui a regra inteira: o que não está no JSON volta ao padrão.
   Rodar de novo apaga qualquer ajuste feito pelo navegador.
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

Dependabot e proteção de segredos:
```bash
gh api repos/Adrian-Pardal/Plataforma-TFA/vulnerability-alerts -i | head -1
gh api repos/Adrian-Pardal/Plataforma-TFA/automated-security-fixes --jq .enabled
gh api repos/Adrian-Pardal/Plataforma-TFA --jq '.security_and_analysis | {secret_scanning: .secret_scanning.status, push_protection: .secret_scanning_push_protection.status}'
```
Esperado: o primeiro responde com código `204` (o importante é o 204, o texto
exato muda conforme a versão do `gh`); o segundo, `true`; o terceiro,
`enabled` nos dois campos.

No navegador: https://github.com/Adrian-Pardal/Plataforma-TFA/settings/branches
e https://github.com/Adrian-Pardal/Plataforma-TFA/settings/security_analysis.

## SE DER ERRADO
- **PR travado esperando um check que não existe:** o nome do job mudou.
  Refaça o passo 2 com o nome novo.
- **Preciso de uma saída de emergência (ex.: CI fora do ar):** é exceção.
  Remova a proteção só da branch necessária, faça o que precisa e refaça o
  passo 2 logo em seguida. Sem a proteção, o GitHub deixa de bloquear o
  merge; na `main`, quem mexe é só o dono. Pelo navegador: Settings →
  Branches → apagar a regra. Pela API (troque `develop` por `main` se for o caso):
  ```bash
  gh api -X DELETE repos/Adrian-Pardal/Plataforma-TFA/branches/develop/protection
  ```
- **Push recusado por segredo:** o GitHub achou um segredo no commit.
  Remova-o do commit e, se for real, revogue a credencial. Só use o
  desbloqueio pela URL que o GitHub mostra se for falso positivo.

## VER TAMBÉM
- `ferramentas/ci.md` (nomes dos checks)
- `ferramentas/merge-de-pr.md` (merge de PR e hook protect-merge)
