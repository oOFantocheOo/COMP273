#name: Yuyao Zhang
#studentID: 260832483

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "cropped.pgm"	#used as output
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
x1: .word 1
x2: .word 23
y1: .word 1
y2: .word 6
headerbuff: .space 2048  #stores header
#any extra .data you specify MUST be after this line 

space: .asciiz " "
flag: .asciiz "\nflag\n"
cantOpen: .asciiz "\nCannot open file!\n"
cantRead: .asciiz "\nCannot read file!\n"
cantClose: .asciiz "\nCannot close file!\n"
specifiedCharacters: .asciiz "P2\n24 7\n15\n"
.align 4
outArray: .space 672	#arrays of integers
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


    #load the appropriate values into the appropriate registers/stack positions
    #appropriate stack positions outlined in function*
	jal crop

	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
	#add what ever else you may need to make this work.
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


crop:
#a0=x1
#a1=x2
#a2=y1
#a3=y2
#16($sp)=buffer
#20($sp)=newbuffer that will be made
#Remember to store ALL variables to the stack as you normally would,
#before starting the routine.
#Try to understand the math before coding!
#There are more than 4 arguments, so use the stack accordingly.
la $s0 buffer
la $s4 inArray

sw $s0 16($sp) #store buffer to 16($sp)
sw $s4 20($sp)
move $s7 $ra	#store return register in s7

jal strToArray


lw $a0 x1
lw $a1 x2
lw $a2 y1
lw $a3 y2
jal generateNewHeader

jal copyArrayToNewPosition

jal arrayToStr

move $ra $s7
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
		beqz $s3 tenChars
		
		
		li   $a2, 11
		j nextStep
		
		tenChars:
		li $a2 10
		
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
sw $t0 0($s4)
jr $ra

finishReadingStr:
jr $ra

saveToArray:
sw $t0 0($s4)
addi $s4 $s4 4
j strToArray

strToArray:
lb $t0 0($s0)
beq $t0 $0 finishReadingStr
addi $s0 $s0 1
blt $t0 48 strToArray	
bgt $t0 57 strToArray	#if not 0-9, process next char
addi $t0, $t0, -48 	#ascii to actual int	
lb $t1 0($s0)		#load next char
beq $t1 $0 finishReadingStrWithOneDigit
addi $s0 $s0 1
blt $t1 48 saveToArray	
bgt $t1 57 saveToArray	#if not 0-9, process next char
addi $t1 $t1 -48
mul $t0 $t0 10
add $t0 $t0 $t1
j saveToArray

finishReadingArray:
jr $ra

arrayToStr:
la $s0 newbuff
li $t8 0
loop:
lw $t0 outArray($t8)
beq $t8 672 finishReadingArray
addi $t8 $t8 4
bgt $t0 9 processTwoDigits
addi $t0 $t0 48 #to ascii
sb $t0 0($s0)
addi $s0 $s0 1
la $t0 0x20  
sb $t0 0($s0)
addi $s0 $s0 1
j loop
processTwoDigits:
rem $t1 $t0 10
div $t2 $t0 10
addi $t1 $t1 48 #to ascii
addi $t2 $t2 48 #to ascii
sb $t2 0($s0)
addi $s0 $s0 1
sb $t1 0($s0)
addi $s0 $s0 1
la $t3 0x20
sb $t3 0($s0)
addi $s0 $s0 1
j loop


copyArrayToNewPosition: 
move $s6 $ra
li $t3 0
lw $t6 x1
lw $t7 y1
lw $t0 x1 #t0=c
lw $t9 x2

lw $t1 y1#t1=r
lw $t8 y2
loopCopy1:
beq $t1 $t8 finishCopy
lw $t0 x1
loopCopy2:
beq $t0 $t9 rPlusOne
addi $a0 $t1 0
addi $a1 $t0 0
jal getAddress
addi $t2 $v0 0 #t2=current element's address in inArray
lw $t5 inArray($t2) #t5=inArray[t2]
sw $t5 outArray($t3)#outArray[t3]=t5
addi $t3 $t3 4
addi $t0 $t0 1
j loopCopy2

rPlusOne:
addi $t1 $t1 1
j loopCopy1

finishCopy:
move $ra $s6
jr $ra

getAddress:	#a0=row a1=col
mul $v0 $a0 24
add $v0 $v0 $a1
mul $v0 $v0 4
jr $ra

generateNewHeader:
sub $s0 $a1 $a0
sub $s1 $a3 $a2
 #s0=new width=x2-x1
 #same for s1=length
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

div $s3 $s0 10
rem $s2 $s0 10

addi $s2 $s2 48 #to ascii
addi $s1 $s1 48 #to ascii

beqz $s3 oneDigitX
addi $s3 $s3 48 #to ascii
sb $s3 0($t0)
addi $t0 $t0 1
oneDigitX:
sb $s2 0($t0)
addi $t0 $t0 1

la $t1 0x20
sb $t1 0($t0)
addi $t0 $t0 1

sb $s1 0($t0)
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
