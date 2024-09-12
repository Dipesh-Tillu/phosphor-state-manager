# setup.sh - setup the configuration for collecting coverage data for Orion

# Determine absolute paths for relative locations.
OPENBMC_DIR=`cd ../../../../.. && pwd`
BUILD_DIR=$OPENBMC_DIR/build/romulus
SOURCE_DIR=$BUILD_DIR/workspace/sources/phosphor-state-manager
OBJECT_DIR=$BUILD_DIR/tmp/work/arm1176jzs-openbmc-linux-gnueabi/phosphor-state-manager/1.0+git/phosphor-state-manager-1.0+git
RUNTIME_DIR=/tmp/coverage
DATA_DIR=`pwd`/data
ORION_DIR=$BUILD_DIR/workspace/sources/orion-c-cpp/build

# Configure data collection test run.
TESTS="test_systemd_parser test_systemd_signal test_scheduled_host_transition test_hypervisor_state"

check_ssh() {
	if [ "`run_target pwd </dev/null >/dev/null 2>&1`" != /home/root ]; then
		echo "ssh to target not working: is the emulator running?" >&2
		exit 1
	fi
}

# Check whether the specified file exists in the specified folder.
check_for_file() {
	if [ $# -ne 2 ]; then
		echo "usage: check_for_file <folder> <file>" >&2
		exit 1
	fi
	folder="$1"
	file="$2"
	if [ ! -f $folder/$file ]; then
		echo "File not in workspace source folder: $folder, file: $file" >&2
		exit 1
	fi
}

# Run the specified command on the target.
run_target() {
	if [ $# -eq 0 ]; then
		echo "usage: run_target <command arg ...>" >&2
		exit 1
	fi
	echo "Running command on target: $@" >&2
	ssh -p 2222 root@localhost "$@"

}

# Copy the specified test to the target's runtime folder.
copy_target() {
	if [ $# -ne 2 ]; then
		echo "usage: copy_target <local_file_name> <remote_folder_name>" >&2
		exit 1
	fi
	local_file_name=$1
	remote_folder_name=$2
	echo "Copying local file $local_file_name => $remote_folder_name" >&2
	scp -P 2222 $local_file_name root@localhost:$remote_folder_name
}

# Run the test on the target 
run_test() {
	if [ $# -ne 1 ]; then
		echo "usage: run_test <test-name>" >&2
		exit 1
	fi

	# Note: we could use GCOV environment variables to control the runtime location of the GCDA files.
	test_name=$1
	copy_target $OBJECT_DIR/$test_name $RUNTIME_DIR
	run_target $RUNTIME_DIR/$test_name
}

# Flush the GCOV data on the target.
flush_coverage()
{
	if [ $# -ne 0 ]; then
		echo "usage: flush_coverage" >&2
		exit 1
	fi

	# Collect and retrieve *.gcda files from target.
	echo "Tar-balling GCDA files for test $test_name => $tarball_name"
	run_target "rm -rf $OBJECT_DIR && mkdir -p $OBJECT_DIR"
}

# Retrieve the GDDA bundle.
retrieve_bundle()
{
	if [ $# -ne 1 ]; then
		echo "usage: retrieve_bundle <tarball>" >&2
		exit 1
	fi
	tarball_name=$1

	# Collect and retrieve *.gcda files from target.
	echo "Tar-balling GCDA files for test $test_name => $tarball_name"
	run_target "cd $OBJECT_DIR && find . -name '*.gcda' -print | tar cvfz - -T -" >$tarball_name
}

# Banner to report who we are and what we do.
echo
echo "Welcome to the coverage data collection driver program."
echo "This is a demonstratino of the OpenBMC coverage toolkit."
echo
echo
echo "Use: . coverage-common.sh"
echo "  use this in the shell to get direct access to the variables we display"
echo
echo "Use: sh setup-ssh.sh"
echo "  when using a freshly build image from bitbake"
echo
echo "Use: sh collect-coverage-data.sh"
echo "  to collect the runtime coverage data (the GCDA files)"
echo
echo "Use: sh make-coverage-archive.sh"
echo "  after collecting the coverage data to produce the coverage"
echo "  compressed data file archive"
echo
echo

# Ensure we are in the phosphor-state-manager source folder.
check_for_file . bmc_state_manager.cpp

# Make sure all folders are present and accounted for.
check_for_file $OPENBMC_DIR setup
check_for_file $SOURCE_DIR bmc_state_manager.cpp
check_for_file $OBJECT_DIR test_systemd_parser
check_for_file $BUILD_DIR qemu-system-arm
check_for_file $ORION_DIR mmx/oriccpp-mmx

# Report all path names that are in use.

echo "The folder where openbmc git repository is:"
echo "OPENBMC_DIR='$OPENBMC_DIR'"
echo "The folder where the project repository is:"
echo "SOURCE_DIR='$SOURCE_DIR'"
echo "The folder where the Yocto build outputs are located:"
echo "OBJECT_DIR='$OBJECT_DIR'"
echo "The folder where the romulus target is located within the openbmc folder:"
echo "BUILD_DIR='$BUILD_DIR'"
echo "The folder where data coverage data is persisted:"
echo "DATA_DIR='$DATA_DIR'"
echo "The folder where the Orion project is located:"
echo "ORION_DIR='$ORION_DIR'"
echo
