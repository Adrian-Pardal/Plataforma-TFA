# ADR 0001: Adotar um fluxo spec-driven com Claude Code, montado peça a peça

- **Status:** Aceito
- **Data:** 2026-10-25
- **Substitui:** nenhum

## Contexto
Uma IA de código usada sem estrutura costuma:
- inventar requisitos que ninguém pediu e APIs que não existem;
- escrever testes fracos, que passam sem provar nada;
- perder decisões entre uma sessão e outra, porque não guarda memória própria.

Além disso, o dono do projeto é estudante e quer **aprender**: entender cada
arquivo e cada escolha, não apenas receber código pronto.

## Decisão
Seguir um fluxo em etapas, com a IA trabalhando dentro de limites explícitos:

**spec → plano → tasks → TDD → revisão → CI**

Ferramentas que sustentam o fluxo, todas montadas aos poucos e explicadas:
- **Claude Code** como assistente de desenvolvimento;
- **CLAUDE.md** com as regras do projeto, lido em toda sessão;
- **skills** para tarefas repetidas (ex.: `/registrar-erro`);
- **subagentes** para tarefas isoladas, como revisão;
- **hooks do Claude Code**, que rodam durante a sessão: bloqueiam a edição de
  `.env` e de ADR aceito, verificam após cada edição, impedem encerrar com teste
  vermelho e bloqueiam push para `main`/`develop`;
- **hooks de Git com Lefthook + Gitleaks**, que rodam antes de cada commit;
- **um único `scripts/verify.sh`** (quick | test | full), usado igual na máquina
  local e no CI, para que "passou aqui" signifique "passa no CI".

Nenhum código é escrito sem spec aprovada, e nenhuma implementação começa sem
plano aprovado.

## Alternativas
1. **Vibe coding (pedir à IA e aceitar o resultado)**
   - Prós: o mais rápido para um protótipo; nenhuma preparação.
   - Contras: sem garantia de qualidade, e a IA pode inventar requisitos sem
     que ninguém perceba.
   - **Descartada** por esses dois motivos.

2. **Framework pronto de spec-driven development**, como
   [Spec Kit](https://github.com/github/spec-kit) (GitHub: kit open source com
   processos estruturados e templates para agentes de IA),
   [Superpowers](https://github.com/obra/superpowers) (metodologia de
   desenvolvimento para agentes, feita de skills) ou
   [OpenSpec](https://github.com/Fission-AI/OpenSpec) (camada leve de specs
   para combinar o que construir antes do código).
   - Prós: resolveriam boa parte do problema do Contexto, com fluxo já testado
     por outras pessoas e menos trabalho inicial.
   - Contras: trazem comandos, estrutura de arquivos e convenções que eu não
     escolhi, e escondem as peças que quero entender.
   - **Descartada** porque o objetivo é aprender montando e entendendo cada peça.
     Não é um julgamento sobre a qualidade dos frameworks.
   - Descrições conferidas nos READMEs oficiais em 2026-10-25. Não avaliei
     recursos além disso.

3. **Desenvolver sem IA**
   - Prós: aprendizado máximo em cada linha; nenhum risco de código inventado.
   - Contras: avanço mais lento.
   - **Descartada** porque um dos objetivos é aprender a desenvolver com IA.

## Consequências
**Positivas:**
- Cada linha de código é rastreável até um requisito e um teste.
- Retomar o trabalho em outra sessão fica fácil (handoff, ADRs e specs guardam o contexto).
- É mais fácil perceber quando a IA inventa algo, porque tudo precisa estar na spec.
- Entendimento de cada peça do fluxo, que é o objetivo de aprendizado.

**Negativas:**
- **Início mais lento:** há bastante preparação antes da primeira linha de código.
- **Manutenção do harness:** CLAUDE.md, skills, hooks e `verify.sh` são código
  que também precisa ser mantido e pode quebrar.
- **Mais consumo do limite do plano:** ler specs e planos, rodar revisões e
  usar subagentes gasta mais do uso disponível do que pedir código direto.
- **Muitas skills para gerenciar:** cada skill nova é mais uma coisa para
  lembrar, ajustar e manter coerente com as outras.
- **Disciplina:** pular etapas "só desta vez" anula o benefício do fluxo.

**Daqui para frente:**
- Criar `scripts/verify.sh`, as skills, os subagentes e os hooks citados.
- Definir a stack em ADRs próprios, na Fase 5, antes de qualquer código.
  (O 0002 será o ADR de TDD como método padrão.)
- Revisar este ADR após a primeira feature completa; se o fluxo se mostrar
  pesado demais, registrar um novo ADR que o substitua.
