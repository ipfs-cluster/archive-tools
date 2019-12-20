#!/usr/bin/env bash

# Usage: ./pin-websites <ipfs-cluster-ctl-args>

set -e

websites='
website.filecoin.io
website.protocol.ai
website.ipfs.io
cluster.ipfs.io
js.ipfs.io
libp2p.io
multiformats.io
saftproject.com
blog.ipfs.io
docs.ipfs.io
docs.libp2p.io
webui.ipfs.io
awesome.ipfs.io
ipld.io
explore.ipld.io
peerpad.net
arewedistributedyet.com
benchmark-js.ipfs.io
cid.ipfs.io
dag.ipfs.io
blocks.ipfs.io
share.ipfs.io
chat.ipfs.io
dweb-primer.ipfs.io
igis.io
maps.ipfs.io
dev.peerpad.net
flipchart.peerpad.net
project-repos.ipfs.io
dev.share.ipfs.io
'

websites='dev.share.ipfs.io'

ipfs-cluster-ctl $@ pin ls > pinset.txt

for s in $websites; do
    oldpin=`grep "$s" pinset.txt | cut -d ' ' -f 1`
    echo "pinning $s"
    newpin=`ipfs-cluster-ctl $@ pin add --no-status --name "$s" "/ipns/$s" | cut -d ' ' -f 1`
    if [[ -n "$oldpin" && ("$newpin" != "$oldpin") ]]; then
        echo "unpinning old version: $oldpin"
        ipfs-cluster-ctl $@ pin rm --no-status "$oldpin" >/dev/null
    fi
done
rm pinset.txt
