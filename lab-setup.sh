# Iniciando cluster kubernetes

```
minikube start
```

# Instalando componentes do k8s

## OpenBao
helm repo add openbao https://openbao.github.io/openbao-helm

helm install openbao -f values-custom-openbao.yaml -n openbao --create-namespace openbao/openbao
> Saiba todos os parâmetros do values no github oficial: https://github.com/openbao/openbao-helm/blob/main/charts/openbao/values.yaml

## External Secrets

helm repo add external-secrets https://charts.external-secrets.io

helm install external-secrets \
   external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace \
    --set installCRDs=true