# Um dia na Hill Valley Tech

A Hill Valley Tech é uma empresa fictícia que serve de palco para este desafio. Tem cinco sistemas em produção, cada um com seu papel bem definido.

| Sistema | Papel |
|---------|-------|
| **Chronos** | API gateway e plataforma core — ponto de entrada de todo tráfego da empresa |
| **Ledger** | Data warehouse em PostgreSQL — histórico de transações e eventos |
| **Reactor** | Processamento assíncrono via filas de mensagens |
| **Beacon** | Observabilidade do ambiente inteiro — métricas, logs e alertas |
| **Lift** | Produto em beta em amadurecimento separado do core |

O time que toca essa operação também é enxuto:

| Pessoa | Papel |
|--------|-------|
| **Doc Brown** | CTO — direção técnica |
| **Jennifer Parker** | PM — priorização do produto |
| **Lorraine Baines** | Líder de SRE — plantão, runbooks e procedimentos |
| **George McFly** | Engenheiro sênior — escreveu boa parte do sistema legado |
| **Goldie Wilson** | CEO — custo e crescimento |
| **Strickland** | Head de Segurança e Compliance — padrões internos para código novo |

Nos próximos cenários você vai pegar algumas dessas demandas que chegam à mesa do time. Em cada questão, a entrega é um prompt de IA aplicando o framework indicado no enunciado, executado em um modelo, com o output registrado e a justificativa mostrando como os componentes do framework apareceram no prompt. A **Questão 08** foge desse padrão: a escolha do framework fica por sua conta entre os cinco do capítulo, com comparação explícita contra duas alternativas.

---

## Questão 01 — Dockerfile para o Lift

O Lift vai sair das VMs onde vem rodando e entrar no cluster Kubernetes da empresa. O código já está pronto: uma API Python/Flask na porta 8080, dependências declaradas em `requirements.txt`, e duas variáveis de ambiente que precisam estar presentes no runtime — `DATABASE_URL` e `API_KEY`.

Estrutura do projeto:

```
lift/
├── app.py
├── requirements.txt
├── lib/
│   ├── auth.py
│   └── storage.py
└── tests/
    └── test_app.py
```

Conteúdo de `requirements.txt`:

```
Flask==3.0.0
gunicorn==21.2.0
requests==2.31.0
python-dotenv==1.0.0
psycopg2-binary==2.9.9
```

Em produção o serviço sobe com `gunicorn --bind 0.0.0.0:8080 --workers 4 app:app`.

Falta o Dockerfile. Seguir todas as boas práticas de criação.

**Tarefa.** Aplicando o framework **R-T-F**, escrever o prompt de IA que produza esse Dockerfile.

**Entregue.** Prompt, modelo, output e justificativa mostrando como Role, Task e Format aparecem no prompt.

---

## Questão 02 — Script de backup do Ledger

Lorraine chegou à conclusão de que o Ledger, o PostgreSQL que o George levantou na EC2 anos atrás, nunca teve rotina de backup automatizada. Hoje isso é uma dependência aberta no radar da SRE, e ela quer fechar com uma cron diária.

O ambiente onde o script vai rodar:

| Parâmetro | Valor |
|-----------|-------|
| Host | `ledger-db.internal.hvt.io` |
| Porta | `5432` |
| Banco | `ledger_prod` |
| Usuário | `backup_user` |
| Senha | variável `PGPASSWORD`, populada pelo AWS Secrets Manager via IAM role |
| Região AWS | `us-east-1` |
| SO | Ubuntu 22.04 LTS |
| Diretório de trabalho | `/var/backups/ledger` (80 GB livres) |
| Tamanho médio do dump compactado | ~12 GB |

O script precisa:

- Fazer o dump com `pg_dump`, compactar com `gzip`
- Subir o arquivo para o bucket S3 `hvt-ledger-backups` via `aws s3 cp`
- Manter 30 dias de retenção no S3 (removendo os mais antigos)
- Registrar cada execução em `/var/log/ledger-backup.log` com timestamp
- Sair com exit code adequado em caso de falha

**Tarefa.** Aplicando o framework **R-T-F**, escrever o prompt de IA que produza esse script bash.

**Entregue.** Prompt, modelo, output e justificativa mostrando como Role, Task e Format aparecem no prompt.

---

## Questão 03 — Relatório de redução de custos cloud

Goldie apresentou a meta do próximo trimestre à diretoria: **15% de redução no custo cloud** até o fim do período, sem degradar SLA. Doc Brown repassou o breakdown de custos AWS do último mês:

| Serviço | Categoria | Custo Mensal (USD) | Uso Médio (%) | Observação |
|---------|-----------|-------------------|---------------|------------|
| EC2 reservada | compute | 4.200 | 72 | Contrato de 1 ano |
| EC2 on-demand | compute | 8.200 | 45 | Workloads variáveis |
| EKS | compute | 6.700 | 58 | 3 clusters |
| RDS PostgreSQL | databases | 8.200 | 62 | Multi-AZ |
| ElastiCache Redis | databases | 2.100 | 40 | Cluster de produção |
| S3 Standard | storage | 3.100 | — | 5 buckets principais |
| EBS gp3 | storage | 1.600 | 68 | Volumes de produção |
| CloudWatch Logs | observability | 2.800 | — | Retenção de 90 dias |
| CloudWatch Metrics | observability | 900 | — | — |
| Data Transfer Out | network | 1.900 | — | Tráfego entre regiões |
| NAT Gateway | network | 1.200 | — | 3 gateways ativos |
| Lambda | compute | 900 | 30 | ~12M invocações/mês |

O relatório que volta para a Goldie precisa trazer: oportunidades de economia priorizadas por impacto, percentual da conta total, esforço de implementação (baixo, médio, alto) e riscos ou pré-requisitos de cada uma.

**Tarefa.** Aplicando o framework **T-A-G**, escrever o prompt de IA que, a partir do CSV acima, produza esse relatório alinhado à meta de 15%.

**Entregue.** Prompt, modelo, output e justificativa mostrando como Task, Action e Goal aparecem no prompt.

---

## Questão 04 — Relatório mensal de transações do Ledger

Jennifer está fechando a apresentação sobre crescimento de transações nos últimos 6 meses por categoria para levar à Goldie. Ela precisa dos números consolidados mas não escreve SQL. O Ledger (PostgreSQL) tem o histórico completo:

```sql
CREATE TABLE transactions (
  id              BIGSERIAL PRIMARY KEY,
  customer_id     BIGINT NOT NULL REFERENCES customers(id),
  category        VARCHAR(32) NOT NULL,
  amount_cents    BIGINT NOT NULL,
  status          VARCHAR(16) NOT NULL,
  payment_method  VARCHAR(16),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at    TIMESTAMPTZ
);

CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_category ON transactions(category);

CREATE TABLE customers (
  id          BIGSERIAL PRIMARY KEY,
  segment     VARCHAR(16) NOT NULL,
  country     CHAR(2) NOT NULL,
  signup_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

Regras do relatório:

- Categorias: `subscription`, `one_time`, `refund`, `credit_adjustment`
- Apenas registros com `status = 'completed'`
- `amount_cents` em centavos de real — saída em reais com 2 casas decimais
- Recorte: últimos 6 meses corridos a partir de 2026-04-24
- Agrupado por mês (`YYYY-MM`) e por categoria
- Métricas por linha: quantidade de transações e volume total em reais
- Ordenação: mês crescente, depois categoria crescente

**Tarefa.** Aplicando o framework **T-A-G**, escrever o prompt de IA que produza essa query SQL.

**Entregue.** Prompt, modelo, output e justificativa mostrando como Task, Action e Goal aparecem no prompt.

---

## Questão 05 — Modernizar deployment legado

Numa revisão de produção, Doc Brown puxou o manifest do Chronos e encontrou este deployment que o George escreveu três anos atrás:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chronos-api
  namespace: production
spec:
  replicas: 1
  selector:
    matchLabels:
      app: chronos-api
  template:
    metadata:
      labels:
        app: chronos-api
    spec:
      containers:
      - name: api
        image: chronos-api:latest
        ports:
        - containerPort: 8080
        env:
        - name: DB_PASSWORD
          value: "P@ssw0rd2023!"
        - name: JWT_SECRET
          value: "hvt-jwt-prod-secret"
```

A versão moderna precisa ter: alta disponibilidade, imagem versionada (sem `latest`), secrets fora do manifest, resource requests e limits, liveness e readiness probes, `securityContext` não-root e demais práticas de produção padrão da empresa.

**Tarefa.** Aplicando o framework **B-A-B**, escrever o prompt de IA que, recebendo esse manifest, produza a versão modernizada.

**Entregue.** Prompt, modelo, output e justificativa mostrando como Before, After e Bridge aparecem no prompt.

---

## Questão 06 — Módulo Terraform no padrão interno

Strickland publicou o padrão interno de IaC que todo módulo Terraform novo precisa seguir:

- Tags obrigatórias em todo recurso: `Owner`, `CostCenter`, `Environment`
- Prefixo `hvt-` nos nomes de recursos
- Todo bucket S3 com: encryption habilitada (SSE-S3 mínimo), versioning ativo, block public access total, logging configurado
- Variáveis de entrada em `variables.tf` com `description` e `type` obrigatórios

Doc Brown pediu um módulo Terraform reutilizável para criar buckets S3 aderentes a esse padrão. Como referência de estilo, o módulo de VPC existente:

```hcl
variable "environment" {
  description = "Nome do ambiente (dev, staging, production)"
  type        = string
}

locals {
  common_tags = {
    Owner       = var.owner
    CostCenter  = var.cost_center
    Environment = var.environment
  }
}

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags = merge(local.common_tags, {
    Name = "hvt-vpc-${var.environment}"
  })
}
```

**Tarefa.** Aplicando o framework **C-A-R-E**, escrever o prompt de IA que produza o módulo Terraform S3 aderente ao padrão, no mesmo estilo do exemplo.

**Entregue.** Prompt, modelo, output e justificativa mostrando como Context, Action, Result e Example aparecem no prompt.

---

## Questão 07 — Runbook para alerta recorrente

Toda semana, em média 4 vezes, o Beacon dispara o mesmo alerta no canal de plantão: `[CRITICAL] High memory usage on Chronos API pods (>85% for 10min)`. Quem assume o plantão gasta de 30 a 40 minutos até resolver, sem procedimento documentado. Lorraine quer um runbook que qualquer plantonista consiga seguir de ponta a ponta.

O ambiente:

| Item | Detalhe |
|------|---------|
| Cluster | EKS, namespace `production`, 6 réplicas, HPA (min 4, max 12, CPU target 70%) |
| Deploy | Argo CD — repositório `hvt/chronos-api` |
| Dependências | Ledger (PostgreSQL), Reactor (filas SQS) |
| Observabilidade | Métricas em `/metrics`, logs no Beacon, dashboards no Grafana |
| Ferramentas | `kubectl`, `aws cli`, `argocd cli` |
| Canal de plantão | `#oncall-chronos` no Slack |
| Escalação | `@chronos-core` — SLA: 15 min (horário comercial), 30 min (fora) |

O runbook precisa cobrir: diagnóstico inicial (com comandos específicos), verificação esperada ao final de cada passo, critérios para escalar ao time sênior e critério para encerrar o incidente.

**Tarefa.** Aplicando o framework **R-I-S-E**, escrever o prompt de IA que produza esse runbook procedural completo.

**Entregue.** Prompt, modelo, output e justificativa mostrando como Role, Input, Steps e Expectation aparecem no prompt.

---

## Questão 08 — Postmortem técnico de incidente em produção

Um incidente está em andamento durante pico de tráfego. Doc Brown precisa de um postmortem técnico em 20 minutos para decidir entre **rollback do deploy v2.48.0** (que subiu ontem) e **scaling emergencial** (aumento de limits do RDS e do pool de conexões).

**Deploy anterior (ontem, 18:42 UTC):**

```
Deploy chronos-api: v2.47.0 -> v2.48.0
Argo CD sync: 2026-04-23 18:42:11 UTC
Changelog:
- Adicionado endpoint POST /v2/transactions/batch
- Refatorado cliente do Ledger (pool de conexões movido para nova biblioteca interna)
- Bump de psycopg 3.1.18 -> 3.2.0
- Reduzido timeout do Ledger de 5s para 2s
```

**Métricas do Beacon (últimos 30 minutos):**

| Timestamp (UTC) | p99 Latência (ms) | Req/s | Erro (%) |
|-----------------|-------------------|-------|----------|
| 2026-04-24 13:30 | 420 | 1.200 | 0,2 |
| 2026-04-24 13:45 | 510 | 1.450 | 0,3 |
| 2026-04-24 14:00 | 780 | 1.780 | 0,8 |
| 2026-04-24 14:10 | 2.400 | 2.100 | 4,5 |
| 2026-04-24 14:15 | 5.200 | 2.400 | 8,2 |
| 2026-04-24 14:20 | 8.100 | 2.650 | 11,7 |

**Log do pod `chronos-api-79c4d8b9-xk2jp`:**

```
2026-04-24 14:19:48 [ERROR] [ledger-client] connection pool exhausted (max=20, active=20, waiting=147)
2026-04-24 14:19:49 [WARN]  [ledger-client] query timeout after 2000ms: SELECT ... FROM transactions WHERE ...
2026-04-24 14:19:49 [ERROR] [handler] POST /v2/transactions/batch failed: context deadline exceeded
2026-04-24 14:19:50 [ERROR] [ledger-client] connection reset by peer
2026-04-24 14:19:51 [WARN]  [circuit-breaker] ledger-client OPEN (threshold 50%, current 87%)
2026-04-24 14:19:52 [ERROR] [reactor] failed to publish message: chronos-api upstream error
```

**Estado do Reactor (fila `chronos-transactions`):**

- 50.127 mensagens acumuladas, crescendo a ~800/min
- Consumer lag: 18 minutos e aumentando

**Estado do cluster:**

| Recurso | Status |
|---------|--------|
| Chronos pods | 12/12 running (HPA no máximo) |
| CPU médio | 62% |
| Memória média | 71% |
| Conexões ao Ledger | 240/250 (limite do RDS) |

**Tarefa.** Escolher entre os cinco frameworks do capítulo (R-T-F, T-A-G, B-A-B, C-A-R-E ou R-I-S-E) aquele que se aplica melhor a esse cenário e escrever o prompt de IA que produza o postmortem técnico que o Doc pediu.

Nesta questão a justificativa é o coração da entrega. Além de explicar o framework escolhido e como seus componentes aparecem no prompt, comparar explicitamente com pelo menos 2 outros frameworks candidatos, apontando o que se ganharia e o que se perderia em cada um.

**Entregue.** Prompt, modelo, output e justificativa estendida com comparação entre frameworks.

---

## Como a entrega deve ser feita

A entrega é um **repositório público no GitHub** contendo os prompts, outputs e justificativas das 8 questões. O link do repositório deve ser enviado ao final.

A organização interna do repositório é livre e intencional. No Capítulo 4 deste módulo será abordado Criação e Versionamento de Prompts, e a estrutura escolhida aqui será comparada com as práticas apresentadas lá.

Cada questão exige 4 campos obrigatórios:

| Campo | Descrição |
|-------|-----------|
| **Prompt** | O texto exato usado |
| **Modelo** | Qual modelo foi executado e, em 1 linha, por que esse modelo foi escolhido |
| **Output** | A resposta real do modelo, na íntegra ou em trecho relevante |
| **Justificativa** | Em 2 a 4 linhas, como os componentes do framework aparecem no prompt (Q08: comparar com 2 alternativas) |

Orientações práticas:

- Usar ao menos **2 providers distintos** ao longo do desafio (OpenAI, Anthropic, Google, Meta ou local via Ollama)
- Registrar outputs ruins também — se um resultado não ficou bom, comentar na justificativa o que faria diferente
- Os dados dos cenários são fictícios, sem necessidade de sanitização
- Registrar o raciocínio, inclusive o que não funcionou, faz parte do valor da entrega

---

## Bônus — Marketing pessoal (opcional)

Seção opcional, sem peso na avaliação. Três temas baseados nas aulas já cobertas para gerar autoridade na área:

### Tema 1 — Como escolher o modelo de IA certo: custo, latência, qualidade e privacidade

Aproveita o que foi visto sobre providers (OpenAI, Anthropic, Google, Meta via Ollama), formas de consumo (chatbot, agente, API) e os critérios para decidir entre eles.

**Formato sugerido:** carrossel de LinkedIn (5 a 7 slides). Hook, um slide por critério com exemplo prático, slide final com matriz de decisão.

### Tema 2 — Os 5 frameworks de prompt engineering aplicados a Cloud, DevOps e SRE

Aproveita as aulas dos frameworks R-T-F, T-A-G, B-A-B, C-A-R-E e R-I-S-E. Um framework por seção, com exemplo concreto da área e indicação de quando usar cada um.

**Formato sugerido:** artigo longo no LinkedIn ou thread no X com 6 a 8 posts, um por framework e o último consolidando a árvore de decisão.

### Tema 3 — Tokens e janela de contexto: o que todo profissional técnico deveria entender

Aproveita as aulas de tokens, tokenização e janela de contexto. Impacta diretamente custo (pay-per-token) e qualidade da resposta (lost-in-the-middle, estouro da janela).

**Formato sugerido:** artigo técnico no Medium, Dev.to ou blog pessoal. Estrutura: o que é um token, por que importa para custo, por que importa para qualidade, exemplos práticos.
