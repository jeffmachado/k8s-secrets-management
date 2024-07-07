# Local setup

## [Linux] [x86-64] Instalando componentes de estação de trabalho

### Está usando WSL? Leia isso :D
Quando usando WSL, a virtualização com minikube e rootless é mais complicada e com podman pode ser um desafio (embora possível).
Sugiro que siga as [orientações desse gist](https://gist.github.com/wholroyd/748e09ca0b78897750791172b2abb051), que tem boas dias sobre setup local para que o minikube fique redondinho.

### Minikube
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
```

### Kubectl
```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
out=`echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check`
if [[ $out != "kubectl: OK" ]]; then
    echo "Not valid kubectl binary"
    exit
fi

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### Helm
```
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

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

### Criando token
```
bao token create -policy="<nome_politica>"
```

Pegue a informação do token que saiu no output, e salve-o em base64. Ele será usado nas próximas etapas.
```
echo "<seu_token>" | base64
``` 

## External Secrets
A ferramenta tem por objetivo gerenciar segredos e integrar/sincronizar com soluções externas.
A documentação falar por si, [saiba mais aqui](https://github.com/external-secrets/external-secrets).

### Criando Secret Store
Use o providor do hashicorp vault, devido a atual compatiblidade, porém, é importante destacar que precisamos acompanhar se futuramente surge um provider apenas do openbao. [Vide link](https://external-secrets.io/main/provider/hashicorp-vault/)

Utilize o arquivo `external-secrets/secret_store.yaml.tpl` para construir uma secret que possua o token de acesso ao Openbao (criado anteriormente) e também o SecretStore, que é o elo que conecta o External Secrets ao seu Vault.

O kind SecretStore é basicamente o seguinte:
``` 
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "http://my.vault.server:8200"
      path: "secret"
      # Version is the Vault KV secret engine version.
      # This can be either "v1" or "v2", defaults to "v2"
      version: "v2"
      auth:
        # points to a secret that contains a vault token
        # https://www.vaultproject.io/docs/auth/token
        tokenSecretRef:
          name: "vault-token"
          key: "token"
```