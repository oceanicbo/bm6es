
/* Tokens.  */
#define GO 258
#define TURN 259
#define VAR 260
#define JUMP 261
#define FOR 262
#define STEP 263
#define TO 264
#define DO 265
#define COPEN 266
#define CCLOSE 267

#define CONST 268
#define ARRAY	 269
#define CASE	 270
#define SWITCH 271
#define IF 272
#define ELSE 273
#define GOTO	 274
#define NIL 275
#define NOT 276
#define PROCEDURE 277
#define PROGRAM 278
#define REPEAT 279
#define TYPE	 280
#define WHILE 281
#define THEN 282


#define SIN 283
#define COS 284
#define SQRT 285
#define FLOAT 286
#define ID 287
#define NUMBER 288
#define SEMICOLON 289
#define PLUS 290
#define MINUS 291
#define TIMES 292
#define DIV 293
#define OPEN 294
#define CLOSE 295
#define ASSIGN 296
#define EQ 299
#define BRACKETL 300
#define BRACKETR 301
#define BRACEL 302
#define BRACER 303
#define GT 304
#define LT 305
#define GE 306
#define LE 307
#define NE 308
#define QM 309
#define UL 310
#define PARAM 311
#define CALL 312


typedef union YYSTYPE
{ int i; node *n; double d;}
        YYSTYPE;
YYSTYPE yylval;

