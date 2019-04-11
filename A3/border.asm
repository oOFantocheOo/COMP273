#name: Yuyao Zhang
#studentID: 260832483

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "borded.pgm"	#used as output

borderwidth: .word 1    #specifies border width
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
headerbuff: .space 2048  #stores header

#any extra data you specify MUST be after this line 
space: .asciiz " "
flag: .asciiz "\nflag\n"
cantOpen: .asciiz "\nCannot open file!\n"
cantRead: .asciiz "\nCannot read file!\n"
cantClose: .asciiz "\nCannot close file!\n"
specifiedCharacters: .asciiz "P2\n24 7\n15\n"
.align 4
outArray: .space 2048	#arrays of integers
inArray: .space 672	
P:.byte 'P'
one:.byte '1'
two:.byte '2'
five:.byte '5'
newLine:.byte '\n'
blank:.byte ' '
	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile


	la $a0,buffer		#$a1 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a2 will specify the buffer that will hold the flipped array.
	la $a2,borderwidth
	jal bord


	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
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

bord:
#a0=buffer
#a1=newbuff
#a2=borderwidth
#Can assume 24 by 7 as input
#Try to understand the math before coding!
#EXAMPLE: if borderwidth=2, 24 by 7 becomes 28 by 11.
la $s1 buffer
la $s2 inArray
move $t9 $ra	#store return register in t9

jal strToArray

jal generateNewHeader

lw $s3 borderwidth

jal setAllToFifteen

jal copyArrayToNewPosition

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
		la   $a1, headerbuff  
		beqz $s5 elevenChars
		li   $a2, 12
		j nextStep
		
		elevenChars:
		li $a2 11
		
		nextStep:
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
lw $t0 outArray($t8)
beq $t8 2048 finishReadingArray
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



copyArrayToNewPosition: 
move $t7 $ra
li $t0 0 #t0=r
loopCopy1:
beq $t0 7 finishCopy
li $t1 0#t1=c

loopCopy2:
beq $t1 24 rPlusOne
addi $a0 $t0 0
addi $a1 $t1 0
jal getAddress
addi $t2 $v0 0 #t2=current element's address in inArray
jal getNewAddress
addi $t3 $v0 0 #target address
lw $t5 inArray($t2) #t5=inArray[t2]
sw $t5 outArray($t3)#outArray[t3]=t5
addi $t1 $t1 1
j loopCopy2

rPlusOne:
addi $t0 $t0 1
j loopCopy1


finishCopy:
move $ra $t7
jr $ra

getAddress:	#a0=row a1=col
mul $v0 $a0 24
add $v0 $v0 $a1
mul $v0 $v0 4
jr $ra

getNewAddress: #a0=row a1=col
add $a0 $a0 $s3
add $a1 $a1 $s3
mul $v0 $a0 $s1
add $v0 $v0 $a1
mul $v0 $v0 4
jr $ra

generateNewHeader:
lw $t0 borderwidth
addi $s1 $t0 24
add $s1 $s1 $t0 #s1=new width=24+2*borderwidth
addi $s2 $t0 7
add $s2 $s2 $t0#same for s2=length
la $t0 headerbuff
lb $t1 P
sb $t1 0($t0)
addi $t0 $t0 1
lb $t1 two
sb $t1 0($t0)
addi $t0 $t0 1
lb $t1 newLine
sb $t1 0($t0)
addi $t0 $t0 1

div $s3 $s1 10
rem $s4 $s1 10
div $s5 $s2 10
rem $s6 $s2 10

addi $s3 $s3 48 #to ascii
addi $s4 $s4 48 #to ascii
addi $s6 $s6 48 #to ascii

sb $s3 0($t0)
addi $t0 $t0 1
sb $s4 0($t0)
addi $t0 $t0 1
la $t1 0x20
sb $t1 0($t0)
addi $t0 $t0 1

beqz $s5 oneDigit
addi $s5 $s5 48 #to ascii
sb $s5 0($t0)
addi $t0 $t0 1
oneDigit:
sb $s6 0($t0)
addi $t0 $t0 1

lb $t1 newLine
sb $t1 0($t0)
addi $t0 $t0 1
lb $t1 one
sb $t1 0($t0)
addi $t0 $t0 1
lb $t1 five
sb $t1 0($t0)
addi $t0 $t0 1
lb $t1 newLine
sb $t1 0($t0)
addi $t0 $t0 1

jr $ra

setAllToFifteen:
move $s4 $ra
li $t0 0 #t0=r
loopSet1:
beq $t0 $s2 finishSet
li $t1 0#t1=c

loopSet2:
beq $t1 $s1 rPlusOneSet
addi $a0 $t0 0
addi $a1 $t1 0
jal getAddressSet
addi $t2 $v0 0
li $t5 15 #t5=inArray[t2]
sw $t5 outArray($t2)#outArray[t3]=t5
addi $t1 $t1 1
j loopSet2

rPlusOneSet:
addi $t0 $t0 1
j loopSet1


finishSet:
move $ra $s4
jr $ra

getAddressSet:	#a0=row a1=col
mul $v0 $a0 $s1
add $v0 $v0 $a1
mul $v0 $v0 4
jr $ra






