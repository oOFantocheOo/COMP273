#name: Yuyao Zhang
#studentID: 260832483

.data
#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "flipped.pgm"	#used as output
axis: .word 1 # 0=flip around x-axis....1=flip around y-axis
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048

#any extra data you specify MUST be after this line 
one: .word 1
zero: .word 0
space: .asciiz " "
flag: .asciiz "\nflag"
flagX: .asciiz "\nX"
flagY: .asciiz "\nY"
cantOpen: .asciiz "\nCannot open file!\n"
cantRead: .asciiz "\nCannot read file!\n"
cantClose: .asciiz "\nCannot close file!\n"
specifiedCharacters: .asciiz "P2\n24 7\n15\n"
.align 4
outArray: .space 672	#arrays of integers
inArray: .space 672	
	.text 
	.globl main

main:
    la $a0,input	#readfile takes $a0 as input
    jal readfile


	la $a0,buffer		#$a0 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a1 will specify the buffer that will hold the flipped array.
	la $a2,axis        #either 0 or 1, specifying x or y axis flip accordingly
	jal flip


	la $a0, output		#writefile will take $a0 as file location we wish to write to.
	la $a1,newbuff		#$a1 takes location of what data we wish to write.
	jal writefile

	li $v0,10		# exit
	syscall

readfile:
#done in Q1
		li $v0, 13          	#open file
		li $a1, 0               #read mode
		li $a2, 0               
		syscall
		bltz $v0, errorOpen     #if there is an error
		move $s0, $v0           #else save descriptor
		li $v0, 14          	
		move $a0, $s0           
		la $a1, buffer          #save as buffer	
		li $a2, 2048        	
		syscall
		bltz $v0, errorRead
		li   $v0, 16       
		move $a0, $s0      # file descriptor to close
		syscall       
		bltz $v0, errorClose     
		jr $ra
		

flip:
#Can assume 24 by 7 again for the input.txt file
#Try to understand the math before coding!
la $s1 buffer
la $s2 inArray
move $t9 $ra	#store return register in t9
jal strToArray

lw $a2 axis
lw $t0 zero
lw $t1 one

beq $a2 $t1 YflipAux
XflipAux:
jal flipX
jal arrayToStr
move $ra $t9
jr $ra

YflipAux:
jal flipY
jal arrayToStr
move $ra $t9
jr $ra


writefile:
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!
		
		li $v0, 13          	#open file 
		la $t0, ($a1)		#point t0 to buffer
		la $a1, ($t3)		#point a1 to irrelevent place so t0 is not modified
		li $a1, 1              
		li $a2, 0               
		syscall
		bltz $v0, errorOpen     #if there is an error
		move $a0, $v0           #else save descriptor
		li   $v0, 15       # write to file
		la   $a1, specifiedCharacters   
		li   $a2, 11
		bltz $v0, errorOpen     #if there is an error
		syscall            
		li   $v0, 15       # write to file
		la   $a1, ($t0)		#load buffer back to a1
		li   $a2, 2048
		syscall            
		bltz $v0, errorOpen     #if there is an error
		li   $v0, 16       
		move $a0, $s0      # file descriptor to close
		syscall       
		bltz $v0, errorClose     	
		jr $ra
		
		
errorRead:
		la $a0, cantRead
		li $v0, 4
		syscall
		j fin

errorOpen:
		la $a0, cantOpen
		li $v0, 4
		syscall
		j fin
		
errorClose:
		la $a0, cantClose
		li $v0, 4
		syscall
		j fin
		
fin:
		li $v0, 10
		syscall

finishReadingStrWithOneDigit:
sw $t0 0($s2)
jr $ra

finishReadingStr:
jr $ra

saveToArray:
sw $t0 0($s2)
addi $s2 $s2 4
j strToArray

strToArray:
lb $t0 0($s1)
beq $t0 $0 finishReadingStr
addi $s1 $s1 1
blt $t0 48 strToArray	
bgt $t0 57 strToArray	#if not 0-9, process next char
addi $t0, $t0, -48 	#ascii to actual int	
lb $t1 0($s1)		#load next char
beq $t1 $0 finishReadingStrWithOneDigit
addi $s1 $s1 1
blt $t1 48 saveToArray	
bgt $t1 57 saveToArray	#if not 0-9, process next char
addi $t1 $t1 -48
mul $t0 $t0 10
add $t0 $t0 $t1
j saveToArray

finishReadingArray:
jr $ra

arrayToStr:
la $s1 newbuff
loop:
lw $t0 outArray($t8)#################to be changed to outArray
beq $t8 672 finishReadingArray
addi $t8 $t8 4
bgt $t0 9 processTwoDigits
addi $t0 $t0 48 #to ascii
sb $t0 0($s1)
addi $s1 $s1 1
la $t0 0x20  
sb $t0 0($s1)
addi $s1 $s1 1
j loop
processTwoDigits:
rem $t1 $t0 10
div $t2 $t0 10
addi $t1 $t1 48 #to ascii
addi $t2 $t2 48 #to ascii
sb $t2 0($s1)
addi $s1 $s1 1
sb $t1 0($s1)
addi $s1 $s1 1
la $t3 0x20
sb $t3 0($s1)
addi $s1 $s1 1
j loop

flipY: #for each row, replace 1st-12th elements with 24th-13th elements
move $t7 $ra
#for r in range(0,6)
#    for c in range(0,24)
#	t0=getAddress(r,c)
#	t1=getAddress(r,23-c)
#	newbuff[t0]=buffer[t1]
li $t0 0 #t0=r
loopFlipY1:
beq $t0 7 finishFlippingY
li $t1 0#t1=c

loopFlipY2:
beq $t1 24 rPlusOneY
addi $a0 $t0 0
addi $a1 $t1 0
jal getAddress
addi $t2 $v0 0 #t2=current element's address in inArray
li $t4 23
sub $a1 $t4 $t1
jal getAddress
addi $t3 $v0 0 #target address
lw $t5 inArray($t2) #t5=inArray[t2]
lw $t6 inArray($t3) #t6=inArray[t3]
sw $t5 outArray($t3)#outArray[t3]=t5
sw $t6 outArray($t2)#outArray[t2]=t6
addi $t1 $t1 1
j loopFlipY2

rPlusOneY:
addi $t0 $t0 1
j loopFlipY1


finishFlippingY:
move $ra $t7
jr $ra

move $ra $t7
jr $ra

flipX: #keep the 4th row, interchage 1st 2nd 3rd and 7th 6th 5th row
move $t7 $ra
#for r in range(0,7)
#    for c in range(0,24)
#	t0=getAddress(r,c)
#	t1=getAddress(6-r,c)
#	newbuff[t0]=buffer[t1]
li $t0 0 #t0=r
loopFlipX1:
beq $t0 7 finishFlippingX
li $t1 0#t1=c

loopFlipX2:
beq $t1 24 rPlusOneX
addi $a0 $t0 0
addi $a1 $t1 0
jal getAddress
addi $t2 $v0 0 #t2=current element's address in inArray
li $t4 6
sub $a0 $t4 $t0
jal getAddress
addi $t3 $v0 0 #target address
lw $t5 inArray($t2) #t5=inArray[t2]
lw $t6 inArray($t3) #t6=inArray[t3]
sw $t5 outArray($t3)#outArray[t3]=t5
sw $t6 outArray($t2)#outArray[t2]=t6
addi $t1 $t1 1
j loopFlipX2

rPlusOneX:
addi $t0 $t0 1
j loopFlipX1


finishFlippingX:
move $ra $t7
jr $ra

getAddress:	#a0=row a1=col
mul $v0 $a0 24
add $v0 $v0 $a1
mul $v0 $v0 4
jr $ra

