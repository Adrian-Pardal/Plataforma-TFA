# Plataforma de Aceitabilidade TFA

## 1. Projeto
Pesquisadores montam pesquisas pelos 7 construtos do TFA, publicam um link
público, coletam respostas anônimas (Likert) e veem médias por construto.
- Stack: a definir (ver docs/adr).
- O dono é estudante e quer ENTENDER o código: prefira clareza a esperteza.

## 2. Fluxo obrigatório
1. Sem spec aprovada em docs/specs, não escreva código.
2. Sem plano aprovado em docs/plans, não implemente.
3. Implemente em TDD (método padrão), uma task por vez.
4. Ao fim da feature: revisão e retro.
5. Ao fim da sessão: handoff (docs/handoff).

## 3. Testes
- O CI só aprova com 100% dos testes passando.
- Nenhum teste desativado ou com .only sem entrada em docs/DEBT.md.
- Antes de encerrar qualquer tarefa, rode `scripts/verify.sh test` e MOSTRE a saída.
- Se falhar: descubra a causa e corrija o código.
- Só altere um teste se ele estiver errado, e explique por quê.
- Nunca enfraqueça verificações (asserts, linters, cobertura, hooks).

## 4. Comandos
- `scripts/verify.sh quick` — Maven `compile`, Gradle `classes`, npm `typecheck` + `lint`
- `scripts/verify.sh test` — Maven `test`, Gradle `test`, npm quick + `test`; falha se houver teste desativado/isolado sem `DEBT-NNN` ou se algum `scripts/tests/*.test.sh` falhar
- `scripts/verify.sh full` — test + `verify`/PIT (Maven), `check` (Gradle), cobertura, mutação, e2e e build (npm; só o que existir) + `shellcheck` nos hooks e scripts, se instalado
- Detecta Maven, Gradle e npm em ., backend/ e frontend/; sem stack avisa e sai com 0. Segredos: gitleaks no commit.

## 5. Anti-alucinação
- Não invente API: consulte a documentação oficial ou pergunte.
- Antes de usar API, configuração ou versão de uma biblioteca, consulte o Context7 (`resolve-library-id` e `query-docs`).
- Não assuma requisito fora da spec; registre em "Perguntas em aberto".
- Não diga que testou sem mostrar a saída.
- Diga "não sei" quando não souber.

## 6. Qualidade
- Diffs pequenos.
- Decisão de arquitetura vira ADR. ADR aceito não se edita (crie outro que o substitua).
- Erro relevante vira ERR-NNN em docs/erros/ (use /registrar-erro).
- Toda ferramenta, credencial ou tarefa manual nova ganha página em docs/help/ no mesmo commit; quando um procedimento mudar, atualize a página. Exceção: skills são documentadas em docs/skills.md, não em docs/help.
- Nunca edite .env nem commite segredos.
- Mostre o conteúdo de todo arquivo novo ou alterado e espere minha aprovação antes de salvar.
- Crie e edite arquivos só com as ferramentas Write/Edit, nunca com cat, echo, sed, tee ou redirecionamento pelo Bash.

## 7. Ensino
- Ao fim de cada task, explique em 3–5 linhas o que mudou e por quê.
- Em escolhas técnicas, apresente 2–3 opções com prós e contras.

## 8. Onde está cada coisa
- docs/specs — o que construir (requisitos)
- docs/plans — como e em que ordem (tasks)
- docs/adr — decisões de arquitetura
- docs/erros — registro de erros (ERR-NNN)
- docs/handoff — passagem de contexto entre sessões
- docs/help — manual do operador (rotinas manuais: atualizar, manter, conferir)
- docs/templates — modelos de spec, plano, ADR, erro, handoff
- docs/DEBT.md — dívida técnica (testes desativados etc.)
- docs/skills.md — índice das skills (fase, manual ou automática, quando usar)
- scripts/verify.sh — verificação única
