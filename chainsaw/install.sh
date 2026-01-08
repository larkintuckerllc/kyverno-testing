#!/bin/bash -xeu
RELEASE=v0.2.14
OS="$(uname | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
CHAINSAW="chainsaw_${OS}_${ARCH}"

curl -fSLO "https://github.com/kyverno/chainsaw/releases/download/${RELEASE}/chainsaw_${OS}_${ARCH}.tar.gz" &&
tar zxvf "${CHAINSAW}.tar.gz" &&
chmod +x chainsaw &&
sudo mv chainsaw /usr/local/bin/ && rm LICENSE chainsaw_linux_amd64.tar.gz
