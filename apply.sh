#!/bin/sh

puppet apply --parser=future --hiera_config=./headless.yaml --modulepath ./modules ./manifests/site.pp
