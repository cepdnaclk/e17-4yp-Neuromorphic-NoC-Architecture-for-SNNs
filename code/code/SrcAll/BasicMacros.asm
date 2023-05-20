
.macro push(%reg)
	addi sp,sp,-4
	sw %reg,0(sp)    
.end_macro

.macro pop(%reg)
	lw %reg,0(sp)
	addi sp,sp,4
.end_macro

.macro pushall
	push ra
	pushAs
	pushSs
	pushTs
.end_macro

.macro popall
	popTs
	popSs
	popAs
    pop ra
.end_macro


.macro pushAs
	  addi sp,sp,-32
      sw a0,0(sp)
      sw a1,4(sp)
      sw a2,8(sp)
      sw a3,12(sp)
      sw a4,16(sp)
      sw a5,20(sp)     
      sw a6,24(sp)
      sw a7,28(sp)
.end_macro

.macro popAs
      lw a0,0(sp)
      lw a1,4(sp)
      lw a2,8(sp)
      lw a3,12(sp)
      lw a4,16(sp)
      lw a5,20(sp)
      lw a6,24(sp)
      lw a7,28(sp)
      addi sp,sp,32
.end_macro


.macro pushSs
	  addi sp,sp,-48
      sw s0,0(sp)
      sw s1,4(sp)
      sw s2,8(sp)
      sw s3,12(sp)
      sw s4,16(sp)
      sw s5,20(sp)     
      sw s6,24(sp)
      sw s7,28(sp)
      sw s8,32(sp)     #;s0
      sw s9,36(sp)
      sw s10,40(sp)    #;a0
      sw s11,44(sp)     
.end_macro

.macro popSs
      lw s0,0(sp)
      lw s1,4(sp)
      lw s2,8(sp)
      lw s3,12(sp)
      lw s4,16(sp)
      lw s5,20(sp)
      lw s6,24(sp)
      lw s7,28(sp)
	  lw s8,32(sp)
      lw s9,36(sp)
      lw s10,40(sp)
      lw s11,44(sp)
      addi sp,sp,48
.end_macro

.macro pushTs
	  addi sp,sp,-28
      sw t0,0(sp)
      sw t1,4(sp)
      sw t2,8(sp)
      sw t3,12(sp)
      sw t4,16(sp)
      sw t5,20(sp)     
      sw t6,24(sp)
.end_macro

.macro popTs
      lw t0,0(sp)
      lw t1,4(sp)
      lw t2,8(sp)
      lw t3,12(sp)
      lw t4,16(sp)
      lw t5,20(sp)
      lw t6,24(sp)
      addi sp,sp,28
.end_macro