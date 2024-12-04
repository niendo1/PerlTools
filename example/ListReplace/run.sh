#!/usr/bin/sh

#mkdir tmp
#cat liste.csv | ../../src/ListReplace.pl -c template.txt -o tmp/@Kessel@.txt

cat liste.csv | ../../src/ListReplace.pl -c template.txt -h header.txt -f "'@AS@' eq 'AS07'"
