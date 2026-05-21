## Modelo

*   **Modelo:** gpt-4-turbo ou similar, especializado em geração de código.

## Output (SQL)

```sql
SELECT
  TO_CHAR(created_at, 'YYYY-MM') AS month,
  category,
  COUNT(id) AS transaction_count,
  (SUM(amount_cents) / 100.0)::DECIMAL(18, 2) AS total_volume_reais
FROM
  transactions
WHERE
  status = 'completed'
  AND created_at >= (DATE '2026-04-24' - INTERVAL '6 months')
  AND created_at < DATE '2026-04-24'
GROUP BY
  month,
  category
ORDER BY
  month ASC,
  category ASC;
```

## Justificativa (T-A-G)

O prompt foi estruturado usando o framework T-A-G para garantir que a IA recebesse um pedido claro, contextualizado e com todos os detalhes necessários.

### Task (Tarefa)

> **"Sua tarefa é escrever uma query SQL para um relatório de transações... Preciso de uma consulta para analisar o crescimento do volume de transações nos últimos seis meses, agrupadas por mês e categoria."**

*   **Função:** Define o papel do assistente ("especialista em PostgreSQL") e estabelece a tarefa principal de alto nível: criar uma query SQL para um relatório específico. Isso orienta a IA sobre o domínio e o tipo de output esperado.

### Action (Ação)

> **"Requisitos (Action): 1. Período: Considere os últimos 6 meses... 2. Filtro: Inclua apenas transações com status = 'completed'... 3. Agrupamento... 4. Métricas... 5. Ordenação..."**

*   **Função:** Detalha de forma explícita e inequívoca todas as regras de negócio, transformações de dados e restrições que a query deve implementar. Cada requisito é um passo lógico:
    *   **Filtros (`WHERE`):** Define o período de tempo e o status das transações.
    *   **Agrupamento (`GROUP BY`):** Especifica como os dados devem ser consolidados.
    *   **Cálculos (`SELECT`/Agregações):** Indica as métricas a serem calculadas (contagem e soma com conversão de tipo).
    *   **Ordenação (`ORDER BY`):** Determina a ordem de apresentação dos resultados.
*   Essa seção é a mais crítica, pois se traduz diretamente nas cláusulas da query SQL.

### Goal (Objetivo)

> **"O resultado final deve ser uma tabela clara e ordenada que mostre a contagem de transações e o volume financeiro total para cada categoria, mês a mês. Isso ajudará a identificar tendências de crescimento e a performance de cada tipo de transação para uma apresentação executiva."**

*   **Função:** Explica o "porquê" por trás da tarefa. Ao saber que o destino é uma apresentação executiva sobre tendências de crescimento, a IA pode inferir a importância da clareza, da ordenação correta e da precisão dos dados. Esse contexto ajuda a resolver ambiguidades e a gerar um código mais alinhado à necessidade final do usuário, em vez de apenas seguir as instruções de forma literal.