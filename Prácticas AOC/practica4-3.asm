.data
Numero:.word 0X12345678,0xABCDEF12
#N�mero de 64 bits guardado en la memoria
Destino:.space 17
#Reservo 17 bytes para los 16 caracteres ASCII por los 16 d�gitos
#hexadecimales de los que se compone el n�mero + el terminador de cadena
PideCadena:.asciiz "Introduce un n�mero entero por favor:\n"
CadenaSalida:.asciiz "El n�mero introducido en hexadecimal es: 0x"

.text		
		#Cargo la direcci�n del n�mero en $a0
		la $a0,Numero
		#Cargo la direcci�n de destino de la cadena en $a1
		la $a1, Destino
		#Llamo a la funci�n que genera una cadena con la representaci�n 
		#hexadecimal del n�mero en $a0
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
CadenaHex:	#Esta funci�n recibe la direcci�n de memoria de un n�mero de 64 bits en $a0
		# y una direcci�n de memoria en $a1, genera una cadena ASCII cuyos caracteres
		#son la representaci�n en hexadecimal del n�mero y la guarda
		#a partir de la direcci�n proporcionada.
		
		#Primero carga los primeros 32 bits del n�mero en un registro y genera los d�gitos
		#hexadecimales correspondientes, despu�s carga los 32 �ltimos
		
		#Para ello carga 1111 0000 0000 0000 0000 0000 0000 0000 en un registro, y usa esos 4
		#unos, que va moviendo hacia la derecha de 4 en 4 para extraer cada d�gito hexadecimal,
		#si el n�mero est� entre 0 y 9 le sumamos 48 para obtener el valor de los n�meros del 
		#0 al 9 en ASCII, si es mayor que 9 (10 al 15) le sumamos 55 para obtener las letras
		#de la A a la F en ASCII
		
		#Le sumo 4 a la direcci�n del n�mero para cargar primero la segunda palabra
		add $a0,$a0,4
		#Guardo un 2 en $t6, lo uso como �ndice para volver a inicio una sola vez
		li $t6, 2
Inicio:
		#Cargo 32 bits a partir de la posici�n almacenada en $a0 en $t7, y luego le resto 4 a $a0 para
		#que la siguiente pasada cargue los siguientes 32:
		lw $t7, ($a0)
		sub $a0,$a0,4
		#cargo un 8 en $t1 para usarlo de �ndice
		li $t1, 8
		#Cargo 1111 0000 0000 0000 0000 0000 0000 0000 en un registro:
		li $t0, 4026531840
		 
BucleExtraerHex:
		#Hago and de $t0 y $t7 para obtener el d�gito hexadecimal y guardo el resultado en $t2
		and $t2, $t0, $t7
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
		add $t2, $t2, 55
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
FinExtraeHex:	
		#Salgo de la funci�n siempre y cuando se haya recorrido la funci�n 2 veces
		#Le resto 1 a $t6
		subi $t6,$t6,1
		#Si no es 0, vuelvo al principio y repito todo
		bne $t6, $zero, Inicio
		jr $ra
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
