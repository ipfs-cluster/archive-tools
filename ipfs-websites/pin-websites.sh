#!/usr/bin/env bash

# Usage: ./pin-websites <ipfs-cluster-ctl-args>

set -e

websites=(
website.filecoin.io
website.protocol.ai
research.protocol.ai
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
igis.io
dev.peerpad.net
flipchart.peerpad.net
project-repos.ipfs.io
dnslink.io
)

pinset_file="$(mktemp "$(basename "$0").XXXXXXXXXX" --tmpdir)"
ipfs-cluster-ctl "$@" pin ls >"$pinset_file"
# remove temp file after this script ends
trap 'rm -f "$pinset_file"' EXIT

for s in "${websites[@]}"; do
    declare -A oldcids
    while read -r oldcid; do
        oldcids["$oldcid"]=1
    done < <(grep "| $s |" "$pinset_file" | cut -d ' ' -f 1)
    newcid="$(ipfs resolve -r "/ipns/$s")" || {
        echo "failed resolving $s"
        continue
    }
    newcid="${newcid#/ipfs/}" # remove /ipfs/ prefix

    if [[ -z "${oldcids["$newcid"]}" ]]; then
        echo "pinning: $s"
        ipfs-cluster-ctl "$@" pin add --no-status --name "$s" "$newcid"
    else
        echo "already pinned in latest version: $s"
    fi

    for oldcid in "${!oldcids[@]}"; do
        if [[ "$oldcid" == "$newcid" ]]; then
            continue
        fi
        echo "unpinning old version of $s: $oldcid"
        ipfs-cluster-ctl "$@" pin rm --no-status "$oldcid"
    done

    unset -v oldcids
done
