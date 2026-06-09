    AREA    TermProject2024, CODE, READONLY
    
; Constants
IMG_WIDTH    EQU     20
IMG_HEIGHT   EQU     20
NEW_WIDTH    EQU     80
NEW_HEIGHT   EQU     80

    ENTRY
     
main        
    ; Load base addresses
    LDR     R4, =source_data     ; Source image
    LDR     R5, =ResultBuffer    ; Destination buffer
    
    ; Initialize loop counters
    MOV     R6, #0              ; row index (i)

outer_loop 
	CMP R6, #NEW_HEIGHT ; is row = 80?
	BEQ	end_program ; all row processing done
	
    MOV     R7, #0              ; column index (j)

inner_loop
    CMP R7, #NEW_WIDTH           ; Check if column == 80
    BEQ next_row                 ; If yes, move to the next row

	; Step 1 : Calculate original coordinates (base indices)
    MOV R8, R6, LSR #2           ; x1 = i / 4 : Original row  
    MOV R9, R7, LSR #2           ; y1 = j / 4 : Original column
	;ADD R10, R8, #1				; x2 = x1 + 1
	;ADD R11, R9, #1				; y2 = y1 + 1

	    ; Q11 (Bottom Left)
    MOV R0, #20
    MUL R3, R8, R0
    ADD R3, R3, R9
    LDR R10, [R4, R3, LSL #2]   ; Load pixel value for Q11
    LDR R0, =store_q11_x        ; Address of Q11 x-coordinate
    STR R10, [R0]               ; Store Q11 x-coordinate

    ; Q12 (Bottom Right)
    MOV R0, #20
    ADD R9, R9, #1              ; Increment column for Q12
    MUL R3, R8, R0
    ADD R3, R3, R9
    LDR R10, [R4, R3, LSL #2]   ; Load pixel value for Q12
    LDR R0, =store_q12_x        ; Address of Q12 x-coordinate
    STR R10, [R0]               ; Store Q12 x-coordinate

    ; Q21 (Top Left)
    MOV R9, R7, LSR #2          ; Reset to original column index
    ADD R8, R8, #1              ; Increment row for Q21
    MOV R0, #20
    MUL R3, R8, R0
    ADD R3, R3, R9
    LDR R10, [R4, R3, LSL #2]   ; Load pixel value for Q21
    LDR R0, =store_q21_x        ; Address of Q21 x-coordinate
    STR R10, [R0]               ; Store Q21 x-coordinate

    ; Q22 (Top Right)
    ADD R9, R9, #1              ; Increment column for Q22
    MOV R0, #20
    MUL R3, R8, R0
    ADD R3, R3, R9
    LDR R10, [R4, R3, LSL #2]   ; Load pixel value for Q22
    LDR R0, =store_q22_x        ; Address of Q22 x-coordinate
    STR R10, [R0]               ; Store Q22 x-coordinate      

	;dx
	AND	R0, R6, #3			; dx = i % 4
	BL get_dx				; Call get_dx(integer tp float)
	LDR R1, =store_dx		; Load address of dx
	STR	R0, [R1]			; Store dx at store_dx

	;1-dx
	MOV R0, R0				; Reuse R0 from previous call
	BL get_one_minus_dx		; call get_one_minus_dx
	LDR	R1, =store_dx		; load address of 1-dx
	STR	R0, [R1]			; store 1-dx at store_1dx
	
	;dy
	AND R0, R7, #3               ; dy = j % 4
    BL get_dy                    ; Call get_dy
    LDR R1, =store_dy            ; Load address of dy
    STR R0, [R1]                 ; Store dy at store_dy
	
	;1-dy
	MOV R0, R0                   ; Reuse R0 from previous call
    BL get_one_minus_dy          ; Call get_one_minus_dy
    LDR R1, =store_1dy           ; Load address of 1-dy
    STR R0, [R1]                 ; Store 1-dy at store_1dy
	
	; Step 4: Perform bilinear interpolation
    BL      bilinear_interpolate  ; Interpolated result in R0

	; Step 5: Store result in the destination buffer
    ADD     R12, R5, R6, LSL #7   ; Address of current row's result
    ADD     R12, R12, R7, LSL #2  ; Add column offset
    STR     R0, [R12]             ; Store result of interpolation

	; Move to the next column
    ADD     R7, R7, #1
    B       inner_loop

next_row
    ADD     R6, R6, #1
    B       outer_loop

;Calculate dx
get_dx
    CMP R0, #0                   ; Check if input is 0
    BEQ load_zero                ; If 0, load 0.0
    
	CMP R0, #1                   ; Check if input is 1
    BEQ load_025        		 ; If 1, load 0.25
    
	CMP R0, #2                   ; Check if input is 2
	BEQ load_05                  ; If 2, load 0.5
	
	CMP R0, #3                   ; Check if input is 3
	BEQ load_075                 ; If 3, load 0.75
    
	;B return_result
	;BX LR                        ; Return to caller

load_zero
    LDR R1, =float_zero          ; Load 0.0
	LDR R0, [R1]
    BX LR                        ; Return to caller

load_025
    LDR R1, =float_025           ; Load 0.25
	LDR R0, [R1]
    BX LR                        ; Return to caller

load_05
    LDR R1, =float_05            ; Load 0.5
	LDR R0, [R1]
    BX LR                        ; Return to caller

load_075
    LDR R1, =float_075           ; Load 0.75
	LDR R0, [R1]
    BX LR                        ; Return to caller

load_one
    LDR R1, =float_1             ; Load 1.0
	LDR R0, [R1]
    BX LR                        ; Return to caller


;return_default
;    MOV R0, #0x00000000          ; Default to 0.0 (should not occur)
;    BX LR                        ; Return to caller
	
	
;Calculate 1-dx 
get_one_minus_dx
	
	CMP R0, #0                   ; Check if input is 0
    BEQ load_one         
    
	CMP R0, #1                   ; Check if input is 1
    BEQ load_075 
    
	CMP R0, #2                   ; Check if input is 2
	BEQ load_05                  ; If 2, load 0.5
	
	CMP R0, #3                   ; Check if input is 3
	BEQ load_025                 ; If 3, load 0.75
    
	;B return_result
	BX LR                        ; Return to caller

; Calculate dy
get_dy
    CMP R0, #0                   ; Check if input is 0
    BEQ load_zero                ; If 0, load 0.0
    
	CMP R0, #1                   ; Check if input is 1
    BEQ load_025        		 ; If 1, load 0.25
    
	CMP R0, #2                   ; Check if input is 2
	BEQ load_05                  ; If 2, load 0.5
	
	CMP R0, #3                   ; Check if input is 3
	BEQ load_075                 ; If 3, load 0.75
    
	;B return_result
	BX LR                        ; Return to caller

;Calculate 1-dy
get_one_minus_dy
	
	CMP R0, #0                   ; Check if input is 0
    BEQ load_one         
    
	CMP R0, #1                   ; Check if input is 1
    BEQ load_075 
    
	CMP R0, #2                   ; Check if input is 2
	BEQ load_05                  ; If 2, load 0.5
	
	CMP R0, #3                   ; Check if input is 3
	BEQ load_025                 ; If 3, load 0.75
    
	;B return_result
	BX LR                        ; Return to caller

bilinear_interpolate
    
	PUSH {R4-R7, LR}
    ; Q11(1-dx)(1-dy) + Q12(dx)(1-dy) + Q21(1-dx)(dy) + Q22(dx)(dy)

	;Q11(1-dx)(1-dy)
	LDR R4, =store_q11_x         ; Address of Q11 x-coordinate
	LDR R0, [R4]
	LDR R4, =store_1dx
	LDR R1, [R4]  
	BL multiply_float
	MOV R3, R0			; r0 = Q11(1-dx)
	LDR R4, =store_1dy
	LDR R1, [R4]
	BL multiply_float	;r0 = Q11(1-dx)(1-dy)

	; Q12(dx)(1-dy)
	LDR R4, =store_q12_x         ; Address of Q12 x-coordinate
	LDR R0, [R4]                 ; Load Q12 value into R0
	LDR R4, =store_dx            ; Address of dx
	LDR R1, [R4]                 ; Load dx into R1
	BL multiply_float            ; R0 = Q12 * dx
	MOV R3, R0                   ; Store intermediate result in R3
	LDR R4, =store_1dy           ; Address of (1-dy)
	LDR R1, [R4]                 ; Load (1-dy) into R1
	BL multiply_float            ; R0 = Q12(dx)(1-dy)
	BL add_float					
	
	;Q21(1-dx)(dy)
	LDR R4, =store_q21_x         ; Address of Q21 x-coordinate
	LDR R0, [R4]                 ; Load Q21 value into R0
	LDR R4, =store_1dx           ; Address of (1-dx)
	LDR R1, [R4]                 ; Load (1-dx) into R1
	BL multiply_float            ; R0 = Q21 * (1-dx)
	MOV R3, R0                   ; Store intermediate result in R3
	LDR R4, =store_dy            ; Address of dy
	LDR R1, [R4]                 ; Load dy into R1
	BL multiply_float            ; R0 = Q21(1-dx)(dy)
	BL add_float
	
	; Q22(dx)(dy)
	LDR R4, =store_q22_x         ; Address of Q22 x-coordinate
	LDR R0, [R4]                 ; Load Q22 value into R0
	LDR R4, =store_dx            ; Address of dx
	LDR R1, [R4]                 ; Load dx into R1
	BL multiply_float            ; R0 = Q22 * dx
	MOV R3, R0                   ; Store intermediate result in R3
	LDR R4, =store_dy            ; Address of dy
	LDR R1, [R4]                 ; Load dy into R1
	BL multiply_float            ; R0 = Q22(dx)(dy)
	BL add_float
	
	
multiply_float
	
	PUSH    {R4-R11, LR}         ; Save registers
	
	; Step 1: Handle special cases
	; Check if R0 (first value) is 0
	CMP     R0, #0x00000000      ; Is R0 equal to 0.0?
    BEQ     zero_case            ; If yes, result is 0
	
	; Check if R1 (second value) is 0
    CMP     R1, #0x00000000      ; Is R1 equal to 0.0?
    BEQ     zero_case            ; If yes, result is 0
	
	; Check if R0 (first value) is 1
    CMP     R0, #0x3F800000      ; Is R0 equal to 1.0?
    BEQ     first_is_one         ; If yes, result is R1

    ; Check if R1 (second value) is 1
    CMP     R1, #0x3F800000      ; Is R1 equal to 1.0?
    BEQ     second_is_one        ; If yes, result is R0

    MOV     R12, #0              ; Initialize result
	
	;Step 3: Extract sign and exp
    MOV     R3, R0, LSR #31      ; Extract sign bit of value 1
    MOV     R4, R1, LSR #31      ; Extract sign bit of value 2
    MOV     R5, R0, LSL #1       ; Extract exponent of value 1
    MOV     R5, R5, LSR #24
    MOV     R6, R1, LSL #1       ; Extract exponent of value 2
    MOV     R6, R6, LSR #24

    ;Step 3: Extract mantissa
    MOV     R9, #1
    MOV     R9, R9, LSL #23      ; Implied 1 in IEEE 754
    MOV     R7, R0, LSL #9       ; Extract mantissa of value 1
    ADD     R7, R9, R7, LSR #9
    MOV     R8, R1, LSL #9       ; Extract mantissa of value 2
    ADD     R8, R9, R8, LSR #9

    ; Step 4: Calculate exponent
    ADD     R5, R5, R6
    SUB     R5, R5, #127         ; Subtract bias (127)

    ; Step 5: Calculate mantissas
    UMULL   R9, R10, R7, R8
    LSL     R10, #9
    LSR     R9, #23
    ADD     R7, R10, R9

    ; Step 6: Normalize
    BL      normalize

    ; Step 7: Assemble result
    MOV     R7, R7, LSL #9
    ADD     R0, R0, R5, LSL #23 ; Add normalized exponent
    ADD     R0, R12, R7, LSR #9  ; Add normalized mantissa
	;R0 = result
	
    ; Restore registers and return
    POP     {R3-R11, PC}
	
zero_case
    MOV     R0, #0x00000000      ; Result is 0
    POP     {R4-R11, PC}

first_is_one
    MOV     R0, R1               ; Result is R1
    POP     {R4-R11, PC}

second_is_one
    ; R0 already contains the correct value
    POP     {R4-R11, PC}

add_float
	MOV 	R1,R11 			; Load the previous result (R11) into R1 for addition
	
    PUSH    {R3-R10, LR}         ; Save registers
	
    MOV     R12, #0              ; Initialize result
    
	; step 1:  Extract sign and exp
	MOV     R3, R0, LSR #31      ; Extract sign bit of value 1
    MOV     R4, R1, LSR #31      ; Extract sign bit of value 2
    MOV     R5, R0, LSL #1       ; Extract exponent of value 1
    MOV     R5, R5, LSR #24
    MOV     R6, R1, LSL #1       ; Extract exponent of value 2
    MOV     R6, R6, LSR #24

    ; step 2: Extract mantissas
    MOV     R9, #1
    MOV     R9, R9, LSL #23      ; Implied 1 in IEEE 754
    MOV     R7, R0, LSL #9       ; Extract mantissa of value 1
    ADD     R7, R9, R7, LSR #9
    MOV     R8, R1, LSL #9       ; Extract mantissa of value 2
    ADD     R8, R9, R8, LSR #9

    ; step 3: exp calculate
    SUBS    R10, R5, R6
    RSBMI   R10, R10, #0
    MOVMI   R5, R6
    MOVPL   R8, R8, LSR R10
    MOVMI   R7, R7, LSR R10

    ; step 4: Compare and calculate
    CMP     R3, R4
    ADDEQ   R7, R7, R8
    MOVEQ   R12, R3, LSL #31
    CMPNE   R7, R8
    MOVLT   R12, R4, LSL #31
    SUBLT   R7, R8, R7
    MOVGT   R12, R3, LSL #31
    SUBGT   R7, R7, R8

    ; result
    BL      normalize

    ; result
    MOV     R7, R7, LSL #9
    ADD     R12, R12, R5, LSL #23 ; Add normalized exponent
    ADD     R12, R12, R7, LSR #9  ; Add normalized mantissa
	MOV		R11,R12 ; R11=result store
    ; Restore registers and return
    POP     {R3-R10, PC}

normalize
    ; Step 1: Check if mantissa is normalized
    MOV     R2, R9, LSR #23       ; Extract the top bit of mantissa
    CMP     R2, #1                ; Is the top bit 1?

    ; Step 2: If mantissa is too large, shift right and increase exponent
    MOVHI   R9, R9, LSR #1        ; If high, shift mantissa right
    ADDHI   R10, R10, #1          ; Increment exponent if needed

    ; Step 3: If mantissa is too small, shift left and decrease exponent
    MOVLO   R9, R9, LSL #1        ; If low, shift mantissa left
    SUBLO   R10, R10, #1          ; Decrement exponent if needed

    ; Step 4: Repeat until mantissa is normalized
    BNE     normalize             ; Loop until normalized

    ; Step 5: Return to caller
    BX      LR                    ; Return from subroutine


; #########################
; DO NOT MODIFY end_program
; #########################
end_program
    MOV     R0, #0             ; Return 0
    MOV     R7, #0x11          ; SWI exit
    SWI     0                   ; Exit program and return 0
; #########################
; DO NOT MODIFY end_program
; #########################

; YOUR CODE HERE
    AREA    ROData, DATA, READONLY
mantissa_mask	DCD     0x007FFFFF          ; Store the large constant here
infinity_const 	DCD		0x7F800000
implied_one     DCD     0x800000

; Data Section for IEEE 754 Values
float_zero    DCD 0x00000000     ; IEEE 754 representation of 0.0
float_025     DCD 0x3E800000     ; IEEE 754 representation of 0.25
float_05      DCD 0x3F000000     ; IEEE 754 representation of 0.5
float_075     DCD 0x3F400000     ; IEEE 754 representation of 0.75
float_1 	  DCD 0x3F800000 ; IEEE 754 representation of 1.0

; Additional constants for floating-point arithmetic
float_constants

	DCD 0x00800000
	DCD 0x007FFFFF

	ALIGN 4

source_data
    INCLUDE data\downsampled\0.txt   ; Include the image data


    AREA    RWData, DATA, READWRITE
		ALIGN 4
ResultBuffer
    SPACE   NEW_WIDTH * NEW_HEIGHT * 4   ; Space for 80x80 result
	ALIGN 4
store_start 	EQU		0x0FFFFF0A ;data store section

;;;;;;data_store_start 
store_dx       DCD 0x0       ; dx
store_1dx      DCD 0x0       ; 1-dx
store_dy       DCD 0x0       ; dy
store_1dy      DCD 0x0       ; 1-dy
	
	ALIGN 4
; Temporary storage for Q11~Q22 coordinates
store_q11_x    DCD 0x0       ; Q11 x-coordinate
	
store_q12_x    DCD 0x0       ; Q12 x-coordinate
	
store_q21_x    DCD 0x0       ; Q21 x-coordinate
	
store_q22_x    DCD 0x0       ; Q22 x-coordinate


    END

