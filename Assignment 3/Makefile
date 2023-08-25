#declare variable
CC=gcc
FC=flex

CFLAG=-c -Wall
CFLAGW=-Wall

#Commmands
output.txt: a.out A3_40.nc
	./a.out < A3_40.nc > output.txt

a.out: lex.yy.c A3_40.o 
	$(CC) $(CFLAGW) A3_40.o

lex.yy.c: A3_40.l
	$(FC) A3_40.l

A3_40.o: A3_40.c
	$(CC) $(CFLAG) A3_40.c -o A3_40.o

clean:
	rm output.txt lex.yy.c a.out *.o