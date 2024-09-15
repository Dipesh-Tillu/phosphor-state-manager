#!/bin/bash
# setup-ssh.sh - setup password-less SSH to target.

# Remove any linger SSH fingerprint from a previous target/emulator.
ssh-keygen -f "/home/ricks/.ssh/known_hosts" -R "[localhost]:2222"

# Copy the public key to the target. User must supply password.
cat ~/.ssh/id_ed25519.pub | ssh -p 2222 root@localhost 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'

# Test password-less SSH.
echo "Testing 'pwd' on target"
ssh -p 2222 root@localhost pwd
