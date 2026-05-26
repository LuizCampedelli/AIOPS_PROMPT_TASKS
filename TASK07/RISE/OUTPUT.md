## Output Gerado (O Runbook)

### Abaixo está o manual gerado pelo modelo ao processar o prompt:

Runbook: High memory usage on Chronos API pods (>85%)
* **Alerta: [CRITICAL] High memory usage on Chronos API pods (>85% for 10min) Aplicação: Chronos API (Namespace: production | EKS) Dependências: Ledger (PostgreSQL) e Reactor (AWS SQS)**


1. Reconhecimento (Acknowledge)
Assuma a ocorrência publicamente para evitar trabalho duplicado.

* **Ação: Envie no canal #oncall-chronos: "👀 Assumindo o alerta de memória no Chronos API. Iniciando o diagnóstico."**

2. Diagnóstico Inicial no Kubernetes
Nota: O HPA está configurado para escalar via CPU. Portanto, um pico de memória não fará os pods escalarem automaticamente. A intervenção manual é necessária.

* **Passo A: Listar o consumo real dos pods**

```
kubectl top pods -n production -l app=chronos-api
Verificação Esperada: Identifique quais dos 6 pods estão com uso de memória acima da margem segura.
```

* **Passo B: Verificar histórico de reinicializações (OOMKilled)**

```
kubectl get pods -n production -l app=chronos-api
Verificação Esperada: Observe a coluna RESTARTS. Se houver muitas reinicializações e o status for OOMKilled, a aplicação já estourou o limite físico alocado e está caindo continuamente.
```

* **Passo C: Validar os eventos recentes**

```
kubectl describe pod <NOME_DO_POD_AFETADO> -n production | tail -n 20
````

3. Checagem de Causas e Dependências
Muitos vazamentos de memória são causados por conexões travadas no banco ou mensagens represadas.

* **Passo A: Validar integridade do Deploy**

```
argocd app get chronos-api
```
Verificação Esperada: O status deve estar Synced e Healthy. Se estiver OutOfSync, a falha de memória pode ser decorrente de um deploy recém-falho.

* **Passo B: Grafana e Dependências**

Acesse o Grafana (Dashboards do Ledger e do Reactor).
Verificações Esperadas:
- PostgreSQL (Ledger): Cheque se há um pico anormal de conexões abertas pendentes limitando a vazão da API.
- SQS (Reactor): Cheque se a métrica ApproximateNumberOfMessagesVisible está subindo drasticamente (filas represadas prendem memória nos workers).

4. Mitigação Paliativa
O objetivo do plantão é restaurar a estabilidade. Sem indícios de queda de banco, deve-se limpar o acúmulo de memória reiniciando os pods controladamente.

* **Passo A: Executar o Restart Controlado (Rollout)**

```
kubectl rollout restart deployment chronos-api -n production

* **Passo B: Acompanhar o processo**
```

```
kubectl rollout status deployment chronos-api -n production
Verificação Esperada: Você deve receber a mensagem "deployment chronos-api successfully rolled out".
```

* **Passo C: Validar a mitigação**

```
kubectl top pods -n production -l app=chronos-api
```

A memória deve ter caído para patamares estáveis (ex: < 50%).

5. Critérios de Escalonamento:
Acione o time de engenharia sênior imediatamente marcando @chronos-core no canal #oncall-chronos se:

- O comando de rollout falhar e os novos pods não subirem (CrashLoopBackOff).
- O consumo de memória retornar a >85% em menos de 10 minutos após o restart.
- O status no Argo CD indicar falha fatal inrecuperável.
- SLA de Resposta @chronos-core: 15 minutos em horário comercial; 30 minutos em regime de sobreaviso (off-hours). Aguarde na thread.

6. Encerramento do Incidente:

- Monitore as métricas (Grafana e kubectl top pods) por 15 minutos corridos após a mitigação.
- Critério de Sucesso: Se a memória se mantiver estável abaixo do limiar (70%) e o alerta do Beacon entrar em RESOLVED, o plantão tático obteve sucesso.

Encerre o fluxo no Slack:
- Ação: Envie no canal #oncall-chronos: "✅ Incidente mitigado com rollout restart. Memória estabilizada há 15min. Abrindo ticket de oportunidade para o time investigar a causa raiz do memory leak durante o expediente."
