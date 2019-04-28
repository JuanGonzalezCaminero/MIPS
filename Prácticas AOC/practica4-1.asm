.data
Destino:.space 9
#Reservo 9 bytes para los 8 caracteres ASCII por los 8 d�gitos
#hexadecimales de los que se compone el n�mero + el terminador de cadena

.text
		#Cargo un n�mero en $a0
		li $a0, 0x10000000
		#Cargo la direcci�n de destino de la cadena en $a1
		la $a1, Destino
		#Llamo a la funci�n que genera una cadena con la representaci�n 
		#hexadecimal del n�mero en $a0
		jal CadenaHex
		
		#Cargo un 4 en $v0 (4 - Print String)
		li $v0, 4
		la $a0, Destino
		syscall

		#Cargo un 10 en $v0
		li $v0, 10
		#Exit
		syscall
CadenaHex:	#Esta funci�n recibe un n�mero en $a0 y una direcci�n de memoria en $a1,
		#Genera una cadena ASCII cuyos caracteres son la representaci�n en hexadecimal
		#del n�mero y la guarda a partir de la direcci�n proporcionada.
		
		#Para ello carga 1111 0000 0000 0000 0000 0000 0000 0000 en un registro, y usa esos 4
		#unos, que va moviendo hacia la derecha de 4 en 4 para extraer cada d�gito hexadecimal,
		#si el n�mero est� entre 0 y 9 le sumamos 48 para obtener el valor de los n�meros del 
		#0 al 9 en ASCII, si es mayor que 9 (10 al 15) le sumamos 87 para obtener las letras
		#de la A a la F en ASCII
		
		#cargo un 8 en $t1 para usarlo de �ndice
		li $t1, 8
		#Cargo 1111 0000 0000 0000 0000 0000 0000 0000 en un registro:
		li $t0, 4026531840
		 
BucleExtraerHex:
		#Hago and de $t0 y $a0 para obtener el d�gito hexadecimal y guardo el resultado en $t2
		and $t2, $t0, $a0
		#Desplazo los 4 bits extra�dos para dejarlos a la derecha del registro:
		#Copio el valor del �ndice en $t3, indica cu�nto mover los bits
		add $t3, $zero, $t1
		#Le resto 1:
		subi $t3,$t3,1
		#Si el �ndice no es 0, en cuyo caso no hay que moverlos, entro en el bucle que los mueve
		beq $t3, $zero,Continua
BucleMoverBits:	#muevo el contenido de $t2 4 posiciones hacia la derecha:
		srl $t2, $t2, 4
		#Le resto 1 al �ndice, si el resultado no es 0, repito el bucle
		subi $t3,$t3,1
		beq $t3, $zero, Continua
		j BucleMoverBits


Continua:
		#Guardo un 10 en $4 para comparar
		li $t4, 10
		#Compruebo si el n�mero es menor o mayor que 9 y act�o en consecuencia
		slt $t5,$t2,$t4
		beq $t5, $zero, MayorQue9
		#Si el n�mero es menor que 9:
		#Le sumo 48:
		add $t2, $t2, 48
		#Guardo el resultado en la direcci�n indicada
		sb $t2, ($a1)
		#Le sumo 1 a la direcci�n donde hay que almacenarlo
		addi $a1, $a1, 1
		#Voy a la parte donde se comprueba si hay que salir del bucle:
		j ContinuaBucle

MayorQue9:	#Si el n�mero es mayor que 9:
		#Le sumo 87:
		add $t2, $t2, 87
		#Guardo el resultado en la direcci�n indicada
		sb $t2, ($a1)
		#Le sumo 1 a la direcci�n donde hay que almacenarlo
		addi $a1, $a1, 1
		#Voy a la parte donde se comprueba si hay que salir del bucle:
		j ContinuaBucle
ContinuaBucle:	#Le resto 1 al �ndice:
		subi $t1, $t1, 1
		#Muevo los 4 unos 4 posiciones a la derecha:
		srl $t0, $t0, 4
		#Si el �ndice es 0 salgo de la funci�n
		beq $t1, $zero, FinExtraeHex
		#Si no, vuelvo a hacer el bucle:
		j BucleExtraerHex
FinExtraeHex:	jr $ra
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
