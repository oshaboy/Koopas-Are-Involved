%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "useless.h"
#include "y.tab.h"
extern YYSTYPE yylval;
variable * variables=NULL;
int last_var_index=0;
int get_var_index(char * identifier);
%}
%%
print {
return PRINT;
}
read {
return READ;
}
while {
return WHILE;
}
goto {
return GOTO;
}
nop {
return NOP;
}
[[:digit:]]+ {
	yylval.terminal_token=atoi(yytext);
	return IMMEDIATE;
	}
[[:alpha:]][[:alnum:]]{0,39} {
	int index=get_var_index(yytext);
	if (index<0){
		if (last_var_index%16==0){
			variables=realloc(variables, (last_var_index+1)*sizeof(variable)*16);
		}
		strcpy(variables[last_var_index].identifier,yytext);
		variables[last_var_index].assigned=variables[last_var_index].used=get_varvalue(last_var_index)=0;
		yylval.terminal_token=last_var_index++;
		
	} else {
		yylval.terminal_token=index;
	}
	
	return VARIABLE;
}
[ \t]+ {
	return WHITESPACE;
	
	}
\n {
	return NEWLINE;
}
[-+*/] {
	yylval.terminal_token=*yytext;
	return OPERATION;
	}
\) {
return CLOSE;
}
\( {
return OPEN;
}	
:= {
return ASSIGN;
}
\? {
return THEN;
}
: {
return ELSE;
}

%%
int get_var_index(char * identifier){
	int index=-1;
	for (int i=0; i<last_var_index; i++){
		if (strncmp(variables[i].identifier, identifier,IDENTIFIER_LENGTH)==0){
			index=i;
			break;
		}	
	}
	return index;
}
int yywrap(){
	return 1;
}