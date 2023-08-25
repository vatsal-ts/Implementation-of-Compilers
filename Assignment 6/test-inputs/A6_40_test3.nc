// Find factorial by iteration
int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

int main()
{
    int n;
    int i = 0;
    int r = 1;
    printStr("Input number to find factorial: \n");
    n=readInt(&n);
    for (i = 1; i <= n; i = i + 1)
        r = r * i;
    printInt(n);
    printStr("! = ");
    printInt(r);
    printStr("\n");
    return 0;
}