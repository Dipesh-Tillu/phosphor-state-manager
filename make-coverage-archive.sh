# make-coverage-archive.sh - merge compile time converage artifacts with runtime coverage artifacts

# Configure the pathnames and tests.
source setup

for $test_name in $TESTS; do

	# Show banner for this test.
	echo
	echo "Merging coverage data for test: '$testname'"
done
