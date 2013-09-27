
%{
#include <stdio.h>
#include "symtab.h"
%}

%union { int i; node *n; double d;}

%token GO TURN VAR JUMP
%token FOR STEP TO DO
%token IF ELSE
%token WHILE
%token PROCEDURE CALL
%token GT LT GE LE NE EQ
%token COPEN CCLOSE
%token SIN COS SQRT
%token <d> FLOAT
%token <n> ID               
%token <i> NUMBER       
%token SEMICOLON PLUS MINUS TIMES DIV OPEN CLOSE ASSIGN PARAM
%token BRACEL BRACER

%type <n> decl
%type <n> decllist

%%
program: head decllist stmtlist tail;

head: { printf("%%!PS Adobe\n"
               "\n"
	       "newpath\n0 0 moveto\n"
	       );
      };

tail: { printf("closepath\nstroke\n"); };

decllist: ;
decllist: decllist decl;

decl: VAR ID SEMICOLON { printf("/tlt%s 0 def\n",$2->symbol);} ;


stmtlist: ;
stmtlist: stmtlist stmt ;

stmt: ID ASSIGN expr SEMICOLON {printf("/tlt%s exch store\n",$1->symbol);} ;
stmt: GO expr SEMICOLON {printf("0 rlineto\n");};
stmt: JUMP expr SEMICOLON {printf("0 rmoveto\n");};
stmt: TURN expr SEMICOLON {printf("rotate\n");};



stmt: FOR ID ASSIGN expr 
          STEP expr
	  TO expr
	  DO {printf("{ /tlt%s exch store\n",$2->symbol);} 
	     stmt {printf("} for\n");};


uniq_L: BRACEL { printf("{ ");};

stmt: IF judg uniq_L
        stmtlist BRACER { printf(" }");} 
      ELSE BRACEL { printf("{ ");} 
        stmtlist BRACER { printf("} ifelse\n");};

stmt: IF judg uniq_L
        stmtlist BRACER { printf("} if\n");};

stmt: WHILE {printf("{ ");}
        judg BRACEL { printf("{} {exit} ifelse\n");} 
      stmtlist BRACER { printf("} loop\n");};

stmt: PROCEDURE ID BRACEL {printf("\/proc%s {", $2->symbol);}
      stmtlist BRACER { printf("} def\n");};

stmt: CALL ID params SEMICOLON { printf("proc%s\n", $2->symbol);};


stmt: COPEN stmtlist CCLOSE;	 

params: ;
params: params param;
param: factor;

cond: expr GT expr { printf("gt\n");};
cond: expr LT expr { printf("lt\n");};
cond: expr GE expr { printf("ge\n");};
cond: expr LE expr { printf("le\n");};
cond: expr NE expr { printf("ne\n");};
cond: expr EQ expr { printf("eq\n");};

judg: OPEN cond CLOSE {printf("");}; 

expr: expr PLUS term { printf("add ");};
expr: expr MINUS term { printf("sub ");};
expr: term;

term: term TIMES factor { printf("mul ");};
term: term DIV factor { printf("div ");};
term: factor;

factor: MINUS atomic { printf("neg ");};
factor: PLUS atomic;
factor: SIN factor { printf("sin ");};
factor: COS factor { printf("cos ");};
factor: SQRT factor { printf("sqrt ");};
factor: atomic;



atomic: OPEN expr CLOSE;
atomic: NUMBER {printf("%d ",$1);};
atomic: FLOAT {printf("%f ",$1);};
atomic: ID {printf("tlt%s ", $1->symbol);};
atomic: PARAM;

%%
int yyerror(char *msg)
{  fprintf(stderr,"Error: %s\n",msg);
   return 0;
}

int main(void)
{   yyparse();
    return 0;
}

