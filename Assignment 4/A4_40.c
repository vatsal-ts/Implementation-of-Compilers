#include "y.tab.h"
#include <stdio.h>
int gl=0;
extern int yyparse();
void red()
{
    if (gl == 1)
        printf("\033[1;31m");
    else
    {
    }
}

void yellow()
{
    if (gl == 1)
        printf("\033[1;33m");
    else
    {
    }
}

void reset()
{
    if (gl == 1)
        printf("\033[0m");
    else
    {
    }
}
int main(int* argc, char* argv[])
{
    gl=atoi(argv[1]);
    yyparse();
    return 0;
}