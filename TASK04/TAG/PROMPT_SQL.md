Você é um especialista em PostgreSQL. Sua tarefa é escrever uma query SQL para um relatório de transações.

**Contexto (Task):**
Preciso de uma consulta para analisar o crescimento do volume de transações nos últimos seis meses, agrupadas por mês e categoria. O resultado será usado em uma apresentação para a diretoria. As tabelas relevantes são `transactions` e `customers`.

**Tabelas:**
```sql
CREATE TABLE transactions (
  id              BIGSERIAL PRIMARY KEY,
  customer_id     BIGINT NOT NULL REFERENCES customers(id),
  category        VARCHAR(32) NOT NULL,
  amount_cents    BIGINT NOT NULL,
  status          VARCHAR(16) NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE customers (
  id          BIGSERIAL PRIMARY KEY,
  segment     VARCHAR(16) NOT NULL,
  country     CHAR(2) NOT NULL,
  signup_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Requisitos (Action):**
1.  **Período:** Considere os últimos 6 meses corridos a partir da data de hoje, `2026-04-24`.
2.  **Filtro:** Inclua apenas transações com `status = 'completed'`.
3.  **Agrupamento:** Agrupe os resultados pelo ano e mês da transação (formato `YYYY-MM`) e pela `category`.
4.  **Métricas:**
    *   `transaction_count`: Contagem total de transações por grupo.
    *   `total_volume_reais`: Soma dos valores (`amount_cents`), convertida para reais (dividida por 100.0) e formatada com duas casas decimais.
5.  **Ordenação:** Ordene os resultados por mês (crescente) e depois por categoria (crescente).

**Objetivo (Goal):**
O resultado final deve ser uma tabela clara e ordenada que mostre a contagem de transações e o volume financeiro total para cada categoria, mês a mês. Isso ajudará a identificar tendências de crescimento e a performance de cada tipo de transação para uma apresentação executiva.
