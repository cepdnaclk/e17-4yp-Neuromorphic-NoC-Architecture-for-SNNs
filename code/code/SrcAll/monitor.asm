

ShowHex4:
  addi sp,sp,-4
  sw ra,0(sp)    
  li a4,8
ShowHex4Again:  
        srli a1,a3,28
        slli a3,a3,4
        jal ShowHexChar
      addi a4,a4,-1
      bne a4,x0,ShowHex4Again
  lw ra,0(sp)
  addi sp,sp,4
  ret 

ShowHex2:
	push ra
	pushAs
		li a4,2
ShowHex2Again:  
			mv a1,a3
			srli a1,a3,4
			slli a3,a3,4
			
			jal ShowHexChar
		  addi a4,a4,-1
		  bne a4,x0,ShowHex2Again
	popAs
	pop ra
	ret 
  
  
ShowHexChar:
	push ra
	pushAs
		addi sp,sp,-4
		sw ra,0(sp)
		andi a1,a1,0xF
		addi a1,a1,'0'
		li t0,':'
		blt a1,t0,ShowHexCharOk
		addi a1,a1,7
ShowHexCharOk:
		jal PrintChar
		lw ra,0(sp)
		addi sp,sp,4
	popAs
	pop ra
  ret 
  
  
  
  
Monitor:
    pushall
      

		li a5,'r'
		li a6,'a'
		lw a7,4(sp)
		jal ShowRegText                #;A5 A6 : A7
		li a5,'s'
		li a6,'p'
		lw a7,8(sp)
		jal ShowRegText              #  ;A5 A6 : A7
		li a5,'g'
		li a6,'p'
		lw a7,12(sp)
		jal ShowRegText              #  ;A5 A6 : A7
		li a5,'t'
		li a6,'p'
		lw a7,16(sp)
		jal ShowRegText             #   ;A5 A6 : A7

		jal NewLine         

		li a5,'a'
		li a6,'0'
		lw a7,40(sp)
		jal ShowReg              #  ;A5 A6 : A7
		lw a7,44(sp)
		jal ShowReg             #   ;A5 A6 : A7      
		lw a7,48(sp)
		jal ShowReg              #  ;A5 A6 : A7      
		lw a7,52(sp)
		jal ShowReg             #   ;A5 A6 : A7      
		lw a7,56(sp)
		jal ShowReg            #    ;A5 A6 : A7      
		lw a7,60(sp)
		jal ShowReg             #   ;A5 A6 : A7      
		lw a7,64(sp)
		jal ShowReg             #   ;A5 A6 : A7      
		lw a7,68(sp)
		jal ShowReg               # ;A5 A6 : A7

		jal NewLine      

		li a5,'s'
		li a6,'0'
		lw a7,32(sp)
		jal ShowReg               # ;A5 A6 : A7
		lw a7,36(sp)
		jal ShowReg              #  ;A5 A6 : A7
		lw a7,72(sp)
		jal ShowReg             #   ;A5 A6 : A7
		lw a7,76(sp)
		jal ShowReg             #   ;A5 A6 : A7
		lw a7,80(sp)
		jal ShowReg             #   ;A5 A6 : A7
		lw a7,84(sp)
		jal ShowReg             #   ;A5 A6 : A7
		lw a7,88(sp)
		jal ShowReg             #   ;A5 A6 : A7
		lw a7,92(sp)
		jal ShowReg             #   ;A5 A6 : A7
		lw a7,96(sp)
		jal ShowReg             #   ;A5 A6 : A7
		lw a7,100(sp)
		jal ShowReg               # ;A5 A6 : A7
		lw a7,104(sp)
		jal ShowReg            #    ;A5 A6 : A7
		lw a7,108(sp)
		jal ShowReg            #    ;A5 A6 : A7
		jal NewLine      

		li a5,'t'
		li a6,'0'
		lw a7,20(sp)
		jal ShowReg          #      ;A5 A6 : A7
		lw a7,24(sp)
		jal ShowReg           #     ;A5 A6 : A7
		lw a7,28(sp)
		jal ShowReg            #    ;A5 A6 : A7
		lw a7,112(sp)
		jal ShowReg             #   ;A5 A6 : A7
		lw a7,116(sp)
		jal ShowReg              #  ;A5 A6 : A7
		lw a7,120(sp)
		jal ShowReg               # ;A5 A6 : A7
		lw a7,124(sp)
		jal ShowReg                #;A5 A6 : A7
		jal NewLine      
      
    popall
    ret 

ShowRegTextB:
	push ra
	push a0
	push a1
	push a3
		jal ShowRegText
	pop a3
	pop a1
	pop a0
	pop ra
	ret
	
ShowRegText:            #    ;A5 A6 : A7
  # addi sp,sp,-4
  # sw ra,0(sp)
  push ra
     mv a1,a5
     jal PrintChar
     mv a1,a6
     jal PrintChar
  j ShowRegB
  
ShowReg:            #    ;A5 A6 : A7
	push ra
  #; addi sp,sp,-4
  #; sw ra,0(sp)
     mv a1,a5
     jal PrintChar
     mv a1,a6
     jal ShowHexChar
ShowRegB:            #   h ;A5 A6 : A7
     li a1,':'
    jal PrintChar
    mv a3,a7
    jal ShowHex4
    li a1,' '
    jal PrintChar
    addi a6,a6,1
	pop ra
  #; lw ra,0(sp)
	#; addi sp,sp,4
  ret
  
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
MemDumpNoLabel:
	pushall
	j MemDumpb
MemDump:
	pushall
		mv a3,a7
		pushAs
			jal ShowHex4	
			li a1,':'
			jal PrintChar
		popAs
MemDumpb:
MemDumpNextLine:		
		jal NewLine
		li a5,8
MemDumpAgain:
		lb a3,(a7)
		jal ShowHex2
		li a1,' '
		jal PrintChar
		addi a7,a7,1
		addi a5,a5,-1
		bne a5,zero,MemDumpAgain
		
		
		addi a7,a7,-8
		li a5,8
MemDumpAgainChar:
		lb a1,(a7)
		li a2,32
		blt a1,a2,MemDumpAgainCharBad
		li a2,128
		bgt a1,a2,MemDumpAgainCharBad
		j MemDumpAgainCharOk
MemDumpAgainCharBad:				
		li a1,'.'
MemDumpAgainCharOk:		
		jal PrintChar
		addi a7,a7,1
		addi a5,a5,-1
		bne a5,zero,MemDumpAgainChar
		
		
		addi a6,a6,-1
		bne a6,zero,MemDumpNextLine
		jal NewLine 
	popall
	ret