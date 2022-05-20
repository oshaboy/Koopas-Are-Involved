all:useless
lex.yy.o: useless_lexer.l y.tab.h
	/usr/bin/lex useless_lexer.l
	gcc -O3 -c lex.yy.c
y.tab.o: y.tab.c 
	gcc -O3 -c y.tab.c
y.tab.h: y.tab.c
y.tab.c: useless_parser.y
	yacc -d useless_parser.y
useless_int.s: y.tab.h useless_int.c
	gcc -O3 -S useless_int.c
useless_int.o: useless_int.s
	gcc -c useless_int.s
useless: y.tab.o lex.yy.o useless_int.o
	gcc -O3 -o useless y.tab.o lex.yy.o useless_int.o -lfl 
clean: 
	rm -f lex.yy.c lex.yy.o y.tab.c y.tab.h y.tab.o useless_int.o useless useless_int.s