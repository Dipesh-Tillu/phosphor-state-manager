# make-coverage-archive.sh - make coverage archive by merging compile and runtime converage artifacts

# Configure the pathnames and tests.
. ./coverage-common.sh

# Choose the bundle folder.
bundle_folder="$DATA_DIR/bundle"

# Clear the entire bundle folder.
rm -rf "$bundle_folder" && mkdir -p "$bundle_folder"

for test_name in $TESTS; do

	# Choose the GCDA archive input file.
	gcda_archive="$DATA_DIR/work/$test_name.tar.gz"

	# Choose test suite destination folder.
	suite_dir="$bundle_folder/$test_name"

	# Fail if the required test files are not present.
	if [ ! -f "$gcda_archive" ]; then
		echo "Missing test suite GCDA bundle, expected in work folder $test_name.tar.gz" >&2
		exit 1
	fi
done

for test_name in $TESTS; do

	# Show banner for this test.
	echo
	echo "Merging coverage data for test: '$test_name'"
	echo

	# Choose the GCDA archive input file.
	gcda_archive="$DATA_DIR/work/$test_name.tar.gz"

	# Choose test suite destination folder.
	suite_dir="$bundle_folder/$test_name"

	# Clear and recreate test suite directory.
	rm -rf "$suite_dir" && mkdir -p "$suite_dir"

	# Unpack runtime coverage artifacts collected during testing.
	tar xvfz - -C "$suite_dir" <"$gcda_archive"

	# Copy the corresponding GCNO file for each GCDA file.
	(cd "$suite_dir" && find -name '*.gcda') |
		sed 's/\.gcda$/.gcno/' |
		xargs -ti cp -v "$OBJECT_DIR/{}" "$suite_dir/{}"

	echo "Deleting the now processed GCDA file."
	rm -f "$gcda_archive"
done

# Clear out the work folder to tidy up.
rm -rf "$DATA_DIR/work" && mkdir -p "$DATA_DIR/work"

# Choose the coverage data bundle archive.
archive_file="$DATA_DIR/bundle.tar.gz"

# Tarball up the archive.
(cd "$bundle_folder" && tar cvfz "$archive_file" .)
