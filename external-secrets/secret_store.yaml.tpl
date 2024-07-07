apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "http://openbao:8200"
      path: "<nome_do_path>"
      # Version is the Vault KV secret engine version.
      # This can be either "v1" or "v2", defaults to "v2"
      version: "v2"
      auth:
        # points to a secret that contains a vault token
        # https://www.vaultproject.io/docs/auth/token
        tokenSecretRef:
          name: "bao-token"
          key: "token"
---
apiVersion: v1
kind: Secret
metadata:
  name: bao-token
data:
  token: <seu_token_em_base64>