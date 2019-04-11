#studentName: Yuyao Zhang
#studentID: 260832483

# This MIPS program should sort a set of numbers using the quicksort algorithm
# The program should use MMIO

.data
#any any data you need be after this line 


arr:		.space 10000
size:	.space 4
n:    	.space 4 #current number
str1:	.asciiz "Welcome to quicksort\n"
str2:	.asciiz "\nThe sorted array is: "
str3:	.asciiz "\nThe array is re-initialized\n"
str4:	.asciiz "\n"
	.text
	.globl main

main:	# all subroutines you create must come below "main"

	jal welcome
startover:
	j ReadNumCSQ #at the start, only a number, c , s, or q is valid

	
	
saveN:
	li $a0 32
	jal write 
	la $t0 size
	lw $t1 ($t0)
	mul $t4 $t1 4
	la $t2 n
	lw $t3 ($t2)
	sw $t3 arr($t4)
	jal sizePlus1
	jal setn0
	j startover
	
	
ReadSpaceNum:
	jal read		# reading and writing using MMIO
	beq $v0 32 saveN	
	bgt $v0 57 ReadSpaceNum# if not valid, ignore and read again
	blt $v0 48 ReadSpaceNum
	
	
	la $t0 n
	lw $t1 ($t0)
	mul $t1 $t1 10
	subi $v0 $v0 48
	add $t1 $t1 $v0
	sw $t1 ($t0)
	# n=10n+v0
	
	addi $a0 $v0 48
	jal write 	
	j ReadSpaceNum

ReadNumCSQ:
	jal read		# reading and writing using MMIO
	beq $v0 113 fin	#if q, finish
	beq $v0 99 clear#if c, clear and print
	beq $v0 115 sort#if s, sort and print
	bgt $v0 57 ReadNumCSQ
	blt $v0 48 ReadNumCSQ
	la $t0 n
	lw $t1 ($t0)
	mul $t1 $t1 10
	subi $v0 $v0 48
	add $t1 $t1 $v0
	sw $t1 ($t0)
	# n=10n+v0
	addi $a0 $v0 48
	jal write 	
	j ReadSpaceNum
QUICK:
## quick sort
# store $s and $ra
	addi	$sp, $sp, -24	# Adjest sp
	sw		$s0, 0($sp)		# store s0
	sw		$s1, 4($sp)		# store s1
	sw		$s2, 8($sp)		# store s2
	sw		$a1, 12($sp)	# store a1
	sw		$a2, 16($sp)	# store a2
	sw		$ra, 20($sp)	# store ra
# set $s
	move	$s0, $a1		# l = left
	move	$s1, $a2		# r = right
	move	$s2, $a1		# p = left
# while (l < r)
Loop_quick1:
	bge		$s0, $s1, Loop_quick1_done
# while (arr[l] <= arr[p] && l < right)
Loop_quick1_1:
	li		$t7, 4			# t7 = 4
	# t0 = &arr[l]
	mult	$s0, $t7
	mflo	$t0				# t0 =  l * 4bit
	add		$t0, $t0, $a0	# t0 = &arr[l]
	lw		$t0, 0($t0)
	# t1 = &arr[p]
	mult	$s2, $t7
	mflo	$t1				# t1 =  p * 4bit
	add		$t1, $t1, $a0	# t1 = &arr[p]
	lw		$t1, 0($t1)
	# check arr[l] <= arr[p]
	bgt		$t0, $t1, Loop_quick1_1_done
	# check l < right
	bge		$s0, $a2, Loop_quick1_1_done
	# l++
	addi	$s0, $s0, 1
	j		Loop_quick1_1
Loop_quick1_1_done:
# while (arr[r] >= arr[p] && r > left)
Loop_quick1_2:
	li		$t7, 4			# t7 = 4
	# t0 = &arr[r]
	mult	$s1, $t7
	mflo	$t0				# t0 =  r * 4bit
	add		$t0, $t0, $a0	# t0 = &arr[r]
	lw		$t0, 0($t0)
	# t1 = &arr[p]
	mult	$s2, $t7
	mflo	$t1				# t1 =  p * 4bit
	add		$t1, $t1, $a0	# t1 = &arr[p]
	lw		$t1, 0($t1)
	# check arr[r] >= arr[p]
	blt		$t0, $t1, Loop_quick1_2_done
	# check r > left
	ble		$s1, $a1, Loop_quick1_2_done
	# r--
	addi	$s1, $s1, -1
	j		Loop_quick1_2
	
Loop_quick1_2_done:

# if (l >= r)
	blt		$s0, $s1, If_quick1_jump
# SWAP (arr[p], arr[r])
	li		$t7, 4			# t7 = 4
	# t0 = &arr[p]
	mult	$s2, $t7
	mflo	$t6				# t6 =  p * 4bit
	add		$t0, $t6, $a0	# t0 = &arr[p]
	# t1 = &arr[r]
	mult	$s1, $t7
	mflo	$t6				# t6 =  r * 4bit
	add		$t1, $t6, $a0	# t1 = &arr[r]
	# Swap
	lw		$t2, 0($t0)
	lw		$t3, 0($t1)
	sw		$t3, 0($t0)
	sw		$t2, 0($t1)
	
# quick(arr, left, r - 1)
	# set arguments
	move	$a2, $s1
	addi	$a2, $a2, -1	# a2 = r - 1
	jal		QUICK
	# pop stack
	lw		$a1, 12($sp)	# load a1
	lw		$a2, 16($sp)	# load a2
	lw		$ra, 20($sp)	# load ra
	
# quick(arr, r + 1, right)
	# set arguments
	move	$a1, $s1
	addi	$a1, $a1, 1		# a1 = r + 1
	jal		QUICK
	# pop stack
	lw		$a1, 12($sp)	# load a1
	lw		$a2, 16($sp)	# load a2
	lw		$ra, 20($sp)	# load ra
	
# return
	lw		$s0, 0($sp)		# load s0
	lw		$s1, 4($sp)		# load s1
	lw		$s2, 8($sp)		# load s2
	addi	$sp, $sp, 24	# Adjest sp
	jr		$ra

If_quick1_jump:

# SWAP (arr[l], arr[r])
	li		$t7, 4			# t7 = 4
	# t0 = &arr[l]
	mult	$s0, $t7
	mflo	$t6				# t6 =  l * 4bit
	add		$t0, $t6, $a0	# t0 = &arr[l]
	# t1 = &arr[r]
	mult	$s1, $t7
	mflo	$t6				# t6 =  r * 4bit
	add		$t1, $t6, $a0	# t1 = &arr[r]
	# Swap
	lw		$t2, 0($t0)
	lw		$t3, 0($t1)
	sw		$t3, 0($t0)
	sw		$t2, 0($t1)
	
	j		Loop_quick1
	
Loop_quick1_done:
	
# return

	lw		$s0, 0($sp)		# load s0
	lw		$s1, 4($sp)		# load s1
	lw		$s2, 8($sp)		# load s2
	addi	$sp, $sp, 24	# Adjest sp
	jr		$ra

clear: 
	jal setSize0 #since my quicksort only sort the first x elements, which is the size I define, I only need to set size to 0 so that eveything will work
	
	la $t2 str3
	jal Write
	
	j startover  #after each command, go to startover
sort:
	la		$a0, arr
	li		$a1, 0
	# a2 = Array_size - 1
	lw		$t0, size
	addi	$t0, $t0, -1
	move	$a2, $t0
	jal		QUICK

	la $t2 str2
	jal Write
	
echoArray: #only print arr[0] to arr[size]
	li $t6 0
	li $t3 0
	la $t4 size
	lw $t7 ($t4)
l:
	beq $t7 $t6 continue
	lw $a0 arr($t3)
	
	bge $a0 10 twoDigits
	addi $a0 $a0 48
	jal write
	j next
	
twoDigits:
	div $t8 $a0 10
	move $t9 $a0
	move $a0 $t8
	addi $a0 $a0 48
	jal write
	mul $t8 $t8 10
	sub $a0 $t9 $t8
	addi $a0 $a0 48
	jal write
	j next
next:
	li $a0 32
	jal write
	addi $t6 $t6 1
	addi $t3 $t3 4
	j l
	
continue:
	la $t2 str4
	jal Write
	j startover  #after each command, go to startover


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
	
	
welcome:
	la $t2 str1
	move $s0 $ra
	jal Write
	move $ra $s0
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
	
setSize0:
	la $t0, size
	li $t1 0
	sw $t1 ($t0)
	jr $ra
setn0:
	la $t0, n
	li $t1 0
	sw $t1 ($t0)
	jr $ra
sizePlus1:
	la $t0, size
	lw $t2 ($t0)
	addi $t2 $t2 1
	sw $t2 ($t0)
	jr $ra
	
fin: