#!/bin/sh

case "$1" in 
  create) 
    shift
    create_pkcs12 "$@"
    ;;
  extract)
    shift 
    extract_pkcs12 "$@"
    ;;
  info)
    shift
    info_pkcs12 "$@"
    ;;
  --help|-h)
    __help --plugin "$PLUGIN_NAME" --exit 0
    shift ;;
  *)
    if [ -z "$1" ] ; then 
      __help --msg "missing sub command" --plugin "$PLUGIN_NAME" --exit 1
    else
      __help --msg "invalid sub command $1" --plugin "$PLUGIN_NAME" --exit 1
    fi
esac

# # Create pkcs 12
# openssl pkcs12 -export -inkey www-perf.carrefour.fr.nopass.key -in www-perf.carrefour.fr.cer -out cert.pf2 -password pass:hello
# 
# # info
# openssl pkcs12 -info -in cert.pf2 -password pass:hello -passout pass:<random>
# 
# # Export certificat
# openssl pkcs12 -in cert.pf2 -clcerts -nokeys -out cert.pem -passin pass:hello
# cat cert.pem | sed -n '/-----BEGIN/,/-----END/p' > cert.ok.pem
# mv cert.ok.pem cert.pem
# 
# # Export private key
# openssl pkcs12 -in cert.pf2 -nocerts -out cert.key -password pass:hello -passout pass:<random>
# openssl rsa -in cert.key -out cert.nopass.key -passin pass:<random>
# mv cert.nopass.key cert.key
