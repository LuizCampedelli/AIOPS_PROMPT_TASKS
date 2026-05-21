# Task

Analyze the following AWS monthly cost breakdown for Hill Valley Tech and produce an executive cost-reduction report. The data represents last month's spending across all production systems (Chronos, Ledger, Reactor, Beacon, Lift).

```csv
servico,categoria,custo_mensal_usd,uso_medio_pct,observacao
EC2 reservada,compute,4200,72,contrato de 1 ano
EC2 on-demand,compute,8200,45,workloads variaveis
EKS,compute,6700,58,3 clusters
RDS PostgreSQL,databases,8200,62,multi-AZ
ElastiCache Redis,databases,2100,40,cluster de producao
S3 Standard,storage,3100,,5 buckets principais
EBS gp3,storage,1600,68,volumes de producao
CloudWatch Logs,observability,2800,,retencao de 90 dias
CloudWatch Metrics,observability,900,,
Data Transfer Out,network,1900,,trafego entre regioes
NAT Gateway,network,1200,,3 gateways ativos
Lambda,compute,900,30,~12M invocacoes/mes
```

Total monthly spend: USD 41,800.

# Action

1. Calculate the total monthly spend and the 15% target savings in absolute dollars.
2. Identify every optimization opportunity from the CSV, considering: underutilized resources (low usage percentage), pricing model changes (Reserved Instances, Savings Plans, Spot), storage tiering (S3 Intelligent-Tiering, lifecycle policies), log retention reduction, network architecture improvements (VPC endpoints, NAT consolidation), and right-sizing.
3. For each opportunity, estimate the monthly savings in USD and as a percentage of the total bill.
4. Classify implementation effort as Low (configuration change, < 1 day), Medium (architecture adjustment, 1-5 days), or High (redesign or migration, > 5 days).
5. Assess risks and prerequisites for each opportunity (e.g., SLA impact, required testing, team coordination, contractual constraints).
6. Rank all opportunities by savings impact (highest first) and present them in a prioritized table.
7. Sum the projected savings and confirm whether the 15% target (USD 6,270/month) is achievable with the proposed actions.

# Goal

Deliver a clear, executive-ready report that the CEO (Goldie Wilson) can present to the board, showing a prioritized roadmap to achieve at least 15% cloud cost reduction (USD 6,270/month) without degrading production SLAs. The report must include: a summary table of opportunities ranked by impact, the percentage each represents of the total bill, effort classification, risks/prerequisites, and a final recommendation on feasibility.
