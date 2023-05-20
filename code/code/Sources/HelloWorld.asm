
.globl __start

.eqv  test,3

.macro push(%reg)
	addi sp,sp,-4
	sw %reg,0(sp)    
.end_macro

.macro pop(%reg)
	lw %reg,0(sp)
	addi sp,sp,4
.end_macro

.data
msg1: 
  .string "Hello World!"
  .byte 255

.text

__start:
    li a1,1
    li a7,7

  jal Monitor
  jal Monitor

  LA a2,msg1
  li a3,255
PrintStringAgain:
  lbu a1,0(a2)
  beq a1,a3,PrintStringDone
  JAL PrintChar  
  addi a2,a2,1
 j PrintStringAgain
PrintStringDone:

Shutdown:
  #; ends the program with status code 0
  li a7, 10
  ecall


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
  
.include "monitor.asm"  
  
Monitor:
      addi sp,sp,-128
      sw x0,0(sp)
      sw x1,4(sp)
      sw x2,8(sp)
      sw x3,12(sp)
      sw x4,16(sp)
      sw x5,20(sp)     #;t0
      sw x6,24(sp)
      sw x7,28(sp)
      sw x8,32(sp)     #;s0
      sw x9,36(sp)
      sw x10,40(sp)    #;a0
      sw x11,44(sp)     
      sw x12,48(sp)
      sw x13,52(sp)
      sw x14,56(sp)
      sw x15,60(sp)
      sw x16,64(sp)
      sw x17,68(sp)    #;a7
      sw x18,72(sp)    #;s0
      sw x19,76(sp)
      sw x20,80(sp)
      sw x21,84(sp)
      sw x22,88(sp)
      sw x23,92(sp)
      sw x24,96(sp)
      sw x25,100(sp)
      sw x26,104(sp)
      sw x27,108(sp)    #;s11
      sw x28,112(sp)    #;t3
      sw x29,116(sp)
      sw x30,120(sp)
      sw x31,124(sp)
      
      
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
      
      lw x0,0(sp)
      lw x1,4(sp)
      lw x2,8(sp)
      lw x3,12(sp)
      lw x4,16(sp)
      lw x5,20(sp)
      lw x6,24(sp)
      lw x7,28(sp)
      lw x8,32(sp)
      lw x9,36(sp)
      lw x10,40(sp)
      lw x11,44(sp)
      lw x12,48(sp)
      lw x13,52(sp)
      lw x14,56(sp)
      lw x15,60(sp)
      lw x16,64(sp)
      lw x17,68(sp)
      lw x18,72(sp)
      lw x19,76(sp)
      lw x20,80(sp)
      lw x21,84(sp)
      lw x22,88(sp)
      lw x23,92(sp)
      lw x24,96(sp)
      lw x25,100(sp)
      lw x26,104(sp)
      lw x27,108(sp)
      lw x28,112(sp)
      lw x29,116(sp)
      lw x30,120(sp)
      lw x31,124(sp)
      addi sp,sp,128
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
  # addi sp,sp,-4
  # sw ra,0(sp)
     mv a1,a5
     jal PrintChar
     mv a1,a6
     jal ShowHexChar
ShowRegB:            #    ;A5 A6 : A7
     li a1,':'
    jal PrintChar
    mv a3,a7
    jal ShowHex4
    li a1,' '
    jal PrintChar
    addi a6,a6,1
	pop ra
  # lw ra,0(sp)
  # addi sp,sp,4
  ret
  
NewLine:
	push ra
  #; addi sp,sp,-4
  #; sw ra,0(sp)
  li a1,'\n'
  jal PrintChar
  #;lw ra,0(sp)
  #;addi sp,sp,4
  pop ra
  ret
PrintChar:
  addi sp,sp,-4
  sw ra,0(sp)
    addi sp,sp,-4
  sw a0,0(sp)
      addi sp,sp,-4
  sw a7,0(sp)
	mv a0,a1
    li a7, 11
    ecall
  lw a7,0(sp)
  addi sp,sp,4
  lw a0,0(sp)
  addi sp,sp,4
  lw ra,0(sp)
  addi sp,sp,4
  ret
