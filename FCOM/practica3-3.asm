	addi $v0,$zero,5 #5-leer int
	syscall
	add $a0,$v0,$zero #Guarda n en $a0
        jal Procedimiento #Guarda la direcci�n de retorno en $ra y le pasa el control a "Procedimiento"
	addi $v0,$zero,10#10-exit
	syscall
	
Procedimiento:	add  $s0,$zero,$a0 #Guarda n en $s0 (porque $a0 se usa para las syscall para pasar el par�metro a imprimir)
		addi $a0,$zero,2 #En $a0 van a estar los n�meros que se van imprimiendo
		addi $t1,$zero,0 #El �ndice en $t1 se usa para acabar el bucle
		addi $v0,$zero,1 #1-imprimir int
Bucle:		syscall
		addi $a0,$a0,2
		addi $t1,$t1,1
		bne $t1,$s0,Bucle
		jr $ra #copia $ra en el PC (y vuelve de la funci�n)
