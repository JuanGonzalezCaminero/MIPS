.data
Destino:.space 9
#Reservo 9 bytes para los 8 caracteres ASCII por los 8 dígitos
#hexadecimales de los que se compone el número + el terminador de cadena

.text
		#Cargo un número en $a0
		li $a0, 0x10000000
		#Cargo la dirección de destino de la cadena en $a1
		la $a1, Destino
		#Llamo a la función que genera una cadena con la representación 
		#hexadecimal del número en $a0
		jal CadenaHex
		
		#Cargo un 4 en $v0 (4 - Print String)
		li $v0, 4
		la $a0, Destino
		syscall

		#Cargo un 10 en $v0
		li $v0, 10
		#Exit
		syscall
CadenaHex:	#Esta función recibe un número en $a0 y una dirección de memoria en $a1,
		#Genera una cadena ASCII cuyos caracteres son la representación en hexadecimal
		#del número y la guarda a partir de la dirección proporcionada.
		
		#Para ello carga 1111 0000 0000 0000 0000 0000 0000 0000 en un registro, y usa esos 4
		#unos, que va moviendo hacia la derecha de 4 en 4 para extraer cada dígito hexadecimal,
		#si el número está entre 0 y 9 le sumamos 48 para obtener el valor de los números del 
		#0 al 9 en ASCII, si es mayor que 9 (10 al 15) le sumamos 87 para obtener las letras
		#de la A a la F en ASCII
		
		#cargo un 8 en $t1 para usarlo de índice
		li $t1, 8
		#Cargo 1111 0000 0000 0000 0000 0000 0000 0000 en un registro:
		li $t0, 4026531840
		 
BucleExtraerHex:
		#Hago and de $t0 y $a0 para obtener el dígito hexadecimal y guardo el resultado en $t2
		and $t2, $t0, $a0
		#Desplazo los 4 bits extraídos para dejarlos a la derecha del registro:
		#Copio el valor del índice en $t3, indica cuánto mover los bits
		add $t3, $zero, $t1
		#Le resto 1:
		subi $t3,$t3,1
		#Si el índice no es 0, en cuyo caso no hay que moverlos, entro en el bucle que los mueve
		beq $t3, $zero,Continua
BucleMoverBits:	#muevo el contenido de $t2 4 posiciones hacia la derecha:
		srl $t2, $t2, 4
		#Le resto 1 al índice, si el resultado no es 0, repito el bucle
		subi $t3,$t3,1
		beq $t3, $zero, Continua
		j BucleMoverBits


Continua:
		#Guardo un 10 en $4 para comparar
		li $t4, 10
		#Compruebo si el número es menor o mayor que 9 y actúo en consecuencia
		slt $t5,$t2,$t4
		beq $t5, $zero, MayorQue9
		#Si el número es menor que 9:
		#Le sumo 48:
		add $t2, $t2, 48
		#Guardo el resultado en la dirección indicada
		sb $t2, ($a1)
		#Le sumo 1 a la dirección donde hay que almacenarlo
		addi $a1, $a1, 1
		#Voy a la parte donde se comprueba si hay que salir del bucle:
		j ContinuaBucle

MayorQue9:	#Si el número es mayor que 9:
		#Le sumo 87:
		add $t2, $t2, 87
		#Guardo el resultado en la dirección indicada
		sb $t2, ($a1)
		#Le sumo 1 a la dirección donde hay que almacenarlo
		addi $a1, $a1, 1
		#Voy a la parte donde se comprueba si hay que salir del bucle:
		j ContinuaBucle
ContinuaBucle:	#Le resto 1 al índice:
		subi $t1, $t1, 1
		#Muevo los 4 unos 4 posiciones a la derecha:
		srl $t0, $t0, 4
		#Si el índice es 0 salgo de la función
		beq $t1, $zero, FinExtraeHex
		#Si no, vuelvo a hacer el bucle:
		j BucleExtraerHex
FinExtraeHex:	jr $ra
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
