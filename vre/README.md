# cern-vre

![Version: 0.1.0-dev0](https://img.shields.io/badge/Version-0.1.0--dev0-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

The Virtual Research Environment developed at CERN.>

**Homepage:** <https://vre-hub.github.io>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| The maintainer name (required for each maintainer) | <The maintainers email (optional for each maintainer)> | <A URL for the maintainer (optional for each maintainer)> |

## Source Code

* <https://github.com/vre-hub/vre>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://hub.jupyter.org/helm-chart | jupyterhub | 3.3.7 |
| https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner | nfs-server-provisioner | 1.8.0 |
| https://reanahub.github.io/reana | reana | 0.9.3 |
| oci://registry-1.docker.io/bitnamicharts | postgresql | 16.5.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| jupyterhub.enabled | bool | `true` |  |
| nfs-server-provisioner.enabled | bool | `true` |  |
| nfs-server-provisioner.persistence.enabled | bool | `true` |  |
| nfs-server-provisioner.persistence.size | string | `"100M"` |  |
| nfs-server-provisioner.persistence.storageClass | string | `"standard"` |  |
| nfs-server-provisioner.storageClass.mountOptions[0] | string | `"tcp"` |  |
| nfs-server-provisioner.storageClass.mountOptions[1] | string | `"nfsvers=4.1"` |  |
| nfs-server-provisioner.storageClass.mountOptions[2] | string | `"retrans=2"` |  |
| nfs-server-provisioner.storageClass.mountOptions[3] | string | `"timeo=30"` |  |
| nfs-server-provisioner.storageClass.name | string | `"cern-vre-shared-volume-storage-class"` |  |
| nfs-server-provisioner.tolerations[0].effect | string | `"NoSchedule"` |  |
| nfs-server-provisioner.tolerations[0].key | string | `"CriticalAddonsOnly"` |  |
| nfs-server-provisioner.tolerations[0].operator | string | `"Exists"` |  |
| reana.components.reana_db.enabled | bool | `false` |  |
| reana.components.reana_server.environment.REANA_USER_EMAIL_CONFIRMATION | bool | `false` |  |
| reana.components.reana_ui.enabled | bool | `true` |  |
| reana.components.reana_ui.local_users | bool | `false` |  |
| reana.components.reana_workflow_controller.environment.REANA_JOB_STATUS_CONSUMER_PREFETCH_COUNT | int | `10` |  |
| reana.components.reana_workflow_controller.environment.SHARED_VOLUME_PATH | string | `"/var/reana/"` |  |
| reana.components.reana_workflow_controller.image | string | `"docker.io/reanahub/reana-workflow-controller:0.9.4"` |  |
| reana.components.reana_workflow_controller.imagePullPolicy | string | `"IfNotPresent"` |  |
| reana.compute_backends[0] | string | `"kubernetes"` |  |
| reana.db_env_config.REANA_DB_HOST | string | `"postgres-postgresql"` |  |
| reana.db_env_config.REANA_DB_NAME | string | `"reana"` |  |
| reana.db_env_config.REANA_DB_PORT | string | `"5432"` |  |
| reana.enabled | bool | `true` |  |
| reana.ingress.enabled | bool | `false` |  |
| reana.login[0].config.auth_url | string | `"https://iam-escape.cloud.cnaf.infn.it/authorize"` |  |
| reana.login[0].config.base_url | string | `"https://iam-escape.cloud.cnaf.infn.it"` |  |
| reana.login[0].config.realm_url | string | `"https://iam-escape.cloud.cnaf.infn.it"` |  |
| reana.login[0].config.title | string | `"ESCAPE IAM"` |  |
| reana.login[0].config.token_url | string | `"https://iam-escape.cloud.cnaf.infn.it/token"` |  |
| reana.login[0].config.userinfo_url | string | `"https://iam-escape.cloud.cnaf.infn.it/userinfo"` |  |
| reana.login[0].name | string | `"escape-iam"` |  |
| reana.login[0].type | string | `"keycloak"` |  |
| reana.notifications.enabled | bool | `false` |  |
| reana.postgres.enabled | bool | `true` |  |
| reana.quota.default_cpu_limit | int | `36000000` |  |
| reana.quota.default_disk_limit | int | `10737418240` |  |
| reana.reana_hostname | string | `"reana-vre.obsuks4.unige.ch"` |  |
| reana.secrets.login.escape-iam.consumer_key | string | `"testkey"` |  |
| reana.secrets.login.escape-iam.consumer_secret | string | `"testsecret"` |  |
| reana.shared_storage.access_modes | string | `"ReadWriteMany"` |  |
| reana.shared_storage.backend | string | `"nfs"` |  |
| reana.shared_storage.volume_size | int | `1` |  |
| reana.traefik.enabled | bool | `false` |  |
| reana.workspaces.paths[0] | string | `"/var/reana:/var/reana"` |  |
| reana.workspaces.retention_rules.cronjob_schedule | string | `"0 2 * * *"` |  |
| reana.workspaces.retention_rules.maximum_period | string | `"forever"` |  |

