# Destruição — Módulo 01

## Procedimento

```powershell
cd etapa-01-fundamentos/modulo-01-primeiro-site/terraform
terraform plan -destroy
terraform destroy
```

Revise a lista de recursos e confirme com `yes` somente se estiver na pasta correta e com o perfil AWS correto (`aws sts get-caller-identity`).

Esperado: `Destroy complete! Resources: 6 destroyed.`

## O que é removido

Bucket, configuração de website, public access block, política e os dois objetos. O bucket usa `force_destroy = true`, portanto o conteúdo é apagado junto.

## Custos

| Recurso | Pode gerar custo? |
|---|---|
| Bucket S3 e objetos | Sim, armazenamento e requisições (valores muito baixos) |
| Transferência de dados | Sim, se o site receber muito tráfego |
| Demais recursos | Não |

## Cuidados e limitações

- O `destroy` remove **apenas** o que está no state desta pasta. Se você apagou o `terraform.tfstate`, o Terraform não saberá o que remover; nesse caso será necessário limpar pelo console ou CLI.
- `force_destroy = true` é conveniente no laboratório, mas em produção apagaria dados sem aviso.
- Se objetos foram adicionados manualmente ao bucket, o `force_destroy` também os remove.
- Se o `destroy` falhar por sessão expirada, renove o login e repita uma vez. Se persistir, leia a mensagem de erro antes de tentar de novo.

## Conferir que não sobrou nada

```powershell
aws s3 ls | Select-String "tfpratica-m01"
```

Sem saída significa que o bucket não existe mais.

Depois do destroy, `terraform.tfstate` fica quase vazio. Os arquivos de state são ignorados pelo Git (veja `.gitignore`).

## Evidências do laboratório

Execução do `terraform destroy`. A ordem é inversa à da criação: política e website primeiro, bucket por último.

![terraform destroy concluído com 6 recursos removidos](<../imagens/imagens (17).png>)

Depois do destroy, abrir a URL do site retorna `404 Not Found` com `Code: NoSuchBucket`, confirmando que o bucket não existe mais:

![Erro 404 NoSuchBucket após o destroy](<../imagens/imagens (18).png>)

O `terraform.tfstate` ficou com `"resources": []` e `aws s3 ls | Select-String "tfpratica-m01"` não retornou nada:

![State vazio e busca sem resultados](<../imagens/imagens (19).png>)
