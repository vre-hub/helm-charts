{{ define "escape-vre.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{/* Extract the host (including port, if any) from a URL; empty input yields empty output. */}}
{{- define "escape-vre.urlHost" -}}
{{- if . -}}{{- (urlParse .).host -}}{{- end -}}
{{- end }}

{{/*
Soft consistency checks, rendered as WARNING lines in NOTES.txt.
These cover couplings that plain values files cannot express:
identity-provider host mixtures, callback-vs-ingress-host agreement,
and values that must embed the Helm release name.
*/}}
{{- define "escape-vre.warnings" -}}
{{- $warnings := list -}}
{{- $red := printf "%c[31m" 27 -}}
{{- $reset := printf "%c[0m" 27 -}}

{{/* Identity provider mixture check */}}
{{- $iamHosts := dict -}}
{{- if .Values.jupyterhub.enabled -}}
{{- with include "escape-vre.urlHost" .Values.jupyterhub.hub.config.RucioAuthenticator.authorize_url -}}
{{- $_ := set $iamHosts "jupyterhub.hub.config.RucioAuthenticator.authorize_url" . -}}
{{- end -}}
{{- end -}}
{{- with .Values.reana.login -}}
{{- with include "escape-vre.urlHost" (dig "config" "base_url" "" (first . | default dict)) -}}
{{- $_ := set $iamHosts "reana.login[0].config.base_url" . -}}
{{- end -}}
{{- end -}}
{{- if .Values.npdb.enabled -}}
{{- with include "escape-vre.urlHost" (dig "files" "authentication" "userinfoUrl" "" .Values.npdb) -}}
{{- $_ := set $iamHosts "npdb.files.authentication.userinfoUrl" . -}}
{{- end -}}
{{- end -}}
{{- if gt (len (values $iamHosts | uniq)) 1 -}}
{{- $details := list -}}
{{- range $key, $host := $iamHosts -}}
{{- $details = append $details (printf "  - %s -> %s%s%s" $key $red $host $reset) -}}
{{- end -}}
{{- $warnings = append $warnings (printf "Mixed identity providers configured; this is unusual, make sure it is intentional:\n%s" (join "\n" $details)) -}}
{{- end -}}

{{/* JupyterHub callback URL vs ingress host */}}
{{- if and .Values.jupyterhub.enabled .Values.jupyterhub.ingress.hosts -}}
{{- $jhubHost := first .Values.jupyterhub.ingress.hosts -}}
{{- $callback := .Values.jupyterhub.hub.config.RucioAuthenticator.oauth_callback_url | default "" -}}
{{- if and $callback (ne (include "escape-vre.urlHost" $callback) $jhubHost) -}}
{{- $warnings = append $warnings (printf "oauth_callback_url (%s) does not point at jupyterhub.ingress.hosts[0] (%s). Expected https://%s/hub/oauth_callback unless an external proxy rewrites the host." $callback $jhubHost $jhubHost) -}}
{{- end -}}
{{- end -}}

{{/* Values that must embed the release name (subchart values cannot reference it) */}}
{{- if (index .Values "nfs-server-provisioner" "enabled") -}}
{{- $scName := index .Values "nfs-server-provisioner" "storageClass" "name" | default "" -}}
{{- if not (hasPrefix .Release.Name $scName) -}}
{{- $warnings = append $warnings (printf "nfs-server-provisioner.storageClass.name (%s) does not start with the release name (%s); the reana-db and reana-shared-volume subcharts will not pick it up." $scName .Release.Name) -}}
{{- end -}}
{{- if .Values.npdb.enabled -}}
{{- $npdbSc := dig "storage" "payload" "storageClass" "" .Values.npdb -}}
{{- if and $npdbSc (ne $npdbSc $scName) -}}
{{- $warnings = append $warnings (printf "npdb.storage.payload.storageClass (%s) differs from nfs-server-provisioner.storageClass.name (%s)." $npdbSc $scName) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- if .Values.npdb.enabled -}}
{{- $expectedNpdbHost := printf "%s-npdb-nginx" .Release.Name -}}
{{- range $key := list "api" "files" -}}
{{- $host := dig "hosts" $key "" $.Values.npdb -}}
{{- if and $host (ne $host $expectedNpdbHost) -}}
{{- $warnings = append $warnings (printf "npdb.hosts.%s (%s) does not match the npdb NGINX service name (%s). Expected for external DNS names, unexpected otherwise." $key $host $expectedNpdbHost) -}}
{{- end -}}
{{- end -}}
{{- if $.Values.jupyterhub.enabled -}}
{{- $expectedNpdbUrl := printf "http://%s-npdb-nginx" .Release.Name -}}
{{- range $key := list "NOPAYLOADDB_URL" "NOPAYLOADDB_FILES_URL" -}}
{{- $url := dig "singleuser" "extraEnv" $key "" $.Values.jupyterhub -}}
{{- if and $url (ne $url $expectedNpdbUrl) -}}
{{- $warnings = append $warnings (printf "jupyterhub.singleuser.extraEnv.%s (%s) does not match the npdb NGINX service (%s). Keep in sync with npdb.hosts." $key $url $expectedNpdbUrl) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- if dig "components" "reana_db" "enabled" false .Values.reana -}}
{{- $expectedDbHost := printf "%s-db" .Release.Name -}}
{{- $dbHost := dig "db_env_config" "REANA_DB_HOST" "" .Values.reana -}}
{{- if and $dbHost (ne $dbHost $expectedDbHost) -}}
{{- $warnings = append $warnings (printf "reana.db_env_config.REANA_DB_HOST (%s) does not match the reana-db service name (%s). Expected for external databases, unexpected otherwise." $dbHost $expectedDbHost) -}}
{{- end -}}
{{- end -}}

{{/* RcloneMount vs singleuser extraVolumes coupling */}}
{{- if .Values.jupyterhub.enabled -}}
{{- $rclonePvc := .Values.RcloneMount.pvcName -}}
{{- $claimsRclonePvc := false -}}
{{- range dig "singleuser" "storage" "extraVolumes" list .Values.jupyterhub -}}
{{- if eq (dig "persistentVolumeClaim" "claimName" "" .) $rclonePvc -}}
{{- $claimsRclonePvc = true -}}
{{- end -}}
{{- end -}}
{{- if and .Values.RcloneMount.enabled (not $claimsRclonePvc) -}}
{{- $warnings = append $warnings (printf "RcloneMount is enabled but no jupyterhub.singleuser.storage.extraVolumes entry claims %s: the rclone PV/PVC will exist but nothing mounts it in user pods (see values-custom-example.yaml)." $rclonePvc) -}}
{{- end -}}
{{- if and (not .Values.RcloneMount.enabled) $claimsRclonePvc -}}
{{- $warnings = append $warnings (printf "jupyterhub.singleuser.storage.extraVolumes claims %s but RcloneMount is disabled: the PVC does not exist and user pods will hang Pending at spawn." $rclonePvc) -}}
{{- end -}}
{{- end -}}

{{- if $warnings -}}
{{- range $warnings }}
WARNING: {{ . }}
{{ end -}}
{{- end -}}
{{- end }}
