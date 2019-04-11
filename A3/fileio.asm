#name: Yuyao Zhang
#studentID: 260832483

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt" #used as input
output:	.asciiz "copy.pgm"	#used as output

buffer:  .space 2048		# buffer for upto 2048 bytes
cantOpen: .asciiz "\nCannot open file!\n"
cantRead: .asciiz "\nCannot read file!\n"
cantClose: .asciiz "\nCannot close file!\n"
specifiedCharacters: .asciiz "P2\n24 7\n15\n"

	.text
	.globl main
	

main:	
		la $a0,input		#readfile takes $a0 as input
		jal readfile

		la $a0, output		#writefile will take $a0 as file location
		la $a1,buffer		#$a1 takes location of what we wish to write.
		jal writefile

		li $v0,10		# exit
		syscall

readfile:
#Open the file to be read,using $a0
#Conduct error check, to see if file exists
		li $v0, 13          	#open file
		li $a1, 0               #read mode
		li $a2, 0               
		syscall
		bltz $v0, errorOpen     #if there is an error
		move $s0, $v0           #else save descriptor
# You will want to keep track of the file descriptor*
# use correct file descriptor, and point to buffer
# hardcode maximum number of chars to read
# read from file
		li $v0, 14          	
		move $a0, $s0           
		la $a1, buffer          #save as buffer	
		li $a2, 2048        	
		syscall
		bltz $v0, errorRead
		la $a0, buffer		#print file
		li $v0, 4
		syscall
# address of the ascii string you just read is returned in $v1.
# the text of the string is in buffer
# close the file (make sure to check for errors)
		li   $v0, 16       
		move $a0, $s0      # file descriptor to close
		syscall       
		bltz $v0, errorClose     
		jr $ra
writefile:
#open file to be written to, using $a0.
		li $v0, 13          	#open file 
		la $t0, ($a1)		#point t0 to buffer
		la $a1, ($t3)		#point a1 to irrelevent place so t0 is not modified
		li $a1, 1              
		li $a2, 0               
		syscall
		bltz $v0, errorOpen     #if there is an error
		move $a0, $v0           #else save descriptor
#write the specified characters as seen on assignment PDF:
#P2
#24 7
#15
#write the content stored at the address in $a1.
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
#close the file (make sure to check for errors)
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

