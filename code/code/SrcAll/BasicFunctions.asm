
NewLine:
	push ra
		li a1,'\n'
		jal PrintChar
	pop ra
	ret
  
PrintString:
	push ra
	pushAs
		li a3,255
PrintStringAgain:
		lbu a1,0(a2)
		beq a1,a3,PrintStringDone
		JAL PrintChar  
		addi a2,a2,1
		j PrintStringAgain
PrintStringDone:
	popAs
	pop ra
	ret
    
  
PrintChar: #;printchar A1
	push ra
	pushAs
		mv a0,a1
		li a7, 11
		ecall
	popAs
	pop ra
	ret

