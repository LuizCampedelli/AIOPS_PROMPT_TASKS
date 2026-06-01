## Modelo

*   **Modelo:**: Gemini 1.5 Flash

# Justificativa do Prompt com Before, After, Bridge (BAB)

Este prompt foi estruturado usando o framework **Before, After, Bridge (BAB)** para guiar a IA de forma clara e eficiente na modernização de um manifesto Kubernetes.

### Before (Onde estamos)

A seção `# Before` estabelece o ponto de partida. Ela apresenta um manifesto Kubernetes (`Deployment`) antigo e defasado, com várias práticas não recomendadas para um ambiente de produção.

```yaml
# Before

apiVersion: apps/v1
kind: Deployment
metadata:
  name: chronos-api
...
  replicas: 1
...
    image: chronos-api:latest
...
      value: "P@ssw0rd2023!"
```

**Características do estado "Before":**
*   **Problema Claro:** O manifesto é funcional, mas inseguro e não resiliente.
*   **Contexto Específico:** Fornece o código exato que precisa ser modificado, eliminando ambiguidades.

#### Destaque: replicas: 1 como ponto de falha único

Uma das falhas mais críticas do manifesto original é `replicas: 1`. Com um único pod em execução, qualquer evento derruba o serviço completamente:

- **Crash ou OOM kill**: serviço indisponível por 30 s a 2 min até o Kubernetes reagendar o pod.
- **Rolling deployment**: o único pod é substituído, causando downtime durante cada deploy.
- **Falha ou manutenção de nó**: se o nó for drenado, não há outro pod para assumir o tráfego.

A nova versão define `replicas: 3`, que é o mínimo recomendado para um serviço de produção stateless. Com três réplicas:

1. Uma falha individual de pod não interrompe o serviço — dois pods continuam ativos enquanto o terceiro é reiniciado.
2. O rolling update padrão (`maxUnavailable: 1`) garante que ao menos dois pods estejam prontos durante qualquer deploy.
3. O tráfego é distribuído entre três instâncias, reduzindo a pressão individual antes de qualquer escalonamento automático via HPA.

Três réplicas atende ao requisito "high availability" declarado no `# After` sem superdimensionar para um serviço cujo perfil de carga ainda não foi definido em staging.

### After (Onde queremos chegar)

A seção `# After` define o estado final desejado. Ela não mostra o código final, mas sim uma lista de requisitos e boas práticas que o novo manifesto deve seguir.

```
# After
Create the new manifest... with the following instructions:

- Need high availability
- version image (Do not use latest tag)
- secrets outside the manifest
- Resource requests and limits
- Livenss and readiness probes
- non-root securityContext
- any other production grade safe practice
```

**Características do estado "After":
*   **Visão Clara:** Descreve o objetivo final de forma conceitual e funcional.
*   **Foco em Resultados:** Em vez de ditar a implementação exata, foca nos *resultados* esperados (alta disponibilidade, segurança, etc.), dando à IA a liberdade de aplicar as melhores soluções técnicas.

### Bridge (Como chegamos lá)

A seção `# Bridge` é a ponte que conecta o "Before" e o "After". Ela solicita um plano de ação detalhado que explica as etapas necessárias para transformar o manifesto antigo no novo.

```
# Bridge
Create a plan that will show what is need to make the changes necessary to achieve the "# AFTER" step, add the step to step instruction in an EXPLANATION.md
```

**Características da "Bridge":**
*   **Roteiro Estratégico:** Exige que a IA pense de forma estruturada, detalhando *o quê* precisa ser feito e *por quê*.
*   **Geração de Conhecimento:** O resultado (`EXPLANATION.md`) não é apenas um passo intermediário, mas um artefato valioso que educa o usuário sobre as boas práticas aplicadas, justificando cada mudança.

### Conclusão

O uso do BAB neste prompt permitiu:
1.  **Contextualizar** a IA com o cenário atual (`Before`).
2.  **Definir** um objetivo claro e de alto nível (`After`).
3.  **Exigir** um plano de execução lógico e fundamentado (`Bridge`).

Essa abordagem garante que a IA não apenas gere o código final (`OUTPUT.md`), mas também demonstre uma compreensão profunda do problema ao criar um guia de modernização (`EXPLANATION.md`).
