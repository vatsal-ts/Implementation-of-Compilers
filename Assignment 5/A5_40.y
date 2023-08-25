%{
    /*
        Sweeya Reddy | 200101079
        Vatsal Gupta | 200101105

        CS-348 - Assignment 5
        Header file
    */

    #include <iostream>
    #include "A5_40_translator.h"
    using namespace std;

    extern int yylex();         // From lexer
    void yyerror(string s);     // Function to report errors
    extern char* yytext;        // From lexer, gives the text being currently scanned
    extern int yylineno;        // Used for keeping track of the line number
    extern string varType;      // Used for storing the last encountered type
    expression* tempBoolT;
%}

%union {
    int intval;             // For an integer value
    char* charval;          // For a char value
    int instr;              // A special type for instruction number, needed in backpatching
    char unaryOp;           // For unary operators
    int numParams;          // For number of parameters to a function
    expression* expr;       // For an expression
    statement* stmt;        // For a statement
    symbol* symp;           // For a symbol
    symbolType* symType;    // For the type of a symbol
    Array* arr;             // For arrays
}

/*
    All tokens
*/
%token CHAR ELSE FOR IF INT RETURN VOID
%token SQUARE_BRACE_OPEN SQUARE_BRACE_CLOSE PARENTHESIS_OPEN PARENTHESIS_CLOSE CURLY_BRACE_OPEN CURLY_BRACE_CLOSE 
%token ARROW BITWISE_AND MULTIPLY ADD SUBTRACT NOT DIVIDE MODULO 
%token LESS_THAN GREATER_THAN LESS_THAN_EQUAL GREATER_THAN_EQUAL EQUAL NOT_EQUAL 
%token LOGICAL_AND LOGICAL_OR QUESTION_MARK COLON SEMICOLON ELLIPSIS 
%token ASSIGN COMMA

// Identifiers are treated with type symbol*
%token <symp> IDENTIFIER

// Integer constants have a type intval
%token <intval> INTEGER_CONSTANT

// Character constants have a type charval
%token <charval> CHAR_CONSTANT

// String literals have a type charval
%token <charval> STRING_LITERAL

// The start symbol is translation_unit
%start translation_unit

// Helps in removing the dangling else problem
%right THEN ELSE

// Non-terminals of type unaryOp (unary operator)
%type <unaryOp> unary_operator

// Non-terminals of type numParams (number of parameters)
%type <numParams> argument_expression_list argument_expression_list_opt

// Non-terminals of type expr (denoting expressions)
%type <expr> 
        expression
        primary_expression 
        multiplicative_expression
        additive_expression
        relational_expression
        equality_expression
        logical_and_expression
        logical_or_expression
        conditional_expression
        assignment_expression
        expression_statement

// Non-terminals of type stmt (denoting statements)
%type <stmt>
        statement
        compound_statement
        selection_statement
        iteration_statement
        jump_statement
        block_item
        block_item_list
        block_item_list_opt

// The pointer non-terminal is treated with type symbolType
%type <symType> pointer

// Non-terminals of type symp (symbol*)
%type <symp> constant initializer
%type <symp> direct_declarator init_declarator declarator interim interim_decl

// Non-terminals of type arr
%type <arr> postfix_expression unary_expression 

// Auxiliary non-terminal M of type instr to help in backpatching
%type <instr> M

// Auxiliary non-terminal N of type stmt to help in control flow statements
%type <stmt> N

%%

primary_expression: 
        IDENTIFIER
        {
            $$ = new expression();  // Create new expression
            $$->loc = $1;           // Store pointer to entry in the symbol table
            $$->type = "non_bool";
            // printf("primary expression from identifier\n");
        }
        | constant
        {
            $$ = new expression();  // Create new expression
            $$->loc = $1;           // Store pointer to entry in the symbol table
            // printf("primary expression from constant\n");
        }
        | STRING_LITERAL
        {
            $$ = new expression();  // Create new expression
            $$->loc = symbolTable::gentemp(new symbolType("ptr"), $1);  // Create a new temporary, and store the value in that temporary
            $$->loc->type->arrType = new symbolType("char");
        }
        | PARENTHESIS_OPEN expression PARENTHESIS_CLOSE
        {
            $$ = $2;    // Simple assignment
            // printf("primary expression from expression\n");
            if($2->type=="bool"){
                tempBoolT=$2;
            }
        }
        ;

constant: 
        INTEGER_CONSTANT
        {
            $$ = symbolTable::gentemp(new symbolType("int"), convertIntToString($1));   // Create a new temporary, and store the value in that temporary
            emit("=", $$->name, $1);
        }
        | CHAR_CONSTANT
        {
            $$ = symbolTable::gentemp(new symbolType("float"), string($1));     // Create a new temporary, and store the value in that temporary
            emit("=", $$->name, string($1));
        }
        ;

postfix_expression: 
        primary_expression
        {
            $$ = new Array();           // Create a new Array
            if($1->type!="bool"){
            $$->Array = $1->loc;        // Store the location of the primary expression
            $$->type = $1->loc->type;   // Update the type
            $$->loc = $$->Array;
            }
            else{
                $$->atype="boolT";
            }
            

        }
        | postfix_expression SQUARE_BRACE_OPEN expression SQUARE_BRACE_CLOSE
        {
            $$ = new Array();               // Create a new Array
            $$->type = $1->type->arrType;   // Set the type equal to the element type
            $$->Array = $1->Array;          // Copy the base
            $$->loc = symbolTable::gentemp(new symbolType("int"));  // Store address of new temporary
            $$->atype = "arr";              // Set atype to "arr"

            if($1->atype == "arr") {        // If we have an "arr" type then, multiply the size of the sub-type of Array with the expression value and add
                symbol* sym = symbolTable::gentemp(new symbolType("int"));
                int sz = sizeOfType($$->type);
                emit("*", sym->name, $3->loc->name, convertIntToString(sz));
                emit("+", $$->loc->name, $1->loc->name, sym->name);
            }
            else {                          // Compute the size
                int sz = sizeOfType($$->type);
                emit("*", $$->loc->name, $3->loc->name, convertIntToString(sz));
            }
        }
        | postfix_expression PARENTHESIS_OPEN argument_expression_list_opt PARENTHESIS_CLOSE
        {   
            // Corresponds to calling a function with the function name and the appropriate number of parameters
            $$ = new Array();
            $$->Array = symbolTable::gentemp($1->type);
            emit("call", $$->Array->name, $1->Array->name, convertIntToString($3));
        }
        | postfix_expression ARROW IDENTIFIER
        {
          // Ignored
        }
        ;

argument_expression_list_opt: 
        argument_expression_list
        {
            $$ = $1;    // Assign $1 to $$
        }
        | %empty
        {
            $$ = 0;     // No arguments, just equate to zero
        }
        ;

argument_expression_list: 
        assignment_expression
        {
            $$ = 1;                         // consider one argument
            emit("param", $1->loc->name);   // emit parameter
        }
        | argument_expression_list COMMA assignment_expression
        {
            $$ = $1 + 1;                    // consider one more argument, so add 1
            emit("param", $3->loc->name);   // emit parameter
        }
        ;

unary_expression: 
        postfix_expression
        {
            $$ = $1;    // Assign $1 to $$
        }
        | unary_operator unary_expression
        {
            // Case of unary operator
            $$ = new Array();
            switch($1) {
                case '&':   // Address
                    $$->Array = symbolTable::gentemp(new symbolType("ptr"));    // Generate a pointer temporary
                    $$->Array->type->arrType = $2->Array->type;                 // Assign corresponding type
                    emit("= &", $$->Array->name, $2->Array->name);              // Emit the quad
                    break;
                case '*':   // De-referencing
                    $$->atype = "ptr";
                    $$->loc = symbolTable::gentemp($2->Array->type->arrType);   // Generate a temporary of the appropriate type
                    $$->Array = $2->Array;                                      // Assign
                    emit("= *", $$->loc->name, $2->Array->name);                // Emit the quad
                    break;
                case '+':   // Unary plus
                    $$ = $2;    // Simple assignment
                    break;
                case '-':   // Unary minus
                    $$->Array = symbolTable::gentemp(new symbolType($2->Array->type->type));    // Generate temporary of the same base type
                    emit("= -", $$->Array->name, $2->Array->name);                              // Emit the quad
                    break;
                case '~':   // Bitwise not
                    $$->Array = symbolTable::gentemp(new symbolType($2->Array->type->type));    // Generate temporary of the same base type
                    emit("= ~", $$->Array->name, $2->Array->name);                              // Emit the quad
                    break;
                case '!':   // Logical not 
                    // Emit the quad
                    if($2->atype=="boolT"){
                        list<int> l=tempBoolT->falselist;
                        tempBoolT->truelist=tempBoolT->falselist;
                        tempBoolT->falselist=l;
                        $$->atype="boolT";
                    }
                    else{
                        $$->Array = symbolTable::gentemp(new symbolType($2->Array->type->type));    // Generate temporary of the same base type
                        emit("= !", $$->Array->name, $2->Array->name);    
                    }
                    break;
            }
        }
        ;

unary_operator:
        BITWISE_AND
        {
            $$ = '&';
        }
        | MULTIPLY
        {
            $$ = '*';
        }
        | ADD
        {
            $$ = '+';
        }
        | SUBTRACT
        {
            $$ = '-';
        }
        | NOT
        {
            $$ = '!';
        }
        ;

multiplicative_expression: 
        unary_expression
        {
            $$ = new expression();          // Generate new expression
            if($1->atype == "arr") {        // atype "arr"
                $$->loc = symbolTable::gentemp($1->loc->type);  // Generate new temporary
                emit("=[]", $$->loc->name, $1->Array->name, $1->loc->name);     // Emit the quad
            }
            else if($1->atype == "ptr") {   // atype "ptr"
                $$->loc = $1->loc;          // Assign the symbol table entry
            }
            else if($1->atype == "boolT"){
                $$=tempBoolT;
            }
            else {
                $$->loc = $1->Array;
            }
        }
        | multiplicative_expression MULTIPLY unary_expression
        {   
            // Indicates multiplication
            if(typecheck($1->loc, $3->Array)) {     // Check for type compatibility
                $$ = new expression();                                                  // Generate new expression
                $$->loc = symbolTable::gentemp(new symbolType($1->loc->type->type));    // Generate new temporary
                emit("*", $$->loc->name, $1->loc->name, $3->Array->name);               // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        | multiplicative_expression DIVIDE unary_expression
        {
            // Indicates division
            if(typecheck($1->loc, $3->Array)) {     // Check for type compatibility
                $$ = new expression();                                                  // Generate new expression
                $$->loc = symbolTable::gentemp(new symbolType($1->loc->type->type));    // Generate new temporary
                emit("/", $$->loc->name, $1->loc->name, $3->Array->name);               // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        | multiplicative_expression MODULO unary_expression
        {
            // Indicates modulo
            if(typecheck($1->loc, $3->Array)) {     // Check for type compatibility
                $$ = new expression();                                                  // Generate new expression
                $$->loc = symbolTable::gentemp(new symbolType($1->loc->type->type));    // Generate new temporary
                emit("%", $$->loc->name, $1->loc->name, $3->Array->name);               // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        ;

additive_expression: 
        multiplicative_expression
        {
            $$ = $1;    // Simple assignment
        }
        | additive_expression ADD multiplicative_expression
        {   
            // Indicates addition
            if(typecheck($1->loc, $3->loc)) {       // Check for type compatibility
                $$ = new expression();                                                  // Generate new expression
                $$->loc = symbolTable::gentemp(new symbolType($1->loc->type->type));    // Generate new temporary
                emit("+", $$->loc->name, $1->loc->name, $3->loc->name);                 // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        | additive_expression SUBTRACT multiplicative_expression
        {
            // Indicates subtraction
            if(typecheck($1->loc, $3->loc)) {       // Check for type compatibility
                $$ = new expression();                                                  // Generate new expression
                $$->loc = symbolTable::gentemp(new symbolType($1->loc->type->type));    // Generate new temporary
                emit("-", $$->loc->name, $1->loc->name, $3->loc->name);                 // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        ;

relational_expression: 
        additive_expression
        {
            $$ = $1;    // Simple assignment
            // printf("relational from just additive\n");
        }
        | relational_expression LESS_THAN additive_expression
        {
            if(typecheck($1->loc, $3->loc)) {                   // Check for type compatibility
                $$ = new expression();                          // Generate new expression of type bool
                $$->type = "bool";
                $$->truelist = makelist(nextinstr());           // Create truelist for boolean expression
                $$->falselist = makelist(nextinstr() + 1);      // Create falselist for boolean expression
                emit("<", "", $1->loc->name, $3->loc->name);    // Emit "if x < y goto ..."
                emit("goto", "");                               // Emit "goto ..."
            }
            else {
                yyerror("Type Error");
            }
        }
        | relational_expression GREATER_THAN additive_expression
        {
            if(typecheck($1->loc, $3->loc)) {                   // Check for type compatibility
                $$ = new expression();                          // Generate new expression of type bool
                $$->type = "bool";
                $$->truelist = makelist(nextinstr());           // Create truelist for boolean expression
                $$->falselist = makelist(nextinstr() + 1);      // Create falselist for boolean expression
                emit(">", "", $1->loc->name, $3->loc->name);    // Emit "if x > y goto ..."
                emit("goto", "");                               // Emit "goto ..."
            }
            else {
                yyerror("Type Error");
            }
        }
        | relational_expression LESS_THAN_EQUAL additive_expression
        {
            if(typecheck($1->loc, $3->loc)) {                   // Check for type compatibility
                $$ = new expression();                          // Generate new expression of type bool
                $$->type = "bool";
                $$->truelist = makelist(nextinstr());           // Create truelist for boolean expression
                $$->falselist = makelist(nextinstr() + 1);      // Create falselist for boolean expression
                emit("<=", "", $1->loc->name, $3->loc->name);   // Emit "if x <= y goto ..."
                emit("goto", "");                               // Emit "goto ..."
            }
            else {
                yyerror("Type Error");
            }
        }
        | relational_expression GREATER_THAN_EQUAL additive_expression
        {
            if(typecheck($1->loc, $3->loc)) {                   // Check for type compatibility
                $$ = new expression();                          // Generate new expression of type bool
                $$->type = "bool";
                $$->truelist = makelist(nextinstr());           // Create truelist for boolean expression
                $$->falselist = makelist(nextinstr() + 1);      // Create falselist for boolean expression
                emit(">=", "", $1->loc->name, $3->loc->name);   // Emit "if x >= y goto ..."
                emit("goto", "");                               // Emit "goto ..."
            }
            else {
                yyerror("Type Error");
            }
        }
        ;

equality_expression: 
        relational_expression
        {
            $$ = $1;    // Simple assignment
            // printf("equality from just relational\n");

        }
        | equality_expression EQUAL relational_expression
        {
            if(typecheck($1->loc, $3->loc)) {                   // Check for type compatibility
                convertBoolToInt($1);                           // Convert bool to int
                convertBoolToInt($3);
                $$ = new expression();                          // Generate new expression of type bool
                $$->type = "bool";
                $$->truelist = makelist(nextinstr());           // Create truelist for boolean expression
                $$->falselist = makelist(nextinstr() + 1);      // Create falselist for boolean expression
                emit("==", "", $1->loc->name, $3->loc->name);   // Emit "if x == y goto ..."
                emit("goto", "");                               // Emit "goto ..."
                
            }
            else {
                yyerror("Type Error");
            }
        }
        | equality_expression NOT_EQUAL relational_expression
        {
            if(typecheck($1->loc, $3->loc)) {                   // Check for type compatibility
                convertBoolToInt($1);                           // Convert bool to int
                convertBoolToInt($3);
                $$ = new expression();                          // Generate new expression of type bool
                $$->type = "bool";
                $$->truelist = makelist(nextinstr());           // Create truelist for boolean expression
                $$->falselist = makelist(nextinstr() + 1);      // Create falselist for boolean expression
                emit("!=", "", $1->loc->name, $3->loc->name);   // Emit "if x != y goto ..."
                emit("goto", "");                               // Emit "goto ..."
            }
            else {
                yyerror("Type Error");
            }
        }
        ;

logical_and_expression: 
        equality_expression
        {
            $$ = $1;    // Simple assignment
        }
        | logical_and_expression LOGICAL_AND M equality_expression
        {
            
            //    Here, we have augmented the grammar with the non-terminal M to facilitate backpatching
            
            convertIntToBool($1);                                   // Convert the expressions from int to bool
            convertIntToBool($4);
            $$ = new expression();                                  // Create a new bool expression for the result
            $$->type = "bool";
            backpatch($1->truelist, $3);                            // Backpatching
            $$->truelist = $4->truelist;                            // Generate truelist from truelist of $4
            $$->falselist = merge($1->falselist, $4->falselist);    // Generate falselist by merging the falselists of $1 and $4
        }
        ; 


logical_or_expression: 
        logical_and_expression
        {
            $$ = $1;    // Simple assignment
        }
        | logical_or_expression LOGICAL_OR M logical_and_expression
        {
            convertIntToBool($1);                                   // Convert the expressions from int to bool
            convertIntToBool($4);
            $$ = new expression();                                  // Create a new bool expression for the result
            $$->type = "bool";
            backpatch($1->falselist, $3);                           // Backpatching
            $$->falselist = $4->falselist;                          // Generate falselist from falselist of $4
            $$->truelist = merge($1->truelist, $4->truelist);       // Generate truelist by merging the truelists of $1 and $4
        }
        ;

conditional_expression: 
        logical_or_expression
        {
            $$ = $1;    // Simple assignment
        }
        | logical_or_expression N QUESTION_MARK M expression N COLON M conditional_expression
        {   
            /*
                Note the augmented grammar with the non-terminals M and N
            */
            $$->loc = symbolTable::gentemp($5->loc->type);      // Generate temporary for the expression
            $$->loc->update($5->loc->type);
            emit("=", $$->loc->name, $9->loc->name);            // Assign the conditional expression
            list<int> l1 = makelist(nextinstr());
            emit("goto", "");                                   // Prevent fall-through
            backpatch($6->nextlist, nextinstr());               // Make list with next instruction
            emit("=", $$->loc->name, $5->loc->name);
            list<int> l2 = makelist(nextinstr());               // Make list with next instruction
            l1 = merge(l1, l2);                                 // Merge the two lists
            emit("goto", "");                                   // Prevent fall-through
            backpatch($2->nextlist, nextinstr());               // Backpatching
            convertIntToBool($1);                               // Convert expression to bool
            backpatch($1->truelist, $4);                        // When $1 is true, control goes to $4 (expression)
            backpatch($1->falselist, $8);                       // When $1 is false, control goes to $8 (conditional_expression)
            backpatch(l1, nextinstr());
        }
        ;


M: %empty
        {   
            // Stores the next instruction value, and helps in backpatching
            $$ = nextinstr();
        }
        ;

N: %empty
        {
            // Helps in control flow
            $$ = new statement();
            $$->nextlist = makelist(nextinstr());
            emit("goto", "");
        }
        ;

assignment_expression: 
        conditional_expression
        {
            $$ = $1;    // Simple assignment
        }
        | unary_expression ASSIGN assignment_expression
        {
            if($1->atype == "arr") {        // If atype is "arr", convert and emit
                $3->loc = convertType($3->loc, $1->type->type);
                emit("[]=", $1->Array->name, $1->loc->name, $3->loc->name);
            }
            else if($1->atype == "ptr") {   // If atype is "ptr", emit 
                emit("*=", $1->Array->name, $3->loc->name);
            }
            else {
                $3->loc = convertType($3->loc, $1->Array->type->type);
                emit("=", $1->Array->name, $3->loc->name);
            }
            $$ = $3;
        }
        ;

expression: 
        assignment_expression
        {
            $$ = $1;
        }
        ;

declaration: 
        type_specifier init_declarator SEMICOLON
        {
          // Ignored
        }
        ;

init_declarator: 
        declarator
        {
            $$ = $1;
        }
        | declarator ASSIGN initializer
        {   
            // Find out the initial value and emit it
            if($3->value != "") {
                $1->value = $3->value;
            }
            emit("=", $1->name, $3->name);
        }
        ;

type_specifier: 
        VOID
        {
            varType = "void";   // Store the latest encountered type in varType
        }
        | CHAR
        {
            varType = "char";   // Store the latest encountered type in varType
        }
        | INT
        {
            varType = "int";    // Store the latest encountered type in varType
            // printf("int type specifier touched\n");
        }
        ;

declarator: 
        pointer direct_declarator
        {
            symbolType* t = $1;
            // In case of multi-dimesnional arrays, keep on going down in a hierarchial fashion to get the base type
            while(t->arrType != NULL) {
                t = t->arrType;
            }
            t->arrType = $2->type;  // Store the base type
            $$ = $2->update($1);    // Update
        }
        | direct_declarator
        {
            // Ignored
        }
        ;

interim_decl:
        pointer interim
        {
            symbolType* t = $1;
            // In case of multi-dimesnional arrays, keep on going down in a hierarchial fashion to get the base type
            while(t->arrType != NULL) {
                t = t->arrType;
            }
            t->arrType = $2->type;  // Store the base type
            $$ = $2->update($1);    // Update
        }
        | interim
        {
            // Ignored
        }

interim:IDENTIFIER
        {
            $$ = $1->update(new symbolType(varType));   // For an identifier, update the type to varType
            currentSymbol = $$;                         // Update pointer to current symbol
        }

direct_declarator: 
        IDENTIFIER
        {
            $$ = $1->update(new symbolType(varType));   // For an identifier, update the type to varType
            currentSymbol = $$;                         // Update pointer to current symbol
        }
        | interim SQUARE_BRACE_OPEN INTEGER_CONSTANT SQUARE_BRACE_CLOSE
        {
            symbolType* t = $1->type;
            symbolType* prev = NULL;
            // Keep moving recursively to get the base type
            while(t->type == "arr") {
                prev = t;
                t = t->arrType;
            }
            if(prev == NULL) {
                int temp = $3;                // Get initial value
                symbolType* tp = new symbolType("arr", $1->type, temp); // Create that type
                $$ = $1->update(tp);                                    // Update the symbol table for that symbol
            }
            else {
                int temp = $3;                // Get initial value
                prev->arrType = new symbolType("arr", t, temp);         // Create that type
                $$ = $1->update($1->type);                              // Update the symbol table for that symbol
            }
        }
        
        | interim PARENTHESIS_OPEN change_table parameter_type_list PARENTHESIS_CLOSE
        {
            currentST->name = $1->name;
            if($1->type->type != "void") {
                symbol* s = currentST->lookup("return");    // Lookup for return value
                s->update($1->type);
            }
            $1->nestedTable = currentST;
            currentST->parent = globalST;   // Update parent symbol table
            switchTable(globalST);          // Switch current table to point to the global symbol table
            currentSymbol = $$;             // Update current symbol
        }
        | interim PARENTHESIS_OPEN change_table PARENTHESIS_CLOSE
        {
            currentST->name = $1->name;
            if($1->type->type != "void") {
                symbol* s = currentST->lookup("return");    // Lookup for return value
                s->update($1->type);
            }
            $1->nestedTable = currentST;
            currentST->parent = globalST;   // Update parent symbol table
            switchTable(globalST);          // Switch current table to point to the global symbol table
            currentSymbol = $$;             // Update current symbol
        }
        ;

pointer: 
        MULTIPLY 
        {
            $$ = new symbolType("ptr");     //  Create new type "ptr"
        }
        ;

parameter_type_list: 
        parameter_list
        {
          // Ignored
        }
        | parameter_list COMMA ELLIPSIS
        {
          // Ignored
        }
        ;

parameter_list: 
        parameter_declaration
        {
          // Ignored
        }
        | parameter_list COMMA parameter_declaration
        {
          // Ignored
        }
        ;

parameter_declaration: 
        type_specifier interim_decl
        {
          // Ignored
        }
        | type_specifier
        {
          // Ignored
        }
        ;

initializer: 
        assignment_expression
        {
            $$ = $1->loc;   // Simple assignment
        }     
        ;
        
statement: 
        compound_statement
        {
            $$ = $1;    // Simple assignment
        }
        | expression_statement
        {
            $$ = new statement();           // Create new statement
            $$->nextlist = $1->nextlist;    // Assign same nextlist
        }
        | selection_statement
        {
            $$ = $1;    // Simple assignment
        }
        | iteration_statement
        {
            $$ = $1;    // Simple assignment
        }
        | jump_statement
        {
            $$ = $1;    // Simple assignment
        }
        ;

/* New non-terminal that has been added to facilitate the structure of loops */

compound_statement: 
        CURLY_BRACE_OPEN X change_table block_item_list_opt CURLY_BRACE_CLOSE
        {
            $$ = $4;
            switchTable(currentST->parent);     // Update current symbol table
        }
        ;

block_item_list_opt: 
        block_item_list
        {
            $$ = $1;    // Simple assignment
        }
        | %empty
        {
            $$ = new statement();   // Create new statement
        }
        ;

block_item_list: 
        block_item
        {
            $$ = $1;    // Simple assignment
        }
        | block_item_list M block_item
        {   
            /*
                This production rule has been augmented with the non-terminal M
            */
            $$ = $3;
            backpatch($1->nextlist, $2);    // After $1, move to block_item via $2
        }
        ;

block_item: 
        declaration
        {
            $$ = new statement();   // Create new statement
        }
        | statement
        {
            $$ = $1;    // Simple assignment
        }
        ;

expression_statement: 
        expression SEMICOLON
        {
            $$ = $1;    // Simple assignment
        }
        | SEMICOLON
        {
            $$ = new expression();  // Create new expression
        }
        ;

selection_statement: 
        IF PARENTHESIS_OPEN expression N PARENTHESIS_CLOSE M statement N %prec THEN
        {
            /*
                This production rule has been augmented for control flow
            */
            backpatch($4->nextlist, nextinstr());                   // nextlist of N now has nextinstr
            convertIntToBool($3);                                   // Convert expression to bool
            $$ = new statement();                                   // Create new statement
            backpatch($3->truelist, $6);                            // Backpatching - if expression is true, go to M
            // Merge falselist of expression, nextlist of statement and nextlist of the last N
            list<int> temp = merge($3->falselist, $7->nextlist);
            $$->nextlist = merge($8->nextlist, temp);
        }
        | IF PARENTHESIS_OPEN expression N PARENTHESIS_CLOSE M statement N ELSE M statement
        {
            /*
                This production rule has been augmented for control flow
            */
            backpatch($4->nextlist, nextinstr());                   // nextlist of N now has nextinstr
            convertIntToBool($3);                                   // Convert expression to bool
            $$ = new statement();                                   // Create new statement
            backpatch($3->truelist, $6);                            // Backpatching - if expression is true, go to first M, else go to second M
            backpatch($3->falselist, $10);
            // Merge nextlist of statement, nextlist of N and nextlist of the last statement
            list<int> temp = merge($7->nextlist, $8->nextlist);
            $$->nextlist = merge($11->nextlist, temp);
        }
        ;

iteration_statement: 
        FOR F PARENTHESIS_OPEN X change_table declaration M expression_statement M expression N PARENTHESIS_CLOSE M statement
        {
            /*
                This production rule has been augmented with non-terminals like F, X, change_table and M to handle the control flow, 
                backpatching, detect the kind of loop, create a separate symbol table for the loop block and give it an appropriate name
            */
            $$ = new statement();                   // Create a new statement
            convertIntToBool($8);                   // Convert expression to bool
            backpatch($8->truelist, $13);           // Go to M3 if expression is true
            backpatch($11->nextlist, $7);           // Go back to M1 after N
            backpatch($14->nextlist, $9);           // Go back to expression after loop_statement
            emit("goto", convertIntToString($9));   // Emit to prevent fall-through
            $$->nextlist = $8->falselist;           // Exit loop if expression_statement is false
            blockName = "";
            switchTable(currentST->parent);
        }
        | FOR F PARENTHESIS_OPEN X change_table expression_statement M expression_statement M expression N PARENTHESIS_CLOSE M statement
        {
            /*
                This production rule has been augmented with non-terminals like F, X, change_table and M to handle the control flow, 
                backpatching, detect the kind of loop, create a separate symbol table for the loop block and give it an appropriate name
            */
            $$ = new statement();                   // Create a new statement
            convertIntToBool($8);                   // Convert expression to bool
            backpatch($8->truelist, $13);           // Go to M3 if expression is true
            backpatch($11->nextlist, $7);           // Go back to M1 after N
            backpatch($14->nextlist, $9);           // Go back to expression after loop_statement
            emit("goto", convertIntToString($9));   // Emit to prevent fall-through
            $$->nextlist = $8->falselist;           // Exit loop if expression_statement is false
            blockName = "";
            switchTable(currentST->parent);
        }
        | FOR F PARENTHESIS_OPEN X change_table declaration M expression_statement M expression N PARENTHESIS_CLOSE M CURLY_BRACE_OPEN block_item_list_opt CURLY_BRACE_CLOSE
        {
            /*
                This production rule has been augmented with non-terminals like F, X, change_table and M to handle the control flow, 
                backpatching, detect the kind of loop, create a separate symbol table for the loop block and give it an appropriate name
            */
            $$ = new statement();                   // Create a new statement
            convertIntToBool($8);                   // Convert expression to bool
            backpatch($8->truelist, $13);           // Go to M3 if expression is true
            backpatch($11->nextlist, $7);           // Go back to M1 after N
            backpatch($15->nextlist, $9);           // Go back to expression after loop_statement
            emit("goto", convertIntToString($9));   // Emit to prevent fall-through
            $$->nextlist = $8->falselist;           // Exit loop if expression_statement is false
            blockName = "";
            switchTable(currentST->parent);
        }
        | FOR F PARENTHESIS_OPEN X change_table expression_statement M expression_statement M expression N PARENTHESIS_CLOSE M CURLY_BRACE_OPEN block_item_list_opt CURLY_BRACE_CLOSE
        {
            /*
                This production rule has been augmented with non-terminals like F, X, change_table and M to handle the control flow, 
                backpatching, detect the kind of loop, create a separate symbol table for the loop block and give it an appropriate name
            */
            $$ = new statement();                   // Create a new statement
            convertIntToBool($8);                   // Convert expression to bool
            backpatch($8->truelist, $13);           // Go to M3 if expression is true
            backpatch($11->nextlist, $7);           // Go back to M1 after N
            backpatch($15->nextlist, $9);           // Go back to expression after loop_statement
            emit("goto", convertIntToString($9));   // Emit to prevent fall-through
            $$->nextlist = $8->falselist;           // Exit loop if expression_statement is false
            blockName = "";
            switchTable(currentST->parent);
        }
        ;

F: %empty
        {   
            /*
            This non-terminal indicates the start of a for loop
            */
            blockName = "FOR";
        }
        ;

X: %empty
        {   
            // Used for creating new nested symbol tables for nested blocks
            string newST = currentST->name + "." + blockName + "$" + to_string(STCount++);  // Generate name for new symbol table
            symbol* sym = currentST->lookup(newST);
            sym->nestedTable = new symbolTable(newST);  // Create new symbol table
            sym->name = newST;
            sym->nestedTable->parent = currentST;
            sym->type = new symbolType("block");    // The type will be "block"
            currentSymbol = sym;    // Change the current symbol pointer
        }
        ;

change_table: %empty
        {   
            // Used for changing the symbol table on encountering functions
            if(currentSymbol->nestedTable != NULL) {
                // If the symbol table already exists, switch to that table
                switchTable(currentSymbol->nestedTable);
                emit("label", currentST->name);
            }
            else {
                // If the symbol table does not exist already, create it and switch to it
                switchTable(new symbolTable(""));
            }
        }
        ;

jump_statement: 
        RETURN expression SEMICOLON
        {
            $$ = new statement();
            emit("return", $2->loc->name);  // Emit return alongwith return value
        }
        | RETURN SEMICOLON
        {
            $$ = new statement();
            emit("return", "");             // Emit return without any return value
        }
        ;

translation_unit: 
        external_declaration
        {
          // Ignored
        }
        | external_declaration translation_unit
        {
          // Ignored
        }
        ;

external_declaration: 
        function_definition
        {
          // Ignored
        }
        | declaration
        {
          // Ignored
        }
        ;

function_definition: 
        type_specifier declarator change_table CURLY_BRACE_OPEN block_item_list_opt CURLY_BRACE_CLOSE
        {   
            currentST->parent = globalST;
            STCount = 0;
            switchTable(globalST);          // After reaching end of a function, change cureent symbol table to the global symbol table
        }
        ;

%%

void yyerror(string s) {
    /*
        This function prints any error encountered while parsing
    */
    cout << "Error occurred: " << s << endl;
    cout << "Line no.: " << yylineno << endl;
    cout << "Unable to parse: " << yytext << endl; 
}
