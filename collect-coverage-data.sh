#!/bin/bash

# run-orion-tests.sh - Collect phosphor-state-manager converage data for using with Orion

# Configure the pathnames and tests.
. setup.sh

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

# Ensure we are in the phosphor-state-manager source folder.
check_for_file . bmc_state_manager.cpp
if [ `run_target pwd` != /home/root ]; then
	echo "ssh to target not working" >&2
	exit 1
fi

# Make sure all folders are present and accounted for.
check_for_file $OPENBMC_DIR setup
check_for_file $SOURCE_DIR bmc_state_manager.cpp
check_for_file $OBJECT_DIR test_systemd_parser
check_for_file $BUILD_DIR qemu-system-arm

# Remove all previous test data on the target.
run_target "sh -c 'rm -rf $RUNTIME_DIR && mkdir -p $RUNTIME_DIR'"

# Remove all the old tmp data folder and recreate it.
rm -rf $DATA_DIR/tmp && mkdir -p $DATA_DIR/tmp

for test_name in $TESTS; do

	# Flush the coverage data on the target.
	flush_coverage

	# Run one "group" of gtest tests.
	run_test $test_name

	# Choose an archive name.
	archive_name=$test_name

	# Create GCDA bundle.
	retrieve_bundle $DATA_DIR/tmp/$archive_name.tar.gz
done
