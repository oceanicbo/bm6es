/* File: ast.cc
 * ------------
 */

#include "ast.h"
#include "ast_type.h"
#include "ast_decl.h"
#include <string.h> // strdup
#include <stdio.h>  // printf

Node::Node(yyltype loc) {
    location = new yyltype(loc);
    parent = NULL;
}

Node::Node() {
    location = NULL;
    parent = NULL;
}

void Node::Print(int indentLevel, const char *label) { 
    const int numSpaces = 3;
    printf("\n");
    if (GetLocation()) 
        printf("%*d", numSpaces, GetLocation()->first_line);
    else 
        printf("%*s", numSpaces, "");
//    printf("%*s%s%s: ", indentLevel*numSpaces, "", 
//           label? label : "", GetPrintNameForNode());
   PrintChildren(indentLevel);
} 	 
	 
Identifier::Identifier(yyltype loc, const char *n) : Node(loc) {
    name = strdup(n);
} 

bool Identifier::operator==(const Identifier &rhs) {
    return strcmp(name, rhs.name) == 0 ? true : false;
}

void Identifier::PrintChildren(int indentLevel) {
    printf("%s", name);
}