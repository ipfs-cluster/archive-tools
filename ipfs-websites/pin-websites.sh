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

pinset_file=$(mktemp "$(basename $0).XXXXXXXXXX" --tmpdir)
# open a file descriptor for writing
exec 3>"$pinset_file"
# remove temp file after this script ends
trap "rm -f $pinset_file" 0 2 3 15

ipfs-cluster-ctl $@ pin ls >&3

for s in $websites; do
    oldcids=$(grep "| $s |" $pinset_file | cut -d ' ' -f 1)
    newcid=$(ipfs resolve -r "/ipns/$s")
    # remove /ipfs prefix
    newcid=$(basename $newcid)
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
            echo "unpinning old version: $oldcid"
            ipfs-cluster-ctl $@ pin rm --no-status "$oldcid"
        fi
    done
done
