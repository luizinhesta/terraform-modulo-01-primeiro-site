# Exercícios — Módulo 01

Tente resolver antes de ler as respostas comentadas no final.

## Exercícios guiados

### 1. Ler um plano
Rode `terraform plan` (antes do apply). Identifique: quantos recursos serão criados? Quais atributos aparecem como `(known after apply)`?

Exemplo de saída do laboratório, para você comparar com a sua:

![Saída do terraform plan](<../imagens/imagens (5).png>)

### 2. Alterar conteúdo
Mude o texto do `<h1>` em `application/index.html`. Rode `plan`. Qual recurso mudou e qual símbolo apareceu?

Exemplo de saída do laboratório (neste caso, `index.html` e `style.css` foram editados, por isso há 2 alterações):

![Plano com alterações em objetos](<../imagens/imagens (16).png>)

### 3. Adicionar uma tag
Em `aws_s3_bucket.site`, adicione `Owner = "aluno"` em `tags`. Rode `plan`. O bucket será recriado ou alterado no lugar?

### 4. Provocar uma dependência
Em `aws_s3_object.style`, troque `aws_s3_bucket.site.id` por um texto fixo com o nome do bucket. Rode `terraform graph` (opcional) ou apenas `plan`. O que se perde em termos de dependência? Desfaça a mudança depois.

### 5. Provocar um erro de validação
Apague uma chave `}` e rode `terraform validate`. Leia a mensagem. Depois use `terraform fmt` e `validate` para conferir o conserto.

## Desafios independentes

1. Publique um terceiro arquivo, `erro.html`, e configure `error_document` no `aws_s3_bucket_website_configuration`.
2. Crie um novo `output` que mostre o ARN do bucket.
3. Troque o valor fixo `"us-east-1"` em `local.bucket_name` pelo atributo `data.aws_region.current.name` (ou `.region` no provider atual; consulte a documentação do data source).
4. Altere o `key` do `aws_s3_object.style` para `css/style.css`. Atualize o HTML. Observe no plano: é alteração ou substituição?

## Critérios de sucesso

- Você consegue prever o símbolo do plano (`+`, `~`, `-`, `-/+`) antes de rodar o comando.
- Você sabe localizar no plano o argumento que força a substituição (`# forces replacement`).

---

## Respostas comentadas (consulte só depois de tentar)

**1.** Seis recursos serão criados. Entre os `(known after apply)` estão `id`, `arn`, `website_endpoint` e `etag` calculados pela AWS.

**2.** Mudou `aws_s3_object.index`, com `~`. Como o conteúdo muda, o hash do `etag` muda.

**3.** Alterado no lugar (`~`). Tags são atualizáveis sem recriar o bucket.

**4.** Com texto fixo, o Terraform perde a referência e não sabe que o objeto depende do bucket. Em um primeiro `apply`, ele pode tentar criar o objeto antes do bucket e falhar. Referências são o que ordena o grafo.

**5.** O `validate` aponta o arquivo e a linha do erro. O `fmt` não conserta sintaxe; só formata.

**Desafio 1.** Adicione ao website configuration:
```hcl
error_document {
  key = "erro.html"
}
```
e um `aws_s3_object` para `erro.html`.

**Desafio 2.**
```hcl
output "bucket_arn" {
  value = aws_s3_bucket.site.arn
}
```

**Desafio 3.** Use `data "aws_region" "current" {}`. O nome do atributo varia entre versões do provider; confirme na documentação do registry antes de usar.

**Desafio 4.** Como o `key` do objeto é argumento imutável, o plano mostra `-/+` (substituição), com `# forces replacement` no `key`. O objeto antigo é removido e o novo criado.
