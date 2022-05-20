#include <stdlib.h>
#include <stdio.h>
#include "useless.h"
#include "y.tab.h"
void run();
AST * run_node(AST * node);
int get_rvalue(AST * node);
int get_anyvalue(AST * node);
int main(int argc, char * argv[]){

    FILE * input;
	if (argc>=2){
		input=fopen(argv[1],"rt");
	} else {
        UWU;
        exit(3);
    }
    create_AST(input);
    run(&the_tree);
    return 0;
    
}
//int line_count=1;
AST * cur_instruction;
void run(){
    AST * cur_node=&the_tree;
    while (cur_node!=NULL){
        cur_node=run_node(cur_node);
    }
}
int get_rvalue(AST * node){
    if (node->token==IF){
        return get_anyvalue(node->extra)?get_rvalue(node->left):get_rvalue(node->right);
    } else {
        return node->value;
    }
}
int get_anyvalue(AST * node){
    if (node->token==VARIABLE){
        return get_varvalue(node->value);
    } else {
        return get_rvalue(node);
    }
}
AST * run_node(AST * node){
        if (node==NULL){
            fprintf(stderr, "Internal Error, run_node NULL\n");
            exit(255);
        }
        switch (node->token){
            case FIRST_NODE:
                return node->right;
            break;
            case INSTRUCTION:
            {
                cur_instruction=node;
                AST *  possible_next=run_node(node->left);
                //line_count++;
                return possible_next?possible_next:node->right;
            }
            break;
            case ASSIGN:
                get_varvalue(node->left->value)=get_rvalue(node->right);
            break;
            case PRINT:
                printf("%d\n",get_anyvalue(node->right));
            break;
            case READ:
            {
                int c=getchar();
                /* Check for EOF ;) */
                if (!c){ 
                    c=1<<(sizeof(int)*8-1);
                }
                get_varvalue(node->right->value)=c;
            }
            break;
            case WHILE:
            {
                if(get_anyvalue(node->left)) {
                    AST * possible_next=run_node(node->right); 
                    /* This might be a GOTO statement so I have to check that it didn't try to pass the next instruction*/
                    return possible_next?possible_next:node;


                }
            }
            break;
            case GOTO:
            {
                int line=get_anyvalue(node->right);
                AST * instruction=cur_instruction;
                if (line>instruction->value){
                    while (instruction&&instruction->value!=line){
                        //printf("%d\n",instruction->value);
                        instruction=instruction->right;
                    }
                    return instruction;

                }
                return NULL;
            }
            break;
            case NOP:
            break;

        }
        return NULL;
}