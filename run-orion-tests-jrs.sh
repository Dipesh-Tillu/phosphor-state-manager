# run-orion-tests.sh - Collect phosphor-state-manager converage data for using with Orion

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
	echo "Running command on target: $@"
	ssh -p 2222 root@localhost "$@"

}

copy_target() {
	if [ $# -ne 2 ]; then
		echo "usage: copy_target <local_file_name> <remote_folder_name>" >&2
		exit 1
	fi
	local_file_name=$1
	remote_folder_name=$2
	echo "Copying local file $local_file_name => $remote_folder_name"
	scp -P 2222 $local_file_name root@localhost:$remote_folder_name
}

run_test() {
	# Note: we could use GCOV environment variables to control the runtime location of the GCDA files.
	test_name=$1
	copy_target $OBJECT_DIR/$test_name $RUNTIME_DIR
	run_target $RUNTIME_DIR/$test_name
}

# Ensure we are in the phosphor-state-manager source folder.
check_for_file . bmc_state_manager.cpp
if [ `run_target pwd` != /home/root ]; then
	echo "ssh to target not working" >&2
	exit 1
fi

# Determine absolute paths for relative locations.
OPENBMC_DIR=`cd ../../../../.. && pwd`
BUILD_DIR=$OPENBMC_DIR/build/romulus
SOURCE_DIR=$BUILD_DIR/workspace/sources/phosphor-state-manager
OBJECT_DIR=$BUILD_DIR/tmp/work/arm1176jzs-openbmc-linux-gnueabi/phosphor-state-manager/1.0+git/phosphor-state-manager-1.0+git
RUNTIME_DIR=/tmp/coverage

# Configure data collection test run.
TESTS="test_systemd_parser test_systemd_signal test_scheduled_host_transition test_hypervisor_state"
ARCHIVE_NAME="phosphor-state-manager-coverage-$(date +%Y%m%d-%H%M%S)"
TARGET_COVERAGE_DIR="/tmp/coverage"
LOCAL_ARCHIVE_DIR="$HOME/coverage-archives"

# Display current values.
echo OPENBMC_DIR=$OPENBMC_DIR
echo BUILD_DIR=$BUILD_DIR
echo SOURCE_DIR=$SOURCE_DIR
echo OBJECT_DIR=$OBJECT_DIR

# Make sure all folders are present and accounted for.
check_for_file $OPENBMC_DIR setup
check_for_file $SOURCE_DIR bmc_state_manager.cpp
check_for_file $OBJECT_DIR test_systemd_parser
check_for_file $BUILD_DIR qemu-system-arm

# Remove all previous test data.
run_target "sh -c 'rm -rf $RUNTIME_DIR && mkdir -p $RUNTIME_DIR'"

for test_name in $TESTS; do

	# Run one "group" of gtest tests.
	run_test $test_name

	# Choose an archive name.
	archive_name=$test_name

	# Create GCDA bundle.
	echo "Tar-balling GCDA files for test $test_name => $archive_name.tar.gz"
	run_target "find $OBJECT_DIR -name '*.gcda' -print | tar cvf - -T -" >$archive_name.tar.gz
done
