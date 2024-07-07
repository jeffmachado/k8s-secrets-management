# [Linux] [x86-64] Instalando componentes de estação de trabalho
# Nesse caso, já existe o podman e o qemu-system instalados.

# ## Minikube
# curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
# sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
``
## Kind

### For AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

### Usando Rootless com WSL
podman machine init --cpus 2 --memory 2048 --disk-size 20
podman machine start
podman system connection default podman-machine-default-root
podman info

## Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
out=`echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check`
if [[ $out != "kubectl: OK" ]]; then
    echo "Not valid kubectl binary"
    exit
fi

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

## Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash