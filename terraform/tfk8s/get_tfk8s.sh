#!/bin/bash
sudo apt-get install golang -y
go install github.com/jrhouston/tfk8s@latest
echo; echo
echo '   Add the go binary path to your PATH variable in bashrc, for example, run:'
echo '     echo "export PATH=\$PATH:$(go env GOPATH)/bin" >> ~/.bashrc"
