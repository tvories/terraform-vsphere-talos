#!/bin/sh

URL="https://github.com/talos-systems/talos/releases/download/${TALOS_VERSION}/"
HOST_ARCH=$(uname -m | awk '{print ($1=="x86_64") ? "amd64" : "arm64"}')

# Download the required package, based on presence of wget or curl on the host
# The first argument represents the remote, and the second one represent the local name of the file
function download {
	if [[ -f $(which wget) ]]; then
		wget -q ${URL}${1} -O ${2}
	elif [[ -f $(which curl) ]]; then
		curl -sSL ${URL}${1} -o ${2}
	else
		echo "Neither wget, nor curl could be found for downloads; please make sure one is installed and accessible, before trying again"
		exit 412 # http 412 - precondition failed
	fi
}

# Validate if the correct version of Talos ISO or CLI are present
# The first argument represents the remote, and the second one represent the local name of the file
function validate_checksum {
	CHECKSUM=""
	download sha512sum.txt ./sha512sum.txt
	if (uname -a | grep -i 'darwin' >/dev/null); then # Host is macOS
		CHECKSUM=$(shasum -a 512 ${2} | awk '{print $1}')
	else # Host is Linux, as other platforms are not tested to be evaluated here
		CHECKSUM=$(sha512sum ${2} | awk '{print $1}')
	fi
	FILENAME=$(basename ${1})
	[ ${CHECKSUM} = $(grep "${FILENAME}" sha512sum.txt | awk  '{print $1}') ]
}

# If the directory, which Talos ISO will be stored into, doesn't exist, create it
mkdir -p ${ISO_DIR}
cd ${ISO_DIR}

# Download Talos ISO, for the selected version, if required
if [[ ! -f ./talos.iso ]] || ! validate_checksum talos-${HOST_ARCH}.iso ./talos.iso; then
	download talos-${HOST_ARCH}.iso ./talos.iso
fi

# Install or upgrade talosctl, if required
if ( ${TALOS_UPDATE} ) &&  ( [[ ! -f /usr/local/bin/talosctl ]] || ! validate_checksum talosctl-darwin-${HOST_ARCH} /usr/local/bin/talosctl ); then
	if (uname -a | grep -i 'darwin' >/dev/null); then # Host is macOS
		download talosctl-darwin-${HOST_ARCH} /usr/local/bin/talosctl
	elif ! validate_checksum talosctl-linux-${HOST_ARCH} /usr/local/bin/talosctl; then
		download talosctl-linux-${HOST_ARCH} /usr/local/bin/talosctl
	fi
	chmod +x /usr/local/bin/talosctl
fi
rm -f ./sha512sum.txt

