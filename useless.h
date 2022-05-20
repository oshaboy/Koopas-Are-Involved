#ifndef USELESS_H
#define USELESS_H
#define IDENTIFIER_LENGTH 40
#include <stdio.h>
typedef struct variable_t{
	char identifier[IDENTIFIER_LENGTH+1];
	int value;
	unsigned short assigned:1;
	unsigned short used:2;
} variable;
extern variable * variables;
struct AST_t;
typedef struct AST_t AST;
typedef union {
	int integer_value;
	int terminal_token;
	AST * ast_node_value;
} YYSTYPE;
struct AST_t {
	struct AST_t * left;
	struct AST_t * right;
	struct AST_t * extra;
	int token;
	int value;
};
#define get_varvalue(x) variables[(x)].value
extern AST the_tree;
void create_AST(FILE * in);
int get_var_index(char * identifier);
#define UWU fprintf(stderr, "uwu\n")
#endif
