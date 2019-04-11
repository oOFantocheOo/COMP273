	.data

entera: 	.asciiz "Please enter a: "
enterb:		.asciiz "Please enter b: "
enterc:		.asciiz "Please enter c: "
noSolution:	.asciiz "No solution"
blank:		.asciiz "\n"

	.text
	.globl main

main:
		li $v0,4			#prompt and user enters a, b, and c
		la $a0,entera
		syscall
    		li $v0,5
    		syscall
    		move $t5,$v0
    		
    		li $v0,4			
		la $a0,enterb
		syscall
    		li $v0,5
    		syscall
    		move $t6,$v0
    		rem $t5,$t5,$t6
    		
    		li $v0,4			
		la $a0,enterc
		syscall
    		li $v0,5
    		syscall
    		move $t7,$v0			#t5=a mod b,t6-b,t7=c
    		
		li $v0,4
		la $a0,blank			#print a empty line
		syscall
		
		li $t3,0			#t3=x=0
		
loop:		add $a0,$0,$t3
		add $a1,$0,$t3
		jal Mul
		rem $t8,$v0,$t6
		bne $t8,$t5,dontPrint		#if x2 != a mod b, dont print anything
						#else print the solution
					
		li $t2,1			#a flag that's used to check if there's any solution
		li $v0,1			# system call code for print_int
		add $a0, $zero, $t3
		syscall 
		li $v0,4
		la $a0,blank			#print a empty line
		syscall
		
dontPrint:		
		beq $t3,$t7 over		#if has run when x==c, it's over
		addi $t3,$t3,1			#else x+=1
		j loop

Mul:		add  $t0,$zero,$zero	# prod=0

Loop:		slt  $t1,$zero,$a1	# mlr > 0?	
		beq  $t1,$zero,Fin	# no=>Fin	
		add  $t0,$t0,$a0	# prod+=mc	
		addi $a1,$a1,-1		# mlr-=1   
		j    Loop		# goto Loop
Fin:		add  $v0,$t0,$0		# $v0=prod		
		jr   $ra		# return
		

over:
		beq $t2,1 skip			#if there's at least one solution, 
						#meaning the flag t2 has been changed to 1, 
						#skip printing no solution 
						#otherwise print no solution
		li $v0,4			
		la $a0,noSolution
		syscall
		
skip:
		nop
