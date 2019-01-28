#!/bin/sh

_PORT=443
while [ "$1" ] ; do
  case "$1" in
    "--port" | "-p" )
      shift
      _PORT="$1"
      shift ;;
    "--help" | "-h" )
      __help --plugin "$PLUGIN_NAME" --exit 0
      shift ;;
    "--")
      shift ;;
    -*)
      __help --plugin "$PLUGIN_NAME" --exit 1 --msg "$1: Invalid option"
      shift ;;
    *)
      _DOMAIN="$1"
      shift;;
  esac
done

if [ "z$_DOMAIN" = "z" ] ; then
  __help --msg "missing domain" --plugin "$PLUGIN_NAME" --exit 1
fi

_TMP_CHAIN=$(mktemp)
_TMP_CHAIN_FILE_BASE=$(mktemp -u)

openssl s_client -showcerts -verify 5 -connect "$_DOMAIN:$_PORT" 2>/dev/null < /dev/null | sed -n '/-----BEGIN/,/-----END/p' > "$_TMP_CHAIN"
awk "/-----BEGIN/{if(NR!=1){for(i=0;i<j;i++)print a[i]>\"${_TMP_CHAIN_FILE_BASE}_\"k\".crt\";j=0;k++;}a[j++]=\$0;next}{a[j++]=\$0;}END{for(i=0;i<j;i++)print a[i]>\"${_TMP_CHAIN_FILE_BASE}_\"k\".crt\"}" i=0 k=1 "$_TMP_CHAIN"

_CERT=$(find "$(dirname "$_TMP_CHAIN_FILE_BASE")" -name "$(basename "$_TMP_CHAIN_FILE_BASE")*" 2>/dev/null | sort | head -1)
_CHAIN=$(find "$(dirname "$_TMP_CHAIN_FILE_BASE")" -name "$(basename "$_TMP_CHAIN_FILE_BASE")*" 2>/dev/null | sort | tail +2 | xargs)
cat $_CHAIN > "$_TMP_CHAIN"

_OCSP_URI=$(openssl x509 -noout -ocsp_uri -in "$_CERT")

_ESC_CERT=$(echo "$_CERT" | sed -e 's/[]\/$*.^[]/\\&/g')
_ESC_DOMAIN=$(echo "$_DOMAIN" | sed -e 's/[]\/$*.^[]/\\&/g')
openssl ocsp -issuer "$_TMP_CHAIN" -cert "$_CERT" -text -url "$_OCSP_URI" 2>/dev/null | sed -n "/$_ESC_CERT/,//p" | sed -e "s/$_ESC_CERT/$_ESC_DOMAIN/g"

rm -f "$_TMP_CHAIN"
rm -f "${_TMP_CHAIN_FILE_BASE}"_*
