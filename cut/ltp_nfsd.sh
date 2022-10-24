#!/bin/bash
# SPDX-License-Identifier: (LGPL-2.1 OR LGPL-3.0)
# Copyright (C) SUSE LLC 2019-2022, all rights reserved.

RAPIDO_DIR="$(realpath -e ${0%/*})/.."
. "${RAPIDO_DIR}/runtime.vars"

_rt_require_dracut_args "$RAPIDO_DIR/autorun/ltp_nfsd.sh" "$@"
_rt_require_networking
_rt_human_size_in_b "${FSTESTS_ZRAM_SIZE:-1G}" zram_bytes \
	|| _fail "failed to calculate memory resources"
_rt_mem_resources_set "$((2048 + (zram_bytes / 1048576)))M"

protocols_file=/etc/protocols; [ -f "$protocols_file" ] || protocols_file=/usr/etc/protocols

if [[ -n $KERNEL_SRC ]]; then
	config="${KERNEL_SRC}/.config"
else
	config="/boot/config-$(uname -r)"
fi

fses=(btrfs exfat ext2 ext3 ext4 fuse nfs ntfs vfat xfs)

"$DRACUT" \
	--install " \
		attr awk basename bc blockdev cat chattr chgrp chmod chown cmp cut date
		dd df diff dirname dmsetup du egrep exportfs expr false fdformat fdisk
		fgrep find free gdb getconf getfacl getfattr grep head hexdump hostname
		id ip kill killall ldd link losetup lsattr lsmod ltrace md5sum
		${fses[*]/#/mkfs.} mktemp ${fses[*]/#/mount.} od parted perl pgrep ping
		ping6 pkill ps quota quotacheck quotaon resize rev rmdir sed seq
		setfacl setfattr sort stat strace sync sysctl tac tail tar tc tee touch
		tr true truncate uniq unlink vgremove wc which xargs xxd yes
		   rpc.statd sm-notify
		   realpath getfacl setfacl sha256sum vim
		   nfsdclddb nfsdclnts nfsdcltrack rcnfs-server
		   rpcbind rpc.mountd rpc.nfsd" \
	--include /etc/rpc /etc \
	--include $protocols_file $protocols_file  \
	--include "$LTP_DIR" "$LTP_DIR"  \
	--include "$config" /.config \
	--add-drivers "loop nfsd btrfs ext4 zram lzo lzo-rle" \
	--modules "base" \
	"${DRACUT_RAPIDO_ARGS[@]}" \
	"$DRACUT_OUT" || _fail "dracut failed"
	#--include "/etc/rpc /etc/" \
	#--include "$protocols_file" "$(dirname $protocols_file)"  \
