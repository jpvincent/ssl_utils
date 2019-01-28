#!/bin/sh

PLUGIN_VERSION="0.0.1"
PLUGIN_DESCRIPTION="Manipulate PKCS#12 file"
PLUGIN_AUTHORS="Greg"

_NOPASS=true

extract_opts() {
  while [ "$1" ] ; do
    case "$1" in
      "--key" | "-k" )
        shift
        _KEY_FILE="$1"
        shift ;;
      "--cert" | "-c" )
        shift
        _CERT_FILE="$1"
        shift ;;
      "--passin" | "-i" )
        shift
        _PASSIN="$1"
        shift ;;
      "--passout" | "-o" )
        shift
        _PASSOUT="$1"
        _NOPASS=false
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
        _PKCS12_FILE="$1"
        shift;;
    esac
  done
}

extract_cert() {
  if openssl pkcs12 -in "$_PKCS12_FILE" -clcerts -nokeys -out "$_CERT_FILE" -passin "pass:$_PASSIN" 1>/dev/null 2>&1 ; then
    cat "$_CERT_FILE" | sed -n '/-----BEGIN/,/-----END/p' > "__OK.$_CERT_FILE"
    mv "__OK.$_CERT_FILE" "$_CERT_FILE"
    echo "Certificat:  $_CERT_FILE"
  else
    __help --plugin "$PLUGIN_NAME" --exit 1 --msg "Extraction failed"
  fi
}

extract_key() {
  if [ "$_NOPASS" = true ] ; then
    _PASSOUT="$_PASSIN"
  fi

  if openssl pkcs12 -in "$_PKCS12_FILE" -nocerts -out "$_KEY_FILE" -password "pass:$_PASSIN" -passout "pass:$_PASSOUT" 1>/dev/null 2>&1 ; then
    if [ "$_NOPASS" = true ] ; then
      if openssl rsa -in "$_KEY_FILE" -out "__OK.$_KEY_FILE" -passin "pass:$_PASSOUT" 1>/dev/null 2>&1 ; then
        mv "__OK.$_KEY_FILE" "$_KEY_FILE"
      else
        rm -f "__OK.$_KEY_FILE" "$_KEY_FILE"
        __help --plugin "$PLUGIN_NAME" --exit 1 --msg "Extraction failed"
      fi
    fi
  else
    __help --plugin "$PLUGIN_NAME" --exit 1 --msg "Extraction failed"
  fi

  cat "$_KEY_FILE" | sed -n '/-----BEGIN/,/-----END/p' > "__OK.$_KEY_FILE"
  echo "Private key: $_KEY_FILE"
  mv "__OK.$_KEY_FILE" "$_KEY_FILE"
}

create_pkcs12() {
  extract_opts $@
  {
    [ -f "$_CERT_FILE" ] && [ -f "$_KEY_FILE" ] ;
  } || __help --plugin "$PLUGIN_NAME" --exit 1 --msg "Missing file"

  [ "x" = "x$_PASSOUT" ] && __help --plugin "$PLUGIN_NAME" --exit 1 --msg "Missing passout"
  openssl pkcs12 -export -inkey "$_KEY_FILE" -in "$_CERT_FILE" -out "$_PKCS12_FILE" -password "pass:$_PASSOUT"
  echo
  echo "Pkcs12: $_PKCS12_FILE"
  echo
}

extract_pkcs12() {
  extract_opts $@
  [ "x$_CERT_FILE" = "x" ] && [ "x$_KEY_FILE" = "x" ] && __help --plugin "$PLUGIN_NAME" --exit 1 --msg "Nothing to extract"

  echo
  [ "x$_CERT_FILE" = "x" ] || extract_cert
  [ "x$_KEY_FILE" = "x" ] || extract_key
  echo
}

info_pkcs12() {
  extract_opts $@
  openssl pkcs12 -info -in "$_PKCS12_FILE" -password "pass:$_PASSIN" -passout "pass:$_PASSIN"
}
