# format-patch.sh - invoke git to create a single patch for all changes.
git format-patch devtool-base..HEAD --stdout > phosphor-state-manager-diffs.txt
