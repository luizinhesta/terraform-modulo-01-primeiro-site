# -----------------------------------------------------------------------------
# versions.tf
#
# O bloco "terraform" configura o próprio Terraform (não é um recurso).
# Aqui dizemos:
#   1. Qual versão do Terraform CLI este código aceita.
#   2. Quais providers (plugins) são necessários e em qual versão.
#
# Por que isso importa? Sem restrições, outra pessoa (ou você, daqui a 1 ano)
# pode rodar o código com uma versão incompatível e obter resultados diferentes.
# -----------------------------------------------------------------------------
terraform {
  # Aceita Terraform 1.5 ou superior, mas abaixo da 2.0.
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      # "source" é o endereço do provider no Terraform Registry:
      # <namespace>/<tipo>  ->  hashicorp/aws
      source = "hashicorp/aws"

      # "~> 6.0" significa: >= 6.0 e < 7.0 (aceita atualizações minor/patch,
      # bloqueia a próxima major, que pode quebrar compatibilidade).
      version = "~> 6.0"
    }
  }
}
