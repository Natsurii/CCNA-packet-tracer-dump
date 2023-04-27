#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <CIDR mask>"
    exit 1
fi

cidr=$1

if ! [[ "$cidr" =~ ^[0-9]+$ ]]; then
    echo "CIDR mask must be a positive integer"
    exit 1
fi

if [ "$cidr" -lt 0 ] || [ "$cidr" -gt 32 ]; then
    echo "CIDR mask must be between 0 and 32"
    exit 1
fi

mask=$((0xffffffff << (32 - $cidr) & 0xffffffff))

subnet_mask=$(printf "%d.%d.%d.%d\n" \
                $(($mask >> 24)) \
                $(($mask >> 16 & 0xff)) \
                $(($mask >> 8 & 0xff)) \
                $(($mask & 0xff)))

echo "Subnet mask: $subnet_mask"
