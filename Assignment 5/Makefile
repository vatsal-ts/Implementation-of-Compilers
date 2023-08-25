BASE=A5_40
DIR=./test-outputs

a.out: lex.yy.o $(BASE).tab.o $(BASE)_translator.o
	g++ lex.yy.o $(BASE).tab.o $(BASE)_translator.o -lfl

$(BASE)_translator.o: $(BASE)_translator.h $(BASE)_translator.cpp
	g++ -c $(BASE)_translator.h
	g++ -c $(BASE)_translator.cpp

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

$(BASE).tab.o: $(BASE).tab.c
	g++ -c $(BASE).tab.c

lex.yy.c: $(BASE).l $(BASE).tab.h $(BASE)_translator.h
	flex $(BASE).l

$(BASE).tab.c: $(BASE).y
	bison -dtv $(BASE).y

$(BASE).tab.h: $(BASE).y
	bison -dtv $(BASE).y

$(BASE).c:
	touch $(BASE).c

test: a.out
	mkdir -p $(DIR)
	@echo "\nTest inputs fetched and run from test-inputs directory.\n"
	./a.out < test-inputs/$(BASE)_test6.nc > test-outputs/$(BASE)_quads6.out
	./a.out < test-inputs/$(BASE)_test5.nc > test-outputs/$(BASE)_quads5.out
	./a.out < test-inputs/$(BASE)_test4.nc > test-outputs/$(BASE)_quads4.out
	./a.out < test-inputs/$(BASE)_test3.nc > test-outputs/$(BASE)_quads3.out
	./a.out < test-inputs/$(BASE)_test2.nc > test-outputs/$(BASE)_quads2.out
	./a.out < test-inputs/$(BASE)_test1.nc > test-outputs/$(BASE)_quads1.out

	@echo "\nTest outputs generated and stored in to test-outputs directory.\n"

clean:
	rm -f lex.yy.c *.tab.c *.tab.h *.output *.o a.out *.gch test-outputs/*_quads*[^preserve].out
