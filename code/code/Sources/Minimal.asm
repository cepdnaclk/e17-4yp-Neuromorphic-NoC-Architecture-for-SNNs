.globl __start

.data		#;Data segment - can only read/write to this area
msg1: 
  .string "Hello World!"
  .byte 0			#;Zero Terminated String
.text

__start:
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  

	LA a0,msg1		#;  Message to show on screen
	li a7, 4		#; Print String 
	ecall			#; Simulator Function call
	
	j Shutdown		#; Jump to Shutdown

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  

Shutdown:			#; Shutdown Label
  
  li a7, 10			#; ends the program with status code 0
  ecall				#; Simulator Function call

