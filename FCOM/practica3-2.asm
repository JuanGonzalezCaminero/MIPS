	addi $v0,$zero,5 #5-leer int
	syscall
	add $s0,$v0,$zero #Guarda n en $s0 porque $a0 lo voy a usar luego
	addi $a0,$zero,2 #En $a0 van a estar los números que se van imprimiendo
	addi $t1,$zero,0 #El índice en $t1 se usa para acabar el bucle
	addi $v0,$zero,1 #1-imprimir int
Bucle:	syscall
	addi $a0,$a0,2
	addi $t1,$t1,1
	bne $t1,$s0,Bucle
	addi $v0,$zero,10#10-exit
	syscall