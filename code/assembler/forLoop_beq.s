addi x1, x1, 15
Loop:
beq x1, x2, 8
addi x2, x2, 1
; loop again
jal x3, Loop