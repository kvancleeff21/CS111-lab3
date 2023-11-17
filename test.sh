#!/bin/sh

counter=1
make
while [ $counter -le 20 ]
do
./hash-table-tester -s 100000
((counter++))
done
echo All done
make clean