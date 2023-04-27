#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <ip_address>/<CIDR_mask>"
    exit 1
fi

ip_and_cidr=$1

IFS="/" read -r ip cidr <<< "$ip_and_cidr"

if ! [[ "$cidr" =~ ^[0-9]+$ ]]; then
    echo "CIDR mask must be a positive integer"
    exit 1
fi

if [ "$cidr" -lt 0 ] || [ "$cidr" -gt 32 ]; then
    echo "CIDR mask must be between 0 and 32"
    exit 1
fi

if ! [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Invalid IP address"
    exit 1
fi

# Calculate the subnet mask
mask=$((0xffffffff << (32 - $cidr) & 0xffffffff))

subnet_mask=$(printf "%d.%d.%d.%d\n" \
                $(($mask >> 24)) \
                $(($mask >> 16 & 0xff)) \
                $(($mask >> 8 & 0xff)) \
                $(($mask & 0xff)))

# Calculate the network address
network=$(( $(echo $ip | awk -F '.' '{print ($1*(256^3)+$2*(256^2)+$3*256+$4)}') & $mask))

# Calculate the broadcast address
broadcast=$(( $network | (~$mask & 0xffffffff) ))

# Calculate the first and last host addresses
first_host=$(( $network + 1 ))
last_host=$(( $broadcast - 1 ))

# Convert addresses to dotted decimal notation
network_address=$(printf "%d.%d.%d.%d\n" \
                $(($network >> 24)) \
                $(($network >> 16 & 0xff)) \
                $(($network >> 8 & 0xff)) \
                $(($network & 0xff)))

broadcast_address=$(printf "%d.%d.%d.%d\n" \
                $(($broadcast >> 24)) \
                $(($broadcast >> 16 & 0xff)) \
                $(($broadcast >> 8 & 0xff)) \
                $(($broadcast & 0xff)))

first_host_address=$(printf "%d.%d.%d.%d\n" \
                $(($first_host >> 24)) \
                $(($first_host >> 16 & 0xff)) \
                $(($first_host >> 8 & 0xff)) \
                $(($first_host & 0xff)))

last_host_address=$(printf "%d.%d.%d.%d\n" \
                $(($last_host >> 24)) \
                $(($last_host >> 16 & 0xff)) \
                $(($last_host >> 8 & 0xff)) \
                $(($last_host & 0xff)))

echo "Subnet mask: $subnet_mask"
echo "Broadcast address: $broadcast_address"
echo "First host address: $first_host_address"
echo "Last host address: $last_host_address"
