addi x1, x1, 15
Loop:
beq x1, x2, 20
nop
nop

; test
nop
addi x2, x2, 1
jal x3, Loop



