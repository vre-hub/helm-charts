# Justfile for VRE Helm Charts

# Set automatic chart version based on git
set-version:
    #!/usr/bin/env bash
    set -euo pipefail

    # Compute version from git describe
    GIT_VERSION=$(git describe --tags --always 2>/dev/null || echo "0.1.0-$(git rev-parse --short HEAD)")

    # Remove 'v' prefix if present
    GIT_VERSION=${GIT_VERSION#v}

    # Convert to valid semver format
    # git describe format: "tag-commits-ghash" (e.g., "0.1.0-3-g8c8ab40")
    # Semver prerelease format: use dots instead of hyphens (e.g., "0.1.0+dev.3.8c8ab40")
    if [[ "$GIT_VERSION" =~ ^([0-9]+\.[0-9]+\.[0-9]+)-([0-9]+)-g([a-f0-9]+)$ ]]; then
        # Version with commits after tag: convert to semver with build metadata
        BASE="${BASH_REMATCH[1]}"
        COMMITS="${BASH_REMATCH[2]}"
        SHA="${BASH_REMATCH[3]}"
        VERSION="${BASE}+dev.${COMMITS}.${SHA}"
    elif [[ "$GIT_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # Exact tag match
        VERSION="$GIT_VERSION"
    else
        # No tags found, use commit SHA with build metadata
        VERSION="0.1.0-dev${GIT_VERSION}"
    fi

    echo "Git version: $GIT_VERSION"
    echo "Setting chart version to: $VERSION"

    # Update Chart.yaml with computed version
    sed -i "s/^version:.*/version: ${VERSION}/" vre/Chart.yaml

    # Show the updated version
    echo "Updated Chart.yaml:"
    grep "^version:" vre/Chart.yaml

# Create a local cluster for testing
create-cluster:
    kind create cluster --config=dev/kind-config.yaml

# Install ingress controller
install-ingress:
    kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s

# Deploy VRE using skaffold
deploy:
    skaffold run

# Update chart version and deploy
deploy-with-version: set-version deploy

# Run pre-commit hooks
lint:
    helm dependency update ./vre
    pre-commit run --all-files

# Show current version
show-version:
    @grep "^version:" vre/Chart.yaml

list-users:
    REANA_ACCESS_TOKEN=$(kubectl get secrets  escape-vre-admin-access-token -o 'jsonpath={.data.ADMIN_ACCESS_TOKEN}' | base64 -d) && \
    kubectl exec -i -t deployment/escape-vre-server -- flask reana-admin user-list --admin-access-token $REANA_ACCESS_TOKEN

token-grant email:
    REANA_ACCESS_TOKEN=$(kubectl get secrets  escape-vre-admin-access-token -o 'jsonpath={.data.ADMIN_ACCESS_TOKEN}' | base64 -d) && \
    kubectl exec -i -t deployment/escape-vre-server -- flask reana-admin token-grant --email {{email}} --admin-access-token $REANA_ACCESS_TOKEN

# Default recipe (show available commands)
default:
    @just --list
