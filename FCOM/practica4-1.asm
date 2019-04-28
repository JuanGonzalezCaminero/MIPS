	addi $t0,$zero,20 #para ver si se han escrito 20 potencias
	addi $a0,$zero,1 #Se van a escribir los valores en $a0
	addi $v0,$zero,1 #1-print int
Bucle:  addi $t0,$t0,-1
	syscall
	sll $a0,$a0,1 #($a0*2)
	bne $t0,$zero,Bucle
	addi $v0,$zero,10
	syscall
