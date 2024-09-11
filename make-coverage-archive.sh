# make-coverage-archive.sh - make coverage archive by merging compile and runtime converage artifacts

# Configure the pathnames and tests.
. ./coverage-common.sh

# Clear the entire bundle folder.
rm -rf "$DATA_DIR/bundle" && mkdir -p "$DATA_DIR/bundle"

for test_name in $TESTS; do

	# Show banner for this test.
	echo
	echo "Merging coverage data for test: '$test_name'"
	echo

	# Choose destination.
	dest_dir="$DATA_DIR/bundle/$test_name"

	# Clear and recreate destination directory."
	rm -rf "$dest_dir" && mkdir -p "$dest_dir"

	# Unpack runtime coverage artifacts collected during testing.
	tar xvfz - -C "$dest_dir" <"$DATA_DIR/work/$test_name.tar.gz"

	# Copy the corresponding GCNO file for each GCDA file.
	(cd "$dest_dir" && find -name '*.gcda') |
		sed 's/\.gcda$/.gcno/' |
		xargs -ti cp -v "$OBJECT_DIR/{}" "$dest_dir/{}"
done
