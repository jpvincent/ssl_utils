#!/bin/sh

PLUGIN_VERSION="0.0.1"
PLUGIN_DESCRIPTION="Get certificate information"
PLUGIN_AUTHORS="Greg"

_INDEX=0
_MAX_FIELD_SIZE=0

get_san() {
  openssl x509 -in "$1" -text -noout | grep "DNS:" | tr "," "\n" | sed -e 's/\s*DNS://' | tr "\n" " " | sed -e 's/\s*$//'
}

analyze() {
  __PIPE=$1
  if [ -n "$__REQ" ] ; then
    for _F in $__FIELDS ; do
      case "$_F" in
        *:*)
          _FUN=$(echo "$_F" | cut -d: -f2)
          _V=$(eval "$_FUN $__FILE")
          _F=$(echo "$_F" | cut -d: -f1)
          ;;
        *)
          if [ "$__PIPE" = true ] ; then
            _V=$(cat "$__FILE" | openssl $__REQ -noout -"$_F" | cut -d= -f "2-" | sed 'N;s/\n/ - /')
          else
            _V=$(openssl $__REQ -in "$__FILE" -noout -"$_F" | cut -d= -f "2-" | sed 'N;s/\n/ - /')
          fi
          ;;
      esac

      if [ -n "$_V" ] ; then
        _S=$(printf "%s" "$_F" | wc -c)
        eval _FIELD_SIZE_${_INDEX}=\$_S
        [ "$_MAX_FIELD_SIZE" -lt "$_S" ] && _MAX_FIELD_SIZE=$_S
        eval _FIELD_V_${_INDEX}=\$_V
        eval _FIELD_F_${_INDEX}=\$_F

        _INDEX=$((_INDEX + 1))
      fi
    done

    for _I in $(seq 0 $((_INDEX - 1))) ; do
      eval _FIELD_SIZE=\$_FIELD_SIZE_"$_I"
      eval _FIELD=\$_FIELD_F_"$_I"
      _FIELD_CMP=$((_MAX_FIELD_SIZE - _FIELD_SIZE))
      eval _VALUE_SIZE=\$_VALUE_SIZE_"$_I"
      eval _VALUE=\$_FIELD_V_"$_I"

      printf "%s" "$_FIELD"
      printf "%${_FIELD_CMP}s"
      echo " : $_VALUE"
    done
  fi
}

purge_fields() {
  if [ "z$_ONLY" = "z" ] ; then
    echo "$1"
  else
    _R=""
    for _F in $1 ; do
      case "$_F" in
        *:*)
          _FF=$(echo "$_F" | cut -d: -f1)
          ;;
        *)
          _FF="$_F"
          ;;
      esac

      _FOUND=$(echo "$_ONLY" | sed -e 's/ /\n/g' | grep -e "^$_FF$" -c)
      [ "$_FOUND" = "0" ] || _R="$_R $_F"
    done

    echo "$_R"
  fi
}

get_fields() {
  case "$__TYPE" in
    "certificate request")
      __REQ="req"
      __FIELDS=$(purge_fields "subject")
      ;;
    "certificate")
      __REQ="x509"
      __FIELDS=$(purge_fields "subject serial startdate enddate fingerprint email issuer san:get_san ocsp_uri")
      ;;
    "rsa private key")
      __REQ="rsa"
      __FIELDS=""
      ;;
    "private key")
      __REQ="rsa"
      __FIELDS=""
      ;;
    *)
      __REQ=""
      __FIELDS=""
      ;;
  esac
}

file_info() {
  __FILE="$(expand "$(dirname "$1")")/$(basename "$1")"
  __TYPE=$(cat "$__FILE" | grep "\\-*BEGIN" | head -1 | sed -e 's/^-*BEGIN *\([^-]*\)-*.*$/\1/' | tr "[A-Z]" "[a-z]")

  if [ "z$__TYPE" = "z" ] ; then
    echo "Unknow file type"
    exit 1
  fi

  _FOUND=$(echo "$_ONLY" | sed -e 's/ /\n/g' | grep -e "^file$" -c)
  if [ ! "$_FOUND" = "0" ] || [ "z$_ONLY" = "z" ]  ; then
    eval _FIELD_SIZE_${_INDEX}=4
    [ "$_MAX_FIELD_SIZE" -lt 4 ] && _MAX_FIELD_SIZE=4
    eval _FIELD_F_${_INDEX}="file"
    eval _FIELD_V_${_INDEX}=\$__FILE
    _INDEX=$((_INDEX + 1))
  fi

  _FOUND=$(echo "$_ONLY" | sed -e 's/ /\n/g' | grep -e "^type$" -c)
  if [ ! "$_FOUND" = "0" ] || [ "z$_ONLY" = "z" ]  ; then
    eval _FIELD_SIZE_${_INDEX}=4
    [ "$_MAX_FIELD_SIZE" -lt 4 ] && _MAX_FIELD_SIZE=4
    eval _FIELD_F_${_INDEX}="type"
    eval _FIELD_V_${_INDEX}=\$__TYPE
    _INDEX=$((_INDEX + 1))
  fi

  get_fields
  analyze
}

domain_info() {
  __DOMAIN="$1"
  __PORT="$2"
  __SERVERNAME="$3"
  _SERVERNAME_CMD=""

  nc -w1 -vz "$__DOMAIN" "$__PORT" 1>/dev/null 2>/dev/null
  if [ ! "$?" = "0" ] ; then
    echo "$__DOMAIN: File or service unreachable on port $__PORT"
    exit 1
  fi

  _FOUND=$(echo "$_ONLY" | sed -e 's/ /\n/g' | grep -e "^domain$" -c)
  if [ ! "$_FOUND" = "0" ] || [ "z$_ONLY" = "z" ]  ; then
    eval _FIELD_SIZE_${_INDEX}=6
    [ "$_MAX_FIELD_SIZE" -lt 6 ] && _MAX_FIELD_SIZE=4
    eval _FIELD_F_${_INDEX}="domain"
    eval _FIELD_V_${_INDEX}=\$__DOMAIN
    _INDEX=$((_INDEX + 1))
  fi

  __FILE=$(mktemp)
  if [ "x" = "x$__SERVERNAME" ] ; then
    _SERVERNAME_CMD=""
  else
    _SERVERNAME_CMD="-servername $__SERVERNAME"
  fi
  openssl s_client -showcerts $_SERVERNAME_CMD -connect "$__DOMAIN:$__PORT" 2>/dev/null 1>"$__FILE" </dev/null
  __TYPE=$(cat "$__FILE" | grep "\\-*BEGIN" | head -1 | sed -e 's/^-*BEGIN *\([^-]*\)-*.*$/\1/' | tr "[A-Z]" "[a-z]")

  get_fields
  analyze true
  rm -f "$__FILE"
}
