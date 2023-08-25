%{
#include <stdio.h>
#include <string.h>

#define SINGLE_LINE_COMM 	1
#define MULTI_LINE_COMM 	2

// keywords
#define RETURN 				3
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
%}

/* Regular Expression Definitions */

/*KEYWORDS char else for if int return void*/
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

ESCAPE_SEQUENCE				\\("\'"|"\""|"\?"|"\\"|"a"|"b"|"f"|"n"|"r"|"t"|"v")
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


RETURN "r""e""t""u""r""n"
VOID "v""o""i""d"
CHAR "c""h""a""r"
FOR "f""o""r"
IF "i""f"
INT "i""n""t"
ELSE "e""l""s""e"



%%
{MULTI_LINE_COMM} 			{return MULTI_LINE_COMM;}
{SINGLE_LINE_COMM}			{return SINGLE_LINE_COMM;}
{RETURN}					{ return RETURN; }
{VOID}						{ return VOID; }
{CHAR}						{ return CHAR; }
{FOR}						{ return FOR; }
{IF}						{ return IF; }
{INT}						{ return INT; }
{ELSE}						{ return ELSE; }
{INTEGER_CONSTANT}	{
	return INTEGER_CONSTANT;
}
{CHARACTER_CONSTANT} {
	return CHARACTER_CONSTANT;
}
{STRING_LITERAL} {
	return STRING_LITERAL;
}
{IDENTIFIER}	{
	return IDENTIFIER;
}
	"[" 					{ return SQRBROPEN;}
	"]" 					{ return SQRBRCLOSE;}
	"(" 					{ return RORBROPEN;}
	")" 					{ return RORBRCLOSE;}
	"{" 					{ return CURBROPEN;}
	"}" 					{ return CURBRCLOSE;}
	"." 					{ return DOT;}
	"->" 					{ return ARWCOM;}

	"&" 					{ return AMPSND;}
	"*" 					{ return MUL;}
	"+" 					{ return ADD;}
	"-" 					{ return SUB;}
	"~" 					{ return NEG;}
	"!" 					{ return EXCLAIM;}

	"/" 					{ return DIV;}
	"%" 					{ return MODULO;}
	"<" 					{ return LST;}
	">" 					{ return GRT;}
	"<=" 					{ return LTE;}
	">=" 					{ return GTE;}
	"==" 					{ return EQL;}
	"!=" 					{ return NEQ;}
	"&&" 					{ return AND;}
	"||" 					{ return OR;}

	"?" 					{ return QUESTION;}
	":" 					{ return COLON;}
	";" 					{ return SEMICOLON;}
	"=" 					{ return ASSIGN;}
	"*=" 					{ return STAREQ;}
	"/=" 					{ return DIVEQ;}
	"%=" 					{ return MODEQ;}
	"+=" 					{ return PLUSEQ;}
	"-=" 					{ return MINUSEQ;}
	"," 					{ return COMMA;}
"\n"|" "|"\t"	{

}
%%





