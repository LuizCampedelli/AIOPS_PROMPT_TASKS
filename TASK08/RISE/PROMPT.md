# Prompt — Framework R-I-S-E
## Questão 08 — Postmortem Técnico de Incidente em Produção

---

## Role

Você é um Senior Site Reliability Engineer (SRE) com especialização em PostgreSQL, gerenciamento de pool de conexões e resposta a incidentes em APIs de alto tráfego. Você domina o stack Kubernetes + Argo CD e tem experiência em emitir diagnósticos rápidos e acionáveis sob pressão, com dados parciais. Seu público imediato é o CTO, que precisa decidir entre duas opções em 20 minutos.

---

## Input

### 1. Evento do deploy anterior (2026-04-23, 18:42 UTC)

```
Deploy chronos-api: v2.47.0 -> v2.48.0
Argo CD sync: 2026-04-23 18:42:11 UTC
Changelog:
- Adicionado endpoint POST /v2/transactions/batch
- Refatorado cliente do Ledger (pool de conexões movido para nova biblioteca interna)
- Bump de psycopg 3.1.18 -> 3.2.0
- Reduzido timeout do Ledger de 5s para 2s
```

### 2. Métricas do Beacon — últimos 30 minutos

| timestamp (UTC)       | p99_latency_ms | req_rate_s | err_rate_pct |
|-----------------------|----------------|------------|--------------|
| 2026-04-24 13:30      | 420            | 1200       | 0.2          |
| 2026-04-24 13:45      | 510            | 1450       | 0.3          |
| 2026-04-24 14:00      | 780            | 1780       | 0.8          |
| 2026-04-24 14:10      | 2400           | 2100       | 4.5          |
| 2026-04-24 14:15      | 5200           | 2400       | 8.2          |
| 2026-04-24 14:20      | 8100           | 2650       | 11.7         |

### 3. Trecho de log — pod `chronos-api-79c4d8b9-xk2jp`

```
2026-04-24 14:19:48 [ERROR] [ledger-client] connection pool exhausted (max=20, active=20, waiting=147)
2026-04-24 14:19:49 [WARN]  [ledger-client] query timeout after 2000ms: SELECT ... FROM transactions WHERE ...
2026-04-24 14:19:49 [ERROR] [handler] POST /v2/transactions/batch failed: context deadline exceeded
2026-04-24 14:19:50 [ERROR] [ledger-client] connection reset by peer
2026-04-24 14:19:51 [WARN]  [circuit-breaker] ledger-client OPEN (threshold 50%, current 87%)
2026-04-24 14:19:52 [ERROR] [reactor] failed to publish message: chronos-api upstream error
```

### 4. Estado do Reactor — fila `chronos-transactions`

```
Mensagens acumuladas: 50.127
Taxa de acúmulo: ~800 mensagens/min
Consumer lag atual: 18 minutos e aumentando
```

### 5. Estado do cluster

```
Chronos: 12/12 pods running (HPA no máximo)
CPU médio dos pods: 62%
Memória média dos pods: 71%
Conexões ativas ao Ledger: 240/250 (limite do RDS)
```

---

## Steps

1. **Identifique a causa raiz** correlacionando as mudanças introduzidas em v2.48.0 com o padrão de degradação nas métricas e os erros nos logs. Seja específico sobre qual mudança (ou combinação) é o gatilho primário.

2. **Avalie o raio de impacto atual e projetado**: quais sistemas estão afetados, qual a severidade, e o que acontece se nenhuma ação for tomada nos próximos 10 minutos.

3. **Analise a Opção A — Rollback para v2.47.0** via Argo CD: estime o tempo de recuperação (TTR), identifique riscos (perda de dados, estado inconsistente, mensagens em fila), e indique se endereça a causa raiz.

4. **Analise a Opção B — Scaling emergencial** (aumento do limite de conexões do RDS + aumento do pool de conexões por pod): estime o TTR, identifique riscos operacionais, e avalie se endereça a causa raiz ou apenas adia a falha.

5. **Emita uma recomendação clara** com nível de confiança (Alto / Médio / Baixo) e a principal premissa que, se falsa, mudaria a decisão.

---

## Expectation

Produza um **postmortem técnico conciso**, adequado para leitura em menos de 5 minutos e tomada de decisão em 20 minutos, com as seguintes seções obrigatórias:

1. **Causa Raiz** — máximo 3 frases, linguagem técnica direta
2. **Linha do Tempo da Degradação** — tabela com timestamp, evento-chave e sistema afetado
3. **Comparação de Opções** — tabela com as colunas: Opção | TTR Estimado | Endereça Causa Raiz? | Principal Risco
4. **Recomendação** — máximo 150 palavras, incluindo nível de confiança e premissa crítica
5. **Próximas Ações Imediatas**
   - Em < 5 minutos (ações de mitigação imediata)
   - Em < 20 minutos (ações de estabilização e monitoramento)
