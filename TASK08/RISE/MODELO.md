## Modelo

*   **Modelo:** Claude Sonnet 4.6

---

## Por que Claude Sonnet 4.6?

A tarefa exige raciocínio técnico multi-camada, não apenas geração de texto. O postmortem precisava correlacionar 5 artefatos distintos (changelog, métricas temporais, logs, fila, cluster), identificar que a causa raiz era uma *combinação* de mudanças (timeout + nova biblioteca de pool + endpoint batch), raciocinar sobre por que o scaling emergencial não funciona mesmo que pareça óbvio (mais conexões não resolvem timeout curto demais), e calcular implicitamente: 12 pods × 20 conexões = 240, que já bate no limite de 250 do RDS. Haiku erraria ou simplificaria esse raciocínio causal encadeado. Opus seria capaz, mas seria custo desnecessário.

O framework R-I-S-E também reduz a carga cognitiva do modelo: o slot `Steps` já decompõe o problema em sequência lógica, então o modelo não precisa planejar *como* raciocinar — só precisa executar cada passo com qualidade. Quando o prompt está bem estruturado assim, Sonnet 4.6 entrega output de nível Opus porque o trabalho de orquestração já foi feito pelo engenheiro de prompt.

| Modelo | Por que não |
|--------|-------------|
| Haiku | Raciocínio causal encadeado com múltiplos artefatos técnicos — risco real de análise rasa ou conclusão errada |
| Opus | Capaz, mas sem ganho prático aqui — o R-I-S-E com Steps explícitos já guia o raciocínio que justificaria Opus |
| **Sonnet 4.6** | Ponto de equilíbrio: forte em análise técnica, infra reasoning e saída estruturada — exatamente o perfil desta tarefa |

O framework bem construído é o multiplicador, e Sonnet 4.6 é o modelo que melhor converte esse multiplicador em output de qualidade sem o custo de Opus.
