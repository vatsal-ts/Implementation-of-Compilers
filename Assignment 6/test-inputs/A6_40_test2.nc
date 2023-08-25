// Swap two numbers
// void swap(int*, int*);
int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);
void swap(int *p,int *q);
void swap(int *p, int *q)
{
    int t;
    t = *p;
    *p = *q;
    *q = t;
    return;
}
int main()
{
    int x;
    int y;
    printStr("Input first element: \n");
    x=readInt(&x);
    printStr("Input second element: \n");
    y=readInt(&y);
    printStr("Before swap:\n");
    printStr("x = ");
    printInt(x);
    printStr(" y = ");
    printInt(y);
    swap(&x, &y);
    printStr("\nAfter swap:\n");
    printStr("x = ");
    printInt(x);
    printStr(" y = ");
    printInt(y);
    printStr("\n");
    return 0;
}
