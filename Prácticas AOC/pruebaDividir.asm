.data
Cad1:.asciiz "\n"
.text
	li $s0, 145
	li $s1, 10
	div $s3, $s0, $s1
	mfhi $s4
	li $v0, 1
	move $a0,$s3
	syscall
	
	li $v0,4
	la $a0, Cad1
	syscall
	
	li $v0, 1
	move $a0, $s4
	syscall
	li $v0,10
	syscall