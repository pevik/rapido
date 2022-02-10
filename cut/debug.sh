#!/bin/bash
#
# Copyright (C) SUSE LINUX GmbH 2019, all rights reserved.
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation; either version 2.1 of the License, or
# (at your option) version 3.
#
# This library is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
# License for more details.

RAPIDO_DIR="$(realpath -e ${0%/*})/.."
. "${RAPIDO_DIR}/runtime.vars"

_rt_require_dracut_args "$@"

"$DRACUT" \
	--install "tail blockdev cat grep dmesg lsmod" \
	$DRACUT_RAPIDO_INCLUDES \
	--include "$LTP_DIR" "$LTP_DIR"  \
	--include "${KERNEL_SRC}/.config" /.config \
	--modules "base" \
	$DRACUT_EXTRA_ARGS \
	$DRACUT_OUT || _fail "dracut failed"

_rt_xattr_vm_networkless_set "$DRACUT_OUT"		# *disable* network
#_rt_xattr_vm_resources_set "$DRACUT_OUT" "2" "2048M"	# 2 vCPUs, 2G RAM
