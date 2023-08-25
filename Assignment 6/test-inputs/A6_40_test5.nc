// // Find fibonacci by co-recursion
// int f_odd(int);
// int f_even(int);
// int fibonnan(int);
// int printStr (char *ch);
// int printInt (int n);
// int readInt (int *eP);

// int fibonacci(int n) {
// return (n % 2 == 0)? f_even(n): f_odd(n);
// }
// int f_odd(int n) {
// return (n == 1)? 1: f_even(n-1) + f_odd(n-2);
// }
// int f_even(int n) {
// return (n == 0)? 0: f_odd(n-1) + f_even(n-2);
// }
// int main() {
// int n = 10;
// int r;
// r = fibonacci(n);
// printStr("fibo(");
// printInt(n);
// printStr(") = ");
// printInt(r);
// return 0;
// }

int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

int main() {
int* x;
int y = 9;
x = &y;
printInt(*x);
*x = 20;
printStr("\n");
printInt(*x);
printStr("\n");
return 0;
}
