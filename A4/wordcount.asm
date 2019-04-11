#studentName: Yuyao Zhang
#studentID: 260832483

# This MIPS program should count the occurence of a word in a text block using MMIO

.data
#any any data you need be after this line 
textSegment:   .space 5000
search: .space 5000
str1:	.asciiz "Word count\nEnter the text segment:\n"
str2:	.asciiz "\nEnter the search word:\n"
str3:	.asciiz "\nYour word occurred "
str4:	.asciiz " time(s)\n"
str5:	.asciiz "press 'e' to enter another segment of text or 'q' to quit.\n"
nextOperation: .space 1000
	.text
	.globl main

main:	# all subroutines you create must come below "main"

nextStart:
	jal textPrompt
	jal readText		# reading and writing using MMIO
	jal searchPrompt
	jal readSearch
	jal feedback1
	jal searchTheWord
	jal printResult
	jal feedback2
	jal nextPrompt
	jal readNext

	j nextStart
	
searchPrompt:
	la $t2 str2
	move $s0 $ra
	jal Write
	move $ra $s0
	jr $ra
textPrompt:
	la $t2 str1
	move $s0 $ra
	jal Write
	move $ra $s0
	jr $ra
readText:
	la $t2 textSegment
	move $s0 $ra
	jal Read
	move $ra $s0
	jr $ra
readSearch:
	la $t2 search
	move $s0 $ra
	jal Read3
	move $ra $s0
	jr $ra	
readNext:
	la $t2 nextOperation
	move $s0 $ra
	jal Read2
	move $ra $s0
	jr $ra	
	
	
Read2:
	move $s1 $ra
	
startRead2:
	jal read2		# reading and writing using MMIO
	beq $v0 101 ret3
	add $a0,$v0,$zero	# in an infinite loop
	j startRead2
ret3:
	move $ra $s1
	jr $ra

read2:  lui $t0, 0xffff 	#ffff0000
loop12:	lw $t1, 0($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,loop12
	lw $v0, 4($t0) 		#data	
	
	beq $v0 113 fin
	jr $ra

Read3:
	move $s1 $ra
startRead3:
	jal read		# reading and writing using MMIO
	beq $v0 32 ret2
	beq $v0 10 ret2
	sw $v0 ($t2)
	addi $t2 $t2 4
	add $a0,$v0,$zero	# in an infinite loop
	jal write
	j startRead3


Read:
	move $s1 $ra
startRead:
	jal read		# reading and writing using MMIO
	beq $v0 10 ret2
	sw $v0 ($t2)
	addi $t2 $t2 4
	add $a0,$v0,$zero	# in an infinite loop
	jal write
	j startRead
ret2:
	sw $0 ($t2)
	move $ra $s1
	jr $ra

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


	

Write:  lui $t0, 0xffff 	#ffff0000
Loop2: 	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop2
	lb $a0 ($t2)
	addi $t2 $t2 1
	sw $a0, 12($t0) 	#data	
	
	beqz $a0 ret
	j Write
ret:
	jr $ra

	
	
searchTheWord:
	move $s0 $ra
	li $s7 0 #Count = 0
	li $t2 0 #textSegment[t2]
	li $t3 0 #search[t3]
startFrom:	
	lw $t4 textSegment($t2) #t4=textSegment[t2]
	lw $t5 search($t3) #t5=search[t3]
	beqz $t5 checkt4  
	beq $t4 $t5 sameChar
	j nextWord
checkt4:
	beq $t4 32 countPlusOne
	beqz $t4 countPlusOne
	j nextWord
countPlusOne:
	addi $s7 $s7 1
	j nextWord
nextWord:
	li $t3 0
loopNextChar:
	beqz $t4 return 
	beq $t4 32 nextChar
	addi $t2 $t2 4 #pay attention to end
	lw $t4 textSegment($t2)
	beqz $t4 return 
	beq $t4 32 nextChar
	j loopNextChar
nextChar:
	addi $t2 $t2 4
	j startFrom
sameChar:
	addi $t2 $t2 4
	addi $t3 $t3 4
	j startFrom
return:    	
	move $ra $s0
	jr $ra
	
printResult:
	move $s0 $ra    
    	
WriteInt:  lui $t0, 0xffff 	#ffff0000
LoopInt: 	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,LoopInt
	
	blt $s7 10 print1Digit
	blt $s7 100 print2Digits
	j print3Digits #hardcode to print the result, given maximum of 600 characters
	
print1Digit:
	addi $s7 $s7 48 #to ascii
	sw $s7, 12($t0) 	#data	
	move $ra $s0
	jr $ra
print2Digits:
	div $t9 $s7 10
	addi $t9 $t9 48
	sw $t9, 12($t0) 	#data
	addi $t9 $t9 -48	
	mul $t9 $t9 10
	sub $s7 $s7 $t9
	j WriteInt
print3Digits:
	div $t9 $s7 100
	addi $t9 $t9 48
	sw $t9, 12($t0) 	#data
	addi $t9 $t9 -48	
	mul $t9 $t9 100
	sub $s7 $s7 $t9
	j WriteInt
feedback1:
	move $s0 $ra
	la $t2 str3
	jal Write
	move $ra $s0
	jr $ra
	
feedback2:
	move $s0 $ra
	la $t2 str4
	jal Write
	move $ra $s0
	jr $ra


nextPrompt:
	move $s0 $ra
	la $t2 str5
	jal Write
	move $ra $s0
	jr $ra	

fin:
	
