#!/bin/bash

# collect-coverage-data.sh - collect phosphor-state-manager converage data for using with Orion

# Configure the pathnames and tests.
. ./coverage-common.sh

# Remove all previous test data on the target.
run_target "sh -c 'rm -rf $RUNTIME_DIR && mkdir -p $RUNTIME_DIR'"

# Remove all the old work folder and recreate it.
rm -rf $DATA_DIR/work && mkdir -p $DATA_DIR/work

for test_name in $TESTS; do

	# Flush the coverage data on the target.
	flush_coverage

	# Run one "group" of gtest tests.
	run_test "$test_name

	# Choose an archive name.
	archive_name="$test_name-gcda"

	# Create GCDA bundle.
	retrieve_bundle $DATA_DIR/work/$archive_name.tar.gz
done
