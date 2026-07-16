apiVersion: v1
kind: Secret
metadata:
  name: secret-sample
type: Opaque
data:
  url: ${storage_url}
  user: ${storage_user}
  password: ${storage_pass}
