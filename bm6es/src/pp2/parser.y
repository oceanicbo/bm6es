/* File: parser.y
   Bo Man --> bm6es
 * --------------
 * Yacc input file to generate the parser for the compiler.
 *
 * pp2: your job is to write a parser that will construct the parse tree
 *      and if no parse errors were found, print it.  The parser should 
 *      accept the language as described in specification, and as augmented 
 *      in the pp2 handout.
 */

%{

/* Just like lex, the text within this first region delimited by %{ and %}
 * is assumed to be C/C++ code and will be copied verbatim to the y.tab.c
 * file ahead of the definitions of the yyparse() function. Add other header
 * file inclusions or C++ variable declarations/prototypes that are needed
 * by your code here.
 */
#include "scanner.h" // for yylex
#include "parser.h"
#include "errors.h"

void yyerror(const char *msg); // standard error-handling routine

%}

/* The section before the first %% is the Definitions section of the yacc
 * input file. Here is where you declare tokens and types, add precedence
 * and associativity options, and so on.
 */
 
/* yylval 
 * ------
 * Here we define the type of the yylval global variable that is used by
 * the scanner to store attibute information about the token just scanned
 * and thus communicate that information to the parser. 
 *
 * pp2: You will need to add new fields to this union as you add different 
 *      attributes to your non-terminal symbols.
 */

%union {
    int integerConstant;
    bool boolConstant;
    char *stringConstant;
    double doubleConstant;
    char identifier[MaxIdentLen+1]; // +1 for terminating null
    Decl *decl;
    List<Decl*> *declList;
    VarDecl *varDecl;
    FnDecl *fnDecl;
    ClassDecl *classDecl;
    InterfaceDecl *interfaceDecl;
    List<VarDecl*> *varList;
    Type *type;
    StmtBlock *stmtBlock;
    List<Identifier*> *identifierList;
    NamedType *namedType;
    List<NamedType*> *namedTypeList;
    List<Stmt*> *stmtList;
    Stmt *stmt;
    Expr *expr;
    List<Expr*> *exprList;
    IfStmt *ifStmt;
    WhileStmt *whileStmt;
    ForStmt *forStmt;
    ReturnStmt *returnStmt;
    Case *caseStmt;
    List<Case*> *caseList;
    Default *defaultStmt;
    SwitchStmt *switchStmt;
    BreakStmt *breakStmt;
    PrintStmt *printStmt;
    LValue *lvalue;
}



/* Tokens
 * ------
 * Here we tell yacc about all the token types that we are using.
 * Yacc will assign unique numbers to these and export the #define
 * in the generated y.tab.h header file.
 */
%token   T_Void T_Bool T_Int T_Double T_String T_Class 
%token   T_LessEqual T_GreaterEqual T_Equal T_NotEqual T_Dims 
%token   T_And T_Or T_Null T_Extends T_This T_Interface T_Implements
%token   T_While T_For T_If T_Else T_Return T_Break
%token	 T_Switch T_Case T_Default T_PostfixAdd T_PostfixMinus
%token   T_New T_NewArray T_Print T_ReadInteger T_ReadLine

%token   <identifier> T_Identifier
%token   <stringConstant> T_StringConstant
%token   <integerConstant> T_IntConstant
%token   <doubleConstant> T_DoubleConstant
%token   <boolConstant> T_BoolConstant


/* Non-terminal types
 * ------------------
 * In order for yacc to assign/access the correct field of $$, $1, we
 * must to declare which field is appropriate for the non-terminal.
 * As an example, this first type declaration establishes that the DeclList
 * non-terminal uses the field named "declList" in the yylval union. This
 * means that when we are setting $$ for a reduction for DeclList ore reading
 * $n which corresponds to a DeclList nonterminal we are accessing the field
 * of the union named "declList" which is of type List<Decl*>.
 * pp2: You'll need to add many of these of your own.
 */

//when tested, use"//"

%type <declList>  DeclList //
%type <decl>      Decl //
%type <varDecl>   VarDecl //
%type <fnDecl>    FnDecl //
%type <classDecl> ClassDecl //
%type <interfaceDecl> InterfaceDecl //
%type <varDecl>       Variable //
%type <type>      Type //
%type <varList>   Formals //
%type <stmtBlock> StmtBlock //
%type <varList>   FormalList //
%type <identifierList> CID //
%type <namedType> CExtends //
%type <namedTypeList> CImpls //
%type <declList>  CFields //
%type <decl>      Field //
%type <declList>  IPrototype //
%type <decl>      Prototype //
%type <stmtList>  StmtList //
%type <stmt>      Stmt //
%type <varList>   VarDecls //
%type <expr>      ExprO //
%type <expr>      Expr //
%type <stmt>      Elses //
%type <ifStmt>    IfStmt //
%type <whileStmt> WhileStmt //
%type <forStmt>   ForStmt //
%type <returnStmt> ReturnStmt //
%type <breakStmt> BreakStmt //
%type <exprList>  Exprs //
%type <printStmt> PrintStmt //
%type <caseStmt>  Case //
%type <caseList>  CaseS //
%type <defaultStmt> Default //
%type <defaultStmt> DefaultO //
%type <switchStmt>  SwitchStmt //
%type <stmtList>  StmtS //
%type <lvalue>    LValue //
%type <exprList>  Actuals //
%type <expr>      Call //
%type <expr>      Constant //


/* Associate the 'else' porition of if statements with the nearest (innermost)
 * 'if' porition.
 */

%nonassoc NoElse
%nonassoc T_Else

%right '='
%left  T_Or
%left  T_And
%left  T_Equal
%left  T_NotEqual
%left  '<'
%left  T_LessEqual
%left  '>'
%left  T_GreaterEqual
%left  '-'
%left  '+'
%left  '/'
%left  '%'
%left  '*'
%right '!'
%left  '.'
%left  '['
%left  ']'
%left  T_Dims
%left  T_PosfixAdd
%left  T_PosfixMinus

%%

/* Rules
 * -----
 * All productions and actions should be placed between the start and stop
 * %% markers which delimit the Rules section.
	 
 */

//Line 1
Program   :    DeclList            { 
                                      @1; 
                                      /* pp2: The @1 is needed to convince 
                                       * yacc to set up yylloc. You can remove 
                                       * it once you have other uses of @n*/
                                      Program *program = new Program($1);
                                      // if no errors, advance to next phase
                                      if (ReportError::NumErrors() == 0) 
                                          program->Print(0);
                                    }
          ;

DeclList  :    DeclList Decl        { ($$=$1)->Append($2); }
          |    Decl                 { ($$ = new List<Decl*>)->Append($1); };

//Line 2
Decl      :    VarDecl              { $$=$1; }
          |    FnDecl               { $$=$1; }
	  |    ClassDecl            { $$=$1; }
          |    InterfaceDecl        { $$=$1; }
	  ;

//Line 3
VarDecl   :    Variable ';'         { $$=$1; }
	  ; 

//Line 4
Variable  :   Type T_Identifier     { 	$$ = new VarDecl(new Identifier(@2, $2), $1); }
	  ;

//Line 5
Type      :    T_Int                { 	$$ = Type::intType; }
          |    T_Bool               { 	$$ = Type::boolType; }
          |    T_String             { 	$$ = Type::stringType; }
          |    T_Double             { 	$$ = Type::doubleType; }
          |    T_Identifier         { 	$$ = new NamedType(new Identifier(@1,$1)); }
          |    Type T_Dims          { 	$$ = new ArrayType(Join(@1, @2), $1); }
	  ;

//Line 6 & 7
FnDecl	  :    Type T_Identifier '(' Formals ')' StmtBlock 
                                    {	$$ = new FnDecl(new Identifier(@2, $2), $1, $4); 
				      	$$->SetFunctionBody($6); 
				    }
          |    T_Void T_Identifier '(' Formals ')' StmtBlock
                                    { 	$$ = new FnDecl(new Identifier(@2, $2), Type::voidType, $4); 
				      	$$->SetFunctionBody($6); 
				    }
	  ;

//Line 8
Formals   :    FormalList           { 	$$ = $1; }
          |    /* empty */          { 	$$ = new List<VarDecl*>; }
	  ;

FormalList:    FormalList ',' Variable  
                                    { 	($$=$1)->Append($3); }
          |    Variable             { 	($$ = new List<VarDecl*>)->Append($1); }
	  ;

//Line 9
ClassDecl :    T_Class T_Identifier CExtends CImpls '{' CFields '}' 
                                    { 	$$ = new ClassDecl(new Identifier(@2, $2), $3, $4, $6); }
          ;

CID 	  :    CID ',' T_Identifier { 	($$=$1)->Append(new Identifier(@3, $3)); }
          |    T_Identifier         { 	($$ = new List<Identifier*>)->Append(new Identifier(@1, $1)); }
          ;

CExtends  :    T_Extends T_Identifier 
				    { 	$$ = new NamedType(new Identifier(@2, $2)); }
          |                         { 	$$ = NULL; }
          ;

CImpls    :    T_Implements CID     { 	$$ = new List<NamedType*>;
                                      	for (int i = 0; i < $2->NumElements(); i++ )
                                        	$$->Append(new NamedType($2->Nth(i)));
                                    }
          |                         { 	$$ = new List<NamedType*>; }
          ;

CFields   :    CFields Field        { 	($$ = $1)->Append($2); }
          |                         { 	$$ = new List<Decl*>; }
          ;

//Line 10
Field     :    VarDecl              { 	$$ = $1; }
          |    FnDecl               { 	$$ = $1; }
          ;

//Line 11
IPrototype :   IPrototype Prototype { 	($$ = $1)->Append($2); }
          |                         { 	$$ = new List<Decl*>; }
          ;

InterfaceDecl : T_Interface T_Identifier '{' IPrototype '}' 
                                    { 	$$  = new InterfaceDecl(new Identifier(@2, $2), $4); }
          ;

//Line 12
Prototype :    Type T_Identifier '(' Formals ')' ';' 
				    { 	Identifier *id = new Identifier(@2, $2);
                                      	$$ = new FnDecl(id, $1, $4);
                                    }
          |    T_Void T_Identifier '(' Formals ')' ';' 
				    { 	Identifier *id = new Identifier(@2, $2);
                                      	Type *tp = new Type(*Type::voidType);
                                      	$$ = new FnDecl(id, tp, $4);
                                    }
	  ;

//Line 13
StmtBlock :  '{' VarDecls StmtList '}' 
                                    { 	$$ = new StmtBlock($2, $3); }
          |  '{' VarDecls '}' 	    {
                                	List<Stmt*> *lid = new List<Stmt*>;
                                	$$ = new StmtBlock($2, lid);
                                    }
          |  '{' StmtList '}' 	    { 
                               		List<VarDecl*> *vid = new List<VarDecl*>;
                               		$$ = new StmtBlock(vid, $2);
                                    }
          |    '{' '}'        	    {	List<VarDecl*> *vid = new List<VarDecl*>;
                                	List<Stmt*> *lid = new List<Stmt*>;
                                	$$ = new StmtBlock(vid, lid);
                                    }              
	  ;

VarDecls  :     VarDecls VarDecl    { 	($$=$1)->Append($2); }
          |     VarDecl             { 	($$ = new List<VarDecl*>)->Append($1); }
	  ;

StmtList  :    StmtList Stmt        { 	($$ = $1)->Append($2); }
          |    Stmt                 { 	($$ = new List<Stmt*>)->Append($1); }
          ;


ExprO     :    Expr                 { 	$$ = $1; }
          | /* empty*/              { 	$$ = new EmptyExpr; }
          ;

Stmt      :    ExprO ';'            { $$ = $1; }
          |    IfStmt               { $$ = $1; }
          |    WhileStmt            { $$ = $1; }
          |    ForStmt              { $$ = $1; }
          |    BreakStmt            { $$ = $1; }
          |    ReturnStmt           { $$ = $1; }
          |    PrintStmt            { $$ = $1; }
	  |    SwitchStmt           { $$ = $1; }
          |    StmtBlock            { $$ = $1; }
          ;

Elses     :    T_Else Stmt %prec T_Else 
				    { $$ = $2; }
          |                %prec NoElse 
				    { $$ = NULL; }
          ;

IfStmt    :    T_If '(' Expr ')' Stmt Elses 
				    { $$ = new IfStmt($3, $5, $6); }
          ;


WhileStmt :    T_While '(' Expr ')' Stmt 
				    { $$ = new WhileStmt($3, $5); }
          ;

ForStmt   :    T_For '(' ExprO ';' Expr ';' ExprO ')' Stmt 
				    { $$ = new ForStmt($3, $5, $7, $9); }
          ;

ReturnStmt:   T_Return ExprO ';'    { $$ = new ReturnStmt(@1, $2); }
          ;

BreakStmt :    T_Break ';'          { $$ = new BreakStmt(@1); }
          ;


Exprs     :    Exprs ',' Expr       { ($$ = $1)->Append($3); }
          |    Expr                 { ($$ = new List<Expr*>)->Append($1); }
          ;

PrintStmt :    T_Print '(' Exprs ')' ';' 
				    { $$ = new PrintStmt($3); }
          ;
		  
StmtS     :    StmtS Stmt           { ($$ = $1)->Append($2); }
          |                         { $$ = new List<Stmt*>; }
          ;

Case      :    T_Case T_IntConstant ':' StmtS {
                                      IntConstant *i = new IntConstant(@2, $2);
                                      $$ = new Case(i, $4);
                                    }
          ;

CaseS     :    CaseS Case           { ($$ = $1)->Append($2); }
          |    Case                 { ($$ = new List<Case*>)->Append($1); }
          ;

Default   :    T_Default ':' StmtS  { $$ = new Default($3); }
          ;

DefaultO  :    Default              { $$ = $1; }
          |                         { $$ = NULL; }
          ;

SwitchStmt :   T_Switch '(' Expr ')' '{' CaseS DefaultO '}' {
                                      $$ = new SwitchStmt($3, $6, $7);
                                    }
          ;

Expr      :    LValue '=' Expr      { Operator *op = new Operator(@2, "=");
                                      $$ = new AssignExpr($1, op, $3);
                                    }
          |    Constant             { $$ = $1; }
          |    LValue               { $$ = $1; }
          |    T_This               { $$ = new This(@1); }
          |    Call                 { $$ = $1; }
          |    '(' Expr ')'         { $$ = $2; }
          |    Expr '+' Expr        { Operator *op = new Operator(@2, "+");
                                      $$ = new ArithmeticExpr($1, op, $3);
                                    }
          |    Expr '-' Expr        { Operator *op = new Operator(@2, "-");
                                      $$ = new ArithmeticExpr($1, op, $3);
                                    }
          |    Expr '*' Expr        { Operator *op = new Operator(@2, "*");
                                      $$ = new ArithmeticExpr($1, op, $3);
                                    }
          |    Expr '/' Expr        { Operator *op = new Operator(@2, "/");
                                      $$ = new ArithmeticExpr($1, op, $3);
                                    }
          |    Expr '%' Expr        { Operator *op = new Operator(@2, "%");
                                      $$ = new ArithmeticExpr($1, op, $3);
                                    }
          |    '-' Expr             { Operator *op = new Operator(@1, "-");
                                      $$ = new ArithmeticExpr(op, $2);
                                    }
          |    Expr '<' Expr        { Operator *op = new Operator(@2, "<");
                                      $$ = new RelationalExpr($1, op, $3);
                                    }
          |    Expr T_LessEqual Expr{
                                      Operator *op = new Operator(@2, "<=");
                                      $$ = new RelationalExpr($1, op, $3);
                                    }
          |    Expr '>' Expr        { Operator *op = new Operator(@2, ">");
                                      $$ = new RelationalExpr($1, op, $3);
                                    }
          |    Expr T_GreaterEqual Expr 
				    {
                                      Operator *op = new Operator(@2, ">=");
                                      $$ = new RelationalExpr($1, op, $3);
                                    }
          |    Expr T_Equal Expr    { Operator *op = new Operator(@2, "==");
                                      $$ = new EqualityExpr($1, op, $3);
                                    }
          |    Expr T_NotEqual Expr {
                                      Operator *op = new Operator(@2, "!=");
                                      $$ = new EqualityExpr($1, op, $3);
                                    }
          |    Expr T_And Expr      {
                                      Operator *op = new Operator(@2, "&&");
                                      $$ = new LogicalExpr($1, op, $3);
                                    }
          |    Expr T_Or Expr       {
                                      Operator *op = new Operator(@2, "||");
                                      $$ = new LogicalExpr($1, op, $3);
                                    }
          |    '!' Expr             { Operator *op = new Operator(@1, "!");
                                      $$ = new LogicalExpr(op, $2);
                                    }
          |    Expr T_PostfixAdd     { Operator *op = new Operator(@2, "++");
                                      $$ = new PostfixExpr($1, op);
                                    }
          |    Expr T_PostfixMinus     { Operator *op = new Operator(@2, "--");
                                      $$ = new PostfixExpr($1, op);
                                    }
          |    T_ReadInteger '(' ')'   
				    { $$ = new ReadIntegerExpr(@1); }
          |    T_ReadLine '(' ')'      
				    { $$ = new ReadLineExpr(@1); }
          |    T_New '(' T_Identifier ')'  { 
				      Identifier *id = new Identifier(@3, $3);
                                      NamedType *nt = new NamedType(id);
                                      $$ = new NewExpr(@1, nt);
                                    }
          |    T_NewArray '(' Expr ',' Type ')' 
				    { $$ = new NewArrayExpr(@1, $3, $5); }
          ;

LValue    :    T_Identifier         { Identifier *id = new Identifier(@1, $1);
                                      $$ = new FieldAccess(NULL, id);
                                    }
          |    Expr '.' T_Identifier{
                                      Identifier *id = new Identifier(@3, $3);
                                      $$ = new FieldAccess($1, id);
                                    }
          |    Expr '[' Expr ']'    { $$ = new ArrayAccess(@1, $1, $3); }
          ;

Call      :    T_Identifier '(' Actuals ')' 
				    {
                                      Identifier *id = new Identifier(@1, $1);
                                      $$ = new Call(@1, NULL, id, $3);
                                    }
          |    Expr '.' T_Identifier '(' Actuals ')' 
				    {
                                      Identifier *id = new Identifier(@3, $3);
                                      $$ = new Call(@2, $1, id, $5);
                                    }
	  ;

Actuals   :    Exprs                { $$ = $1; }
          |    /*empty*/            { $$ = new List<Expr*>; }
          ;

Constant  :    T_IntConstant        { $$ = new IntConstant(@1, $1); }
          |    T_DoubleConstant     { $$ = new DoubleConstant(@1, $1); }
          |    T_BoolConstant       { $$ = new BoolConstant(@1, $1); }
          |    T_StringConstant     { $$ = new StringConstant(@1, $1); }
          |    T_Null               { $$ = new NullConstant(@1); }
          ;

%%

/* The closing %% above marks the end of the Rules section and the beginning
 * of the User Subroutines section. All text from here to the end of the
 * file is copied verbatim to the end of the generated y.tab.c file.
 * This section is where you put definitions of helper functions.
 */

/* Function: InitParser
 * --------------------
 * This function will be called before any calls to yyparse().  It is designed
 * to give you an opportunity to do anything that must be done to initialize
 * the parser (set global variables, configure starting state, etc.). One
 * thing it already does for you is assign the value of the global variable
 * yydebug that controls whether yacc prints debugging information about
 * parser actions (shift/reduce) and contents of state stack during parser.
 * If set to false, no information is printed. Setting it to true will give
 * you a running trail that might be helpful when debugging your parser.
 * Please be sure the variable is set to false when submitting your final
 * version.
 */
void InitParser()
{
   PrintDebug("parser", "Initializing parser");
   yydebug = false;
}
