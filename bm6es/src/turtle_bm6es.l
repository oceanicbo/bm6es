
%{
#include "symtab.h"
#include "token.h"
%}

%%

\/\/.*          ;
[[:space:]]     ;

GO              return GO;
TURN            return TURN; 
VAR             return VAR;
JUMP            return JUMP;
FOR             return FOR;
STEP            return STEP;
TO              return TO;
DO              return DO;
BEGIN           return COPEN;
END             return CCLOSE;
CONST		    return CONST;
ARRAY		    return ARRAY;
CASE		    return CASE;
SWITCH		    return SWITCH;
IF		    return IF;
ELSE		    return ELSE;
GOTO		    return GOTO;
NIL		    return NIL;
NOT		    return NOT;
PROCEDURE	    return PROCEDURE;
PROGRAM	    return PROGRAM;
REPEAT		    return REPEAT;
TYPE		    return TYPE;
WHILE		    return WHILE;
THEN		    return THEN;


sin             return SIN;
cos             return COS;
sqrt            return SQRT;

;               return SEMICOLON;
\+              return PLUS;
-               return MINUS;
\*              return TIMES;
\/              return DIV;
\(              return OPEN;
\)              return CLOSE;
=               return ASSIGN;
,		    return COMMA;
:		    return COLON;
==		    return EQUAL;
\[		    return BRACKETLEFT;
\]		    return BRACKETRIGHT;
\{		    return BRACELEFT;
\}		    return BRACERIGHT;
\>		    return GREATERTHAN;
\<		    return LESSTHAN;
\>=		    return NOLESSTHAN;
\<=		    return NOGREATERTHAN;
\!=		    return NOTEQUAL;
\?		    return QUESTIONMARK;
\_		    return UNDERLINE;

[a-z]+          { yylval.n = lookup(yytext); 
                  if (yylval.n==NULL)
		    yylval.n = insert(yytext);
                  return ID;
		}
    
[0-9]+\.[0-9]+  yylval.d = atof(yytext);  return FLOAT;
[0-9]+          yylval.i = atoi(yytext);  return NUMBER;

.               fprintf(stderr,"Unexpected character %c (%2X)\n",yytext[0],yytext[0]);

%%
