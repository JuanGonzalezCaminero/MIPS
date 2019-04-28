.data
	A:.word 0x20, 0x40, 0x10, 0x01, 0x03, 0x22, 0x08
	B:.word 10, 24, 55, 67, 89, 90, 110
	C:.space 100
	coma:.asciiz ", "
.text		
		#Cargo la direcci�n inicial de A en $s0
		la $s0, A
		#Cargo la direcci�n inicial de B en $s1
		la $s1, B
		#Cargo la direcci�n inicial de C en $s2
		la $s2, C
		#Voy a usar el registro $s7 como �ndice
		addi $s7,$zero,0
		#Y $s6 para guardar un 7 para comparar con el �ndice
		addi $s6, $zero, 7
		#El siguiente bucle suma las componentes de A y de B y las pone en la correspondiente
		#Posici�n en C, despu�s les suma 4 a las direcciones en $s0, $s1 y $s2
		
BucleSumar:	#Si el �ndice es 7, salgo del bucle
		beq $s7,$s6,FinSumar
		#Cargo en $t0 el dato en la direcci�n A[i]
		lw $t0,($s0)
		#Cargo en $t1 el dato en B[i]
		lw $t1,($s1)
		#Sumo ambos datos en $t2
		add $t2, $t0, $t1
		#Guargo el resultado en C[i]
		sw $t2,($s2)
		#Le sumo 4 a cada direcci�n para pasar a la siguiente posici�n del vector
		addi $s0,$s0,4
		addi $s1,$s1,4
		addi $s2,$s2,4
		#Le sumo 1 al �ndice
		addi $s7,$s7,1
		#Vuelvo al principio del bucle	
		j BucleSumar
FinSumar:	#Despu�s de salir del bucle, uso otro bucle para imprimir el contenido del 
		#Vector por pantalla, la condici�n de salida es la misma
		
		#Guargo la direcci�n inicial de la cadena "coma" en $s3
		la $s3, coma
		#Guardo de nuevo la direcci�n inicial de C en $s2
		la $s2, C
		#Pongo el �ndice a 0 de nuevo
		addi $s7, $zero, 0
		
BucleImprimir:	#Compruebo si ya se han realizado 7 iteraciones
		beq $s6, $s7, FinImprimir
		#Cargo C[i] en $t0
		lw $t0,($s2)
		#Cargo el dato le�do en $a0 para imprimirlo
		add $a0, $t0, $zero
		#Guardo un 1 en $v0 (1-print int)
		addi $v0, $zero, 1
		#Imprimo el n�mero por pantalla
		syscall
		#Pongo la direcci�n inicial de la cadena "coma" en $a0 
		#Para imprimirla
		add $a0, $s3, $zero
		#Guardo un 4 en $v0 (4-print String)
		addi $v0, $zero, 4
		#Imprimo la coma
		syscall
		#Sumo 4 a la direcci�n en $s2 para pasar a la siguiente
		#posici�n del vector
		addi $s2, $s2, 4
		#Le sumo 1 al �ndice
		addi $s7,$s7,1
		#Vuelvo al inicio del bucle
		j BucleImprimir
FinImprimir:	#Acabo el programa
		addi $v0, $zero, 10
		syscall
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	