# Plano: <nome da feature>

- **Spec:** [link para docs/specs/...](../specs/...)
- **Status:** Rascunho | Aprovado | Em execução | Concluído
- **Data:** AAAA-MM-DD

## Visão técnica
Em poucas linhas: a abordagem geral e como as peças se encaixam.

## Modelo de dados
Entidades, campos principais e relações.

## Interfaces
Endpoints, telas ou contratos entre back e front (entradas, saídas, erros).

## Decisões
- <decisão> — ver ADR NNNN (se for decisão de arquitetura, crie o ADR).

## Riscos
- <o que pode dar errado> → <como reduzir>

## Tasks
Formato: `T<n> [back|front|ambos] — descrição · Cobre: RF-xx/CA-x · Teste: NomeDoTeste`
Marque com 🎓 as tasks que você faz à mão.

- [ ] T1 [back] — <descrição> · Cobre: RF-01/CA-1 · Teste: <NomeDoTeste>
- [ ] T2 [front] — <descrição> · Cobre: RF-01/CA-2 · Teste: <NomeDoTeste>
- [ ] 🎓 T3 [ambos] — <descrição> · Cobre: RF-02/CA-1 · Teste: <NomeDoTeste>

## Rastreabilidade
Todo RF/CA da spec deve aparecer aqui. Linha sem task ou sem teste = lacuna.

| Requisito | Critério | Task | Teste |
|-----------|----------|------|-------|
| RF-01     | CA-1     | T1   | <NomeDoTeste> |
