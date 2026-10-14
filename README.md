# FreeBSD netlink YANG

YANG 1.1 modules describing FreeBSD's netlink(4) protocols as the
kernel implements them: the route messages of `NETLINK_ROUTE`
(rtnetlink), every fixed header, attribute, flag and enumeration,
with the C names of its headers, read from `sys/netlink`.

The modules are a description of the wire protocol, not a data model
of the network stack: an rpc is a request and its reply, a
notification a message the kernel multicasts, and the attribute type
numbers are in the modules, so that a program can be generated from
them.

One directory per release:

| Directory    | FreeBSD                              | Revision     |
|--------------|--------------------------------------|--------------|
| `16-CURRENT` | 16.0-CURRENT (`84f790e5b6cc`)        | `2026-10-14` |

## The modules

| Module | Describes |
|--------|-----------|
| `freebsd-netlink-extensions` | The `nlx:` statements that carry the wire facts: `nlx:attr`, `nlx:name-prefix`, `nlx:fixed-header`, `nlx:struct`, `nlx:width`, `nlx:array`, `nlx:selector`, `nlx:msg-type`, `nlx:group` ... Its description is the reading rules. |
| `freebsd-netlink-types` | Addresses as attributes carry them, interface indexes, address families, FIB numbers. |
| `freebsd-netlink` | `<netlink/netlink.h>`: the socket address and options, the message and attribute headers, the flags, the control messages, the error acknowledgement, the message information cmsg, the compact bitset. |
| `freebsd-rtnetlink` | `<netlink/route/common.h>`: the message types and multicast groups of `NETLINK_ROUTE`. |
| `freebsd-rtnetlink-route` | `RTM_{NEW,DEL,GET}ROUTE`: `struct rtmsg`, `RTA_*`, the metrics, the multipath nexthops. |

## How a protocol is written in YANG

A grouping is an attribute set, a fixed header, or a message (both).
A node with `nlx:attr N` is attribute number N of the set it is in; a
leaf without it, in a grouping marked `nlx:struct`, is a member of
that C structure.  Containers are nested attributes, lists repeated
ones (or, with `nlx:array`, one container attribute of entries),
leaf-lists repeated scalars, a choice with `nlx:attr` an attribute
whose format another attribute selects.  The C name of an attribute
is the `nlx:name-prefix` in force and the node's name in upper case,
`NL_RTA_` and `dst` giving `NL_RTA_DST`.  The YANG type is the wire type:
the integer types by their size, `boolean` a one byte boolean,
`empty` a flag, `string` a NUL-terminated string, `binary` bytes; an
enumeration or bits type is an integer of `nlx:width` bits.

Each attribute's description says whether the kernel sends it, reads
it, both, or neither (an attribute defined for Linux compatibility
and not supported).  Where the kernel's reading and writing of an
attribute disagree, the description says so.

An rpc is a request and its reply; `nlx:msg-type` is the message
type, `nlx:do` and `nlx:dump` say whether it answers a request for
one object or a dump, `nlx:privilege` the privilege it needs.  A
notification is a message the kernel multicasts, `nlx:group` the
group.  Where the kernel always sends an attribute in a reply or a
notification, a `refine` makes it mandatory there.

## Checking

    ./check.sh

compiles every module with pyang, which is all the YangModels
repository asks.  The modules import nothing outside this
directory.

## Generating code

The attribute numbers, C names, fixed headers and wire types in the
modules are what a code generator needs to produce parsers and
builders of the messages.  yanl, the YANG netlink generator, reads
them to generate the snl(3) parsers of the base system,
`netlink_snl_route_parsers.h`, from the binding modules in
`16-CURRENT/snl`: `freebsd-netlink-snl` is their vocabulary,
`freebsd-rtnetlink-route-snl` binds the route message to its parser
and output structure.  They are here until they and yanl move into
`sys/netlink/specs` and `sys/tools/yanl` of the base system.

## License

BSD-2-Clause; see LICENSE.  Each module starts with its SPDX
identifier.
