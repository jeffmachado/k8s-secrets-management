apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: vault-example
spec:
  refreshInterval: "15s"
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
  target:
    name: example-sync
  data:
  - secretKey: foobar
    remoteRef:
      key: <sub_path>
      property: <bao_secret_key>