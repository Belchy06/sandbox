#!/usr/bin/env bash

# stops the execution if a command or pipeline has an error
set -eu

if command -v tput >/dev/null && tput setaf 1 >/dev/null 2>&1; then
	# color codes
	RED="$(tput setaf 1)"
	RESET="$(tput sgr0)"
fi

ERR="${RED:-}ERROR:${RESET:-}"


err() (
	if [[ -z ${1:-} ]]; then
		cat >&2
	else
		echo "$ERR " "$@" >&2
	fi
)

candidate_interfaces() (
	ip -o link show | awk -F': ' '{print $2}' | sed 's/[ \t].*//;/^\(lo\|bond0\|\|\)$/d' | sort
)


grab_interface_ip() (
    local tink_interface=$1
	ip addr show $tink_interface | grep "inet\b" | awk '{print $2}' | cut -d/ -f1
)

grab_interface_cidr() (
    local tink_interface=$1
	ip addr show $tink_interface | grep "inet\b" | awk '{print $2}' | cut -d/ -f2
)

cidr_to_subnet() {
    value=$(( 0xffffffff ^ ((1 << (32 - $1)) - 1) ))
    echo "$(( (value >> 24) & 0xff )).$(( (value >> 16) & 0xff )).$(( (value >> 8) & 0xff )).$(( value & 0xff ))"
}

validate_tinkerbell_network_interface() (
	local tink_interface=$1

	if ! candidate_interfaces | grep -q "^$tink_interface$"; then
		err "Invalid interface ($tink_interface) selected, must be one of:"
		candidate_interfaces | err
		return 1
	else
		return 0
	fi
)


main() (
    if [[ -z ${1:-} ]]; then
		err "Usage: $0 network-interface-name > .env"
		exit 1
	fi


    local tink_interface="$1"
	validate_tinkerbell_network_interface "$tink_interface"

    local ip
    ip=$(grab_interface_ip "$tink_interface")
    local cidr
    cidr=$(grab_interface_cidr "$tink_interface")



    cat <<-EOF
		# Tinkerbell Stack Prerun Environment vars

        # Tinkerbell Machine HostIP
		export TINKERBELL_HOST_IP="$ip"

        # The CIDR of the Tinkerbell machine's network
		export TINKERBELL_CIDR="$cidr"
	EOF
)
    
# wrapped up in a function so that we have some protection against only getting
# half the file during "curl | sh"
main "$@"