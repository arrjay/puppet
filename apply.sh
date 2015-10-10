#!/bin/sh

PUPPETVER=$(facter -p puppetversion)
PUPPETARGS=""

case PUPPETVER in
  0*|1*|2*)
    # wow how did you get here?
    echo "unsupported puppet version ${PUPPETVER}"
    exit 1
    ;;
  3*)
    PUPPETARGS="--parser=future"
    ;;
  *)
    # noop
    ;;
esac

if [ -z "${PUPPETVER}" ] ; then
  echo "I don't think you even have puppet. where's facter?"
  exit 1
fi

puppet apply ${PUPPETARGS} --hiera_config=./headless.yaml --modulepath ./modules ./manifests/site.pp
