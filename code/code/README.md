# RISCV Assmebly

## Architecture

<ul>
<li>supports 32bit 64bit, and 128-bit implementations</li>
<li>33 registers including $pc, 32 general use 
<ul><li>x0-x31 + pc</li></ul>
<li>Given seperate identifiers based on use in the RISC-V calling convention (x0 = zero, x1 = ra (return address), x2 = sp (stack pointer ), x3 = gp (Global pointer), x4 = tp (thread pointer))</li>
<ul>
<li>6 special purpose</li>
<li>7 temp (t0-t6): volatile</li> 
<li>12 saved (s0-s11): non-volatile</li> 
<li>8 arguments (a0-a7)</li> 
</ul>
</li>
</ul>
in addition can have many more. 

## INTRUCTION 

Three register instruction structure <br>
>\<operation> \<dst>,\<src1>,\<src2>

addi a2, x0, 64
<ul>
<li>$a2 = $zero + 64 </li>
<li>$a2 = 64 </li>
</ul>

la a1, helloworld
<ul>
<li>a1 = address of helloworld label </li>
</ul>


# ChibiAkumas

https://www.chibialiens.com/riscv/


using RARS simulator for the code. 

