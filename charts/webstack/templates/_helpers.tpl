{{- define "argo.helm.values" }}
      {{- if .parameters }}
      parameters:
      {{- range $key, $value := .parameters }}
        - name: {{$key}}
          value: {{$value | quote}}
      {{- end }}
      {{- end}}
      {{- if .values }}
      values: {{ toYaml .values | indent 6 }}
      {{- end }}
{{- end }}

