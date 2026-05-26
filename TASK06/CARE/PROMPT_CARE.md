Você é um Engenheiro de DevOps Sênior e Especialista em Cloud Architecture com vasta experiência em Terraform e segurança na AWS.

## [CONTEXTO]
A nossa empresa possui políticas de governança e conformidade extremamente rigorosas estabelecidas pelo nosso time de segurança (liderado por Strickland). Todo novo módulo de Infraestrutura como Código (IaC) em Terraform deve seguir um padrão corporativo estrito para garantir rastreabilidade de custos, padronização de nomenclatura e postura de segurança avançada. O Doc Brown solicitou a criação de um módulo reutilizável do Terraform para provisionamento de buckets do Amazon S3 que siga integralmente esse padrão corporativo. Este módulo será consumido por todos os times de engenharia da empresa.

## [AÇÃO]
Escreva um módulo Terraform completo e reutilizável para provisionar buckets do Amazon S3 que atenda estritamente aos seguintes critérios técnicos:
1. Tags Obrigatórias: Todo recurso criado deve receber as tags "Owner", "CostCenter" e "Environment". Elas devem ser compostas de variáveis de entrada e mescladas eficientemente.
2. Padronização de Nomes: Todo nome físico do recurso na AWS deve obrigatoriamente iniciar com o prefixo corporativo "hvt-".
3. Segurança Máxima no S3:
   - Criptografia em repouso habilitada (mínimo SSE-S3 usando o recurso `aws_s3_bucket_server_side_encryption_configuration`).
   - Versionamento ativado (`aws_s3_bucket_versioning`).
   - Bloqueio total e irrestrito de acesso público (`aws_s3_bucket_public_access_block` com todas as flags setadas para true).
   - Configuração de logging ativa (`aws_s3_bucket_logging`) direcionada para um bucket de logs centralizado parametrizável.
4. Documentação de Variáveis: Todas as variáveis de entrada no arquivo `variables.tf` devem conter obrigatoriamente os atributos `type` e `description` preenchidos de forma clara e em português.

## [RESULTADO]
Forneça o código completo separado nos seguintes arquivos da estrutura padrão do módulo:
- `variables.tf`: Definição tipada e descrita de todas as entradas necessárias.
- `main.tf`: Definição do bucket, recursos de segurança agregados e locals para manipulação de tags e nomes.
- `outputs.tf`: Exportação de atributos chaves (como o ID e a ARN do bucket).
- Além dos arquivos do módulo, forneça um bloco de código demonstrando um "Exemplo de Uso" prático chamando este módulo em um ambiente corporativo.
Certifique-se de que o código utilize as melhores práticas do Terraform >= 1.0 e do AWS Provider v5+ (onde recursos secundários do S3 são declarados de forma independente em vez de blocos inline obsoletos). Não utilize placeholders incompletos ou reticências.

## [EXEMPLO]
Para garantir a consistência estética, de estilo de código e de nomenclatura com os demais módulos corporativos, utilize estritamente o design pattern adotado no módulo de VPC existente na empresa mostrado abaixo:

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

* **Alinhe as declarações do módulo S3 para seguirem a mesma filosofia de reaproveitamento de tags via `locals` e uso do prefixo "hvt-" no nome do recurso.**
