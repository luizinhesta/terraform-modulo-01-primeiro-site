# Conceitos Terraform do Módulo 01

## Os arquivos `.tf`

O Terraform lê **todos** os arquivos `.tf` da pasta como se fossem um só. Os nomes são convenção, não obrigação.

| Arquivo | Conteúdo | Por que existe |
|---|---|---|
| `versions.tf` | Bloco `terraform` | Fixa versões do CLI e do provider |
| `providers.tf` | Bloco `provider` | Configura região e tags padrão |
| `main.tf` | `resource`, `data`, `locals` | A infraestrutura em si |
| `outputs.tf` | Blocos `output` | Informações exibidas ao final |

## Bloco `terraform` e `required_providers`

```hcl
terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }
}
```

- `required_version` restringe o **CLI**.
- `required_providers` informa de onde baixar o plugin e qual versão aceitar.
- `~> 6.0` permite `6.x`, mas não `7.0`.

## Bloco `provider`

O provider é um plugin que traduz HCL em chamadas à API da AWS. O bloco `provider "aws"` define a região e as `default_tags`. As credenciais **não** ficam no código: vêm do perfil do AWS CLI.

## Bloco `resource`

```hcl
resource "aws_s3_bucket" "site" { bucket = "..." }
```

- `aws_s3_bucket`: tipo (vem do provider).
- `site`: nome local (só existe no Terraform).
- Endereço do recurso: `aws_s3_bucket.site`.

## Configurações adicionais do S3

Desde o provider v4, o bucket é separado de suas configurações. Por isso existem recursos distintos para website, bloqueio de acesso público e política. Cada um se liga ao bucket via `bucket = aws_s3_bucket.site.id`.

Como fica na AWS depois do `apply`:

![Hospedagem de site estático ativada, com index.html](<../imagens/imagens (8).png>)

*`aws_s3_bucket_website_configuration`: hospedagem ativada com `index.html` como documento de índice.*

![Bloqueio de acesso público ajustado no bucket](<../imagens/imagens (11).png>)

*`aws_s3_bucket_public_access_block`: ACLs continuam bloqueadas; a política pública foi liberada só neste bucket.*

![Política do bucket com s3:GetObject](<../imagens/imagens (10).png>)

*`aws_s3_bucket_policy`: leitura pública apenas de objetos (`s3:GetObject`), restrita ao ARN deste bucket.*

## Referências e dependências

Quando um recurso usa `aws_s3_bucket.site.id`, o Terraform monta um grafo e cria o bucket **antes**. Isso é uma **dependência implícita**. Você não precisa dizer a ordem; ela vem das referências.

O `depends_on` do `aws_s3_bucket_policy` é usado porque a política pública só é aceita depois que o bloqueio de política pública é desligado, e não há referência direta entre os dois.

Dá para ver essa ordem no log do `apply`: o bucket é criado primeiro e a política por último.

![Ordem de criação dos recursos no apply](<../imagens/imagens (3).png>)

## Conceitos de apoio

Aparecem no código para o laboratório funcionar. Entenda a ideia; o aprofundamento vem depois.

| Conceito | Explicação curta | Onde aprofundar |
|---|---|---|
| `data "aws_caller_identity"` | Um `data` **lê** algo que já existe e não cria nada. Aqui lê o ID da conta para compor um nome de bucket único | Módulo 02 (outro uso) |
| `locals` | Valores calculados reutilizáveis dentro do módulo, como variáveis internas (`local.bucket_name`) | Módulo 03 |
| `path.module` | Caminho da pasta do código; evita caminhos absolutos da sua máquina | Uso contínuo |
| `jsonencode(...)` | Função que converte uma estrutura HCL em JSON, evitando erros de aspas na policy | Módulo 03 |
| `filemd5(...)` | Função que calcula o hash de um arquivo local, para o Terraform notar mudanças | Módulo 02 |
| `depends_on` | Força uma ordem quando não há referência direta entre recursos | Módulo 02 |
| `default_tags` | Tags aplicadas a todos os recursos do provider | Módulo 03 |

## `aws_s3_object` e detecção de mudanças

O `etag = filemd5(...)` guarda o hash do arquivo. Se o arquivo local mudar, o hash muda, e o `plan` mostra `~ update in-place`.

![Plano mostrando o etag mudando em index.html e style.css](<../imagens/imagens (16).png>)

*O `etag` antigo vira o novo (`->`). O recurso é atualizado no lugar, sem recriar.*

## Atributos computados e outputs

Alguns valores só existem depois da criação, como `website_endpoint`. No `plan` aparecem como `(known after apply)`. O `output` os expõe.

![Plan com outputs known after apply](<../imagens/imagens (5).png>)

*No `plan`, `bucket_name` e `website_url` são `(known after apply)`. Após o `apply`, os valores reais aparecem em `Outputs:`.*

## Comandos

| Comando | O que faz | Altera a AWS? |
|---|---|---|
| `terraform init` | Baixa providers e prepara o diretório | Não |
| `terraform fmt` | Formata o código | Não |
| `terraform validate` | Verifica sintaxe e coerência interna | Não |
| `terraform plan` | Mostra o que mudaria | Não |
| `terraform apply` | Executa as mudanças | **Sim** |
| `terraform destroy` | Remove tudo o que o state gerencia | **Sim** |

## Símbolos do plano

| Símbolo | Significado |
|---|---|
| `+` | criar |
| `~` | alterar no lugar |
| `-` | destruir |
| `-/+` | destruir e recriar (substituição) |

## State

Depois do `apply` surge `terraform.tfstate` na pasta `terraform/`. É o registro do que o Terraform criou. **Não edite nem versione.** O módulo 04 explora esse tema em profundidade.

Depois do `destroy`, o state continua existindo, mas sem recursos (`"resources": []`):

![terraform.tfstate vazio após o destroy](<../imagens/imagens (19).png>)
