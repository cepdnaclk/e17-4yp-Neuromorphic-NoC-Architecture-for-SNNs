.globl __start

.include "../SrcAll/BasicMacros.asm"

.text
__start:

	j LogicalOps
	j BitShifts
	j SetCommands
	
LogicalOps:	
	li a0,0x12345678
	li a1,0x12345678
	li a2,0xFFFF0000
	
	jal MonitorA0A1A2 	#; Show A0,A1,A2 to screen
	
	
	xor  a0,a0,a2		#;A0= A0 Xor X2
	xori a1,a1,0xFF		#;A0= A0 Xor 0xFF (immediate has 1 byte limit)
	
	jal MonitorA0A1A2 
	
	and  a0,a0,a2		#;A0= A0 And X2
	andi a1,a1,0xFF		#;A0= A0 And 0xFF (immediate has 1 byte limit)
	
	li a2,0xCD000000
	or a1,a1,a2
	ori a0,a0,0xCD
	
	jal MonitorA0A1A2 
	
	#; LI is a psuedo instruction - the assembler uses LUI and Add commands to make up the actual command
	
	lui a0,0xFF			 #;=0x000FF000
	lui a1,0xFFFF		 #;=0x0FFFF000
	lui a2,0xFFFFF		 #;=0xFFFFF000
	#;lui a1,0xFFFFFF #; This wont work - 5 character limit
	jal MonitorA0A1A2 
	
	li a2,0x00001234
	not a0,a2			#;Flip bits
	neg a1,a2			#;Flip bits, Add 1
	
	jal MonitorA0A1A2 
	
	jal NewLine
	j Shutdown
	
#;Bit Shifts
BitShifts:
	
	li a4,4
	li a0,0x80002001
	mv a1,a0
	mv a2,a0
	li a3,1
	jal MonitorA0A1A2 
ShiftLoop:
	#;sll a1,a1,a3		#;Shift Bits Left by a3
	slli a1,a1,1		#;Shift Bits Left by 1
	srl  a2,a2,a3		#;Shift bits Right by a3
	#;srli a2,a2,1		#;Shift bits Right by 1
	jal MonitorA0A1A2 
	
	addi a4,a4,-1
	bne a4,zero,ShiftLoop
	
	
	jal NewLine
	
	li a4,4
	li a0,0x80002001
	mv a1,a0
	mv a2,a0
	li a3,1
	jal MonitorA0A1A2 
ArithmeticShiftLoop:
	srai a1,a1,1		#;Arithmetic Shift bits Right by 1
	sra  a2,a2,a3		#;Arithmetic Shift bits Right by 1
	jal MonitorA0A1A2 
	
	addi a4,a4,-1
	bne a4,zero,ArithmeticShiftLoop
	
	jal NewLine
	j Shutdown
	
#;Set if LessThan / Greater To	
SetCommands:
	li a0,0
	li a1,20
	li a2,15
	
	sltu a0,a1,a2		#;Set A0=1 if A1<A2 else 0 (unsigned)
	jal MonitorA0A1A2 
	sgtu a0,a1,a2		#;Set A0=1 if A1>A2 else 0 (unsigned)
	jal MonitorA0A1A2 
	
	li a0,0
	li a1,20
	li a2,-100
	
	jal NewLine
	
	slt a0,a1,a2		#;Set A0=1 if A1<A2 else 0 (signed)
	jal MonitorA0A1A2 
	sgt a0,a1,a2		#;Set A0=1 if A1>A2 else 0 (signed)
	jal MonitorA0A1A2 
	
Shutdown:
  #; ends the program with status code 0
  li a7, 10
  ecall
  
	
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
TestData:
	.byte 0xF0,0xF1,0xF2,0xF3	#;Little Endian - so this is $F3F2F1F0
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