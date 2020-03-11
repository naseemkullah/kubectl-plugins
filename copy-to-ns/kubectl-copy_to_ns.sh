#!/usr/bin/env bash
#
# Copy a resource from one namespace to another.

usage() {
  cat <<EOF
Usage:
  kubectl copy-to-ns <resource type> <resource name> <source namespace> <destination namespace>
EOF
}

cleanup() {
  jq 'del(.metadata | .namespace, .creationTimestamp, .uid, .resourceVersion, .selfLink, .annotations."kubectl.kubernetes.io/last-applied-configuration")'
}

copy_resource() {
  TYPE=$1
  NAME=$2
  SRC_NS=$3
  DST_NS=$4
  #TODO: Support more resource types if in demand.
  case "$TYPE" in
  secrets | secret | configmaps | cm | configmap)
    kubectl get "$TYPE" "$NAME" --namespace "$SRC_NS" -o json |
      cleanup |
      kubectl apply --namespace "$DST_NS" -f -
    ;;
  *)
    echo >&2 "\"$TYPE\" is not a valid resource type. Only secrets and configmaps are supported in this version."
    usage
    exit 1
    ;;
  esac
}

if [[ $# -lt 4 ]]; then
  echo >&2 "Missing parameters."
  usage
  exit 1
fi
copy_resource "$@"
