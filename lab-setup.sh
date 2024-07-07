# Iniciando cluster kubernetes

```
minikube start
```

# Instalando componentes do k8s

## OpenBao
helm repo add openbao https://openbao.github.io/openbao-helm

# Saiba todos os parâmetros do values no github oficial: https://github.com/openbao/openbao-helm/blob/main/charts/openbao/values.yaml
helm install openbao -f values-custom-openbao.yaml openbao/openbao