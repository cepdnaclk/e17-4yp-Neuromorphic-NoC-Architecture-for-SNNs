#Text after a hash is comments, you don't need to type it in
	li a1,0x12345678
	jal ShowRegA1		# Show a test value

	jal ReadRegA1		# Read a test value from the user
	jal ShowRegA1		# Show it on the screen

 	li a7, 10			# 10 - Exit - Exits the program with code 0
 	ecall				# ECALL is not a 'real' RISC-V command
  						# It's a special one supported by the RARS simulator
  				
ReadRegA1:
	addi sp,sp,-4		# Backup Return address (PUSH RA) 
  	sw ra,0(sp)    
	  	li a4,8			# We're showing 8 chars
ReadRegCharAgain:			
		li a7,12		# 12 - ReadChar - Reads a character from input console 
		ecall			# Read into A0
		
		li t0,':'  				# For comparison
		blt a0,t0,ReadRegCharOk #See if we're >9
		andi a0,a0,0xdf		 	# Convert Lower-> Upper %11011111
		addi a0,a0,-7			# Fix A-F
ReadRegCharOk:		
		addi a0,a0,-48			# Subtract Ascii 0
		andi a0,a0,0xF			# Mask leftmost nibble
		
		slli a1,a1,4			# Shift A1 4 bits Left
		or a1,a1,a0				# OR in this nibble
		
		addi a4,a4,-1
		bne a4,zero,ReadRegCharAgain # Compare to Zero (x0)
		
 		li a0,' '
		jal PrintChar	# Print a space ' ' 
  	lw ra,0(sp)
  	addi sp,sp,4		# Restore Return address (RA)
	ret					# Return to RA
  
  
ShowRegA1:
	addi sp,sp,-4		# Backup Return address (PUSH RA) 
  	sw ra,0(sp)    
		li a0,'A'		# Show our header 'A1:'
		jal PrintChar
		li a0,'1'
		jal PrintChar
		li a0,':'
		jal PrintChar
	
		mv a3,a1		# A3 is our work var
	  	li a4,8			# We're showing 8 chars
ShowHexAgain:  
        srli a0,a3,28	# Leftmost nibble to rightmost 
        slli a3,a3,4    # Remove leftmost nibble from A3

		andi a0,a0,0xF	# Mask leftmost nibble
		addi a0,a0,'0'	# Add Ascii 0
		
		li t0,':'  		# For comparison
		blt a0,t0,ShowHexCharOk #See if we're >9
		addi a0,a0,7	# Fix A-F
ShowHexCharOk:
		jal PrintChar	# Show Character
      	addi a4,a4,-1
      	bne a4,zero,ShowHexAgain	 # Compare to Zero (x0)
      	
 		li a0,' '
		jal PrintChar	# Print a space ' ' 
  	lw ra,0(sp)
  	addi sp,sp,4		# Restore Return address (RA)
	ret					# Return to RA
  
  
PrintChar: # Print Character A0
	li a7, 11			# 11 - PrintChar - Prints an ascii character
	ecall				# Print A0
	ret					# This is a pseudo op for "JALR ZERO,RA,0"

