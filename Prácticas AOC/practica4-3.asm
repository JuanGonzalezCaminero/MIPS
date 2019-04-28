.data
Numero:.word 0X12345678,0xABCDEF12
#Número de 64 bits guardado en la memoria
Destino:.space 17
#Reservo 17 bytes para los 16 caracteres ASCII por los 16 dígitos
#hexadecimales de los que se compone el número + el terminador de cadena
PideCadena:.asciiz "Introduce un número entero por favor:\n"
CadenaSalida:.asciiz "El número introducido en hexadecimal es: 0x"

.text		
		#Cargo la dirección del número en $a0
		la $a0,Numero
		#Cargo la dirección de destino de la cadena en $a1
		la $a1, Destino
		#Llamo a la función que genera una cadena con la representación 
		#hexadecimal del número en $a0
		jal CadenaHex
		
		#Imprimo la salida
		li $v0, 4
		la $a0, CadenaSalida
		syscall
		
		li $v0, 4
		la $a0, Destino
		syscall

		#Cargo un 10 en $v0
		li $v0, 10
		#Exit
		syscall
CadenaHex:	#Esta función recibe la dirección de memoria de un número de 64 bits en $a0
		# y una dirección de memoria en $a1, genera una cadena ASCII cuyos caracteres
		#son la representación en hexadecimal del número y la guarda
		#a partir de la dirección proporcionada.
		
		#Primero carga los primeros 32 bits del número en un registro y genera los dígitos
		#hexadecimales correspondientes, después carga los 32 últimos
		
		#Para ello carga 1111 0000 0000 0000 0000 0000 0000 0000 en un registro, y usa esos 4
		#unos, que va moviendo hacia la derecha de 4 en 4 para extraer cada dígito hexadecimal,
		#si el número está entre 0 y 9 le sumamos 48 para obtener el valor de los números del 
		#0 al 9 en ASCII, si es mayor que 9 (10 al 15) le sumamos 55 para obtener las letras
		#de la A a la F en ASCII
		
		#Le sumo 4 a la dirección del número para cargar primero la segunda palabra
		add $a0,$a0,4
		#Guardo un 2 en $t6, lo uso como índice para volver a inicio una sola vez
		li $t6, 2
Inicio:
		#Cargo 32 bits a partir de la posición almacenada en $a0 en $t7, y luego le resto 4 a $a0 para
		#que la siguiente pasada cargue los siguientes 32:
		lw $t7, ($a0)
		sub $a0,$a0,4
		#cargo un 8 en $t1 para usarlo de índice
		li $t1, 8
		#Cargo 1111 0000 0000 0000 0000 0000 0000 0000 en un registro:
		li $t0, 4026531840
		 
BucleExtraerHex:
		#Hago and de $t0 y $t7 para obtener el dígito hexadecimal y guardo el resultado en $t2
		and $t2, $t0, $t7
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
		add $t2, $t2, 55
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
FinExtraeHex:	
		#Salgo de la función siempre y cuando se haya recorrido la función 2 veces
		#Le resto 1 a $t6
		subi $t6,$t6,1
		#Si no es 0, vuelvo al principio y repito todo
		bne $t6, $zero, Inicio
		jr $ra
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
