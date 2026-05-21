# Cloud Cost Reduction Report — Hill Valley Tech

**Prepared for:** Goldie Wilson (CEO)
**Date:** 2026-05-21
**Objective:** Achieve 15% reduction in monthly AWS spend without SLA degradation
**Current monthly spend:** USD 41,800
**Target savings:** USD 6,270/month (15%)

---

## Executive Summary

Analysis of last month's AWS bill identified **10 optimization opportunities** totaling an estimated **USD 7,830 to USD 9,470/month in savings (18.7% to 22.7%)**. The 15% target of USD 6,270/month is **achievable** using only Low and Medium effort initiatives, without touching core architecture or degrading SLAs.

The three highest-impact actions alone — right-sizing EC2 on-demand, converting stable workloads to Savings Plans, and consolidating EKS clusters — account for approximately USD 5,500/month (13.2%).

---

## Cost Breakdown by Category

| Category | Monthly Cost (USD) | % of Total |
|---|---|---|
| Compute (EC2 + EKS + Lambda) | 20,000 | 47.8% |
| Databases (RDS + ElastiCache) | 10,300 | 24.6% |
| Storage (S3 + EBS) | 4,700 | 11.2% |
| Observability (CloudWatch) | 3,700 | 8.9% |
| Network (Data Transfer + NAT) | 3,100 | 7.4% |
| **Total** | **41,800** | **100%** |

---

## Prioritized Optimization Opportunities

| # | Opportunity | Service | Est. Savings (USD/mo) | % of Total Bill | Effort | Risk / Prerequisites |
|---|---|---|---|---|---|---|
| 1 | **Right-size EC2 on-demand instances** — Usage at 45%. Downsize instance types or adopt autoscaling to match actual load. Target 70% utilization. | EC2 on-demand | 2,870 – 3,280 | 6.9% – 7.8% | Medium | Requires load testing to confirm smaller instances handle peak traffic. Monitor for 1-2 weeks before committing. No SLA impact if staged. |
| 2 | **Convert stable EC2 on-demand to Savings Plans** — After right-sizing, commit predictable baseline to 1-year Compute Savings Plan (~30% discount). | EC2 on-demand | 1,480 – 1,640 | 3.5% – 3.9% | Low | Financial commitment (1-year). Analyze 30-day usage pattern with AWS Cost Explorer before purchasing. Reversible: Savings Plans apply automatically. |
| 3 | **Consolidate EKS clusters from 3 to 2** — Usage at 58%. Merge dev/staging or underutilized clusters. Redistribute workloads. | EKS | 1,120 – 2,230 | 2.7% – 5.3% | High | Requires workload mapping and namespace reorganization. Must validate cluster capacity and network policies. Plan 2-3 sprint cycles. |
| 4 | **Right-size ElastiCache Redis** — Usage at 40%. Scale down node type or reduce replica count. | ElastiCache Redis | 630 – 840 | 1.5% – 2.0% | Medium | Test cache hit rates and latency under reduced capacity. Failover test required before production change. |
| 5 | **Reduce CloudWatch Logs retention from 90 to 30 days** — Archive older logs to S3 for compliance if needed. | CloudWatch Logs | 1,400 – 1,870 | 3.3% – 4.5% | Low | Confirm 30-day retention meets compliance requirements (check with Strickland). Set up S3 export for logs older than 30 days if audit trail is needed. |
| 6 | **Move infrequently accessed S3 data to Intelligent-Tiering** — Analyze access patterns across 5 buckets. | S3 Standard | 310 – 620 | 0.7% – 1.5% | Low | No retrieval penalty with Intelligent-Tiering. Enable on a per-bucket basis. Monitor for 30 days. Zero risk to SLA. |
| 7 | **Consolidate NAT Gateways from 3 to 1-2** — Evaluate if all 3 AZs require dedicated NAT Gateways or if traffic can be routed through fewer. | NAT Gateway | 400 – 600 | 1.0% – 1.4% | Medium | Increased blast radius if single NAT fails. Keep at least 2 for HA. Requires VPC route table changes and testing. |
| 8 | **Reduce cross-region data transfer** — Evaluate if workloads can be co-located in a single region or use VPC endpoints for AWS service traffic. | Data Transfer Out | 380 – 570 | 0.9% – 1.4% | High | Architecture review needed. Some cross-region traffic may be required for disaster recovery. VPC endpoints for S3/DynamoDB are zero-cost and immediate. |
| 9 | **Right-size RDS PostgreSQL** — Usage at 62%. Evaluate if a smaller instance class handles the load, or switch to Aurora Serverless v2 for variable workloads. | RDS PostgreSQL | 820 – 1,230 | 2.0% – 2.9% | High | Multi-AZ must be preserved. Requires thorough performance testing. Instance change causes brief failover (~30s). Aurora migration is a larger project. |
| 10 | **Optimize Lambda with ARM64 (Graviton)** — Migrate functions to arm64 for 20% cost reduction. Reduce over-provisioned memory. | Lambda | 130 – 180 | 0.3% – 0.4% | Low | Test function compatibility with arm64. Most Python/Node runtimes are compatible. Minimal risk. |

---

## Savings Summary

| Effort Level | Opportunities | Est. Combined Savings (USD/mo) | % of Total Bill |
|---|---|---|---|
| **Low** | #2, #5, #6, #10 | 3,320 – 4,310 | 7.9% – 10.3% |
| **Medium** | #1, #4, #7 | 3,900 – 4,720 | 9.3% – 11.3% |
| **High** | #3, #8, #9 | 2,320 – 4,030 | 5.5% – 9.6% |
| **Total (all)** | 10 opportunities | **7,830 – 9,470** | **18.7% – 22.7%** |

---

## Recommended Implementation Roadmap

### Phase 1 — Quick Wins (Weeks 1-2) — Low Effort
- Reduce CloudWatch Logs retention to 30 days (after compliance confirmation)
- Enable S3 Intelligent-Tiering on non-critical buckets
- Migrate Lambda functions to Graviton (arm64)
- **Expected savings: ~USD 1,840 – 2,670/month**

### Phase 2 — Right-Sizing (Weeks 3-6) — Medium Effort
- Right-size EC2 on-demand instances (staged rollout with monitoring)
- Right-size ElastiCache Redis nodes
- Consolidate NAT Gateways from 3 to 2
- Purchase Compute Savings Plan for stabilized EC2 baseline
- **Expected savings: ~USD 5,380 – 6,280/month (cumulative)**

### Phase 3 — Architecture Optimization (Weeks 7-12) — High Effort
- Consolidate EKS clusters
- Reduce cross-region data transfer (VPC endpoints first, co-location later)
- Evaluate RDS right-sizing or Aurora migration
- **Expected savings: ~USD 7,830 – 9,470/month (cumulative)**

---

## Feasibility Assessment

**The 15% target (USD 6,270/month) is achievable by the end of Phase 2**, using only Low and Medium effort initiatives. This avoids the risk and coordination cost of High effort architectural changes.

If Phases 1 and 2 are executed as planned, the company can expect savings between **USD 5,380 and USD 6,280/month (12.9% – 15.0%)**. Adding any single High-effort item from Phase 3 comfortably exceeds the target.

**Recommendation:** Execute Phases 1 and 2 this quarter. Use Phase 3 as a stretch goal or carry into Q3 if the board targets deeper cuts.
