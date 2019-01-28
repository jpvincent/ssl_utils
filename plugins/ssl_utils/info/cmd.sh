#!/bin/sh

_PORT=443
_ONLY=""
while [ "$1" ] ; do
  case "$1" in
    "--port" | "-p" )
      shift
      _PORT="$1"
      shift ;;
    "--servername" | "-s" )
      shift
      _SERVERNAME="$1"
      shift ;;
    "--help" | "-h" )
      __help --plugin "$PLUGIN_NAME" --exit 0
      shift ;;
    "--only" | "-o" )
      shift ;
      ONLY=1
      while [ "$ONLY" = "1" ] ; do
        case "$1" in
          -*)
            ONLY=0
            ;;
          *)
            if [ -n "$1" ] ; then
              _ONLY="$_ONLY $1"
              shift
            else
              ONLY=0
            fi
            ;;
        esac
      done
      ;;
    "--")
      shift ;;
    -*)
      __help --plugin "$PLUGIN_NAME" --exit 1 --msg "$1: Invalid option"
      shift ;;
    *)
      FILE_OR_DOMAIN="$1"
      shift;;
  esac
done

if [ "z$FILE_OR_DOMAIN" = "z" ] ; then
  __help --msg "missing file or domain" --plugin "$PLUGIN_NAME" --exit 1
fi

if [ -f "$FILE_OR_DOMAIN" ] ; then
  file_info "$FILE_OR_DOMAIN"
else
  domain_info "$FILE_OR_DOMAIN" "$_PORT" "$_SERVERNAME"
fi
