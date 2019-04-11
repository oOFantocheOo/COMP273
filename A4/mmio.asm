# This MIPS program illustrates an infinite loop where characters
# from the keyboard are read in, one at a time, and simply echo'd to the display


	.data
	
str1:	.asciiz "\nStart entering characters in the MMIO Simulator"

	.text 
	
	.globl echo

	li $v0, 4		# single print statement	
	la $a0, str1
	syscall
	
echo:	jal read		# reading and writing using MMIO
	add $a0,$v0,$zero	# in an infinite loop
	jal write
	j echo

read:  	lui $t0, 0xffff 	#ffff0000
loop1:	lw $t1, 0($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,loop1
	lw $v0, 4($t0) 		#data	
	jr $ra

write:  lui $t0, 0xffff 	#ffff0000
loop2: 	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,loop2
	sw $a0, 12($t0) 	#data	
	jr $ra

	
