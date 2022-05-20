%{
#include <stdio.h>
#include <stdlib.h>
#include "useless.h"
int yylex();
int yyerror(const char * format);
int op (int a, int op, int b);
AST * create_AST_node(AST * left, AST * right, int token, int value );
AST the_tree;
extern FILE * yyin;
%}

%token<terminal_token> FIRST_NODE IMMEDIATE VARIABLE OPERATION WHITESPACE OPEN CLOSE ASSIGN PRINT THEN ELSE WHILE READ GOTO INSTRUCTION IF NEWLINE NOP
%type<ast_node_value> program print variable read assignment rvalue goto loop anyvalue instruction nop 
%type<integer_value> rvalue_raw 
%%

initialize:
	program {
		the_tree.right=$1;
	};
program:
	instruction {
		$$=create_AST_node($1, NULL, INSTRUCTION,-1);
	} |
	instruction NEWLINE program {
		$$=create_AST_node($1, $3, INSTRUCTION,-1);
	} ;


instruction:
	{$$=create_AST_node(NULL, NULL, NOP, 0);} | 
	assignment |
	print | 
	loop | 
	read | 
	goto |
	nop 
	;
	
	
anyvalue: 
	rvalue|
	variable;	

nop:
	NOP {
		$$=create_AST_node(NULL, NULL, NOP, 0);
	}
print:
	PRINT WHITESPACE anyvalue {
		$$=create_AST_node(NULL, $3 , PRINT, 0);
	};
variable:
	VARIABLE {
		$$=create_AST_node(NULL, NULL, VARIABLE, $1);
		variables[$1].used++;
		if (variables[$1].used>2){
			UWU;
			exit(2);
		}
	};
read:
	READ WHITESPACE variable {
		$$=create_AST_node( NULL, $3, READ, 0);
	};
assignment: variable ASSIGN rvalue {
	
	$$=create_AST_node( $1, $3, ASSIGN,0 );
	if (variables[$1->value].assigned){
		UWU;
		exit(2);
	}
	variables[$1->value].assigned=1;
	
};
rvalue:
	rvalue_raw {$$=create_AST_node(NULL, NULL, IMMEDIATE, $1);}|
	OPEN anyvalue THEN rvalue ELSE rvalue CLOSE {

		$$=create_AST_node($4, $6, IF, 0);
		$$->extra=$2;
	};
rvalue_raw:
	IMMEDIATE {
		$$=$1;
	}| 
	OPEN rvalue_raw OPERATION rvalue_raw CLOSE {
		$$=op($2,$3,$4);
	}
;
goto:
	GOTO WHITESPACE anyvalue {
		$$=create_AST_node(NULL, $3, GOTO, 0);
	};
loop: 
	WHILE WHITESPACE anyvalue WHITESPACE instruction {
	
		$$=create_AST_node($3, $5, WHILE, 0);
	};
%%

int op (int a, int op, int b){
	switch (op){
		case '+':
			return a+b;
		case '-': 
			return a-b;
		case '*':
			return a*b;
		case '/':
			return a/b;
		default:
			exit(2);
		
	}
}

int yyerror(const char * format){
	UWU;
	exit(1);
}
AST * create_AST_node( AST * left, AST * right, int token, int value ){
	AST * result=malloc(sizeof(AST));
	*result=(AST){.left=left,.right=right,.token=token,.value=value,.extra=NULL};
	return result;
;
}

void number(){
	int count=1;
	AST * cur_node=the_tree.right;
	while (cur_node){
		cur_node->value=count++;
		cur_node=cur_node->right;
	}
}
void create_AST(FILE * in){
	the_tree=(AST){.left=NULL, .right=NULL, .token=FIRST_NODE, .value=0};
	yyin=in;

	yyparse();
	number();
}
