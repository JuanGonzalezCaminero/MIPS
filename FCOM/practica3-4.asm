.data
A :.asciiz "Assembly is cool!"
B: .space 40
.text
		la $a0,A
		la $a1,B
		jal Copia_Cadena
		addi $v0,$zero,10 #10-Exit
		syscall
Copia_Cadena:   
Bucle:		lb $t0,0($a0)
		sb $t0,0($a1)
		addi $a0,$a0,1
		addi $a1,$a1,1
		bne $t0,$zero,Bucle
		jr $ra
