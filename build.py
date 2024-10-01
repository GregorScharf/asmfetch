import os
import sys


if (sys.argv[1] =="asm"):
    os.system("as main.s -o main.o -g")
    os.system("gcc main.o -o main -nostdlib --static")
if (sys.argv[1] =="c"):
    os.system("gcc test.c -o test -g -lm")
if(sys.argv[1] =="test"):
    os.system("as test.s -o test.o -g")
    os.system("gcc test.o -o test -nostdlib --static")
