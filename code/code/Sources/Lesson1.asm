
.globl __start

.include "../SrcAll/BasicMacros.asm"

.macro MonitorA0A1RAPCm
	push ra
		mv a6,ra
		jal MonitorA0A1RAPC
	pop ra
.end_macro

.text
__start:

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  


	li ra,0
	MonitorA0A1RAPCm	#;Show Starting point
	jal NewLine  
	
	j TestBasicMaths
	
	#;j TestMemory
	j TestJumps
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  

#;LI is a psuedo op, it's made up of multiple commands in the built code

TestBasicMaths:	
	
    li a0,192			#;Load 192 in decimal (0xC0)
    li a1,0xFFEEDDCC	#;Load a hexadecimal value into A0
	li a2,'A'			#;load 'A' in ascii (0x41)
	jal MonitorA0A1A2 	#; Show A0,A1,A2 to screen
	
	li a0,0x01020304	#;Load a hexadecimal value into A0
	mv a1,a0			#;Move A0->A1
	mv a2,a0			#;Move A0->A2
	jal MonitorA0A1A2 	#; Show A0,A1,A2 to screen
	
.eqv  testSym,3		#;Define testSym=3
	
	li a0,testSym		#;Load a symbol
    li a1,testSym		#;Load a symbol
	li a2,testSym		#;Load a symbol
	jal MonitorA0A1A2 	#; Show A0,A1,A2 to screen
	
	li a0,192			#;Load 192 in decimal (0xC0)
	addi a1,a0,1		#; Add 1 to A0, store result in A1
	addi a2,a0,-1		#; Subtract 1 from A0, store result in A2
	jal MonitorA0A1A2 	#; Show A0,A1,A2 to screen
	
	li a0,192			#;Load 192 in decimal (0xC0)
	li a2,0x00000100	#;Value to add or subtract
	jal MonitorA0A1A2 	#; Show A0,A1,A2 to screen

	add a1,a0,a2		#;A1 = A0+A2
	sub a0,a0,a2		#;A0 = A0-A2
	jal MonitorA0A1A2 

	
	j Shutdown
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
TestMemory:
	
	li a1,0				#;Clear a1
	
	la a7,TestData		#;Address
	li a6,2				#;Line Count
	jal MemDump			#;Dump Ram to screen
	
	jal NewLine  
	
	la a2,TestData		#;Load address of TestData
	lw a0,(a2)			#;Load Word (32 bit) into A0 from address in A2
	jal MonitorA0A1A2 	
	
	lhu a0,(a2)			#;Load Half (16 bit) (other bits 0)
	lh a1,(a2)			#;Load Half (16 bit) (other bits bit15)
	jal MonitorA0A1A2 	
	
	lbu a0,(a2)			#;Load Byte (other bits 0)
	lb a1,(a2)			#;Load Byte (other bits bit7)
	jal MonitorA0A1A2 	
	
	jal NewLine  
	
	la a7,TestData		#;Address
	li a6,2				#;Line Count
	jal MemDump			#;Dump Ram to screen
	
	lw a0,(a2)			#;Load Word into A0 from address in A2
	jal MonitorA0A1A2 	
	
	jal NewLine  
	
	sw a2,(a2)			#;Store Word from A0 into address in A2
	sw a0,4(a2)			#;Store Word from A0 into address in A2+4
		
	sh a0,8(a2)			#;Store HalfWord from A0 into address in A2+8
	
	sb a0,12(a2)		#;Store Byte from A0 into address in A2+12
	
	la a7,TestData		#;Address
	li a6,2				#;Line Count
	jal MemDump			#;Dump Ram to screen
	
	
	#;la a7,TestDataB		#;This doesn't work as its not in the data area
	#;li a6,2				#;Line Count
	#;jal MemDump			#;Dump Ram to screen

	j Shutdown
TestDataB:
	nop 
	nop 
	nop 
	nop 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestJumps:	

	j JumpTest1			#;Jump to a label
ReturnFromJumpB:
	
	la a0,JumpTest2		#;Jump to address in Register
	jr a0
ReturnFromJump:

	jal JumpTest3		#;Jump And Link to label (PC->RA)
	
	jal a1,JumpTest3b	#;Jump And Link to label (PC->A1)

	la a0,JumpTest4		
	jalr a0		#;Jump And Link to address in Register (A0->RA)
	#;jalr ra,a0,0		#;Alternate form of JALR command
	
	jal NewLine  	
	j Shutdown
	
JumpTest1:
	MonitorA0A1RAPCm
	la a2,JumpTo
	jal PrintString
	push ra
		jal NewLine       
	pop ra
	j ReturnFromJumpB
	
JumpTest2:
	MonitorA0A1RAPCm
	la a2,JumpToRegister
	jal PrintString
	push ra
		jal NewLine       
	pop ra
	j ReturnFromJump
  	
JumpTest3:
	MonitorA0A1RAPCm
	push ra
		la a2,JumpAndLinkTo
		jal PrintString
		jal NewLine       
	pop ra
	ret		#;jr RA
	
JumpTest3b:
	MonitorA0A1RAPCm
	push a1
		la a2,JumpAndLinkTo
		jal PrintString
		jal NewLine       
	pop a1
	jr a1 #;ret
	
	
JumpTest4:
	MonitorA0A1RAPCm
	push ra
		la a2,JumpAndLinkToRegister
		jal PrintString
		jal NewLine       
	pop ra
	ret		#;jr RA
	
Shutdown:
	#; ends the program with status code 0
	li a7, 10
	ecall
  
 #;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 

MonitorA0A1RAPC:
	pushAs
	push ra
		push a6
			li a5,'a'
			li a6,'0'
			mv a7,a0
			jal ShowRegTextB             #   ;A5 A6 : A7
			li a5,'a'
			li a6,'1'
			mv a7,a1
			jal ShowRegTextB             #   ;A5 A6 : A7
			li a5,'r'
			li a6,'a'
		pop a7
		jal ShowRegTextB             #   ;A5 A6 : A7
		li a5,'p'
		li a6,'c'
	pop a7
	push a7
		jal ShowRegTextB             #   ;A5 A6 : A7  
	pop ra
	popAs
	ret
 
MonitorA0A1A2:
	push ra
	pushAs
	    li a5,'a'
		li a6,'0'
		mv a7,a0
		jal ShowRegTextB             #   ;A5 A6 : A7
		li a5,'a'
		li a6,'1'
		mv a7,a1
		jal ShowRegTextB             #   ;A5 A6 : A7
		li a5,'a'
		li a6,'2'
		mv a7,a2
		jal ShowRegTextB             #   ;A5 A6 : A7
		jal NewLine         
	popAs
	pop ra
	ret
  
.include "../SrcAll/monitor.asm"  
.include "../SrcAll/BasicFunctions.asm"  
  
#;All Data must go in the Data Segment - cannot read from code segment
.data
TestData:	#;Little Endian - so this is $F3F2F1F0
	.byte 0xF0,0xF1,0xF2,0xF3	
	.byte 0,0,0,0,0,0,0,0,0,0,0,0
	
JumpAndLinkTo: 
  .string "JAL "
  .byte 255 
JumpTo: 
  .string "J   "
  .byte 255 
JumpToRegister: 
  .string "JR  "
  .byte 255 
JumpAndLinkToRegister: 
  .string "JALR"
  .byte 255 
