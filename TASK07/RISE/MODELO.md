## Modelo Recomendado

* **Modelo: Gemini 3.1 Pro (High).**

Justificativa: Por se tratar de um modelo de altíssima capacidade lógica e de contexto, o Gemini 3.1 Pro é capaz de correlacionar fatos sutis descritos no [INPUT] (como o fato de o HPA ser baseado em CPU, logo, não ajudará automaticamente em um vazamento de memória) e redigirá os passos corretos de mitigação manual (como o rollout restart). O alinhamento à sintaxe exata das ferramentas (kubectl, argocd) exigido em runbooks operacionais é perfeito nesta classe de modelo.
