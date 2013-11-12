/* File: ast_stmt.cc
 * -----------------
 * Implementation of statement node classes.
 */
#include "ast_stmt.h"
#include "ast_type.h"
#include "ast_decl.h"
#include "ast_expr.h"
#include "errors.h"
#include "ast_type.h"

int Scope::AddDecl(Decl *d) {
    Decl *lookup = table->Lookup(d->Name());

    if (lookup != NULL) {
            ReportError::DeclConflict(d, lookup);
            return 1;
    }

    table->Enter(d->Name(), d);
    return 0;
}

ostream& operator<<(ostream& out, Scope *s) {
    out << "========== Scope ==========" << std::endl;
    Iterator<Decl*> iter = s->table->GetIterator();
    Decl *d;
    while ((d = iter.GetNextValue()) != NULL)
        out << d << std::endl;
    return out;
}

Scope *Program::gScope = new Scope();


Program::Program(List<Decl*> *d) {
    Assert(d != NULL);
    (decls=d)->SetParentAll(this);
}

//void Program::PrintChildren(int indentLevel) {
//    decls->PrintAll(indentLevel+1);
//    printf("\n");
//}

void Program::Check() {
    /* pp3: here is where the semantic analyzer is kicked off.
     *      The general idea is perform a tree traversal of the
     *      entire program, examining all constructs for compliance
     *      with the semantic rules.  Each node can have its own way of
     *      checking itself, which makes for a great use of inheritance
     *      and polymorphism in the node classes.
     */

    BuildScope();

    for (int i = 0, n = decls->NumElements(); i < n; ++i)
        decls->Nth(i)->Check();
}

void Program::BuildScope() {
    for (int i = 0, n = decls->NumElements(); i < n; ++i)
        gScope->AddDecl(decls->Nth(i));

    for (int i = 0, n = decls->NumElements(); i < n; ++i)
        decls->Nth(i)->BuildScope(gScope);
}

void Stmt::BuildScope(Scope *parent) {
    scope->SetParent(parent);
}

StmtBlock::StmtBlock(List<VarDecl*> *d, List<Stmt*> *s) {
    Assert(d != NULL && s != NULL);
    (decls=d)->SetParentAll(this);
    (stmts=s)->SetParentAll(this);
}

//void StmtBlock::PrintChildren(int indentLevel) {
//    decls->PrintAll(indentLevel+1);
//    stmts->PrintAll(indentLevel+1);
//}

void StmtBlock::BuildScope(Scope *parent) {
    scope->SetParent(parent);

    for (int i = 0, n = decls->NumElements(); i < n; ++i)
        scope->AddDecl(decls->Nth(i));

    for (int i = 0, n = decls->NumElements(); i < n; ++i)
        decls->Nth(i)->BuildScope(scope);

    for (int i = 0, n = stmts->NumElements(); i < n; ++i)
        stmts->Nth(i)->BuildScope(scope);
}

void StmtBlock::Check() {
    for (int i = 0, n = decls->NumElements(); i < n; ++i)
        decls->Nth(i)->Check();

    for (int i = 0, n = stmts->NumElements(); i < n; ++i)
        stmts->Nth(i)->Check();
}

ConditionalStmt::ConditionalStmt(Expr *t, Stmt *b) {
    Assert(t != NULL && b != NULL);
    (test=t)->SetParent(this);
    (body=b)->SetParent(this);
}

void ConditionalStmt::BuildScope(Scope *parent) {
    scope->SetParent(parent);

    test->BuildScope(scope);
    body->BuildScope(scope);
}

void ConditionalStmt::Check() {
    test->Check();
    body->Check();

    if (!test->GetType()->IsEquivalentTo(Type::boolType))
        ReportError::TestNotBoolean(test);
}

void LoopStmt::BuildScope(Scope *parent) {
    scope->SetParent(parent);
    scope->SetLoopStmt(this);

    test->BuildScope(scope);
    body->BuildScope(scope);
}

ForStmt::ForStmt(Expr *i, Expr *t, Expr *s, Stmt *b): LoopStmt(t, b) { 
    Assert(i != NULL && t != NULL && s != NULL && b != NULL);
    (init=i)->SetParent(this);
    (step=s)->SetParent(this);
}

//void ForStmt::PrintChildren(int indentLevel) {
//    init->Print(indentLevel+1, "(init) ");
//    test->Print(indentLevel+1, "(test) ");
//    step->Print(indentLevel+1, "(step) ");
//    body->Print(indentLevel+1, "(body) ");
//}

//void WhileStmt::PrintChildren(int indentLevel) {
//    test->Print(indentLevel+1, "(test) ");
//    body->Print(indentLevel+1, "(body) ");
//}

IfStmt::IfStmt(Expr *t, Stmt *tb, Stmt *eb): ConditionalStmt(t, tb) { 
    Assert(t != NULL && tb != NULL); // else can be NULL
    elseBody = eb;
    if (elseBody) elseBody->SetParent(this);
}

//void IfStmt::PrintChildren(int indentLevel) {
//    test->Print(indentLevel+1, "(test) ");
//    body->Print(indentLevel+1, "(then) ");
//    if (elseBody) elseBody->Print(indentLevel+1, "(else) ");
//}

void IfStmt::BuildScope(Scope *parent) {
    scope->SetParent(parent);

    test->BuildScope(scope);
    body->BuildScope(scope);

    if (elseBody != NULL)
        elseBody->BuildScope(scope);
}

void IfStmt::Check() {
    test->Check();
    body->Check();

    if (!test->GetType()->IsEquivalentTo(Type::boolType))
        ReportError::TestNotBoolean(test);

    if (elseBody != NULL)
        elseBody->Check();
}

void BreakStmt::Check() {
    Scope *s = scope;
    while (s != NULL) {
        if (s->GetLoopStmt() != NULL)
            return;

        s = s->GetParent();
    }

    ReportError::BreakOutsideLoop(this);
}

ReturnStmt::ReturnStmt(yyltype loc, Expr *e) : Stmt(loc) { 
    Assert(e != NULL);
    (expr=e)->SetParent(this);
}

//void ReturnStmt::PrintChildren(int indentLevel) {
//    expr->Print(indentLevel+1);
//}

void ReturnStmt::BuildScope(Scope *parent) {
    scope->SetParent(parent);

    expr->BuildScope(scope);
}

void ReturnStmt::Check() {
    expr->Check();

    FnDecl *d = NULL;
    Scope *s = scope;
    while (s != NULL) {
        if ((d = s->GetFnDecl()) != NULL)
            break;

        s = s->GetParent();
    }

    if (d == NULL) {
        ReportError::Formatted(location,
                               "return is only allowed inside a function");
        return;
    }

    Type *expected = d->GetReturnType();
    Type *given = expr->GetType();

    if (!given->IsEquivalentTo(expected))
        ReportError::ReturnMismatch(this, given, expected);
}
  
PrintStmt::PrintStmt(List<Expr*> *a) {    
    Assert(a != NULL);
    (args=a)->SetParentAll(this);
}

//void PrintStmt::PrintChildren(int indentLevel) {
//    args->PrintAll(indentLevel+1, "(args) ");
//}

void PrintStmt::BuildScope(Scope *parent) {
    scope->SetParent(parent);

    for (int i = 0, n = args->NumElements(); i < n; ++i)
        args->Nth(i)->BuildScope(scope);
}

void PrintStmt::Check() {
    for (int i = 0, n = args->NumElements(); i < n; ++i) {
        Type *given = args->Nth(i)->GetType();

        if (!(given->IsEquivalentTo(Type::intType) ||
              given->IsEquivalentTo(Type::boolType) ||
              given->IsEquivalentTo(Type::stringType)))
            ReportError::PrintArgMismatch(args->Nth(i), i+1, given);
    }

    for (int i = 0, n = args->NumElements(); i < n; ++i)
        args->Nth(i)->Check();
}

Case::Case(IntConstant *v, List<Stmt*> *s) {
    Assert(s != NULL);
    value = v;
    if (value) value->SetParent(this);
    (stmts=s)->SetParentAll(this);
}

//void Case::PrintChildren(int indentLevel) {
//    if (value) value->Print(indentLevel+1);
//    stmts->PrintAll(indentLevel+1);
//}

SwitchStmt::SwitchStmt(Expr *e, List<Case*> *c) {
    Assert(e != NULL && c != NULL);
    (expr=e)->SetParent(this);
    (cases=c)->SetParentAll(this);
}

void SwitchStmt::BuildScope(Scope *parent) {
	int a = 0;
}

void SwitchStmt::Check() {
	int a = 0;
}
      
//void SwitchStmt::PrintChildren(int indentLevel) {
//    expr->Print(indentLevel+1);
//    cases->PrintAll(indentLevel+1);
//}


