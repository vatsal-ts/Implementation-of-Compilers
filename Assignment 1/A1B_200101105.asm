BITS 64
SECTION .text
    extern printf
    extern scanf
GLOBAL main
    main:
        push rbp ; a standard practice requires us to push rbp after the main function call and pop it before we quit the call
        
        ; note all inputs/outputs are assumed to be integral, and restricted to the 4 byte region.

        ; please note the standard practice for printf and scanf is defined in the comment section of the
        ; first call of these functions as below
        ; there after, these are assumed to be understood and followed as per the convention defined and elaborated successively
        ; the format is stored in a variable defined in the .data section which is moved to the rdi register 
        ; the variable called and stored in the rsi register is defined in the .data section for all printf calls
        ; and the variable in which the input is stored is defined in the .bss section for all scanf calls

        ; kind note:
        ; for using scanf we always pass the address of the variable where we want to store the user input to the rsi
        ; register and for all printf calls , if we want to print a string we pass the address of the string but if we
        ; want to print a number we pass the numeric value of it by dereferencing the variable itself
        ; this is as per C++17 convention. 

        ;lea rsi,[length] is equivalent to mov rsi,length
        ; lea calculates the address of the dereferenced variable while the variable name in itself points to its address as well

        ; TAKING INPUT N AND STORING IT IN LENGTH VARIABLE IS DONE BELOW
        mov rdi, stringFormat ;move to rdi the address of stringFormat variable
        ; the rdi register stores the first arguement of the printf function
        ; it is the format of the output we are providing i.e. stringFormat is defined in the .data section
        mov rax, 0 ; number of arguments in SSE ; rax must be set to zero before the printf call so me move the value 0 to rax
        lea rsi,[whatIsLength] ;move to rsi the address of whatIsLength variable -- note that whatIsLength is the string defined in the .data section asking for the length of the array
        call printf ;calling printf function

        mov rdi, decimalFormat ;similar practice as the printf function is followed first arguement defines 
        ;the format of the input we want to take in --move to rdi the address of decimalFormat variable
        mov rsi, length ;this is the variable which will store the length once the user inputs it;
        ; it is defined in the .bss function as it is an unitialized variable as of yet 
        mov rax, 0 ; number of arguments in SSE ;rax must be set to zero before the scanf call
        call scanf







        ; ; TAKING ARRAY INPUT IS DONE BELOW
        ;same convetion as above for asking for user to enter array's values
        mov rdi, stringFormat
        mov rax, 0 ; number of arguments in SSE
        lea rsi,[askForArray]
        call printf
        ; we are going to create a loop for user input , we will use r12 as the counter for this loop
        push r12
        mov r12,qword 0                 ;i=0 (for loop convention in c++)

        ; loop for input think of this as the for loop [for (i=0;i<length;i++)]
        inputTake:; this can be thought of as the name for the loop
        cmp r12,[length]                ;conditonal check i<length (for loop convention in c++)
        jge all_processed               ;jump outside if greater than or equal to length


        ; ; ;checking by printing if loop works fine
                                        ; push rax
                                        ; push rdi
                                        ; push rsi
                                        ; mov rdi, decimalFormati
                                        ; mov al, 0 ; number of arguments in SSE
                                        ; mov rsi,r12
                                        ; call printf
                                        ; pop rsi
                                        ; pop rdi
                                        ; pop rax
        ; it is crucial to push rax,rdi and rsi register as we are going to use scanf in a loop
        ; so these registers must preserve their old values and must be cleaned before use
        ; this push-po encapsulating the scna fufnciton is a good practive to follow
        ; as the scanf funciton uses the registers for its operation

        push rax
        push rdi
        push rsi

        mov rdi, decimalFormat
        lea rsi, [arr+r12*8] ; we calculate the address of the position in the array (named arr)
        ; where we want to store the value we take as an input, we are using 8 bytes to store each integer input
        mov rax, 0 ; number of arguments in SSE
        call scanf

        ;pushed registers are popped in reverse order (LIFO policy)
        pop rsi
        pop rdi
        pop rax
            ;CORNER CASE CHECKING IS DONE HERE
            ;checking if number is less than 2 and if so then not taking it and 
            
            cmp [arr+r12*8],dword 2
            jl element_not_taken_in; the element isn't taken in and we jump to the next
            ;iteration of the loop to scan the next element in the same position to 
            ;rewrite this element


            ;DUPLICACY CHECKING NESTED_LOOP
            ; push r13
            mov r13,dword 0 ;j=0 like command. we are making a nested for loop to check if this
            ;element is already taken in

            nested_for_loop:;r13 acts ass counter for the internal loop
            cmp r13,r12; we check for all values of r13<r12 
            ;in the array this is all values of j<i
            jge nested_for_loop_over; if r13>=r12 we have checked all array values and we jump



            ; push r14
            mov r14, [arr+r13*8]; to compare the previous value we store it in r14
                    ; ;checking by printing if loop works fine
                                        ; push rax
                                        ; push rdi
                                        ; push rsi
                                        ; mov rdi, decimalFormatj
                                        ; mov al, 0 ; number of arguments in SSE
                                        ; mov rsi,r14
                                        ; call printf
                                        ; pop rsi
                                        ; pop rdi
                                        ; pop rax
            cmp r14,qword [arr+r12*8];previous array value arr[j] s compared with the just
            ;scanned array value arr[i] 
            ; pop r14
            je element_not_taken_in ;if the elements are equal the element isn't taken in and we jump to the next
            ;iteration of the loop to scan the next element in the same position to 
            ;rewrite this element
            

                


            inc r13; incrementing r13 j++
            jmp nested_for_loop; proceeding to the next iteration of the loop

            nested_for_loop_over:
            ; pop r13








            ; ;PRIMALITY CHECKING NESTED_LOOP
            ; ; push r13
            mov r13,dword 2;j=2 like command. we are going to perform primality check in 
            ;O(n) by checking for all values from 2 to arr[i]
            nested_for_loop_2:
            cmp r13,qword [arr+r12*8]; we terminate the loop and exit it 
            ; when r13>= current value (j<arr[i] conditional check)
            ; we check for all lower values whether we get a perfect divisor 
            ; of this element
            jge nested_for_loop_2_over; if j>=arr[i] we exit the loop and the check was passed

                                ; ; ;checking by printing if loop works fine
                                ;         push rax
                                ;         push rdi
                                ;         push rsi
                                ;         mov rdi, decimalFormatj
                                ;         mov al, 0 ; number of arguments in SSE
                                ;         mov rsi,r13
                                ;         call printf
                                ;         pop rsi
                                ;         pop rdi
                                ;         pop rax
            ; push rax
            ; push rdx
            mov rax,qword [arr+r12*8]; when dividing rax holds dividend
            mov rdx,0; rdx will store remainder and is cleared beforehand
            div r13; r13 will sotre the divisor in our case
            ;after the div operation rdx stores remainder
            cmp rdx,qword 0; if the remainder is 0 then we found a perfect divisor of arr[i]
            ;in which case it isn't prime

            je element_not_taken_in ;if the elements are equal the element isn't taken in and we jump to the next
            ;iteration of the loop to scan the next element in the same position to 
            ;rewrite this element
           

                


            inc r13;j++
            jmp nested_for_loop_2;try next iteration

            nested_for_loop_2_over:
            ; ; pop r13


        
        element_taken_in:; if all checks have passed and no jump to element not taken in has happened
        ; then we naturally land up taking the element into the array
        inc r12  ; do this carefully!! i++ we are going to scan the next element and this element is accepted
        element_not_taken_in:
        jmp inputTake ;next iteration of scanning loop is performed





        all_processed:
        pop r12; we have used the counter r12 and pop it to restore old value










        ; OUTPUTTING ARRAY
        ;same printf convention as descirbed before is followed
        mov rdi, decimalFormatArrStart
        mov rsi, [length]
        mov rax, 0 ; number of arguments in SSE
        call printf



        push r12 ;r12 acts as counter same loop convention as before
        mov r12,dword 0                 ;i=0

        ; loop for output
        opShow:
        cmp r12,[length]            ;conditonal check i<length
        jge all_shown               ;jump outside if ge length

        ;checking by printing if loop works fine
                                        ; mov rdi, decimalFormat
                                        ; mov al, 0 ; number of arguments in SSE
                                        ; mov rsi,r12
                                        ; call printf
        
        push rax
        push rdi
        push rsi

        mov rdi, decimalFormatArr
        mov rsi, [arr+r12*8]
        mov rax, 0 ; number of arguments in SSE
        call printf

        pop rsi
        pop rdi
        pop rax

        inc r12
        jmp opShow ;next iteration of loop to output next element


        all_shown:
        mov rdi, newLine ;once all elements are shown we output newline
        mov rsi, 0
        mov rax, 0 ; number of arguments in SSE
        call printf



        pop r12

        pop rbp
        ret

SECTION .bss
    length: resb 8 ;length of array
    k: resb 10 ; k value as in question
    flag: resb 10 ;flag as in question
    arr : resb 10000 ;array of numbers
    sum: resb 10; sum needed as in question

SECTION .data
    ;self explainatory variables are used see their usage in corresponding printf functions as above
    stringFormat: db "%s",0
    decimalFormat: db "%d",0
    decimalFormati: db "i = %d",0Ah,0
    decimalFormatj: db "j = %d",0Ah,0
    decimalFormatArr: db "%d ",0
    decimalFormatArrStart: db "Printing array of %d elements ",0Ah,0
    whatIsLength: db "Enter length of array(n): ", 0
    askForArray: db 0Ah,"Enter array numbers: ",0Ah,0
    newLine: db "", 0Ah,0

    ; flag_precursor: db "flag = ",0
    ; someNum: db 4    
    ; newLine: db 0Ah,0  