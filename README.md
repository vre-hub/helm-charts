# VRE Helm charts repository

## Testing locally

We recommend using [kind](https://kind.sigs.k8s.io/) to test the charts locally. Chart operations are done using [Skaffold](https://skaffold.dev/):

```
$ kind create cluster --config dev/kind-config.yaml
$ kind create cluster
$ kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
$ skaffold dev
```
