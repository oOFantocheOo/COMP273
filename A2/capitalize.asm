# This program illustrates an exercise of capitalizing a string.
# The test string is hardcoded. The program should capitalize the input string
# Comment your work

	.data

inputstring: 	.asciiz "I am a student at McGill University"
outputstring:	.space 100
blank:		.asciiz "\n"


	.text
	.globl main

main:
		la $t0, inputstring		#current position of input
		la $t1, outputstring
		la $t3, outputstring		#current position of output
		
		li $v0,4			#print input
		la $a0,inputstring
		syscall
		li $v0,4
		la $a0,blank			#print a empty line
		syscall
		
loop:		lb $t2,0($t0)
		beq $t2, 0, fin			#if finished (current char==0)
    		blt $t2, 'a', copy		#if <'a' or > 'z', directly copy this char 
    		bgt $t2, 'z', copy
    		subi $t2,$t2,32			#else capitalize it and copy to output
    		sb $t2,0($t3)
		addi $t3,$t3,1
		addi $t0,$t0,1
		j loop
    		
copy:		sb $t2,0($t3)
		addi $t3,$t3,1			#increment to next char
		addi $t0,$t0,1
		j loop

fin:		li $v0,4			#print output
		la $a0,outputstring 
		syscall
