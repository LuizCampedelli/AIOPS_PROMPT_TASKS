## Justificativa do Mapeamento (Framework R-I-S-E)

Ao utilizar o framework R-I-S-E, conseguimos forçar o modelo a gerar uma documentação de uso tático:

- Role (Papel): No bloco [ROLE], ao definir o perfil do SRE Sênior focado em redação à prova de falhas para plantonistas sob pressão, o modelo é induzido a abandonar verbosidade, focando estritamente em formatação imperativa e layout de manual de emergência.

- Input (Entrada): Injetamos explicitamente em [INPUT] todos os dados do cenário de Lorraine (HPA limitante de CPU, PostgreSQL, EKS, repositório Argo CD, SLAs). Isso impede o uso de placeholders inúteis (ex: [INSIRA O NOME DO SEU CLOUD PROVIDER]), resultando em um material 100% pronto. A menção ao limite de CPU forçou o modelo a deduzir que o HPA não salvaria a aplicação da falha de memória, corroborando o passo de reinício do deployment.

- Steps (Passos): O bloco [STEPS] dividiu o pensamento estrutural do LLM em 6 áreas fundamentais da resposta a incidentes de software (Acknowledge -> Investigação -> Dependências -> Mitigação -> Escalonamento -> Encerramento). Mais importante: a exigência sistemática da "Verificação Esperada" ensina o plantonista novato não apenas o que rodar, mas como interpretar a saída do terminal.

- Expectation (Expectativa): Em [EXPECTATION], cravamos as regras estéticas: formatação puramente em Markdown, alertas visuais chamativos para a zona de escalonamento, comandos envelopados em "codeblocks". Isso poupa a formatação manual pela Lorraine e entrega o texto pronto para ser colado na base de conhecimento.
