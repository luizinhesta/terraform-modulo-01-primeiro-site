# -----------------------------------------------------------------------------
# outputs.tf
#
# Outputs exibem valores ao final do apply e ficam disponíveis com
# "terraform output". Muitos valores (como a URL) só são conhecidos DEPOIS que
# a AWS cria o recurso: são os "atributos computados".
# -----------------------------------------------------------------------------
output "bucket_name" {
  description = "Nome do bucket S3 criado."
  value       = aws_s3_bucket.site.id
}

output "website_url" {
  description = "URL HTTP do site (S3 Website Hosting não oferece HTTPS)."
  value       = "http://${aws_s3_bucket_website_configuration.site.website_endpoint}"
}
