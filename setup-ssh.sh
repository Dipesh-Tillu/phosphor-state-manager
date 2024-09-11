# Copy the public key to the target. User must supply password.
cat ~/.ssh/id_ed25519.pub | ssh -p 2222 root@localhost 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
