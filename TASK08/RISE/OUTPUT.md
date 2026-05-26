# Output — Postmortem Técnico: Incidente Chronos API (2026-04-24)

> Gerado por Claude Sonnet 4.6 a partir do prompt R-I-S-E em PROMPT.md

---

## 1. Causa Raiz

O deploy v2.48.0 introduziu três mudanças co-dependentes que se tornaram críticas sob carga de pico: o timeout do Ledger foi reduzido de 5s para 2s; o cliente do Ledger foi refatorado com uma nova biblioteca de pool (comportamento não validado em produção); e o novo endpoint `POST /v2/transactions/batch` passou a executar queries bulk no Ledger, aumentando o tempo de hold de conexão por requisição. Sob tráfego crescente (2.650 req/s às 14:20), as queries do batch excedem 2s e retornam `context deadline exceeded` sem liberar a conexão imediatamente, esgotando o pool de 20 conexões por pod. Com 12 pods e pool max=20, o total de conexões ativas (240/250) já atinge o limite do RDS, tornando ineficaz qualquer escalonamento de pool sem também aumentar o limite do banco — e mesmo assim sem endereçar o timeout curto demais.

---

## 2. Linha do Tempo da Degradação

| Timestamp (UTC)     | Evento-Chave                                                         | Sistema Afetado        |
|---------------------|----------------------------------------------------------------------|------------------------|
| 2026-04-23 18:42    | Deploy v2.48.0 via Argo CD (timeout 5s→2s, novo pool, batch endpoint) | Chronos               |
| 2026-04-24 13:30    | Latência p99 em 420ms, erro em 0.2% — baseline degradado mas estável | Chronos, Ledger        |
| 2026-04-24 14:00    | Latência p99 sobe para 780ms, erros em 0.8% — primeiros sinais de pressão no pool | Chronos, Ledger |
| 2026-04-24 14:10    | Salto para 2.400ms / 4.5% de erros — pool começa a esgotar sob 2.100 req/s | Chronos, Ledger   |
| 2026-04-24 14:15    | 5.200ms / 8.2% — pool exaurido, queries batch acumulando timeouts     | Chronos, Ledger        |
| 2026-04-24 14:19    | Pool exhausted (20/20, 147 waiting), circuit-breaker OPEN (87%)      | Chronos, Ledger        |
| 2026-04-24 14:19    | Reactor falha ao publicar mensagens — fila começa a acumular          | Reactor                |
| 2026-04-24 14:20    | 8.100ms / 11.7%, 50k mensagens na fila, consumer lag 18min e subindo | Chronos, Reactor, Ledger |

**Projeção se nada for feito (próximos 10 min):** latência p99 > 15s, erro rate > 20%, fila Reactor acima de 60k mensagens, conexões RDS saturadas (250/250) causando falhas em outros serviços dependentes do Ledger.

---

## 3. Comparação de Opções

| Opção                              | TTR Estimado       | Endereça Causa Raiz? | Principal Risco                                                                                  |
|------------------------------------|--------------------|----------------------|--------------------------------------------------------------------------------------------------|
| **A — Rollback para v2.47.0**      | 5–8 minutos        | **Sim**              | Mensagens na fila do Reactor precisam ser reprocessadas; o endpoint `/batch` fica indisponível   |
| **B — Scaling emergencial** (RDS + pool) | 15–25 minutos | **Não**              | Aumentar o pool sem corrigir o timeout de 2s apenas distribui mais conexões que vão expirar; o problema raiz persiste e o RDS pode saturar em novo patamar |

**Detalhe da Opção B:** Mesmo elevando o limite do RDS para 500 conexões e o pool para 40 por pod (12 × 40 = 480 conexões totais), se as queries do batch continuam levando > 2s, o pool ainda vai esgotar — apenas num limiar mais alto. O timeout de 2s é insuficiente para queries bulk em tabela `transactions` sob carga. A nova biblioteca de pool tem comportamento de reconexão diferente da versão anterior, o que agrava o `connection reset by peer`.

---

## 4. Recomendação

**Execute o rollback para v2.47.0. Confiança: Alta.**

O timeout reduzido de 5s→2s, combinado com o novo endpoint de batch gerando queries pesadas no Ledger, é a causa direta do esgotamento do pool. O rollback restaura o timeout original e remove o endpoint batch, permitindo que conexões completem e sejam liberadas antes de expirar. O TTR estimado de 5–8 minutos é inferior à janela de decisão de 20 minutos.

**Premissa crítica:** esta recomendação assume que o comportamento do pool em v2.47.0 era estável sob a carga atual. Se o tráfego cresceu substancialmente desde a última versão estável, o rollback pode não ser suficiente e escalonamento adicional de pods será necessário em paralelo.

O scaling emergencial (Opção B) não deve ser descartado como complemento pós-rollback se o consumer lag do Reactor não se recuperar, mas não deve substituir o rollback.

---

## 5. Próximas Ações Imediatas

### Em < 5 minutos

- [ ] **Acionar rollback no Argo CD**: reverter `chronos-api` para a imagem `v2.47.0`
- [ ] **Abrir Beacon**: criar alerta em tempo real para `err_rate_pct` e `connections_active/ledger`
- [ ] **Notificar o time do Reactor**: consumer lag vai se normalizar após Chronos recuperar — não intervir manualmente na fila ainda

### Em < 20 minutos

- [ ] **Verificar conexões ativas ao Ledger no Beacon**: confirmar queda abaixo de 100/250 após pods v2.47.0 subirem
- [ ] **Confirmar p99 voltando à baseline**: latência deve retornar para < 500ms com tráfego atual
- [ ] **Monitorar consumer lag do Reactor**: deve começar a cair assim que Chronos estiver saudável; se lag > 25k em 20 min, considerar aumentar consumers temporariamente
- [ ] **Acionar post-mortem de engenharia**: agendar revisão do changelog v2.48.0 — testar timeout adequado para batch queries em staging com carga sintética antes de redeployar
- [ ] **Documentar timeline no canal de incidente**: registrar timestamps de decisão e ações para o relatório formal
