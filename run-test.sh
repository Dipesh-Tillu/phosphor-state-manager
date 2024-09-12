#!/bin/bash

# run-test.sh - Run phosphor-state-manager

# Configure the pathnames and tests.
. setup.sh

# Remove all previous test data on the target.
run_target "sh -c 'rm -rf $RUNTIME_DIR && mkdir -p $RUNTIME_DIR'"

# Remove all the old tmp data folder and recreate it.
rm -rf $DATA_DIR/tmp && mkdir -p $DATA_DIR/tmp

# Choose test to run.
if [ $# -ne 1]; then
	echo "usage: sh run-test.sh <test-name>" >&2
	echo "  e.g." >&2
	for i in $TESTS; do
		echo "  sh run-tests.sh $test_name" >&2
	done
	exit 1
fi

test_name="$1"

# Flush the coverage data on the target.
flush_coverage

# Run one "group" of gtest tests.
run_test $test_name

# Choose an archive name.
archive_name=$test_name

# Create GCDA bundle.
retrieve_bundle $DATA_DIR/tmp/$archive_name.tar.gz
