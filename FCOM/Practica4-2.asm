.text		
		addi $s1,$zero,1 #Este número se utiliza para hacer ands con el número introducido y ver lo que hay en cada posición
		addi $s0,$zero,255 #este es el número del que se quiere saber el número de bits a 1 en su representación
		addi $t1,$zero,0 #Contador de bits a 1
		addi $t2,$t2,32 #El bucle acaba después de mover el 1 en $s1 32 bits (pongo 32 en vez de 31 por cómo se comprueba al final del bucle)

Bucle:		and $t3,$s1,$s0 #Con cada and se comprueba una posición, si el resultado es 1, el bit de $s0 está a 1
		beq $t3,$zero,Continua
		addi $t1,$t1,1#Si el bit está a 1, le suma 1 al contador
Continua:	sll $s1,$s1,1 #Desplaza el bit a 1 de $s1 una posición a la izquierda
		addi $t2,$t2,-1
		bne $t2,$zero,Bucle
		addi $v0,$zero,1
		add $a0,$zero,$t1
		syscall
		addi $v0,$zero,10
		syscall