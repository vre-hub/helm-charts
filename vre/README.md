# cern-vre

![Version: 0.1.0-dev1](https://img.shields.io/badge/Version-0.1.0--dev1-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

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
| jupyterhub.hub.config.JupyterHub.authenticator_class | string | `"generic-oauth"` |  |
| jupyterhub.hub.config.RucioAuthenticator.allow_all | bool | `true` |  |
| jupyterhub.hub.config.RucioAuthenticator.authorize_url | string | `"https://iam-escape.cloud.cnaf.infn.it/authorize"` |  |
| jupyterhub.hub.config.RucioAuthenticator.enable_auth_state | bool | `true` |  |
| jupyterhub.hub.config.RucioAuthenticator.oauth_callback_url | string | `"https://jhub-vre.obsuks4.unige.ch/hub/oauth_callback"` |  |
| jupyterhub.hub.config.RucioAuthenticator.scope[0] | string | `"openid"` |  |
| jupyterhub.hub.config.RucioAuthenticator.scope[1] | string | `"profile"` |  |
| jupyterhub.hub.config.RucioAuthenticator.scope[2] | string | `"email"` |  |
| jupyterhub.hub.config.RucioAuthenticator.token_url | string | `"https://iam-escape.cloud.cnaf.infn.it/token"` |  |
| jupyterhub.hub.config.RucioAuthenticator.userdata_url | string | `"https://iam-escape.cloud.cnaf.infn.it/userinfo"` |  |
| jupyterhub.hub.config.RucioAuthenticator.username_key | string | `"preferred_username"` |  |
| jupyterhub.hub.db.type | string | `"postgres"` |  |
| jupyterhub.hub.db.url | string | `nil` |  |
| jupyterhub.hub.extraConfig.token-exchange | string | `"import pprint\nimport os\nimport warnings\nimport requests\nfrom oauthenticator.generic import GenericOAuthenticator\n\n# custom authenticator to enable auth_state and get access token to set as env var for rucio extension\nclass RucioAuthenticator(GenericOAuthenticator):\n    def __init__(self, **kwargs):\n        super().__init__(**kwargs)\n        self.enable_auth_state = True\n\n    def exchange_token(self, token):\n        params = {\n            'client_id': self.client_id,\n            'client_secret': self.client_secret,\n            'grant_type': 'urn:ietf:params:oauth:grant-type:token-exchange',\n            'subject_token_type': 'urn:ietf:params:oauth:token-type:access_token',\n            'subject_token': token,\n            'scope': 'openid profile',\n            'audience': 'rucio'\n        }\n        response = requests.post(self.token_url, data=params)\n        print(\"EXCHANGE TOKEN for params\", params)\n        print(response.json())\n        rucio_token = response.json()['access_token']\n\n        return rucio_token\n        \n    async def pre_spawn_start(self, user, spawner):\n        auth_state = await user.get_auth_state()\n        #print(\"AUTH_state\")\n        #pprint.pprint(auth_state)\n        if not auth_state:\n            # user has no auth state\n            return False\n        \n        # define token environment variable from auth_state\n        spawner.environment['RUCIO_ACCESS_TOKEN'] = self.exchange_token(auth_state['access_token'])\n        spawner.environment['EOS_ACCESS_TOKEN'] = auth_state['access_token']\n\n# set the above authenticator as the default\nc.JupyterHub.authenticator_class = RucioAuthenticator\n\n# enable authentication state\nc.GenericOAuthenticator.enable_auth_state = True\n"` |  |
| jupyterhub.hub.networkPolicy.enabled | bool | `false` |  |
| jupyterhub.hub.service.type | string | `"ClusterIP"` |  |
| jupyterhub.ingress.annotations."traefik.ingress.kubernetes.io/router.entrypoints" | string | `"websecure"` |  |
| jupyterhub.ingress.annotations."traefik.ingress.kubernetes.io/router.tls" | string | `"true"` |  |
| jupyterhub.ingress.enabled | bool | `true` |  |
| jupyterhub.ingress.hosts[0] | string | `"jhub-vre.obsuks4.unige.ch"` |  |
| jupyterhub.ingress.hosts[1] | string | `"jhub-vre-etap.obsuks4.unige.ch"` |  |
| jupyterhub.ingress.ingressClassName | string | `nil` |  |
| jupyterhub.prePuller.hook.enabled | bool | `true` |  |
| jupyterhub.proxy.service.type | string | `"ClusterIP"` |  |
| jupyterhub.singleuser.cloudMetadata.blockWithIptables | bool | `false` |  |
| jupyterhub.singleuser.cmd | string | `nil` |  |
| jupyterhub.singleuser.defaultUrl | string | `"/lab"` |  |
| jupyterhub.singleuser.extraEnv.OAUTH2_TOKEN | string | `"FILE:/tmp/eos_oauth.token"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_AUTH_URL | string | `"https://vre-rucio-auth.cern.ch"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_BASE_URL | string | `"https://vre-rucio.cern.ch"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_CA_CERT | string | `"/certs/rucio_ca.pem"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_DEFAULT_AUTH_TYPE | string | `"oidc"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_DEFAULT_INSTANCE | string | `"vre-rucio.cern.ch"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_DESTINATION_RSE | string | `"CERN-EOSPILOT"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_DISPLAY_NAME | string | `"RUCIO - CERN VRE"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_MODE | string | `"replica"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_NAME | string | `"vre-rucio.cern.ch"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_OAUTH_ID | string | `"rucio"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_OIDC_AUTH | string | `"env"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_OIDC_ENV_NAME | string | `"RUCIO_ACCESS_TOKEN"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_PATH_BEGINS_AT | string | `"5"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_RSE_MOUNT_PATH | string | `"/eos/eulake"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_SITE_NAME | string | `"CERN"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_WEBUI_URL | string | `"https://vre-rucio-ui.cern.ch"` |  |
| jupyterhub.singleuser.extraEnv.RUCIO_WILDCARD_ENABLED | string | `"1"` |  |
| jupyterhub.singleuser.image.name | string | `"ghcr.io/vre-hub/vre-singleuser-py311"` |  |
| jupyterhub.singleuser.image.pullPolicy | string | `"Always"` |  |
| jupyterhub.singleuser.image.tag | string | `"sha-281055c"` |  |
| jupyterhub.singleuser.lifecycleHooks.postStart.exec.command[0] | string | `"sh"` |  |
| jupyterhub.singleuser.lifecycleHooks.postStart.exec.command[1] | string | `"-c"` |  |
| jupyterhub.singleuser.lifecycleHooks.postStart.exec.command[2] | string | `"if [ \"${SKIP_POSTSTART_HOOK}\" = \"true\" ]; then\n  echo \"hello world\";\nelse\n  mkdir -p /certs /tmp;\n  echo -n $RUCIO_ACCESS_TOKEN > /tmp/rucio_oauth.token;\n  echo -n \"oauth2:${EOS_ACCESS_TOKEN}:iam-escape.cloud.cnaf.infn.it/userinfo\" > /tmp/eos_oauth.token;\n  chmod 0600 /tmp/eos_oauth.token;\n  mkdir -p /opt/rucio/etc;\n  echo \"[client]\" >> /opt/rucio/etc/rucio.cfg;\n  echo \"rucio_host = https://vre-rucio.cern.ch\" >> /opt/rucio/etc/rucio.cfg;\n  echo \"auth_host = https://vre-rucio-auth.cern.ch\" >> /opt/rucio/etc/rucio.cfg;\n  echo \"ca_cert = /certs/rucio_ca.pem\" >> /opt/rucio/etc/rucio.cfg;\n  echo \"account = $JUPYTERHUB_USER\" >> /opt/rucio/etc/rucio.cfg;\n  echo \"auth_type = oidc\" >> /opt/rucio/etc/rucio.cfg;\n  echo \"oidc_audience = rucio\" >> /opt/rucio/etc/rucio.cfg;\n  echo \"oidc_polling = true\" >> /opt/rucio/etc/rucio.cfg;\n  echo \"oidc_issuer = escape\" >> /opt/rucio/etc/rucio.cfg;\n  echo \"oidc_scope = openid profile offline_access\" >> /opt/rucio/etc/rucio.cfg;\n  echo \"auth_token_file_path = /tmp/rucio_oauth.token\" >> /opt/rucio/etc/rucio.cfg;\nfi;\n"` |  |
| jupyterhub.singleuser.networkPolicy.enabled | bool | `false` |  |
| jupyterhub.singleuser.profileList[0].default | bool | `true` |  |
| jupyterhub.singleuser.profileList[0].description | string | `"Based on a scipy notebook environment with a python-3.11 kernel, the rucio jupyterlab extension and the reana client installed."` |  |
| jupyterhub.singleuser.profileList[0].display_name | string | `"Default environment"` |  |
| jupyterhub.singleuser.startTimeout | int | `1200` |  |
| jupyterhub.singleuser.storage.extraVolumeMounts | list | `[]` |  |
| jupyterhub.singleuser.storage.extraVolumes | list | `[]` |  |
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
| reana.ingress_override | bool | `true` |  |
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
| reana.secrets.database.password | string | `nil` |  |
| reana.secrets.database.user | string | `nil` |  |
| reana.secrets.login.escape-iam.consumer_key | string | `"testkey"` |  |
| reana.secrets.login.escape-iam.consumer_secret | string | `"testsecret"` |  |
| reana.shared_storage.access_modes | string | `"ReadWriteMany"` |  |
| reana.shared_storage.backend | string | `"nfs"` |  |
| reana.shared_storage.volume_size | int | `1` |  |
| reana.traefik.enabled | bool | `false` |  |
| reana.workspaces.paths[0] | string | `"/var/reana:/var/reana"` |  |
| reana.workspaces.retention_rules.cronjob_schedule | string | `"0 2 * * *"` |  |
| reana.workspaces.retention_rules.maximum_period | string | `"forever"` |  |

