#!/bin/bash
# run-mmx.sh - run the matrix mapper from the Orion project

. ./coverage-common.sh

#"$ORION_DIR/mmx/oriccpp-mmx" "$@"
strace -f -o matrix-mapper.out "$ORION_DIR/mmx/oriccpp-mmx" "$@"
