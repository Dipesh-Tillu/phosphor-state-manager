#!/bin/bash

# run-orion-tests.sh - Collect phosphor-state-manager converage data for using with Orion

# Configure the pathnames and tests.
source coverage-common.sh

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
