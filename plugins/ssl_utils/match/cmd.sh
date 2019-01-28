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

MATCH=$(echo "$(openssl x509 -noout -modulus -in "$__CERT" | openssl md5 ; openssl rsa -noout -modulus -in "$__KEY" | openssl md5)" | uniq | wc -l)
if [ "z$MATCH" = "z1" ] ; then
  echo "Match!"
else
  echo "NOT Match!"
fi
