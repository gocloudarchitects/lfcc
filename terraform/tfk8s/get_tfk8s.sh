#!/bin/bash
sudo apt-get install golang -y
go install github.com/jrhouston/tfk8s@latest
echo; echo
echo '   Add to ~/.bashrc:'
echo '      export PATH=$PATH:$(go env GOPATH)/bin'
echo
