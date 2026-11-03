# Implantação — Módulo 01

> Nada neste projeto foi implantado automaticamente. Você executa cada comando e confere o resultado.

## 1. Preparar credenciais

```powershell
aws sso login --profile <seu-perfil>
$env:AWS_PROFILE = "<seu-perfil>"
aws sts get-caller-identity
```

O último comando deve mostrar a conta e o usuário/role. Isso confirma que o Terraform usará a conta correta.

![Login via SSO e confirmação da identidade com aws sts get-caller-identity](<../imagens/imagens (2).png>)

*Login SSO concluído e `aws sts get-caller-identity` retornando a identidade usada pelo Terraform (dados sensíveis ocultados).*

## 2. Entrar na pasta do Terraform

```powershell
cd etapa-01-fundamentos/modulo-01-primeiro-site/terraform
```

## 3. `terraform init`

```powershell
terraform init
```

O que acontece: baixa o provider `hashicorp/aws` para `.terraform/` e cria `.terraform.lock.hcl`, que registra a versão exata e os hashes. **Versione o lock file no Git.**

Esperado: mensagem `Terraform has been successfully initialized!`.

## 4. `terraform fmt` e `terraform validate`

```powershell
terraform fmt
terraform validate
```

- `fmt` ajusta indentação e alinhamento (lista os arquivos que mudou).
- `validate` confere sintaxe e referências, sem acessar a AWS.

Esperado: `Success! The configuration is valid.`

![terraform init, fmt e validate executados com sucesso](<../imagens/imagens (7).png>)

*`init` baixando o provider `hashicorp/aws` v6.71.0, seguido de `fmt` (sem saída, nada a formatar) e `validate` com sucesso.*

## 5. `terraform plan`

```powershell
terraform plan
```

Leia a saída com calma. Esperado: `Plan: 6 to add, 0 to change, 0 to destroy.` Os recursos são o bucket, website, public access block, policy e dois objetos. Valores como `website_endpoint` aparecem como `(known after apply)`.

![Saída do terraform plan com 6 recursos a criar](<../imagens/imagens (5).png>)

*Final do `plan`: `Plan: 6 to add, 0 to change, 0 to destroy`, com as tags padrão (`ManagedBy`, `Module`, `Project`) e os outputs `(known after apply)`.*

Opcional, para guardar um plano exato:

```powershell
terraform plan -out=tfplan
terraform apply tfplan
```

## 6. `terraform apply`

```powershell
terraform apply
```

O Terraform mostra o plano e pede `yes`. Digite `yes` apenas após revisar. Ao final aparecem os outputs.

![terraform apply aguardando confirmação](<../imagens/imagens (6).png>)

*O `apply` mostra o plano e aguarda a confirmação (`Enter a value:`). Nada é criado antes de você digitar `yes`.*

![terraform apply concluído com 6 recursos criados](<../imagens/imagens (3).png>)

*Após o `yes`: bucket criado primeiro, depois os recursos que dependem dele. Resultado: `Apply complete! Resources: 6 added, 0 changed, 0 destroyed.`*

## 7. Consultar os outputs

```powershell
terraform output
terraform output -raw website_url
```

Abra a URL no navegador. Veja `TESTES.md`.

## 8. Alterar e reaplicar

Edite um texto em `application/index.html` e rode:

```powershell
terraform plan
terraform apply
```

O plano deve mostrar `aws_s3_object.index` como `~ update in-place`. Se você também alterou o `style.css` (como no laboratório com as capturas abaixo), o plano mostrará os **dois** objetos: `Plan: 0 to add, 2 to change, 0 to destroy.`

![terraform plan após alterar index.html e style.css](<../imagens/imagens (16).png>)

*O `plan` mostra `~ update in-place` para `aws_s3_object.style` e `aws_s3_object.index`: o `etag` mudou porque o hash dos arquivos locais mudou.*

![terraform apply da alteração concluído](<../imagens/imagens (15).png>)

*`apply` da alteração: `Apply complete! Resources: 0 added, 2 changed, 0 destroyed.` Só os objetos foram reenviados; o bucket não foi tocado.*

## 9. Destruir

Ao terminar, siga `DESTRUICAO.md`.

## Erros comuns

| Sintoma | Causa provável | Ação |
|---|---|---|
| `No valid credential sources found` | Sessão SSO expirada ou `AWS_PROFILE` ausente | `aws sso login` e defina `AWS_PROFILE` |
| `BucketAlreadyExists` | Nome em uso por outra conta | Altere o prefixo em `local.bucket_name` |
| `AccessDenied` ao criar a policy | Bloqueio de acesso público no nível da **conta** ou SCP | Verifique as configurações da conta/organização; não as altere sem autorização |
| `Error acquiring the state lock` | Outro terraform em execução na mesma pasta | Aguarde ou encerre o processo anterior |
| Página baixa em vez de abrir | `content_type` incorreto | Confira o argumento nos `aws_s3_object` |
| `403 Forbidden` no navegador | Policy ainda não aplicada ou objeto inexistente | Rode `terraform plan`; deve indicar `No changes` |
| `The configuration is invalid` | Erro de sintaxe/referência | Leia a linha indicada pela mensagem |
