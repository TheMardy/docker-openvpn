#!/bin/bash
set -e

testAlias+=(
	[themardy/openvpn]='openvpn'
)

imageTests+=(
	[openvpn]='
	paranoid
        conf_options
        client
        basic
        dual-proto
        otp
	'
)
