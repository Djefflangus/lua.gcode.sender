#!/bin/sh

export DIR=$PWD

echo "  --> lua-5.3"
cd $DIR/lua-5.3.3
make linux
make install

echo "  --> luafilesystem"
cd $DIR/luafilesystem
make
make install

echo "  --> lua-perifery"
cd $DIR/lua-periphery
./bs.sh

echo "  --> gcode parser"
cd $DIR/gcode-parser
./bld.sh

echo "  --> tekUI"
cd $DIR/tekUI
make all
make install

echo "  --> main src"
cd $DIR/src
./bs.sh

cd $DIR/bld
