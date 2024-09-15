#!/bin/sh
# run-emulator.sh - Run the target under the emulator with a copy of the deployed image.

# Make sure we have QEMU.
if [ ! -f qemu-system-arm ]; then
	echo "Emulator missing, copying from bitbake image" >&2
	cp $(BUILD_DIR)/tmp/sysroots-components/x86_64/qemu-system-native/usr/bin/qemu-system-arm .
fi

# Make sure qemu isn't already running.
qemu_pid=`ps acx | grep qemu-system-arm`
if [ -n "$qemu_pid" ]; then
	echo "QEMU ios already running" >&2
	exit 1
fi

# Copy the phosphor image to the current folder so that using QEMU doesn't corrupt it.
cp -v ../../../tmp/deploy/images/romulus/obmc-phosphor-image-romulus.static.mtd .


# Run the local QEMU with our image and settings.
nohup ./qemu-system-arm -m 256 -machine romulus-bmc -nographic     \
	-drive file=./obmc-phosphor-image-romulus.static.mtd,format=raw,if=mtd     \
	-net nic     \
	-net user,hostfwd=:127.0.0.1:2222-:22,hostfwd=:127.0.0.1:2443-:443,hostfwd=udp:127.0.0.1:2623-:623,hostname=qemu >qemu-system-arm.out \
	2>&1 &
