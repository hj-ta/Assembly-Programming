	AREA ARMex, CODE, READONLY
		ENTRY
	
start 

	MOV R0, #1 ; save the result
	
	;R0 = 1 * 10
	MOV R1, R0  ;Copy R0 value to R1, R1=1 
	ADD R0,R1,R1,LSL #3 ;R0 = R1+8*R1 = 9*R1
	ADD R0,R0,R1 ; R0 = 10 *R1 =10
	
	;R0 = R0 X 9 
	MOV R1,R0 ;Copy value,R1=10
	ADD R0,R1,R1,LSL #3 ; R0 = R1+8*R1 = 9*R1 = 9*10
	
	;R0 = R0 X 8 
	MOV R1,R0 ;Copy value,R1=90
	ADD R0,R1,R1,LSL #2 ; R0= R1+4*R1= 5*R1
	ADD R0,R0,R1,LSL #1 ; R0= 5*R1 + 2*R1 = 7*R1
	ADD R0,R0,R1 ; R0=7*R1 + R1= 8*R1 = 720
	
	;R0 = R0 X 7
	MOV R1,R0 ;Copy value,R1=720
	ADD R0,R1,R1,LSL #2 ; R0 = R1+4*R1 = 5*R1
	ADD R0,R0,R1 ; R0 = 5*R1 + R1 = 6*R1
	ADD R0,R0,R1 ; R0 = 6*R1 + R1= 7*R1 = 5040
	
	;R0 = R0 X 6
	MOV R1,R0 ;Copy value,R1=5040
	ADD R0,R1,R1,LSL #2 ; R0 = R1+4*R1= 5*R1
	ADD R0,R0,R1 ; R0= 5*R1+R1 = 6*R1 = 30240
	
	;R0 = R0 X 5
	MOV R1,R0 ;Copy value,R1=30240
	ADD R0,R1,R1,LSL #2 ; R0 = R1+4*R1= 5*R1 = 151200
	
	;R0 = R0 X 4
	MOV R1,R0 ;Copy value,R1=151200
	ADD R0,R1,R1,LSL #1 ; R0 = R1+2*R1 = 3*R1
	ADD R0,R0,R1 ; R0=3*R1 + R1 = 4*R1 = 604800
	
	;R0 = R0 X 3
	MOV R1,R0 ;Copy value,R1=604800
	ADD R0,R1,R1,LSL #1 ; R0 = R1+2*R1 = 3*R1 = 1814400
	
	;R0 = R0 X 2
	MOV R1,R0 ;Copy value,R1=1814400
	ADD R0,R1,R1 ; R0=R1+R1=2*R1=3628800
	
	LDR R2, =0x40000000 ;Save to memory address 0x40000000
	STR R0, [R2] 
	
	MOV R7, #1
	MOV R0, #0
	SVC #0 

	END
	
	
	
	
	
	
	