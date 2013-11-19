#!/bin/bash
shopt -s globstar
for file in pp4-tests/*.decaf
do
  echo "do something with $file"
  testoutput="${file/.decaf/.testout}"
  ./dcc < $file >& $testoutput
  refoutput="${file/.decaf/.out}"
  diff -b $refoutput $testoutput
done
