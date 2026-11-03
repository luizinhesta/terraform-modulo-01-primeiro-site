# -----------------------------------------------------------------------------
# providers.tf
#
# O bloco "provider" CONFIGURA o plugin declarado em required_providers.
# Se versions.tf diz "qual plugin", providers.tf diz "como usá-lo".
#
# Credenciais: NÃO são escritas aqui. O provider usa a cadeia padrão da AWS:
# variáveis de ambiente (AWS_PROFILE) ou ~/.aws/config. Exemplo:
#   aws sso login --profile meu-perfil
#   $env:AWS_PROFILE = "meu-perfil"      # PowerShell
#   export AWS_PROFILE=meu-perfil         # Linux/macOS
# -----------------------------------------------------------------------------
provider "aws" {
  region = "us-east-1"

  # default_tags aplica estas tags automaticamente a todos os recursos que
  # suportam tags, sem repetir em cada bloco "resource".
  default_tags {
    tags = {
      Project   = "terraform-na-pratica"
      Module    = "modulo-01-primeiro-site"
      ManagedBy = "terraform"
    }
  }
}
