
all: turtle eins.ps

eins.ps: eins.tlt turtle
	./turtle < eins.tlt > eins.ps

lex.yy.o:  lex.yy.c turtle.tab.h symtab.h
	gcc -c lex.yy.c

lex.yy.c: turtle.l
	flex turtle.l
	
turtle.tab.h: turtle-bm6es.y
	bison -v -d turtle-bm6es.y
	
turtle.tab.c: turtle-bm6es.y
	bison -v -d turtle-bm6es.y
	
turtle.tab.o: turtle.tab.c symtab.h
	gcc -c turtle-bm6es.tab.c

turtle: turtle.tab.o lex.yy.o symtab.c
	gcc lex.yy.o turtle-bm6es.tab.o symtab.c -ll -o turtle

clean:
	rm -f turtle lex.* turtle.tab.* *.o eins.ps

