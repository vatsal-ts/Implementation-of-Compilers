/* hanoi.c: solves the tower of hanoi problem.*/

/* The original towers of hanoi problem seems to have been originally posed
   by one M. Claus in 1883. There is a popular legend that goes along with
   it that has been often repeated and paraphrased. It goes something like this:
   In the great temple at Benares there are 3 golden spikes. On one of them,
   God placed 64 disks increasing in size from bottom to top, at the beginning
   of time. Since then, and to this day, the priest on duty constantly transfers
   disks, one at a time, in such a way that no larger disk is ever put on top
   of a smaller one. When the disks have been transferred entirely to another
   spike the Universe will come to an end in a large thunderclap.
   This paraphrases the original legend due to DeParville, La Nature, Paris 1884,
   Part I, 285-286. For this and further information see: Mathematical
   Recreations & Essays, W.W. Rouse Ball, MacMillan, NewYork, 11th Ed. 1967,
   303-305.
 *
 *
 */

/* These are the three towers. For example if the state of A is 0,1,3,4, that
 * means that there are three discs on A of sizes 1, 3, and 4. (Think of right
 * as being the "down" direction.) */
int A[4];
int B[4];
int C[4];
int n=4;
void Hanoi(int, int *, int *, int *);

/* Print the current configuration of A, B, and C to the screen */
void PrintAll()
{
    int i;

    printf("A: ");
    for (i = 0; i < 4; i = i + 1)
    {
        printf(" %d ", A[i]);
    }
    printf("\n");

    printf("B: ");
    for (i = 0; i < 4; i = i + 1)
        printf(" %d ", B[i]);
    printf("\n");

    printf("C: ");
    for (i = 0; i < 4; i = i + 1)
        printf(" %d ", C[i]);
    printf("\n");
    printf("------------------------------------------\n");
    return;
}

/* Move the leftmost nonzero element of source to dest, leave behind 0. */
/* Returns the value moved (not used.) */
int Move(int *source, int *dest)
{
    int i = 0;
    int j = 0;

    for (i = 0; i < 4 && (source[i]) == 0; i = i + 1)
    {
        ;
    }
    for (j = 0; j < 4 && (dest[j]) == 0; j = j + 1)
    {
        ;
    }

    dest[j - 1] = source[i];
    source[i] = 0;
    PrintAll(); /* Print configuration after each move. */
    return dest[j - 1];
}

/* Moves first 4 nonzero numbers from source to dest using the rules of Hanoi.
   Calls itself recursively.
   */
void Hanoi(int n, int *source, int *dest, int *spare)
{
    int i;
    if (n == 1)
    {
        Move(source, dest);
        return;
    }

    Hanoi(4 - 1, source, spare, dest);
    Move(source, dest);
    Hanoi(4 - 1, spare, dest, source);
    return;
}

int main()
{
    int i;

    /* initialize the towers */
    for (i = 0; i < 4; i = i + 1)
        A[i] = i + 1;
    for (i = 0; i < 4; i = i + 1)
        B[i] = 0;
    for (i = 0; i < 4; i = i + 1)
        C[i] = 0;

    printf("Solution of Tower of Hanoi Problem with %d Disks\n\n", n);

    /* Print the starting state */
    printf("Starting state:\n");
    PrintAll();
    printf("\n\nSubsequent states:\n\n");

    /* Do it! Use A = Source, B = Destination, C = Spare */
    Hanoi(4, A, B, C);

    return 0;
}

