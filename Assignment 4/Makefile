a.out: lex.yy.o y.tab.o A4_40.o
	gcc lex.yy.o y.tab.o A4_40.o -lfl

A4_40.o: A4_40.c
	gcc -c A4_40.c

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

y.tab.o: y.tab.c
	gcc -c y.tab.c

lex.yy.c: A4_40.l y.tab.h
	flex A4_40.l

y.tab.c: A4_40.y
	yacc -dtv A4_40.y -Wnone -Wno-empty-rule

y.tab.h: A4_40.y
	yacc -dtv A4_40.y -Wnone -Wno-empty-rule

clean:
	rm -f lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o A4_40.o y.output a.out output_A4_40.txt

test: 
	./a.out 1 < A4_40.nc

test_file: 
	./a.out 0 < A4_40.nc > output_A4_40.txt
A4_40.c:
	touch A4_40.c
