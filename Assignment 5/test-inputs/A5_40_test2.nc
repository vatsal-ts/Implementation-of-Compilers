// Swap two numbers
// void swap(int*, int*);
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
    readInt(&x);
    readInt(&y);
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
