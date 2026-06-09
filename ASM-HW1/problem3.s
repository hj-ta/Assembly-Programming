    AREA ARMex, CODE, READONLY
    ENTRY

start
    MOV r0, #17               ; Load 17 into r0
    MOV r1, #3                ; Load 3 into r1

    ; Perform 17 * 3
    MUL r2, r0, r1            ; r2 = 17 * 3 (result in r2)

    MOV r0, #3                ; Reload 3 into r0
    MOV r1, #17               ; Reload 17 into r1

    ; Perform 3 * 17
    MUL r3, r0, r1            ; r3 = 3 * 17 (result in r3)

    ; Store results in r0 and r7 as per the requirement
    MOV r0, r2                ; Move the result of 17 * 3 to r0
    MOV r7, r3                ; Move the result of 3 * 17 to r7

    ; End program with syscall
    MOV r7, #1                ; Syscall number for exit
    MOV r0, #0                ; Return code 0
    SVC 0                     ; Execute syscall

    END
