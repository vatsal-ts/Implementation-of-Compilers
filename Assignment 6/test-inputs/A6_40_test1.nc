int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

// Forward declarations
void swap(int *p, int *q);
int main() {
    int n;
    int err;
    printStr("Input array size: \n");
    n = readInt(&n);
    int arr[10];
    printStr("Input array elements: \n");
    // readArray(n);
    printStr("Input array: \n");
    int i;
    for (i = 0; i < n; i = i + 1) {
        printStr("Input next element\n");
        arr[i] = readInt(&(err));
    } 
    for (i = 0; i < n; i = i + 1) {
        printInt(arr[i]); printStr(" ");
    }
    printStr("\n");

    int i;
    int j;
    for (i = 0; i < n - 1; i = i + 1)
        // Last i elements are already in place
        for (j = 0; j < n - i - 1; j = j + 1)
            if (arr[j] > arr[j + 1])
            {// swap(&arr[j], &arr[j + 1]);
                int t = arr[j];
                arr[j]=arr[j+1];
                arr[j+1]=t;
            }

    for (i = 0; i < n; i = i + 1) {
        printInt(arr[i]); printStr(" ");
    }
    printStr("\n");
    return 0;
}