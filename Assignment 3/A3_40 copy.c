#include <stdio.h>
#include "lex.yy.c"
extern char* yytext;
#define pr(x) printf(x, token, yytext)
int yywrap(){}

int main()
{
  int token;
  while((token=yylex()))
  {
    
         if ( token == SINGLE_LINE_COMM)    pr("< SINGLE_LINE_COMM, %d, %s>\n"); 
         else if ( token == MULTI_LINE_COMM)     pr("< MULTI_LINE_COMM, %d, %s>\n"); 

        //KeyWords
         else if ( token == RETURN) pr("< KEYWORD: RETURN, %d, %s >\n"); 
         else if ( token == VOID) pr("< KEYWORD: VOID, %d, %s >\n"); 
         else if ( token == CHAR) pr("< KEYWORD: CHAR, %d, %s >\n"); 
         else if ( token == FOR) pr("< KEYWORD: FOR, %d, %s >\n"); 
         else if ( token == IF) pr("< KEYWORD: IF, %d, %s >\n"); 
         else if ( token == INT) pr("< KEYWORD: INT, %d, %s >\n"); 
         else if ( token == ELSE) pr("< KEYWORD: ELSE, %d, %s >\n"); 
        
        // identifiers
         else if ( token == IDENTIFIER)     pr("< IDENTIFIER, %d, %s>\n"); 
         else if ( token == INTEGER_CONSTANT)       pr("< INTEGER_CONSTANT, %d, %s>\n"); 
         else if ( token == CHARACTER_CONSTANT)    pr("< CHARACTER_CONSTANT, %d, %s>\n"); 
         else if ( token == STRING_LITERAL)    pr("< STRING_LITERAL, %d, %s>\n"); 

        //punctuators
         else if ( token == PUNCTUATOR: SQRBROPEN)      pr("< SQRBROPEN, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: SQRBRCLOSE)     pr("< SQRBRCLOSE, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: RORBROPEN)      pr("< RORBROPEN, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: RORBRCLOSE)     pr("< RORBRCLOSE, %d, %s>\n");  
         else if ( token == PUNCTUATOR: CURBROPEN)     pr("< CURBROPEN, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: CURBRCLOSE)    pr("< CURBRCLOSE, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: DOT)    pr("< DOT, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: ARWCOM)    pr("< ARWCOM, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: AMPSND)    pr("< AMPSND, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: MUL)    pr("< MUL, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: ADD)    pr("< ADD, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: SUB)    pr("< SUB, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: NEG)    pr("< NEG, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: EXCLAIM)    pr("< EXCLAIM, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: DIV)    pr("< DIV, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: MODULO)     pr("< MODULO, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: LST)     pr("< LST, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: GRT)     pr("< GRT, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: LTE)    pr("< LTE, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: GTE)    pr("< GTE, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: EQL)     pr("< EQL, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: NEQ)    pr("< NEQ, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: AND)    pr("< AND, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: OR)     pr("< OR, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: QUESTION)       pr("< QUESTION, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: COLON)      pr("< COLON, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: SEMICOLON)      pr("< SEMICOLON, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: ASSIGN)     pr("< ASSIGN, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: STAREQ)     pr("< STAREQ, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: DIVEQ)      pr("< DIVEQ, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: MODEQ)      pr("< MODEQ, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: PLUSEQ)     pr("< PLUSEQ, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: MINUSEQ)    pr("< MINUSEQ, %d, %s>\n"); 
         else if ( token == PUNCTUATOR: COMMA)      pr("< COMMA, %d, %s>\n"); 
    
  }
return 0;
}