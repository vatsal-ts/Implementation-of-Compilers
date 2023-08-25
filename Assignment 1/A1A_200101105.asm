BITS 64
SECTION .text
    extern printf ;Note that printf and scanf functions from gcc need to be used
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

        ;kind note:
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





        ; TAKING INPUT K AND STORING IT IN k VARIABLE IS DONE BELOW
        ;same convetion as above for asking for k value and succesively storing it in k variable is done
        mov rdi, stringFormat
        mov rax, 0 ; number of arguments in SSE
        lea rsi,[whatIsK]
        call printf
        mov rdi, decimalFormat
        mov rsi, k
        mov rax, 0 ; number of arguments in SSE
        call scanf


        ;COPYING K TO K_PRESERVE IS DONE BELOW
        push r15 ;r15 can be used and is pushed and succesively popped to preserve its old value
        mov r15,[k]; we move k value to r15
        mov [k_preserve],r15 ; we then move this value to k_preserve variable
        ;as we will be modyifying k we want to store it before hand in an unchanged variable which 
        ;preserves the original value entered
        pop r15




        ; SETTING FLAG AND K IS DONE BELOW
        mov qword [flag], qword 1 ;originally flag is intialised to 1

        ;Fun Note/Observation: Only one memory refernce works in any function!
        push r12 ;r12 can be used and is pushed and succesively popped to preserve its old value
        mov r12,[k]; we move the value of k to r12 as we will be comparing this value against the length in order 
        ;to set the flag variable 
        cmp r12,[length]
        jle next_1 ;if k<=length everything is alright and we jump to next_1 label without changing the flag value
        pop r12 ;else we continue along this path
        push r12 ; we will again use r12 variable to
        ;set k=n if (k>=n) & flag to zero 
        mov qword [flag], qword 0 ;flag is set to zero
        ; k is set to n
        mov r12,[length]; length is moved to r12
        mov [k],r12; then to k


        next_1:
        pop r12 ;pop r12 as we have now set flag and k correctly


        ;check by printing if all set ups are correct
        ;print k,n,flag
                                            ; mov rdi, decimalFormat
                                            ; mov al, 0 ; number of arguments in SSE
                                            ; mov rsi,[k]
                                            ; call printf
                                            ; mov rdi, decimalFormat
                                            ; mov al, 0 ; number of arguments in SSE
                                            ; mov rsi,[length]
                                            ; call printf
                                            ; mov rdi, decimalFormat
                                            ; mov al, 0 ; number of arguments in SSE
                                            ; mov rsi,[flag]
                                            ; call printf








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

        ;checking by printing if loop works fine
                                        ; mov rdi, decimalFormat
                                        ; mov al, 0 ; number of arguments in SSE
                                        ; mov rsi,r12
                                        ; call printf

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

        inc r12 ;i++ at the end of each iteration
        jmp inputTake ;jump to next iteration of the loop after the increment operation


        all_processed:
        pop r12 ;pop r12 after its use as a counter is over











        ; CALCULATING SUM IS DONE BELOW
        ; we are going to create a loop for user input , we will use r12 as the counter for this loop

        push r12; r12 will act as counter for loop
        push r13; r13 will sotre the sum calculated for k values
        mov r12,qword 0                 ;i=0(for loop convention in c++)
        mov r13,qword 0

        ; loop for sum think of this as the for loop [for (i=0;i<length;i++)]
        sumCalculate:
        cmp r12,[k]                ;conditonal check i<k
        ; note that k is the value entered
        ; it is set to n if it exceeds n to make sure we dont
        ; access values outside the array
        jge sum_calculated         ;jump outside if greater than or equal to length

        ;checking by printing if loop works fine
                                        ; mov rdi, decimalFormat
                                        ; mov al, 0 ; number of arguments in SSE
                                        ; mov rsi,r12
                                        ; call printf
    
        add r13,qword [arr+r12*8]
        ; add function adds the second value to the first 
        ;and stores it in the first value


        inc r12 ;i++
        jmp sumCalculate ;next iteration of loop


        sum_calculated:
        pop r12 ;loop is over
        mov [sum],r13 ; value stored in register is moved to the sum variable whic was decalred in the .bss section
        pop r13




        ; OUTPUTTING SUM AND FLAG IS DONE BELOW
        ; to output sum same convention as before is used for printf calls
        mov rdi, stringFormat
        mov rax, 0 ; number of arguments in SSE
        lea rsi,[sumIs]
        call printf

        mov rdi, decimalFormat
        mov al, 0 ; number of arguments in SSE
        mov rsi,[sum]
        call printf

        ;simple newLine print call newLine variable only stores 0Ah which is the code for a new Line
        mov rdi, stringFormat
        mov al, 0 ; number of arguments in SSE
        lea rsi,[newLine]
        call printf




        ;to output flag same convention as before is used
        mov rdi, stringFormat
        mov al, 0 ; number of arguments in SSE
        lea rsi,[flagIs]
        call printf

        mov rdi, decimalFormat
        mov al, 0 ; number of arguments in SSE
        mov rsi,[flag]
        call printf

        cmp qword [flag],qword 1 ; we only print the message saying that number of values asked for isn't present if flag is set to zero
        je allright ;if flag was 1 and never became zero everything was all right and first k numbers sum was printed as needed
        mov rdi, howManyAsked ; else we show that number of values that was asked for exceeds n and those many (k_preserve) numbers aren't present in the array
        mov al, 0 ; number of arguments in SSE
        mov rsi,[k_preserve]
        call printf
        
        allright:
        mov rdi, stringFormat
        mov al, 0 ; number of arguments in SSE
        lea rsi,[newLine]
        call printf

        pop rbp ;pop rbp
        ret ;return from the main function

SECTION .bss
    length: resb 10 ;length of array
    k: resb 10 ; k value as in question
    flag: resb 10 ;flag as in question
    arr : resb 4000 ;array of numbers
    sum: resb 10; sum needed as in question
    k_preserve: resb 4; saved value of k

SECTION .data
    ;self explainatory variables are used see their usage in corresponding printf functions as above
    stringFormat: db "%s",0
    decimalFormat: db "%d",0
    whatIsLength: db "Enter length of array(n): ", 0
    whatIsK: db "Enter k: ", 0
    askForArray: db 0Ah,"Enter array numbers: ",0Ah,0
    sumIs: db "Sum=", 0
    flagIs: db "Flag=", 0
    howManyAsked: db "    ##%d numbers are not present in array ", 0
    newLine: db "", 0Ah,0
