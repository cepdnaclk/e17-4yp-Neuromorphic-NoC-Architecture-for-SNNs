#Text after a hash is comments, you don't need to type it in

.data					# Data Segment start (All data must go here)
txtHelloWorld: 
  .ascii "Hello World!!!"
  .byte 255				# 255 terminated string
  
  
.text					# Code Segment (Our Program)
	la a1,txtHelloWorld	# Address of the string we want to show
  	jal PrintString		# Call subroutine PrintString (Show A2)

 	li a7, 10			# 10 - Exit - Exits the program with code 0
 	ecall				# ECALL is not a 'real' RISC-V command
  						# It's a special one supported by the RARS simulator
  						
PrintString: # Show String A1
	addi sp,sp,-4		# Backup Return address (PUSH RA) 
	sw ra,0(sp)    
		li a2,255		# For comparison
PrintStringAgain:
		lbu a0,0(a1)			  # Load unsigned byte
		beq a0,a2,PrintStringDone # Compare to 255 and branch if equal
		jal PrintChar  			  # Call PrintChar subroutine
		addi a1,a1,1			  # Move to next character
		j PrintStringAgain
PrintStringDone:
	lw ra,0(sp)  		# Restore Return address (POP RA) 
	addi sp,sp,4
	ret					# Return to RA
    
  
PrintChar: # Print Character A0
	li a7, 11			# 11 - PrintChar - Prints an ascii character
	ecall				# Print A0
	ret					# This is a pseudo op for "JALR ZERO,RA,0"


