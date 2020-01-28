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
docs-beta.ipfs.io
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

ipfs-cluster-ctl $@ pin ls | grep -v -e '-outdated-' > pinset.txt

for s in $websites; do
    oldcids=`grep "| $s |" pinset.txt | cut -d ' ' -f 1`
    newcid=$(basename `ipfs resolve -r "/ipns/$s"`) # remove /ipfs prefix
    pinned=no
    for oldcid in $oldcids; do
        if [[ "$oldcid" == "$newcid" || "$pinned" == "yes" ]]; then
            echo "already pinned in latest version: $s"
        else 
            echo "pinning: $s"
            ipfs-cluster-ctl $@ pin add --no-status --name "$s" "$newcid"
            pinned=yes
        fi
        if [[ -n "$oldcid" && ("$newcid" != "$oldcid") ]]; then
            echo "unpinning old version after 48h: $oldcid"
            ipfs-cluster-ctl $@ pin add --expire-in '172800s' --no-status --name "${s}-outdated-$(date --utc -Iseconds)" "$oldcid"
        fi
    done
done
#rm pinset.txt
