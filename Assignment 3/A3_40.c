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
         else if ( token == SQRBROPEN)      pr("< SQRBROPEN, %d, %s>\n"); 
         else if ( token == SQRBRCLOSE)     pr("< SQRBRCLOSE, %d, %s>\n"); 
         else if ( token == RORBROPEN)      pr("< RORBROPEN, %d, %s>\n"); 
         else if ( token == RORBRCLOSE)     pr("< RORBRCLOSE, %d, %s>\n");  
         else if ( token == CURBROPEN)     pr("< CURBROPEN, %d, %s>\n"); 
         else if ( token == CURBRCLOSE)    pr("< CURBRCLOSE, %d, %s>\n"); 
         else if ( token == DOT)    pr("< DOT, %d, %s>\n"); 
         else if ( token == ARWCOM)    pr("< ARWCOM, %d, %s>\n"); 
         else if ( token == AMPSND)    pr("< AMPSND, %d, %s>\n"); 
         else if ( token == MUL)    pr("< MUL, %d, %s>\n"); 
         else if ( token == ADD)    pr("< ADD, %d, %s>\n"); 
         else if ( token == SUB)    pr("< SUB, %d, %s>\n"); 
         else if ( token == NEG)    pr("< NEG, %d, %s>\n"); 
         else if ( token == EXCLAIM)    pr("< EXCLAIM, %d, %s>\n"); 
         else if ( token == DIV)    pr("< DIV, %d, %s>\n"); 
         else if ( token == MODULO)     pr("< MODULO, %d, %s>\n"); 
         else if ( token == LST)     pr("< LST, %d, %s>\n"); 
         else if ( token == GRT)     pr("< GRT, %d, %s>\n"); 
         else if ( token == LTE)    pr("< LTE, %d, %s>\n"); 
         else if ( token == GTE)    pr("< GTE, %d, %s>\n"); 
         else if ( token == EQL)     pr("< EQL, %d, %s>\n"); 
         else if ( token == NEQ)    pr("< NEQ, %d, %s>\n"); 
         else if ( token == AND)    pr("< AND, %d, %s>\n"); 
         else if ( token == OR)     pr("< OR, %d, %s>\n"); 
         else if ( token == QUESTION)       pr("< QUESTION, %d, %s>\n"); 
         else if ( token == COLON)      pr("< COLON, %d, %s>\n"); 
         else if ( token == SEMICOLON)      pr("< SEMICOLON, %d, %s>\n"); 
         else if ( token == ASSIGN)     pr("< ASSIGN, %d, %s>\n"); 
         else if ( token == STAREQ)     pr("< STAREQ, %d, %s>\n"); 
         else if ( token == DIVEQ)      pr("< DIVEQ, %d, %s>\n"); 
         else if ( token == MODEQ)      pr("< MODEQ, %d, %s>\n"); 
         else if ( token == PLUSEQ)     pr("< PLUSEQ, %d, %s>\n"); 
         else if ( token == MINUSEQ)    pr("< MINUSEQ, %d, %s>\n"); 
         else if ( token == COMMA)      pr("< COMMA, %d, %s>\n"); 
    
  }
return 0;
}