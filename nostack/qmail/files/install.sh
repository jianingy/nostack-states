#!/bin/bash

# filename   : install.sh
# created at : 2014-09-02 15:46:57
# author     : Jianing Yang <jianingy.yang@gmail.com>

version=1.06

cd /usr/local/src/netqmail-$version || exit 111
make setup check || exit 111
./config || exit 111
