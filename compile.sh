#!/bin/bash

while true;
do
while read j;
do
   echo "detected change, recompiling"
   dmd main.d decompile.d
   echo "running decompiler"
   ./main mainServer.cs.dso
done < <(inotifywait -q -e modify ./decompile.d)
done
