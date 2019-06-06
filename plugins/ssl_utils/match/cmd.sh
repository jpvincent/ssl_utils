#!/bin/sh

__CERT=""
__KEY=""

set_file() {
  __FILE="$(expand "$(dirname "$1")")/$(basename "$1")"
  __TYPE=$(cat "$__FILE" | grep "\\-*BEGIN" | head -1 | sed -e 's/^-*BEGIN *\([^-]*\)-*.*$/\1/' | tr "[A-Z]" "[a-z]")
  case "$__TYPE" in
    "certificate")
      __CERT=$__FILE
      ;;
    "rsa private key")
      __KEY=$__FILE
      ;;
    "private key")
      __KEY=$__FILE
      ;;
    *)
      echo "$__FILE: invalid file!"
      exit 1
      ;;
  esac
}

check_help "$@"

while [ "$1" ] ; do
  case "$1" in
    "--help" | "-h" )
      __help --plugin "$PLUGIN_NAME" --exit 0
      shift ;;
    *)
      set_file "$1"
      shift ;;
  esac
done

if [ "z$__CERT" = "z" ] ; then
  echo "Missing certificate"
  exit 1
fi

if [ "z$__KEY" = "z" ] ; then
  echo "Missing key file"
  exit 1
fi

echo
echo "Certificate : $__CERT"
echo "Key         : $__KEY"
echo

CERT_MODULUS=$(openssl x509 -noout -modulus -in "$__CERT" | openssl md5  | sed -e 's/^.*=\s*//')
KEY_MODULUS=$(openssl rsa -noout -modulus -in "$__KEY" | openssl md5  | sed -e 's/^.*=\s*//')
MATCH=$(echo "$(openssl x509 -noout -modulus -in "$__CERT" | openssl md5 ; openssl rsa -noout -modulus -in "$__KEY" | openssl md5)" | uniq | wc -l)
# if [ "z$MATCH" = "z1" ] ; then
if [ "$CERT_MODULUS" = "$KEY_MODULUS" ] ; then
  echo "Match!"
else
  echo "NOT Match!"
  echo "  - Certificate: $CERT_MODULUS"
  echo "  - Key:         $KEY_MODULUS"
fi
