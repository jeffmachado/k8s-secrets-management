apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      # Exemplo: "http://openbao.default.svc.cluster.local:8200"
      server: "http://<openbao_address>:<openbao_port>"
      path: "<path_name>"
      # Version is the Vault KV secret engine version.
      # This can be either "v1" or "v2", defaults to "v2"
      version: "v2"
      auth:
        # points to a secret that contains a vault token
        # https://www.vaultproject.io/docs/auth/token
        tokenSecretRef:
          namespace: openbao
          name: "bao-token"
          key: "token"
---
apiVersion: v1
kind: Secret
metadata:
  name: bao-token
  namespace: openbao
data:
  token: <seu_token_em_base64>