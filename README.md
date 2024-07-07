# Usando as ferramentas

## Minikube
Caso esteja usando podman, atente-se a essas orientações:
https://minikube.sigs.k8s.io/docs/drivers/podman/

Desativar rootless é uma opção:
`minikube config set rootless true`

### Acessando services privados
No minikube, a rede dos serviços possivelmente estará isolada. Para acessar esses componentes a partir da sua máquina local, pode ser necessário fazer um roteamento/proxy adicional.

Existem diversas maneiras de fazer isso, porém a opção abaixo tende a ser a mais prática usando o próprio minikube:
```
minikube service <nome_do_svc> --url
```
Você também pode utilizar `kubectl port-forward` sem problemas. Por exemplo:
```
kubectl port-forward svc/openbao 8200:8200
```

## OpenBAO
Como o OpenBAO é um fork do Hashcorp vault, a maioria dos utilitários funcional de maneira igual.

Primeiramente, exporte seu token de acesso:
```
export VAULT_TOKEN="<seu_token_aqui>"
```
Esse token permitirá que você, via shell, interaja com o serviço do OpenBAO.

Caso esteja utilizando o modo produtivo, é necessário ter feito o unseal, criado as suas políticas e gerado o token de acesso.

Uma vez que o serviço está sendo executado, você pode acessar ele via SDK ou Curl.

### Instalando CLI
O OpenBAO também conta com um CLI para interação. Baixe e instale o binário conforme orientações [do site](https://openbao.org/downloads/).

Caso não queira, tem como fazer via Curl ou SDK também, mas terá que adaptar interação. Exemplo:

```
curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    http://<server>:<porta>/v1/secret/data/my-secret-password 
```

### Criando paths
Paths é a estrutura organizacional das suas secrets, que poderão ser usadas depois para posicionar suas políticas.
```
bao secrets enable -path=<nome_do_path> kv
```

### Obter segredos
```
openbao kv get <nome_do_path>/<sub_path>
```

### Criar segredos
```
openbao kv put <nome_do_path>/<sub_path> key1=value1 key2=value2
```

### Criar políticas
Visto que o Openbao é clone do Vault, suas políticas também são criadas em HCL (HashiCorp Configuration Language).

Segue exemplo básico de política que concede leitura para um path específico:
```
path "<path>/<sub_path>" {
  capabilities = ["read"]
}
```

Para criar a política, execute:
```
bao policy write <nome_politica> ./<arquivo_policy>.hcl
```

As políticas podem ser criadas com diversos níveis de complexidade. Saiba mais na [documentação oficial]('https://openbao.org/docs/commands/policy/').