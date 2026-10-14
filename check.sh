#!/bin/sh
#
# Compile every module of every release with pyang, as the check
# scripts of the YangModels repository do.  Run from this directory or
# from the root of a tree this one is a submodule of.
#
# SPDX-License-Identifier: BSD-2-Clause

set -u

cd "$(dirname "$0")" || exit 1

status=0
for dir in */; do
	dir=${dir%/}
	[ -f "$dir/freebsd-netlink.yang" ] || continue
	errors=$(pyang -p "$dir" "$dir"/*.yang 2>&1 | grep -v 'warning:')
	if [ -d "$dir/snl" ]; then
		errors="$errors$(pyang -p "$dir" -p "$dir/snl" "$dir"/snl/*.yang \
		    2>&1 | grep -v 'warning:')"
	fi
	if [ -n "$errors" ]; then
		printf 'PYANG: errors in %s\n%s\n' "$dir" "$errors"
		status=1
	else
		echo "$dir: ok"
	fi
done
exit $status
