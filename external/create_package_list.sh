#!/bin/sh

# compile a puppet catalog and retrieve the package edges that puppet installs. only tested on metadata version 1.
puppet catalog find package --render-as json | sed -e '1d' | jq '.data.edges[]|.target' | fgrep '"Package[' | sed -e 's/"Package\[//g' -e 's/\]"//g'
