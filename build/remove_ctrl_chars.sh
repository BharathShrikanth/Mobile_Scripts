#!/bin/bash
for f in $(find . -name "*.sh")
do
cat $f | col -b > $f.bak
mv $f.bak $f
done