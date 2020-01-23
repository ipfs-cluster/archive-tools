#!/usr/bin/env bash

# Usage: ./pin-websites <ipfs-cluster-ctl-args>

set -e

websites='
website.filecoin.io
website.protocol.ai
ipfs.io
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
chat.ipfs.io
dweb-primer.ipfs.io
igis.io
dev.peerpad.net
flipchart.peerpad.net
project-repos.ipfs.io
dnslink.io
'

ipfs-cluster-ctl $@ pin ls > pinset.txt

for s in $websites; do
    oldcid=`grep "| $s |" pinset.txt | cut -d ' ' -f 1`
    newcid=$(basename `ipfs resolve -r "/ipns/$s"`) # remove /ipfs prefix
    if [[ "$oldcid" == "$newcid" ]]; then
        echo "$s already pinned in latest version"
        continue
    fi
    echo "pinning $s"
    ipfs-cluster-ctl $@ pin add --no-status --name "$s" "$newcid"
    if [[ -n "$oldcid" && ("$newcid" != "$oldcid") ]]; then
        echo "unpinning old version: $oldcid"
        ipfs-cluster-ctl $@ pin rm --no-status "$oldcid"
    fi
done
#rm pinset.txt
