/* File: ast_expr.cc
 * -----------------
 * Implementation of expression node classes.
 */
#include "ast_expr.h"
#include "ast_type.h"
#include "ast_decl.h"
#include <string.h>


ClassDecl* Expr::GetClassDecl(Scope *s) {
    while (s != NULL) {
        ClassDecl *d;
        if ((d = s->GetClassDecl()) != NULL)
            return d;
        s = s->GetParent();
    }

    return NULL;
}

Decl* Expr::GetFieldDecl(Identifier *f, Type *b) {
    NamedType *t = dynamic_cast<NamedType*>(b);

    while (t != NULL) {
        Decl *d = Program::gScope->table->Lookup(t->Name());
        ClassDecl *c = dynamic_cast<ClassDecl*>(d);
        InterfaceDecl *i = dynamic_cast<InterfaceDecl*>(d);

        Decl *fieldDecl;
        if (c != NULL) {
            if ((fieldDecl = GetFieldDecl(f, c->GetScope())) != NULL)
                return fieldDecl;
            else
                t = c->GetExtends();
        } else if (i != NULL) {
            if ((fieldDecl = GetFieldDecl(f, i->GetScope())) != NULL)
                return fieldDecl;
            else
                t = NULL;
        } else {
            t = NULL;
        }
    }

    return GetFieldDecl(f, scope);
}

Decl* Expr::GetFieldDecl(Identifier *f, Scope *s) {
    while (s != NULL) {
        Decl *lookup;
        if ((lookup = s->table->Lookup(f->Name())) != NULL)
            return lookup;

        s = s->GetParent();
    }

    return NULL;
}

Type* EmptyExpr::GetType() {
    return Type::errorType;
}

IntConstant::IntConstant(yyltype loc, int val) : Expr(loc) {
    value = val;
}

//void IntConstant::PrintChildren(int indentLevel) { 
//    printf("%d", value);
//}

Type* IntConstant::GetType() {
    return Type::intType;
}

DoubleConstant::DoubleConstant(yyltype loc, double val) : Expr(loc) {
    value = val;
}

Type* DoubleConstant::GetType() {
    return Type::doubleType;
}

//void DoubleConstant::PrintChildren(int indentLevel) { 
//    printf("%g", value);
//}

BoolConstant::BoolConstant(yyltype loc, bool val) : Expr(loc) {
    value = val;
}

Type* BoolConstant::GetType() {
    return Type::boolType;
}

//void BoolConstant::PrintChildren(int indentLevel) { 
//    printf("%s", value ? "true" : "false");
//}

StringConstant::StringConstant(yyltype loc, const char *val) : Expr(loc) {
    Assert(val != NULL);
    value = strdup(val);
}

//void StringConstant::PrintChildren(int indentLevel) { 
//   printf("%s",value);
//}

Type* StringConstant::GetType() {
    return Type::stringType;
}

Type* NullConstant::GetType() {
    return Type::nullType;
}

Operator::Operator(yyltype loc, const char *tok) : Node(loc) {
    Assert(tok != NULL);
    strncpy(tokenString, tok, sizeof(tokenString));
}

//void Operator::PrintChildren(int indentLevel) {
//    printf("%s",tokenString);
//}

CompoundExpr::CompoundExpr(Expr *l, Operator *o, Expr *r) 
  : Expr(Join(l->GetLocation(), r->GetLocation())) {
    Assert(l != NULL && o != NULL && r != NULL);
    (op=o)->SetParent(this);
    (left=l)->SetParent(this); 
    (right=r)->SetParent(this);
}

CompoundExpr::CompoundExpr(Operator *o, Expr *r) 
  : Expr(Join(o->GetLocation(), r->GetLocation())) {
    Assert(o != NULL && r != NULL);
    left = NULL; 
    (op=o)->SetParent(this);
    (right=r)->SetParent(this);
}

//void CompoundExpr::PrintChildren(int indentLevel) {
//   if (left) left->Print(indentLevel+1);
//   op->Print(indentLevel+1);
//   right->Print(indentLevel+1);
//}

void CompoundExpr::BuildScope(Scope *parent) {
    scope->SetParent(parent);

    if (left != NULL)
        left->BuildScope(scope);

    right->BuildScope(scope);
}

void CompoundExpr::Check() {
    if (left != NULL)
        left->Check();

    right->Check();
}

Type* ArithmeticExpr::GetType() {
    Type *rtype = right->GetType();

    if (left == NULL) {
        if (rtype->IsEquivalentTo(Type::intType) ||
            rtype->IsEquivalentTo(Type::doubleType))
            return rtype;
        else
            return Type::errorType;
    }

    Type *ltype = left->GetType();

    if (ltype->IsEquivalentTo(Type::intType) &&
        rtype->IsEquivalentTo(Type::intType))
        return ltype;

    if (ltype->IsEquivalentTo(Type::doubleType) &&
        rtype->IsEquivalentTo(Type::doubleType))
        return ltype;

    return Type::errorType;
}

void ArithmeticExpr::Check() {
    if (left != NULL)
        left->Check();

    right->Check();

    Type *rtype = right->GetType();

    if (left == NULL) {
        if (rtype->IsEquivalentTo(Type::intType) ||
            rtype->IsEquivalentTo(Type::doubleType))
            return;
        else
            ReportError::IncompatibleOperand(op, rtype);

        return;
    }

    Type *ltype = left->GetType();

    if (ltype->IsEquivalentTo(Type::intType) &&
        rtype->IsEquivalentTo(Type::intType))
        return;

    if (ltype->IsEquivalentTo(Type::doubleType) &&
        rtype->IsEquivalentTo(Type::doubleType))
        return;

    ReportError::IncompatibleOperands(op, ltype, rtype);
}

Type* RelationalExpr::GetType() {
    Type *rtype = right->GetType();
    Type *ltype = left->GetType();

    if (ltype->IsEquivalentTo(Type::intType) &&
        rtype->IsEquivalentTo(Type::intType))
        return Type::errorType;

    if (ltype->IsEquivalentTo(Type::doubleType) &&
        rtype->IsEquivalentTo(Type::doubleType))
        return Type::errorType;

    return Type::boolType;
}

void RelationalExpr::Check() {
    Type *rtype = right->GetType();
    Type *ltype = left->GetType();

    if (ltype->IsEquivalentTo(Type::intType) &&
        rtype->IsEquivalentTo(Type::intType))
        return;

    if (ltype->IsEquivalentTo(Type::doubleType) &&
        rtype->IsEquivalentTo(Type::doubleType))
        return;

    ReportError::IncompatibleOperands(op, ltype, rtype);
}

Type* EqualityExpr::GetType() {
    Type *rtype = right->GetType();
    Type *ltype = left->GetType();

    if (!rtype->IsEquivalentTo(ltype) &&
        !ltype->IsEquivalentTo(rtype))
        return Type::errorType;

   return Type::boolType;
}

void EqualityExpr::Check() {
    left->Check();
    right->Check();

    Type *rtype = right->GetType();
    Type *ltype = left->GetType();

    if (!rtype->IsEquivalentTo(ltype) &&
        !ltype->IsEquivalentTo(rtype))
        ReportError::IncompatibleOperands(op, ltype, rtype);
}

Type* LogicalExpr::GetType() {
    Type *rtype = right->GetType();

    if (left == NULL) {
        if (rtype->IsEquivalentTo(Type::boolType))
            return Type::boolType;
        else
            return Type::errorType;
    }

    Type *ltype = left->GetType();

    if (ltype->IsEquivalentTo(Type::boolType) &&
        rtype->IsEquivalentTo(Type::boolType))
        return Type::boolType;

    return Type::errorType;
}

void LogicalExpr::Check() {
    if (left != NULL)
        left->Check();

    right->Check();

    Type *rtype = right->GetType();

    if (left == NULL) {
        if (rtype->IsEquivalentTo(Type::boolType))
            return;
        else
            ReportError::IncompatibleOperand(op, rtype);

        return;
    }

    Type *ltype = left->GetType();

    if (ltype->IsEquivalentTo(Type::boolType) &&
        rtype->IsEquivalentTo(Type::boolType))
        return;

    ReportError::IncompatibleOperands(op, ltype, rtype);
}

Type* AssignExpr::GetType() {
    Type *ltype = left->GetType();
    Type *rtype = right->GetType();

    if (!rtype->IsEquivalentTo(ltype))
        return Type::errorType;

    return ltype;
}

void AssignExpr::Check() {
    left->Check();
    right->Check();

    Type *ltype = left->GetType();
    Type *rtype = right->GetType();

    if (!rtype->IsEquivalentTo(ltype) && !ltype->IsEqualTo(Type::errorType))
        ReportError::IncompatibleOperands(op, ltype, rtype);
}

Type* This::GetType() {
    ClassDecl *d = GetClassDecl(scope);
    if (d == NULL)
        return Type::errorType;

    return d->GetType();
}

void This::Check() {
    if (GetClassDecl(scope) == NULL)
        ReportError::ThisOutsideClassScope(this);
}   
  
ArrayAccess::ArrayAccess(yyltype loc, Expr *b, Expr *s) : LValue(loc) {
    (base=b)->SetParent(this); 
    (subscript=s)->SetParent(this);
}

//void ArrayAccess::PrintChildren(int indentLevel) {
//    base->Print(indentLevel+1);
//    subscript->Print(indentLevel+1, "(subscript) ");
//  }
  
Type* ArrayAccess::GetType() {
    ArrayType *t = dynamic_cast<ArrayType*>(base->GetType());
    if (t == NULL)
        return Type::errorType;

    return t->GetElemType();
}

void ArrayAccess::BuildScope(Scope *parent) {
    scope->SetParent(parent);

    base->BuildScope(scope);
    subscript->BuildScope(scope);
}

void ArrayAccess::Check() {
    base->Check();
    subscript->Check();

    ArrayType *t = dynamic_cast<ArrayType*>(base->GetType());
    if (t == NULL)
        ReportError::BracketsOnNonArray(base);

    if (!subscript->GetType()->IsEqualTo(Type::intType))
        ReportError::SubscriptNotInteger(subscript);
}

     
FieldAccess::FieldAccess(Expr *b, Identifier *f) 
  : LValue(b? Join(b->GetLocation(), f->GetLocation()) : *f->GetLocation()) {
    Assert(f != NULL); // b can be be NULL (just means no explicit base)
    base = b; 
    if (base) base->SetParent(this); 
    (field=f)->SetParent(this);
}


//  void FieldAccess::PrintChildren(int indentLevel) {
//    if (base) base->Print(indentLevel+1);
//    field->Print(indentLevel+1);
//  }

Type* FieldAccess::GetType() {
    Decl *d;
    ClassDecl *c;
    Type *t;

    c = GetClassDecl(scope);

    if (base == NULL) {
        if (c == NULL) {
            d = GetFieldDecl(field, scope);
        } else {
            t = c->GetType();
            d = GetFieldDecl(field, t);
        }
    } else {
        t = base->GetType();
        d = GetFieldDecl(field, t);
    }

    if (d == NULL)
        return Type::errorType;

    if (dynamic_cast<VarDecl*>(d) == NULL)
        return Type::errorType;

    return static_cast<VarDecl*>(d)->GetType();
}

void FieldAccess::BuildScope(Scope *parent) {
    scope->SetParent(parent);

    if (base != NULL)
        base->BuildScope(scope);
}

void FieldAccess::Check() {
    if (base != NULL)
        base->Check();

    Decl *d;
    Type *t;

    if (base == NULL) {
        ClassDecl *c = GetClassDecl(scope);
        if (c == NULL) {
            if ((d = GetFieldDecl(field, scope)) == NULL) {
                ReportError::IdentifierNotDeclared(field, LookingForVariable);
                return;
            }
        } else {
            t = c->GetType();
            if ((d = GetFieldDecl(field, t)) == NULL) {
                ReportError::FieldNotFoundInBase(field, t);
                return;
            }
        }
    } else {
        t = base->GetType();
        if ((d = GetFieldDecl(field, t)) == NULL) {
            ReportError::FieldNotFoundInBase(field, t);
            return;
        }
        else if (GetClassDecl(scope) == NULL) {
            ReportError::InaccessibleField(field, t);
            return;
        }
    }

    if (dynamic_cast<VarDecl*>(d) == NULL)
        ReportError::IdentifierNotDeclared(field, LookingForVariable);
}  

Call::Call(yyltype loc, Expr *b, Identifier *f, List<Expr*> *a) : Expr(loc)  {
    Assert(f != NULL && a != NULL); // b can be be NULL (just means no explicit base)
    base = b;
    if (base) base->SetParent(this);
    (field=f)->SetParent(this);
    (actuals=a)->SetParentAll(this);
}

// void Call::PrintChildren(int indentLevel) {
//    if (base) base->Print(indentLevel+1);
//    field->Print(indentLevel+1);
//    actuals->PrintAll(indentLevel+1, "(actuals) ");
//  }

Type* Call::GetType() {
    Decl *d;

    if (base == NULL) {
        ClassDecl *c = GetClassDecl(scope);
        if (c == NULL) {
            if ((d = GetFieldDecl(field, scope)) == NULL)
                return Type::errorType;
        } else {
            if ((d = GetFieldDecl(field, c->GetType())) == NULL)
                return Type::errorType;
        }
    } else {
        Type *t = base->GetType();
        if ((d = GetFieldDecl(field, t)) == NULL) {

            if (dynamic_cast<ArrayType*>(t) != NULL &&
                strcmp("length", field->Name()) == 0)
                return Type::intType;

            return Type::errorType;
        }
    }

    if (dynamic_cast<FnDecl*>(d) == NULL)
        return Type::errorType;

    return static_cast<FnDecl*>(d)->GetReturnType();
}

void Call::BuildScope(Scope *parent) {
    scope->SetParent(parent);

    if (base != NULL)
        base->BuildScope(scope);

    for (int i = 0, n = actuals->NumElements(); i < n; ++i)
        actuals->Nth(i)->BuildScope(scope);
}

void Call::Check() {
    if (base != NULL)
        base->Check();

    Decl *d;
    Type *t;

    if (base == NULL) {
        ClassDecl *c = GetClassDecl(scope);
        if (c == NULL) {
            if ((d = GetFieldDecl(field, scope)) == NULL) {
                CheckActuals(d);
                ReportError::IdentifierNotDeclared(field, LookingForFunction);
                return;
            }
        } else {
            t = c->GetType();
            if ((d = GetFieldDecl(field, t)) == NULL) {
                CheckActuals(d);
                ReportError::IdentifierNotDeclared(field, LookingForFunction);
                return;
            }
        }
    } else {
        t = base->GetType();
        if ((d = GetFieldDecl(field, t)) == NULL) {
            CheckActuals(d);

            if (dynamic_cast<ArrayType*>(t) == NULL ||
                strcmp("length", field->Name()) != 0)
                ReportError::FieldNotFoundInBase(field, t);
            return;
        }
    }

    CheckActuals(d);
} 

void Call::CheckActuals(Decl *d) {
    for (int i = 0, n = actuals->NumElements(); i < n; ++i)
        actuals->Nth(i)->Check();

    FnDecl *fnDecl = dynamic_cast<FnDecl*>(d);
    if (fnDecl == NULL)
        return;

    List<VarDecl*> *formals = fnDecl->GetFormals();

    int numExpected = formals->NumElements();
    int numGiven = actuals->NumElements();
    if (numExpected != numGiven) {
        ReportError::NumArgsMismatch(field, numExpected, numGiven);
        return;
    }

    for (int i = 0, n = actuals->NumElements(); i < n; ++i) {
        Type *given = actuals->Nth(i)->GetType();
        Type *expected = formals->Nth(i)->GetType();
        if (!given->IsEquivalentTo(expected))
            ReportError::ArgMismatch(actuals->Nth(i), i+1, given, expected);
    }
}

NewExpr::NewExpr(yyltype loc, NamedType *c) : Expr(loc) { 
  Assert(c != NULL);
  (cType=c)->SetParent(this);
}

//void NewExpr::PrintChildren(int indentLevel) {	
//    cType->Print(indentLevel+1);
//}

Type* NewExpr::GetType() {
    Decl *d = Program::gScope->table->Lookup(cType->Name());
    ClassDecl *c = dynamic_cast<ClassDecl*>(d);

    if (c == NULL)
        return Type::errorType;

    return c->GetType();
}

void NewExpr::Check() {
    Decl *d = Program::gScope->table->Lookup(cType->Name());
    ClassDecl *c = dynamic_cast<ClassDecl*>(d);

    if (c == NULL)
        ReportError::IdentifierNotDeclared(cType->GetId(), LookingForClass);
}

NewArrayExpr::NewArrayExpr(yyltype loc, Expr *sz, Type *et) : Expr(loc) {
    Assert(sz != NULL && et != NULL);
    (size=sz)->SetParent(this); 
    (elemType=et)->SetParent(this);
}

//void NewArrayExpr::PrintChildren(int indentLevel) {
//    size->Print(indentLevel+1);
//    elemType->Print(indentLevel+1);
//}

Type* NewArrayExpr::GetType() {
    return new ArrayType(elemType);
}

void NewArrayExpr::BuildScope(Scope *parent) {
    scope->SetParent(parent);

    size->BuildScope(scope);
}

void NewArrayExpr::Check() {
    size->Check();

    if (!size->GetType()->IsEqualTo(Type::intType))
        ReportError::NewArraySizeNotInteger(size);

    if (elemType->IsPrimitive() && !elemType->IsEquivalentTo(Type::voidType))
        return;

    Decl *d = Program::gScope->table->Lookup(elemType->Name());
    if (dynamic_cast<ClassDecl*>(d) == NULL)
        elemType->ReportNotDeclaredIdentifier(LookingForType);
}

Type* ReadIntegerExpr::GetType() {
    return Type::intType;
}

Type* ReadLineExpr::GetType() {
    return Type::stringType;
}

PostfixExpr::PostfixExpr(LValue *lv, Operator *o){// : Expr(Join(lv->GetLocation(), o->GetLocation())) {
    Assert(lv != NULL && o != NULL);
    (lvalue=lv)->SetParent(this);
    (op=o)->SetParent(this);
}

Type* PostfixExpr::GetType() {
    return Type::intType;
}

//void PostfixExpr::PrintChildren(int indentLevel) {
//    lvalue->Print(indentLevel+1);
//    op->Print(indentLevel+1);
//}
       
