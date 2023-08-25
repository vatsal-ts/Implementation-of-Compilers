%{
#include <stdio.h>
#include <string.h>
/*
#define SINGLE_LINE_COMM 	1
#define MULTI_LINE_COMM 	2

// keywords
#define red();printf("TOKEN:\t				3\n");reset();RETURN 				3
#define VOID 				4     
#define CHAR 				5
#define FOR 				6     
#define IF 					7
#define INT 				8
#define ELSE 				9

#define IDENTIFIER 			10
#define INTEGER_CONSTANT 	11
#define CHARACTER_CONSTANT 	12
#define STRING_LITERAL 		13
#define BOOLEAN_CONSTANT	14
#define SQRBROPEN 			15  
#define SQRBRCLOSE 			16  
#define RORBROPEN 			17
#define RORBRCLOSE 			18
#define CURBROPEN 			19
#define CURBRCLOSE 			20
#define DOT 				21  
#define ARWCOM 				22  
#define AMPSND 				23  
#define MUL 				24
#define ADD 				25
#define SUB 				26
#define NEG 				27
#define EXCLAIM 			28   
#define DIV 				29   
#define MODULO 				30   
#define LST 	 			31
#define GRT 				32
#define LTE 				33   
#define GTE 				34
#define EQL 				35   
#define NEQ 				36
#define AND 				37
#define OR 					38
#define QUESTION 			39   
#define COLON 				40   
#define SEMICOLON 			41
#define ASSIGN 				42
#define STAREQ 				43
#define DIVEQ 				44
#define MODEQ 				45
#define PLUSEQ 				46
#define MINUSEQ 			47
#define COMMA 				48  
*/
#include "y.tab.h"
%}
%option yylineno
/* Regular Expression Definitions */

/*KEYWORDS char else for if int red();printf("TOKEN:\tvoid\n");reset();return void*/
KEYWORD						"char"|"else"|"for"|"if"|"int"|"return"|"void"	

/*IDENTIFIERS*/
DIGIT						[0-9]
IDENTIFIER_NONDIGIT 		"_"|[a-zA-Z]
IDENTIFIER 					{IDENTIFIER_NONDIGIT}({IDENTIFIER_NONDIGIT}|{DIGIT})*


/*CONSTANTS*/
SIGN 						"-"|"+"
NONZERO_DIGIT				[1-9]
NONZERO_INTEGER_CONSTANT	{SIGN}?{NONZERO_DIGIT}({NONZERO_DIGIT}|{DIGIT})*
INTEGER_CONSTANT			({SIGN}?"0")|({NONZERO_INTEGER_CONSTANT})
/*changed from defiiton to incorporate 0*/

ESCAPE_SEQUENCE				"\\"("\'"|"\""|"\?"|"\\"|"a"|"b"|"f"|"n"|"r"|"t"|"v")
C_CHAR 						{ESCAPE_SEQUENCE}|[^("\'"|"\\"|"\n")]
C_CHAR_SEQUENCE				{C_CHAR}+
CHARACTER_CONSTANT			"\'"{C_CHAR_SEQUENCE}"\'"

CONSTANT {INTEGER_CONSTANT}|{CHARACTER_CONSTANT}

/*STRING_LITERALS*/
S_CHAR  					{ESCAPE_SEQUENCE}|[^("\""|"\\"|"\n")]
S_CHAR_SEQUENCE				{S_CHAR}+
/*STRING_LITERAL 				"\""{S_CHAR_SEQUENCE}?"\0""\"" */
/*S_CHAR  					{ESCAPE_SEQUENCE}|[^("\""|"\\"|"\n")]*/
/*S_CHAR_SEQUENCE				{S_CHAR}+*/
STRING_LITERAL 				"\""{S_CHAR_SEQUENCE}?"\""

/*PUNCTUATORS*/
PUNCTUATOR					"["|"]"|"("|")"|"{"|"}"|"->"|"&"|"*"|"+"|"-"|"/"|"%"|"!"|"?"|"<"|">"|"<="|">="|"=="|"!="|"&&"|"||"|"="|":"|";"|","

/*COMMENTS*/
SINGLE_LINE_COMM			[/][/][^\n]*
SEQUENCE 					[^*]|[*][^/]
MULTI_LINE_COMM 			[/][*]{SEQUENCE}*[*][/]

COMMENT {SINGLE_LINE_COMM}|{MULTI_LINE_COMM}

RETURN "r""e""t""u""r""n"
VOID "v""o""i""d"
CHAR "c""h""a""r"
FOR "f""o""r"
IF "i""f"
INT "i""n""t"
ELSE "e""l""s""e"

ERROR /.*/


%%
{MULTI_LINE_COMM} 			{red();printf("TOKEN:\tmulti line COMMENT\n");reset();}
{SINGLE_LINE_COMM}			{red();printf("TOKEN:\tsingle line COMMENT\n");reset();}
{RETURN}					{ red();printf("TOKEN:\tRETURN\n");reset();return RETURN; }
{VOID}						{ red();printf("TOKEN:\tVOID\n");reset();return VOID; }
{CHAR}						{ red();printf("TOKEN:\tCHAR\n");reset();return CHAR; }
{FOR}						{ red();printf("TOKEN:\tFOR\n");reset();return FOR; }
{IF}						{ red();printf("TOKEN:\tIF\n");reset();return IF; }
{INT}						{ red();printf("TOKEN:\tINT\n");reset();return INT; }
{ELSE}						{ red();printf("TOKEN:\tELSE\n");reset();return ELSE; }
{INTEGER_CONSTANT}	{
	red();printf("TOKEN:\tINTEGER_CONSTANT\n");reset();return INTEGER_CONSTANT;
}
{CHARACTER_CONSTANT} {
	red();printf("TOKEN:\tCHARACTER_CONSTANT\n");reset();return CHARACTER_CONSTANT;
}
{STRING_LITERAL} {
	red();printf("TOKEN:\tSTRING_LITERAL\n");reset();return STRING_LITERAL;
}
{IDENTIFIER}	{
	red();printf("TOKEN:\tIDENTIFIER\n");reset();return IDENTIFIER;
}

	"[" 					{ red();printf("TOKEN:\tSQRBROPEN\n");reset();return SQRBROPEN;}
	"]" 					{ red();printf("TOKEN:\tSQRBRCLOSE\n");reset();return SQRBRCLOSE;}
	"(" 					{ red();printf("TOKEN:\tPARENTHESISOPEN\n");reset();return PARENTHESISOPEN;}
	")" 					{ red();printf("TOKEN:\tPARENTHESISCLOSE\n");reset();return PARENTHESISCLOSE;}
	"{" 					{ red();printf("TOKEN:\tCURBOPEN\n");reset();return CURBOPEN;}
	"}" 					{ red();printf("TOKEN:\tCURBCLOSE\n");reset();return CURBCLOSE;}
	"->" 					{ red();printf("TOKEN:\tARROW\n");reset();return ARROW;}

	"&" 					{ red();printf("TOKEN:\tBITWISE_AND\n");reset();return BITWISE_AND;}
	"*" 					{ red();printf("TOKEN:\tMUL\n");reset();return MUL;}
	"+" 					{ red();printf("TOKEN:\tADD\n");reset();return ADD;}
	"-" 					{ red();printf("TOKEN:\tSUB\n");reset();return SUB;}
	"!" 					{ red();printf("TOKEN:\tNOT\n");reset();return NOT;}

	"/" 					{ red();printf("TOKEN:\tFORWARD_SLASH\n");reset();return FORWARD_SLASH;}
	"%" 					{ red();printf("TOKEN:\tMODULO\n");reset();return MODULO;}
	"<" 					{ red();printf("TOKEN:\tLESS_THAN\n");reset();return LESS_THAN;}
	">" 					{ red();printf("TOKEN:\tGREATER_THAN\n");reset();return GREATER_THAN;}
	"<=" 					{ red();printf("TOKEN:\tLESS_THAN_EQUAL\n");reset();return LESS_THAN_EQUAL;}
	">=" 					{ red();printf("TOKEN:\tGREATER_THAN_EQUAL\n");reset();return GREATER_THAN_EQUAL;}
	"==" 					{ red();printf("TOKEN:\tEQUALITY\n");reset();return EQUALITY;}
	"!=" 					{ red();printf("TOKEN:\tNOT_EQUAL\n");reset();return NOT_EQUAL;}
	"&&" 					{ red();printf("TOKEN:\tAND\n");reset();return AND;}
	"||" 					{ red();printf("TOKEN:\tOR\n");reset();return OR;}

	"?" 					{ red();printf("TOKEN:\tTERNARY_OP\n");reset();return TERNARY_OP;}
	":" 					{ red();printf("TOKEN:\tCOLON\n");reset();return COLON;}
	";" 					{ red();printf("TOKEN:\tSEMICOLON\n");reset();return SEMICOLON;}
	"=" 					{ red();printf("TOKEN:\tASSIGNMENT\n");reset();return ASSIGNMENT;}
	"," 					{ red();printf("TOKEN:\tCOMMA\n");reset();return COMMA;}
"\n"|" "|"\t"				{}
%%





