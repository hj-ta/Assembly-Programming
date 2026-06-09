	AREA FloatedLoad, CODE, READONLY
	ENTRY

main

	LDR r0, value1  ; 
	LDR r1, value2  ;
	LDR r10, =0x40000000
	
	;sign bit
	MOV r2, r0, LSR #31 ;v1
	MOV r3, r1, LSR #31 ;v2

	;exp_value1
	LSL r4, r0, #1
	LSR r4, r4, #24
	
	;exp_value2
	LSL r5, r1, #1
	LSR r5, r5, #24
	
	;Mantissa_value1
	LSL r6, r0, #9
	LSR r6, r6, #9
	ORR r6, r6, #0x00800000
	
	;Mantissa_value2
	LSL r7, r1, #9
	LSR r7, r7, #9
	ORR r7, r7, #0x00800000

	;expontent compare
	CMP r4,r5 ;r4-r5, exp1-exp2
	;+if 0
	BEQ combine_mantissas ;exp1==exp2
	
	;exp1 > exp2
	SUBGT r8, r4, r5
	LSRGT r7,r7,r8 ;shift m2 
	MOVGT r5,r4 ;exp2 set
	
	;exp1 < exp2
	SUBLT r8, r5, r4
	LSRLT r6, r6, r8
	MOVLT r4, r5
	;CMP r8, #0 ?

combine_mantissas
	;sign bit compare
	CMP	r2,r3
	
	;if, sign equal
	MOVEQ r11, r2, LSL #31
	ADDEQ r6, r6, r7

	;if sign different
	CMP r6,r7 
	
	;m2-m1(v2>v1)
	MOVLT r11, r3, LSL #31 ;result sign set(_v2)
	SUBLT r6,r7,r6	; m2-m1

	;m1-m2
	MOVGT r11, r2, LSL #31
	SUBGT r7,r7,r8

normalize
	CMP r6, #0x01000000         ; Check if Mantissa exceeds normalized range
	BHS normalize_shift_right   ; If Mantissa too large, shift right
	CMP r6, #0x00800000         ; Check if Mantissa below normalized range
	BLO normalize_shift_left    ; If Mantissa too small, shift left
	B end_normalize             ; If normalized, exit

normalize_shift_right
	ADD r4, r4, #1              ; Increment exponent
	LSR r6, r6, #1              ; Shift Mantissa right
	B normalize                 ; Continue normalization

normalize_shift_left
	SUB r4, r4, #1              ; Decrement exponent
	LSL r6, r6, #1              ; Shift Mantissa left
	B normalize                 ; Continue normalization

end_normalize
	LDR r9, =0x007FFFFF
	LSL r4, r4, #23
	ORR r4, r4, r11          ; Combine sign and exponent
	AND r6, r6, r9 ; Mask Mantissa to 23 bits
	ORR r0, r4, r6           ; Combine all parts into r0
	
	;store
	STR r0, [r10]
	
	; System call
	MOV r7, #1  ; sycall 1
	MOV r0, #0 ; return 0
	SVC 0 ; execute syscall
	
value1 DCI 0x3E800000
value2 DCI 0x3E000000
	
		END