Cloudflare Tunnel with Helm (Quick Notes)

1. Create Tunnel via CLI

cloudflared tunnel login
cloudflared tunnel create wildcard-tunnel

2. Get tunnelID (UUID)

You can find it in the credentials file or via:

cloudflared tunnel list

Example:

aa04f37f-025a-4dbb-8a06-87acf29ff7a2.cfargotunnel.com

Use this as the DNS CNAME target for your domain/subdomain.

3. Create secret in Kubernetes

kubectl create secret generic cloudflared-credential-token \
--from-file=credentials.json \
-n cloudflare

4. Install chart with values.yaml

Example minimal values.yaml:

cloudflare:
tunnelName: wildcard-tunnel
secretName: cloudflared-credential-token

ingress:
- hostname: "*.serhii.link"
service: http://ingress-nginx-controller.ingress-nginx.svc.cluster.local:80

replicaCount: 1

5. Deploy via Helm

helm repo add cloudflare https://cloudflare.github.io/helm-charts
helm repo update
helm upgrade --install cloudflare-tunnel cloudflare/cloudflare-tunnel \
-n cloudflare -f values.yaml

6. Add CNAME Record in Cloudflare DNS

Type: CNAME
Name: jenkins.serhii.link
Target: aa04f37f-025a-4dbb-8a06-87acf29ff7a2.cfargotunnel.com
Proxy: ON


