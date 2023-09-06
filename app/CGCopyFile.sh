#!/bin/bash
# first= 33 .. last=64

if [ $# -ne 4 ]
then
  echo "Usage $0 firstvm(33) lastvm(64) file_src file_dst"
  exit 1
fi

firstvm=$1
lastvm=$2
srcFile=$3
dstFile=$4
cp /dev/null log_copy.txt
for ((n=$firstvm;n<=$lastvm;n++))
do
	#(sshpass -p supercognet scp $srcFile cognet@vmCGClient$n:$dstFile && echo vmCGClient$n) &
	(sshpass -p supercognet scp $srcFile cognet@vmCGClient$n:$dstFile && echo vmCGClient$n) >> log_copy.txt &
done
echo "waiting for termination .."
wait

for ((n=$firstvm;n<=$lastvm;n++))
do
  if ! grep "vmCGClient$n" log_copy.txt >/dev/null
  then
	echo "vm $n NOK"
  fi
done
