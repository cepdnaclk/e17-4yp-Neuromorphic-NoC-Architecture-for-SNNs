
.globl __start

.eqv  test,3

.include "../SrcAll/BasicMacros.asm"

.macro MonitorA0A1RAPCm
	push ra
		mv a6,ra
		jal MonitorA0A1RAPC
	pop ra
.end_macro
.macro DumpStack
	jal MonitorA0A1PCSP

	li a6,2			#;Line Count
	jal MemDumpNoLabel	#;Dump Stack to screen
	jal NewLine
	
.end_macro
.text
__start:
	li ra,0

	#;j StackTest
	
	#;j TestEqualsNotequals #;= !=
	#;j TestLessGreaterUnsigned #;< <= > >=
	#;j TestLessGreaterSigned #;< <= > >=
	j TestLessGreaterZero	#;<0 <=0 >0 >=0
	
	
	
StackTest:
	mv a7,sp		#;Address
	addi a7,a7,-16
	
	li a0,0xF4F3F2F1
	DumpStack		#;Dump Stack to screen
	
	addi sp,sp,-4	#;push a0
	sw a0,0(sp)    	#;push a0
		li a0,0
		DumpStack	#;Dump Stack to screen
		jal SubTest
	lw a0,0(sp)		#;pop a0
	addi sp,sp,4	#;pop a0
	
	DumpStack		#;Dump Stack to screen
	jal MonitorA0A1PCSP	
	j Shutdown

SubTest:
	addi sp,sp,-4		#;push ra
	sw ra,0(sp)   		#;push ra
		li a0,0x11223344
		push a0
			DumpStack	#;Dump Stack to screen
		pop a0
		DumpStack		#;Dump Stack to screen
		
	lw ra,0(sp)			#;pop ra
	addi sp,sp,4		#;pop ra
	ret
	
	
	
	
#; These have psuedo-ops: BEQZ, BNEZ, BLEZ, BGEZ, BLTZ, BGTZ	
TestLessGreaterZero:
	#;li a0,-100		#;TestVal1
	li a0,0				#;TestVal1

	jal MonitorA0A1
	
	beq a0,zero,PrintEquals		#;Compare a0 to zero (x0 register)
	bne a0,zero,PrintNotEquals	#;Compare a0 to zero (x0 register)
	
	#;blt a0,zero,PrintLessThan			#;is a0 < zero (x0 register)
	#;bgt a0,zero,PrintGreaterThan		#;is a0 > zero (x0 register)

	#;ble a0,zero,PrintLessThanEquals		#;is a0 <= zero (x0 register)
	#;bge a0,zero,PrintGreaterThanEquals	#;is a0 >= zero (x0 register)
	
	j Shutdown

	
TestLessGreaterSigned:
	li a0,-100			#;TestVal1

	li a1,99			#;Less Than Test
	 #;li a1,-100		#;Equals Test
	#;li a1,-101		#;Greater than Test
	
	jal MonitorA0A1
	
	#;blt a0,a1,PrintLessThan			#;is a0 < a1
	#;bgt a0,a1,PrintGreaterThan		#;is a0 > a1

	ble a0,a1,PrintLessThanEquals		#;is a0 <= a1
	bge a0,a1,PrintGreaterThanEquals	#;is a0 >= a1
	
	j Shutdown

	
	
TestLessGreaterUnsigned:
	li a0,100			#;TestVal1

	li a1,99			#;Less Than Test
	#; li a1,100		#;Equals Test
	li a1,101			#;Greater than Test
	
	jal MonitorA0A1
	
	#;bltu a0,a1,PrintLessThan			#;is a0 < a1
	#;bgtu a0,a1,PrintGreaterThan		#;is a0 > a1
	
	bleu a0,a1,PrintLessThanEquals		#;is a0 <= a1
	bgeu a0,a1,PrintGreaterThanEquals	#;is a0 >= a1
	
	j Shutdown

	
TestEqualsNotequals:
	li a0,100			#;TestVal1

	#; li a1,100		#;Equals Test
	li a1,101			#;Not Equals Test
	
	jal MonitorA0A1
	
	beq a0,a1,PrintEquals		#;Compare a0 to a1
	bne a0,a1,PrintNotEquals	#;Compare a0 to a1
	
	j Shutdown
	
Shutdown:
  #; ends the program with status code 0
  li a7, 10
  ecall
 
PrintNotEquals:
	push ra
		li a1,'!'
		jal PrintChar
		li a1,'='
		jal PrintChar
	pop ra
	j Shutdown
PrintEquals:
	push ra
		li a1,'='
		jal PrintChar
	pop ra
	j Shutdown
PrintLessThan:
	push ra
		li a1,'<'
		jal PrintChar
	pop ra
	j Shutdown
PrintLessThanEquals:
	push ra
		li a1,'<'
		jal PrintChar
		li a1,'='
		jal PrintChar
	pop ra
	j Shutdown
PrintGreaterThan:
	push ra
		li a1,'>'
		jal PrintChar
	pop ra
	j Shutdown
PrintGreaterThanEquals:
	push ra
		li a1,'>'
		jal PrintChar
		li a1,'='
		jal PrintChar
	pop ra
	j Shutdown


MonitorA0A1:
	push ra
	pushAs
	    li a5,'a'
		li a6,'0'
		mv a7,a0
		jal ShowRegTextB             
		li a5,'a'
		li a6,'1'
		mv a7,a1
		jal ShowRegTextB             
		jal NewLine         
	popAs
	pop ra
	ret

MonitorA0A1PCSP:
	mv a4,sp
	addi a4,a4,4
	push ra
	pushAs
		push a4
			push ra
				li a5,'a'
				li a6,'0'
				mv a7,a0
				jal ShowRegTextB             #   ;A5 A6 : A7
				li a5,'a'
				li a6,'1'
				mv a7,a1
			jal ShowRegTextB             #   ;A5 A6 : A7
			li a5,'p'
			li a6,'c'
			pop a7
			jal ShowRegTextB             #   ;A5 A6 : A7
			li a5,'s'
			li a6,'p'
		pop a7
		jal ShowRegTextB             #   ;A5 A6 : A7
		
	popAs
	pop ra
	ret
  
.include "../SrcAll/monitor.asm"  
.include "../SrcAll/BasicFunctions.asm"  
  
#;All Data must go in the Data Segment - cannot read from code segment
.data