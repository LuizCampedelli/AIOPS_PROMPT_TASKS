# Justificativa — Escolha do Framework R-I-S-E

## Framework Escolhido: R-I-S-E

**R**ole — **I**nput — **S**teps — **E**xpectation

---

## Por que R-I-S-E é o framework ideal para este cenário

### Natureza do problema

Este cenário tem três características que ditam a escolha do framework:

1. **Volume e estrutura de artefatos**: foram fornecidos cinco blocos de dados técnicos distintos — changelog do deploy, tabela de métricas, trecho de log, estado de fila e estado do cluster. Qualquer framework escolhido precisa ter um slot explícito para absorver esse input sem diluí-lo no corpo narrativo do prompt.

2. **Decisão binária com prazo rígido**: o CTO precisa escolher entre duas opções em 20 minutos. O prompt não pode apenas pedir uma análise genérica — precisa guiar o modelo por um raciocínio estruturado que leve a uma recomendação acionável.

3. **Audiência técnica de alto nível**: o output vai para um CTO em call de incidente, não para um cliente ou produto. O formato deve ser denso, tabular e direto — sem narrativa explicativa longa.

### Como cada componente de R-I-S-E aparece no prompt

| Componente    | Onde aparece no prompt                                                                                                                | O que resolve                                                                                 |
|---------------|---------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| **Role**      | "Você é um Senior SRE com especialização em PostgreSQL, pool de conexões e resposta a incidentes de alto tráfego..."                  | Calibra o modelo para linguagem técnica, julgamentos de engenharia e tom de urgência          |
| **Input**     | Seção dedicada com 5 blocos numerados: changelog, métricas, logs, estado Reactor, estado cluster                                      | Organiza os artefatos de forma que o modelo possa referenciá-los individualmente nos Steps    |
| **Steps**     | 5 passos sequenciais: causa raiz → raio de impacto → Opção A → Opção B → recomendação                                                | Prescreve o caminho de raciocínio, evitando que o modelo pule direto para a conclusão ou repita dados sem análise |
| **Expectation** | Seção com 5 sub-seções obrigatórias, formatos definidos (tabelas, limite de palavras por seção)                                     | Garante que o output seja imediatamente utilizável numa call de incidente sem reformatação    |

O diferencial de R-I-S-E neste caso é a combinação entre **Input** (estrutura para absorver dados) e **Steps** (estrutura para conduzir o raciocínio). Nenhum dos frameworks alternativos possui os dois simultaneamente com essa clareza.

---

## Comparação com Frameworks Alternativos

### Candidato 1: C-A-R-E (Context, Action, Result, Example)

**O que se ganharia:**
- O slot `Context` é semanticamente natural para despejar os artefatos técnicos do incidente — changelog, métricas e logs caberiam bem ali, e o modelo está bem treinado para processar contexto rico nesse formato.
- O slot `Example` poderia ser usado para fornecer um template de postmortem de referência, servindo como few-shot para o formato de saída esperado.

**O que se perderia:**
- `Action` e `Result` se sobrepõem parcialmente neste cenário: o que o modelo deve *fazer* (analisar e recomendar) e o que deve *entregar* (o postmortem) são quase a mesma coisa quando a tarefa é geração de documento. Essa sobreposição força o engenheiro de prompt a repetir informação ou deixar um dos dois vago.
- C-A-R-E não tem um slot explícito para `Steps` — o modelo precisaria inferir a sequência de raciocínio (causa raiz → opções → recomendação) a partir do `Context` ou do `Action`. Num cenário onde a ordem de análise importa (você precisa diagnosticar antes de recomendar), a ausência de steps explícitos aumenta o risco de o modelo ir direto à conclusão sem justificativa técnica adequada.
- **Veredicto**: C-A-R-E seria uma boa segunda opção se o prompt fosse mais narrativo e menos orientado a processo de decisão. Aqui, a ausência de Steps é uma desvantagem concreta.

---

### Candidato 2: R-T-F (Role, Task, Format)

**O que se ganharia:**
- Extrema simplicidade e familiaridade — R-T-F é o framework mais direto e amplamente utilizado. Qualquer SRE ou engenheiro de prompt o entende imediatamente.
- O slot `Format` cobre bem a estrutura de saída esperada (tabelas, seções, limites de palavras).

**O que se perderia:**
- R-T-F não tem slot para `Input`: os artefatos técnicos (métricas, logs, changelog) teriam que ser incorporados dentro do `Task` ou do `Format`, tornando o prompt semanticamente confuso — o `Task` misturaria "o que fazer" com "os dados sobre os quais agir".
- R-T-F não tem slot para `Steps`: o modelo recebe a tarefa e o formato, mas nenhuma orientação sobre como raciocinar para chegar ao output. Num incidente com múltiplas hipóteses (timeout? library bug? carga?), a falta de steps pode levar o modelo a uma análise superficial ou a ancorar na explicação mais óbvia sem considerar as alternativas de forma comparativa.
- O prompt de R-T-F para este cenário ficaria sobrecarregado no `Task`, acumulando dados + instruções de raciocínio + critérios de decisão num único parágrafo denso e de difícil manutenção.
- **Veredicto**: R-T-F é excelente para tarefas de geração direta (como o TASK01 — criar um Dockerfile). Para tarefas de análise com decisão, ele é insuficiente porque não orienta o processo de raciocínio.

---

### Candidato 3 (referência rápida): B-A-B (Before, After, Bridge)

B-A-B seria inadequado aqui porque é um framework orientado a *transformação* — descreve um estado antes, um estado depois desejado, e pede ao modelo que construa a ponte. Ele funciona bem para proposta de mudança arquitetural ou pitch de produto, mas não para análise de causa raiz de incidente. O cenário não é "quero ir de A para B" — é "algo quebrou, diagnostique e recomende". B-A-B seria forçado e resultaria num postmortem estruturado como narrativa de transformação, não como diagnóstico técnico.

---

## Resumo da Decisão

| Framework | Slot para Input? | Slot para Steps? | Slot para Formato? | Adequação ao cenário |
|-----------|-----------------|------------------|--------------------|----------------------|
| R-I-S-E   | Sim (Input)     | Sim (Steps)      | Sim (Expectation)  | **Alta**             |
| C-A-R-E   | Sim (Context)   | Não              | Parcial (Result)   | Média                |
| R-T-F     | Não             | Não              | Sim (Format)       | Baixa-Média          |
| B-A-B     | Não             | Não              | Não                | Baixa                |

R-I-S-E vence porque é o único framework que possui os três atributos críticos para este tipo de cenário: **um slot dedicado para dados de entrada**, **orientação explícita do processo de raciocínio**, e **especificação precisa do formato de saída**. Para prompts de análise técnica com artefatos ricos e decisão sob prazo, essa tríade é insubstituível.
