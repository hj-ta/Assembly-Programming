    AREA ARMex, CODE, READONLY
    ENTRY

start
    MOV r0, #10	;set r0 to 10 to calculate 10!
    BL recursion ;call recursion function      

    LDR r1, =0x40000000 ;Load the memory address to store result
    STR r0, [r1]

    MOV r7, #1	;Set up system call for program exit
    MOV r0, #0  ;Exit code 0
    SVC 0 ;

recursion
    CMP r0, #1	; check if r0 <= 1 (base case)
    BLE end_recursion ; if r0 <= 1, jump to end

    PUSH {r0, lr} ;save r0 and return address     
    SUB r0, r0, #1 ;decrement r0 by 1        
    BL recursion ;recursive call with (r0 - 1)

    POP {r1, lr} ;restore previous r0 to r1
    MUL r0, r1, r0 ;r0 = r1 * r0 (accumulate result)
    BX lr           ;return           

end_recursion 
	MOV r0, #1 ;base case (set r0 to 1)
    BX lr  ;return   
    END