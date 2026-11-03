# Testes — Módulo 01

Registre seus próprios resultados na coluna **Resultado obtido**. Este documento não traz resultados de execução prontos.

| # | Teste | Como executar | Resultado esperado | Resultado obtido |
|---|---|---|---|---|
| 1 | Inicialização | `terraform init` | `successfully initialized`; surge `.terraform.lock.hcl` | |
| 2 | Formato e validade | `terraform fmt -check` e `terraform validate` | Sem arquivos listados; `configuration is valid` | |
| 3 | Plano | `terraform plan` | `Plan: 6 to add, 0 to change, 0 to destroy` | |
| 4 | Apply | `terraform apply` | `Apply complete! Resources: 6 added` e outputs exibidos | |
| 5 | Arquivos no bucket | `aws s3 ls s3://$(terraform output -raw bucket_name)` | Lista `index.html` e `style.css` | |
| 6 | Site abre | Abrir `terraform output -raw website_url` | Página "Terraform na Prática" visível | |
| 7 | HTML e CSS | Aba Rede (F12) | `index.html` e `style.css` com status 200; página estilizada | |
| 8 | Sem divergências | `terraform plan` após apply | `No changes. Your infrastructure matches the configuration.` | |
| 9 | Alteração de conteúdo | Editar texto em `index.html`, `plan`, `apply`, recarregar | Plano com 1 `~ update`; texto novo aparece | |
| 10 | Destroy | `terraform destroy` | `Destroy complete! Resources: 6 destroyed` | |
| 11 | Pós-destroy | Abrir a URL novamente | Erro (bucket inexistente) | |

## Observações

- O teste 5 usa `$(...)` do PowerShell. Se preferir, copie o nome do bucket manualmente.
- O S3 Website só serve **HTTP**. Um aviso de "site não seguro" no navegador é esperado.
- Se o teste 9 não mostrar mudança, confira se salvou o arquivo e se o cache do navegador não está interferindo (`Ctrl+F5`).

## Critérios de sucesso do módulo

- [ ] Todos os testes de 1 a 11 passaram.
- [ ] Você sabe explicar a diferença entre `plan` e `apply`.
- [ ] Você sabe dizer por que o `plan` pós-apply não mostra alterações.

## Evidências do laboratório

Capturas de tela de uma execução real, relacionadas aos testes da tabela.

**Testes 1 e 2: inicialização, formato e validade**

![init, fmt e validate](<../imagens/imagens (7).png>)

**Teste 3: plano**

![plan com 6 recursos a criar](<../imagens/imagens (5).png>)

**Teste 4: apply**

![apply concluído](<../imagens/imagens (3).png>)

**Teste 5: arquivos no bucket** (console do S3)

![Objetos no bucket](<../imagens/imagens (9).png>)

**Teste 6 e 7: site abre, HTML e CSS com status 200**

![Site no navegador com DevTools](<../imagens/imagens (13).png>)

**Teste 9: alteração de conteúdo** (plano com `~ update in-place`, apply e site alterado)

![plan da alteração](<../imagens/imagens (16).png>)

![apply da alteração](<../imagens/imagens (15).png>)

![Site alterado no navegador](<../imagens/imagens (14).png>)

**Testes 10 e 11: destroy e pós-destroy**

![destroy concluído](<../imagens/imagens (17).png>)

![404 NoSuchBucket](<../imagens/imagens (18).png>)

> Na alteração do teste 9, o plano mostrou 2 objetos alterados (`index.html` e `style.css`), porque os dois arquivos foram editados.
