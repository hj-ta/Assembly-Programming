    AREA ARMex, CODE, READONLY
    ENTRY

start
    ; Initialize R0 to R7 with values 1 to 8
    MOV r0, #1                ; R0 = 1
    MOV r1, #2                ; R1 = 2
    MOV r2, #3                ; R2 = 3
    MOV r3, #4                ; R3 = 4
    MOV r4, #5                ; R4 = 5
    MOV r5, #6                ; R5 = 6
    MOV r6, #7                ; R6 = 7
    MOV r7, #8                ; R7 = 8

    ; Push all initial values to the stack in their original order
    STMFD sp!, {r0-r7}        ; Store R0-R7 on the stack

    ; Pop values from the stack in the specified order to achieve the desired swap
    LDMFD sp!, {r1}           ; Load the original R0 value into R1
    LDMFD sp!, {r6}           ; Load the original R1 value into R6
    LDMFD sp!, {r0}           ; Load the original R2 value into R0
    LDMFD sp!, {r2}           ; Load the original R3 value into R2
    LDMFD sp!, {r7}           ; Load the original R4 value into R7
    LDMFD sp!, {r3}           ; Load the original R5 value into R3
    LDMFD sp!, {r4}           ; Load the original R6 value into R4
    LDMFD sp!, {r5}           ; Load the original R7 value into R5

    ; End program with syscall
    MOV r7, #1                ; Syscall number for exit
    MOV r0, #0                ; Return code 0
    SVC 0                     ; Execute syscall to exit

    END