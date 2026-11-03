# -----------------------------------------------------------------------------
# main.tf - Módulo 01: primeiro site com Terraform
#
# Sintaxe de um resource:
#   resource "<TIPO>" "<NOME_LOCAL>" { ...argumentos... }
#   - TIPO: definido pelo provider (aws_s3_bucket).
#   - NOME_LOCAL: escolhido por você; só existe dentro do Terraform.
#   Juntos formam o endereço do recurso: aws_s3_bucket.site
# -----------------------------------------------------------------------------

# DATA SOURCE: LÊ informações existentes, não cria nada.
# Usamos o ID da conta para compor um nome de bucket globalmente único,
# sem precisar escrever o ID da conta no código.
data "aws_caller_identity" "current" {}

# "locals" são valores calculados reutilizáveis (como variáveis internas).
locals {
  # Nomes de bucket S3: minúsculas, números e hífens; únicos no mundo todo.
  bucket_name = "tfpratica-m01-${data.aws_caller_identity.current.account_id}-us-east-1"

  application_path = "${path.module}/../application"
}

# 1) O BUCKET ------------------------------------------------------------------
resource "aws_s3_bucket" "site" {
  bucket = local.bucket_name

  # force_destroy = true permite que o "terraform destroy" apague o bucket
  # mesmo com objetos dentro. Útil em laboratório; cuidado em produção!
  force_destroy = true

  tags = {
    Name = "Modulo 01 - Primeiro site"
  }
}

# 2) HOSPEDAGEM DE SITE ESTÁTICO ---------------------------------------------
# Desde o provider v4 as configurações do S3 são recursos SEPARADOS do bucket.
resource "aws_s3_bucket_website_configuration" "site" {
  # REFERÊNCIA: <tipo>.<nome>.<atributo>
  # Ao referenciar aws_s3_bucket.site.id, o Terraform entende que este recurso
  # DEPENDE do bucket e o cria depois (dependência implícita).
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }
}

# 3) ACESSO PÚBLICO (SOMENTE DIDÁTICO) ---------------------------------------
# O S3 Website Hosting usa HTTP anônimo, então precisamos liberar a política
# pública NESTE BUCKET. Isso NÃO altera a configuração da conta inteira.
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true # continua bloqueando ACLs públicas
  ignore_public_acls      = true
  block_public_policy     = false # permite bucket policy pública
  restrict_public_buckets = false # permite que a policy pública funcione
}

# 4) POLÍTICA DE LEITURA PÚBLICA ----------------------------------------------
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id

  # jsonencode converte uma estrutura HCL em JSON. Evita erros de aspas.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "LeituraPublicaSomenteDoLaboratorio"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject" # somente ler objetos, nada de listar/escrever
        # Limitada aos objetos DESTE bucket (arn do bucket + /*).
        Resource = "${aws_s3_bucket.site.arn}/*"
      }
    ]
  })

  # Esta dependência já é implícita pelo bucket, mas a política pública só é
  # aceita DEPOIS que o block_public_policy for desligado. Como não há
  # referência direta ao public access block, declaramos depends_on.
  depends_on = [aws_s3_bucket_public_access_block.site]
}

# 5) ARQUIVOS DO SITE ---------------------------------------------------------
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.site.id
  key    = "index.html" # nome do objeto dentro do bucket
  source = "${local.application_path}/index.html"

  # Sem content_type o navegador baixaria o arquivo em vez de exibir.
  content_type = "text/html; charset=utf-8"

  # etag = hash do arquivo local. Se você editar o HTML, o hash muda e o
  # Terraform detecta e reenvia o arquivo no próximo apply.
  etag = filemd5("${local.application_path}/index.html")
}

resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.site.id
  key          = "style.css"
  source       = "${local.application_path}/style.css"
  content_type = "text/css; charset=utf-8"
  etag         = filemd5("${local.application_path}/style.css")
}
