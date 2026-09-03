# VRE Helm charts repository

This readme explains how to deploy VRE. For users, [VRE user guide](userguide.md) may be more interesting.

## Installation


The ESCAPE VRE Helm chart is published to GitHub Pages and can be installed from the chart repository.

First please copy and customize `values-custom-example.yaml` to `values-custom.yaml` with your specific configuration, paying special attention to secrets for accessing DB and IAM.

Then install the chart using Helm:

```bash
# Add the VRE Helm chart repository
helm repo add vre-helm-charts https://vre-hub.github.io/helm-charts

# Update your local Helm chart repository cache
helm repo update

# Install the chart
helm install escape-vre vre-helm-charts/escape-vre

# Or install with custom values
helm install escape-vre vre-helm-charts/escape-vre -f values-custom.yaml
```

Note that release has to be called `escape-vre` to match other values. If you change the release name e.g. to `my-vre`, you need to change another value like `--set nfs-server-provisioner.storageClass.my-vre-shared-volume-storage-class`.

By default, `nfs-server-provisioner` will use default cluster storageclass to host volumes.

To search for available chart versions:

```bash
helm search repo vre-helm-charts/escape-vre --versions
```

If you want to see development versions, you can do:

```bash
helm search repo vre-helm-charts/escape-vre --versions --devel
```

### Example deployment

An example installation command with custom values could look like this:

```bash
$ helm upgrade --install escape-vre vre/escape-vre -n test --create-namespace --devel \
 --set nfs-server-provisioner.persistence.storageClass=vspherecsi-resize \
 --set nfs-server-provisioner.persistence.size=20Gi --set reana.reana_hostname=reana-vre.obsuks5.unige.ch \
 --set jupyterhub.hub.config.RucioAuthenticator.oauth_callback_url=https://jhub-vre.obsuks5.unige.ch/hub/oauth_callback\
 --set reana.secrets.login.iam.consumer_key=XXXXX --set reana.secrets.login.iam.consumer_secret=YYYYYYYYYYYYYY
```

The user has to be authorized manually. The email notification to the admin is not enabled by default, and thus some communication needs to be done between the user and the admin.

Get an admin access token (replace `<admin-email>` with the actual email):

```bash
$ REANA_ACCESS_TOKEN=$(kubectl get secrets  escape-vre-admin-access-token -o 'jsonpath={.data.ADMIN_ACCESS_TOKEN}' | base64 -d)
```

To list the users:

```bash
$ kubectl exec -i -t deployment/escape-vre-server -- flask reana-admin user-list --admin-access-token $REANA_ACCESS_TOKEN
```

To authorize (the user had to try to connect beforehand):

```bash
$ kubectl exec -i -t deployment/escape-vre-server -- flask reana-admin token-grant \
--email user@example.com --admin-access-token $REANA_ACCESS_TOKEN
```
The redirect URIs to be used in INDIGO IAM have to be:

* https://jhub-vre.obsuks5.unige.ch/hub/oauth_callback
* https://reana-vre.obsuks5.unige.ch/api/oauth/authorized/keycloak/ (please mind the trailing "/")
* https://reana-vre.obsuks5.unige.ch/hub/oauth_callback

## Development

### Using Just

This repository includes a [justfile](https://github.com/casey/just) for common development tasks. Install `just` and run:

```bash
# Show available commands
just

# Set chart version automatically from git
just set-version

# Show current chart version
just show-version

# Run pre-commit hooks
just lint

# Create local cluster, install ingress, and deploy
just create-cluster
just install-ingress
just deploy-with-version
```

### Chart Versioning

The chart version is automatically computed from git tags and commits:

- On a tagged commit (e.g., `v1.0.0`): version is `1.0.0`
- After a tag with additional commits: version is `1.0.0+dev.3.8c8ab40` (tag + commit count + SHA)
- Without tags: version is `0.1.0+dev.cc1a9ee` (default + commit SHA)

To set the version manually, use:

```bash
just set-version
```

The version is automatically updated by:
- Pre-commit hook when committing changes to `vre/` directory
- GitHub Actions workflow when publishing to GitHub Pages

## Testing locally

### Setting up cluster

#### Create a cluster

We recommend using [kind](https://kind.sigs.k8s.io/) to test the charts locally. Chart operations are done using [Skaffold](https://skaffold.dev/):

```bash
# Using just
just create-cluster

# Or manually
kind create cluster --config dev/kind-config.yaml
```

#### Install an ingress controller

The easiest and production-like way to access local VRE deployment is by installing a simple ingress controller. Production clusters will almost always already have one included.

```bash
# Using just
just install-ingress

# Or manually
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
```

#### Customize local values

Even in a local cluster, you may want to use a real IAM instance. To do that, you will need to customize some secret values. You can do it by copying provided example:

```bash
cp vre/values-custom-example.yaml vre/values-custom.yaml
```

`client_id`, `client_secret`, `consumer_key` and `consumer_secret` are empty in the example. The deploy fails until you fill them in.

#### Deploy VRE

The dashboard is created in `crm.namespace`, which the chart does not create, and the ingress admission webhook rejects the chart's Ingress objects until its controller is running:

```bash
kubectl create namespace monitoring
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/component=controller -n ingress-nginx --timeout=180s
```

```bash
# Using just (automatically sets version)
just deploy-with-version

# Or using skaffold directly
skaffold run
```

## Configuration

For complete list of helm chart values, see chart [doc](vre/README.md). These values give a lot of flexibility allow to customize the chart.

Some values almost certainly need to be set in every particular deployment. These values are provided in [vre/values-custom.yaml](vre/values-custom-example.yaml).

## Troubleshooting



### NFS mount error

If you see an error like this in pod events:

```
  Warning  FailedMount       98s (x20 over 26m)  kubelet            MountVolume.SetUp failed for volume "pvc-...." : mount failed: exit status 32
Mounting command: mount
Mounting arguments: -t nfs -o nfsvers=4.1,retrans=2,tcp,timeo=30 10.XX.XX.XX:/exported/path /var/lib/kubelet/pods/86be9a70-3267-4861-8bbd-7c02f18b3532/volumes/kubernetes.io~nfs/pvc-...
Output: mount: /var/lib/kubelet/pods/.../volumes/kubernetes.io~nfs/pvc-....: bad option; for several filesystems (e.g. nfs, cifs) you might need a /sbin/mount.<type> helper program.
```

This means that NFS client utilities are not installed on your nodes. To fix this, install `nfs-common` package (on Debian-based systems) or equivalent for your OS on all nodes.


## Known issues

* rucio token expires before login to jupyterlab. It means that sometimes it is possible to access jupyterhub but not start session (which relies on token exchange). If you find yourself in this situation, try to relogin to jupyterhub, it is likely to fix the issue.

