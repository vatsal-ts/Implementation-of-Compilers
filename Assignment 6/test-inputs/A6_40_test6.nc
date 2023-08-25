int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

int main() {
int arr[5];
int i;
for(i=0; i<5; i=i+1){
    arr[i]=i;
}
i=0;
printStr("Printing array elements:\n");
for(i=0; i<5; i=i+1){
    printInt (arr[i]);
    printStr(" ");
}
printStr("\n");
return 0;
}