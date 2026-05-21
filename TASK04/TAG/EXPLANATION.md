## Justificativa (T-A-G)

O prompt foi estruturado usando o framework T-A-G para garantir que a IA recebesse um pedido claro, contextualizado e com todos os detalhes necessários para gerar a query SQL correta.

### Task (Tarefa)

A seção **Task** define o papel do assistente ("especialista em PostgreSQL") e estabelece a tarefa principal de alto nível: criar uma query SQL para um relatório de crescimento de transações.

*   **No prompt:** `Você é um especialista em PostgreSQL. Sua tarefa é escrever uma query SQL para um relatório de transações... Preciso de uma consulta para analisar o crescimento do volume de transações nos últimos seis meses...`
*   **Função:** Orienta a IA sobre o domínio (SQL, PostgreSQL) e o objetivo geral, focando o escopo da resposta.

### Action (Ação)

A seção **Action** detalha de forma explícita e inequívoca todas as regras de negócio e restrições que a query deve implementar. É a parte mais técnica do prompt e se traduz diretamente nas cláusulas da query.

*   **No prompt:** A lista numerada de "Requisitos", detalhando período, filtros, agrupamento, métricas (com cálculo e formatação) e ordenação.
*   **Função:** Fornece as instruções passo a passo que eliminam ambiguidades e guiam a construção da query, especificando o que vai nas cláusulas `WHERE`, `GROUP BY`, `SELECT` e `ORDER BY`.

### Goal (Objetivo)

A seção **Goal** explica o "porquê" por trás da solicitação. Ela contextualiza o uso final do resultado.

*   **No prompt:** `O resultado final deve ser uma tabela clara e ordenada... Isso ajudará a identificar tendências de crescimento e a performance de cada tipo de transação para uma apresentação executiva.`
*   **Função:** Permite que a IA faça inferências para além do texto literal. Saber que o destino é uma apresentação executiva reforça a necessidade de clareza (usando aliases como `month`), precisão nos cálculos e ordenação lógica, produzindo um resultado mais útil e alinhado à necessidade real do usuário.