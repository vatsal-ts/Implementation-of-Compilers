%{
#include <stdio.h>
	extern int yylex();
	void yyerror(const char *);
	extern char *yytext;
	extern int yylineno;
%}

%union
{
	float floatval;
	char *charval;
	int intval;
}
		
%token CHAR 
%token ELSE 
%token FOR 
%token IF 
%token INT 
%token RETURN 
%token VOID 

%token PARENTHESISOPEN 
%token PARENTHESISCLOSE 
%token CURBOPEN 
%token CURBCLOSE 
%token SQRBROPEN 
%token SQRBRCLOSE 
%token BITWISE_AND 

%token MUL 
%token ADD 
%token SUB 
%token NOT 
%token MODULO 
%token LESS_THAN 
%token GREATER_THAN 
%token COLON 
%token SEMICOLON 
%token ASSIGNMENT 
%token TERNARY_OP 
%token FORWARD_SLASH 
%token COMMA

		
%token ARROW 
%token GREATER_THAN_EQUAL 
%token LESS_THAN_EQUAL 
%token NOT_EQUAL 
%token EQUALITY 
%token OR 
%token AND 

		
%token WHITESPACE 
%token COMMENT 
%token IDENTIFIER 
%token INTEGER_CONSTANT 
%token CHARACTER_CONSTANT 
%token STRING_LITERAL

%start translation_unit

/* Below list is the set of all Production Rules */

%%
constant : INTEGER_CONSTANT |
	CHARACTER_CONSTANT;

primary_expression : IDENTIFIER
{
	yellow();printf("primary_expression\n");reset();
}
| constant
{
	yellow();printf("primary_expression\n");reset();
}
| STRING_LITERAL
{
	yellow();printf("primary_expression\n");reset();
}
| PARENTHESISOPEN expression PARENTHESISCLOSE
{
	yellow();printf("primary_expression\n");reset();
};

postfix_expression : primary_expression
{
	yellow();printf("primary_expression\n");reset();
}
| postfix_expression SQRBROPEN expression SQRBRCLOSE
{
	yellow();printf("postfix_expression\n");reset();
}
| postfix_expression PARENTHESISOPEN PARENTHESISCLOSE
{
	yellow();printf("postfix_expression\n");reset();
}
| postfix_expression PARENTHESISOPEN argument_expression_list PARENTHESISCLOSE
{
	yellow();printf("postfix_expression\n");reset();
}
| postfix_expression ARROW IDENTIFIER
{
	yellow();printf("postfix_expression\n");reset();
};

argument_expression_list : assignment_expression
{
	yellow();printf("argument_expression_list\n");reset();
}
| argument_expression_list COMMA assignment_expression
{
	yellow();printf("argument_expression_list\n");reset();
};

unary_expression : postfix_expression
{
	yellow();printf("unary_expression\n");reset();
}
| unary_operator unary_expression
{
	yellow();printf("unary_expression\n");reset();
};

unary_operator : BITWISE_AND
{
	yellow();printf("unary_operator\n");reset();
}
| MUL
{
	yellow();printf("unary_operator\n");reset();
}
| ADD
{
	yellow();printf("unary_operator\n");reset();
}
| SUB
{
	yellow();printf("unary_operator\n");reset();
}
| NOT
{
	yellow();printf("unary_operator\n");reset();
};

multiplicative_expression : unary_expression
{
	yellow();printf("multiplicative_expression\n");reset();
}
| multiplicative_expression MUL unary_expression
{
	yellow();printf("multiplicative_expression\n");reset();
}
| multiplicative_expression FORWARD_SLASH unary_expression
{
	yellow();printf("multiplicative_expression\n");reset();
}
| multiplicative_expression MODULO unary_expression
{
	yellow();printf("multiplicative_expression\n");reset();
};

additive_expression : multiplicative_expression
{
	yellow();printf("additive_expression\n");reset();
}
| additive_expression ADD multiplicative_expression
{
	yellow();printf("additive_expression\n");reset();
}
| additive_expression SUB multiplicative_expression
{
	yellow();printf("additive_expression\n");reset();
};

relational_expression : additive_expression
{
	yellow();printf("relational_expression\n");reset();
}
| relational_expression LESS_THAN additive_expression
{
	yellow();printf("relational_expression\n");reset();
}
| relational_expression GREATER_THAN additive_expression
{
	yellow();printf("relational_expression\n");reset();
}
| relational_expression LESS_THAN_EQUAL additive_expression
{
	yellow();printf("relational_expression\n");reset();
}
| relational_expression GREATER_THAN_EQUAL additive_expression
{
	yellow();printf("relational_expression\n");reset();
};

equality_expression : relational_expression
{
	yellow();printf("equality_expression\n");reset();
}
| equality_expression EQUALITY relational_expression
{
	yellow();printf("equality_expression\n");reset();
}
| equality_expression NOT_EQUAL relational_expression
{
	yellow();printf("equality_expression\n");reset();
};

logical_and_expression : equality_expression
{
	yellow();printf("logical_and_expression\n");reset();
}
| logical_and_expression AND equality_expression
{
	yellow();printf("logical_and_expression\n");reset();
};

logical_or_expression : logical_and_expression
{
	yellow();printf("logical_or_expression\n");reset();
}
| logical_or_expression OR logical_and_expression
{
	yellow();printf("logical_or_expression\n");reset();
};

conditional_expression : logical_or_expression
{
	yellow();printf("conditional_expression\n");reset();
}
| logical_or_expression TERNARY_OP expression COLON conditional_expression
{
	yellow();printf("conditional_expression\n");reset();
};

assignment_expression : conditional_expression
{
	yellow();printf("assignment_expression\n");reset();
}
| unary_expression ASSIGNMENT assignment_expression
{
	yellow();printf("assignment_expression\n");reset();
};


expression : assignment_expression
{
	yellow();printf("expression\n");reset();
}

expression_optional : expression | %empty;

declaration : type_specifier init_declarator SEMICOLON
{
	yellow();printf("declaration\n");reset();
};

init_declarator : declarator
{
	yellow();printf("init_declarator\n");reset();
}
| declarator ASSIGNMENT initializer
{
	yellow();printf("init_declarator\n");reset();
};


type_specifier : VOID
{
	yellow();printf("type_specifier\n");reset();
}
| CHAR
{
	yellow();printf("type_specifier\n");reset();
}
| INT
{
	yellow();printf("type_specifier\n");reset();
};



declarator : pointer direct_declarator
{
	yellow();printf("declarator\n");reset();
}
| direct_declarator
{
	yellow();printf("declarator\n");reset();
};

direct_declarator : IDENTIFIER
{
	yellow();printf("direct_declarator\n");reset();
}
| IDENTIFIER SQRBROPEN INTEGER_CONSTANT SQRBRCLOSE
{
	yellow();printf("direct_declarator\n");reset();
}
| IDENTIFIER PARENTHESISOPEN PARENTHESISCLOSE
{
	yellow();printf("direct_declarator\n");reset();
}
| IDENTIFIER PARENTHESISOPEN parameter_list PARENTHESISCLOSE
{
	yellow();printf("direct_declarator\n");reset();
}

/* assignment_expression_opt : %empty
{
	yellow();printf("assignment_expression_opt\n");reset();
}
| assignment_expression
{
	yellow();printf("assignment_expression_opt\n");reset();
}; */



pointer : MUL
{
	yellow();printf("pointer\n");reset();
}

parameter_list : parameter_declaration
{
	yellow();printf("parameter_list\n");reset();
}
| parameter_list COMMA parameter_declaration
{
	yellow();printf("parameter_list\n");reset();
};



parameter_declaration : type_specifier
{
	yellow();printf("parameter_declaration\n");reset();
}
| type_specifier pointer
{
	yellow();printf("parameter_declaration\n");reset();
};
| type_specifier IDENTIFIER
{
	yellow();printf("parameter_declaration\n");reset();
};
| type_specifier pointer IDENTIFIER
{
	yellow();printf("parameter declaration\nreset();");
}

initializer : assignment_expression
{
	yellow();printf("initializer\n");reset();
}

statement : compound_statement
{
	yellow();printf("statement\n");reset();
}
| expression_statement
{
	yellow();printf("statement\n");reset();
}
| selection_statement
{
	yellow();printf("statement\n");reset();
}
| iteration_statement
{
	yellow();printf("statement\n");reset();
}
| jump_statement
{
	yellow();printf("statement\n");reset();
};


compound_statement : CURBOPEN CURBCLOSE
{
	yellow();printf("compound_statement\n");reset();
}
| CURBOPEN block_item_list CURBCLOSE
{
	yellow();printf("compound_statement\n");reset();
};

block_item_list : block_item
{
	yellow();printf("block_item_list\n");reset();
}
| block_item_list block_item
{
	yellow();printf("block_item_list\n");reset();
};

block_item : declaration
{
	yellow();printf("block_item\n");reset();
}
| statement
{
	yellow();printf("block_item\n");reset();
};

expression_statement : SEMICOLON
{
	yellow();printf("expression_statement\n");reset();
}
| expression SEMICOLON
{
	yellow();printf("expression_statement\n");reset();
};

selection_statement : IF PARENTHESISOPEN expression PARENTHESISCLOSE statement //%prec IF
{
	yellow();printf("selection_statement\n");reset();
}
| IF PARENTHESISOPEN expression PARENTHESISCLOSE statement ELSE statement
{
	yellow();printf("selection_statement\n");reset();
}

iteration_statement : FOR PARENTHESISOPEN expression_optional SEMICOLON expression_optional SEMICOLON expression_optional PARENTHESISCLOSE statement
{
	yellow();printf("iteration_statement\n");reset();
}

jump_statement : RETURN SEMICOLON
{
	yellow();printf("jump_statement\n");reset();
};
| RETURN expression SEMICOLON
{
	yellow();printf("jump_statement\n");reset();
};

external_declaration : function_definition
{
	yellow();printf("external_declaration\n");reset();
}
| declaration
{
	yellow();printf("external_declaration\n");reset();
};

translation_unit : external_declaration
{
	yellow();printf("translation_unit\n");reset();
}
| external_declaration translation_unit
{
	yellow();printf("translation_unit\n");reset();
};

function_definition : type_specifier declarator compound_statement
{
	yellow();printf("function_definition\n");reset();
}
/* | type_specifier declarator PARENTHESISOPEN declaration_list PARENTHESISCLOSE compound_statement
{
	yellow();printf("function_definition\n");reset();
} */

declaration_list : declaration
{
	yellow();printf("declaration_list\n");reset();
}
| declaration_list declaration
{
	yellow();printf("declaration_list\n");reset();
};
%%

void yyerror(const char *s)
{
	yellow();printf("type of error is: %s\n", s);
	yellow();printf("ERROR is: %s\n", yytext);
	yellow();printf("Line Number is: %d\n", yylineno);
}
