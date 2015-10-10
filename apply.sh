#!/bin/sh

PUPPETVER=$(facter -p puppetversion)
PUPPETARGS=""
HIERA_CONFIG=""

if [ -f "./keys/private_key.pkcs7.pem" ] && [ -f "./keys/public_key.pkcs7.pem" ] ; then
  GEMCHECK=$(gem list -i hiera-eyaml)
  case ${GEMCHECK} in
    true)
      HIERA_CONFIG="./headless-e.yaml"
      ;;
    false)
      echo "you don't have the hiera-eyaml gem, you should fix that."
      exit 1
      ;;
  esac 
else
  HIERA_CONFIG="./headless.yaml"
fi

case ${PUPPETVER} in
  0*|1*|2*)
    # wow how did you get here?
    echo "unsupported puppet version ${PUPPETVER}"
    exit 1
    ;;
  3*)
    PUPPETARGS="${PUPPETARGS} --parser=future"
    ;;
  *)
    # noop
    ;;
esac

if [ -z "${PUPPETVER}" ] ; then
  echo "I don't think you even have puppet. where's facter?"
  exit 1
fi

puppet apply ${PUPPETARGS} --hiera_config="${HIERA_CONFIG}" --modulepath ./modules ./manifests/site.pp
