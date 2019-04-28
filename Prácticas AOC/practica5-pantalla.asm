.data
Cadena:.space 20
Destino:.space 9
#Reservo 9 bytes para los 8 caracteres ASCII por los 8 dígitos
#hexadecimales de los que se compone el número + el terminador de cadena
Salida:.asciiz "\nEl número es: "
Error1:.asciiz "Hay caracteres no válidos en la cadena"
Error2:.asciiz "Cadena demasiado larga"
Pide:.asciiz "Introduce un número en hexadecimal: 0x"
CadenaSalida:.asciiz "\nEl opuesto del número introducido es: 0x"
.text		
PedirDeNuevo:	#Direccion inicial de la cadena
		la $t0, Cadena
		#Guardo el 0x:
		li $t1, 48
		sb $t1, ($t0)
		addi $t0,$t0,1
		li $t1, 78
		sb $t1, ($t0)
		#Pido el número:
		la $a0, Pide
		#Cargo un 4 en $v0 (4 - Print String)
		li $v0, 4
		syscall
		#Cargo un 8 en $v0 (4 - Read String)
		li $v0, 8
		#Cargo en $a0 la dirección donde se almacena y la longitud (9) en $a1
		add $a0, $zero, $t0
		li $a1, 9
		syscall
		#Recorro la cadena y cambio el line feed, si está, por un 0:
		#Indice en $t1
		li $t1, 8
		li $t2, 10
		BucleLF:	#Cargo un byte de la cadena en $t0
		lb $t0,($a0)
		bne $t0, 10, SigueBucle
		#Si es 10, pone un 0 y sale del bucle
		sb $zero, ($a0)
		j SalirBucle
SigueBucle:	#Le suma 1 a la dirección
		addi $a0, $a0, 1
		#Le resta 1 al índice
		subi $t1, $t1, 1
		beq $t1,$zero,SalirBucle
		j BucleLF
		
SalirBucle:	#Cargo la dirección inicial en $a0
		la $a0, Cadena
		#Llamo a la función que obtiene el número en binario a partir de la cadena hexadecimal
		jal HexABinario
		#Compruebo si ha habido errores:
		beq $v1, $zero, ObtenerOpuesto
		li $t6,1
		bne $v1, $t6, CadLarga
		la $a0, Error1
		#Cargo un 4 en $v0 (4 - Print String)
		li $v0, 4
		syscall
		#Vuelvo a pedir la entrada:
		j PedirDeNuevo
CadLarga:	la $a0, Error2
		#Cargo un 4 en $v0 (4 - Print String)
		li $v0, 4
		syscall
		j FinPrograma
ObtenerOpuesto:
		#guardo en $a0 el opuesto del número
		sub $a0, $zero, $v0
		la $a1, Destino
		#Paso ese número a una cadena hexadecimal
		jal CadenaHex
		#Imprimo la salida
		li $v0, 4
		la $a0, CadenaSalida
		syscall
		
		li $v0, 4
		la $a0, Destino
		syscall
		
FinPrograma:	#Cargo un 10 en $v0
		li $v0, 10
		#Exit
		syscall
HexABinario:	#Esta función recibe como parámetro la dirección de una cadena ascii que contiene un número
		#en hexadecimal en $a0, lo convierte a binario y devuelve el resultado en $v0, si hay algún error
		#lo indica con un mensaje en $v1
		#Para realizar la conversión, primero adelanta el puntero 2 posiciones para saltarse los dos bytes
		#correspondientes al "0x", después, utiliza un bucle controlado por índice para cargar uno a uno los
		#8 bytes siguientes, para cada byte, primero comprueba qué caracter es, si es mayor que 47 y menor
		#que 58, será un número del 0 al 9, le resta 48 para obtener el número deseado, si es mayor que 64 
		#y menor que 71, le resta 55, ya que será una letra mayúscula, si es mayor que 96 y menor que 103, es
		# una letra minúscula y le resta 87, si no está en ninguno de los intervalos anteriores, es un caracter no
		#hexadecimal y se sale de la función con un código de error
		#Después de lo anterior, se mueve el byte cargado, que estará a la derecha del todo, a su posición final
		#usando un bucle, y por último se hace un or con $v0 para colocarlo
		
		#Pongo $v0 a 0
		add $v0, $zero, $zero
		#cargo un 8 en $t1 para usarlo de índice
		li $t1, 8
		#Aumento en 2 el registro que apunta a la dirección inicial de la cadena:
		add $a0, $a0, 1
		 
BucleExtraerBin:
		#Cargo un byte en $t0:
		lb $t0, ($a0)
		#Si el byte cargado es 0 y el índice en $t1 no es 0 aún, es que la cadena era de menos
		#de 8 caracteres, en ese caso muevo el contenido de $v0 a la derecha en función de lo
		#que quede en $t1 y después salgo de la función
		bne $t0, $zero, Sigue
		beq $t1, $zero, Sigue
		#Copio el valor del índice en $t3, indica cuánto mover los bits
		add $t3, $zero, $t1
		#Si el índice no es 0, en cuyo caso no hay que moverlos, entro en el bucle que los mueve
		beq $t3, $zero, Salir
MueveDerecha:	#muevo el contenido de $t0 4 posiciones hacia la derecha:
		srl $v0, $v0, 4
		#Le resto 1 al índice, si el resultado no es 0, repito el bucle
		subi $t3,$t3,1
		beq $t3, $zero, Salir
		j MueveDerecha

Sigue:		#Aumento $a0 en 1:
		addi $a0, $a0, 1
		#Ahora compruebo si es un dígito hexadecimal y lo convierto a binario:
		slti $t2, $t0, 48
		#En cada comprobación $t2 tiene que ser 0, si no no es un caracter válido
		slti $t3, $t0, 58
		#Si $t3 no es 1, se comprueba el siguiente intervalo
		#Usando lo anterior, compruebo si se sale y actúo en consecuencia:
		bne $t2, $zero, Error
		beq $t3, $zero, CompruebaMayus
		#Si no hay error, le resto lo que corresponda:
		subi $t0, $t0, 48
		j FinComprobacion
		
		#Comprobación del intervalo de las mayúsculas:
CompruebaMayus: slti $t2, $t0, 65
		#En cada comprobación $t2 tiene que ser 0, si no no es un caracter válido
		slti $t3, $t0, 71
		#Si $t3 no es 1, se comprueba el siguiente intervalo
		#Usando lo anterior, compruebo si se sale y actúo en consecuencia:
		bne $t2, $zero, Error
		beq $t3, $zero, CompruebaMinus
		#Si no hay error, le resto lo que corresponda:
		subi $t0, $t0, 55
		j FinComprobacion
		
		#Comprobación del intervalo de las minúsculas:
CompruebaMinus: slti $t2, $t0, 97
		#En cada comprobación $t2 tiene que ser 0, si no no es un caracter válido
		slti $t3, $t0, 103
		#Si $t3 no es 1, se comprueba el siguiente intervalo
		#Usando lo anterior, compruebo si se sale y actúo en consecuencia:
		bne $t2, $zero, Error
		beq $t3, $zero, Error
		#Si no hay error, le resto lo que corresponda:
		subi $t0, $t0, 87
		j FinComprobacion
		
Error:		#Pongo el error 1-carácter incorrecto en $v1 y salgo de la función:
		li $v1, 1
		jr $ra
		
FinComprobacion:
		#Desplazo el byte leído para dejarlo en la posición corespondiente, lo que nos
		#interesa son 4 bits a la derecha del registro, habrá que moverlos más cuanto mayor
		#sea el índice
		
		#Copio el valor del índice en $t3, indica cuánto mover los bits
		add $t3, $zero, $t1
		#Le resto 1:
		subi $t3,$t3,1
		#Si el índice no es 0, en cuyo caso no hay que moverlos, entro en el bucle que los mueve
		beq $t3, $zero,ContinuaBucle
BucleMoverBits:	#muevo el contenido de $t0 4 posiciones hacia la izquierda:
		sll $t0, $t0, 4
		#Le resto 1 al índice, si el resultado no es 0, repito el bucle
		subi $t3,$t3,1
		beq $t3, $zero, ContinuaBucle
		j BucleMoverBits


ContinuaBucle:	#Le resto 1 al índice:
		subi $t1, $t1, 1
		#Hago or de $t0 y $v0:
		or $v0, $t0, $v0
		#Si el índice es 0 salgo de la función
		beq $t1, $zero, FinExtraeBin
		#Si no, vuelvo a hacer el bucle:
		j BucleExtraerBin
FinExtraeBin:	#Antes de salir cargo un byte más de $a0, si no es 0, es porque la cadena es
		#Demasiado larga:
		lb $t5, ($a0)
		beq $t5, $zero, Salir
		li $v1, 2
Salir:		jr $ra


#######################################################################################################


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
		li $t0, 0xF0000000
		 
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
BucleMoverBitsD:	#muevo el contenido de $t2 4 posiciones hacia la derecha:
		srl $t2, $t2, 4
		#Le resto 1 al índice, si el resultado no es 0, repito el bucle
		subi $t3,$t3,1
		beq $t3, $zero, Continua
		j BucleMoverBitsD


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
		j ContinuaBucleH

MayorQue9:	#Si el número es mayor que 9:
		#Le sumo 87:
		add $t2, $t2, 87
		#Guardo el resultado en la dirección indicada
		sb $t2, ($a1)
		#Le sumo 1 a la dirección donde hay que almacenarlo
		addi $a1, $a1, 1
		#Voy a la parte donde se comprueba si hay que salir del bucle:
		j ContinuaBucleH
ContinuaBucleH:	#Le resto 1 al índice:
		subi $t1, $t1, 1
		#Muevo los 4 unos 4 posiciones a la derecha:
		srl $t0, $t0, 4
		#Si el índice es 0 salgo de la función
		beq $t1, $zero, FinExtraeHex
		#Si no, vuelvo a hacer el bucle:
		j BucleExtraerHex
FinExtraeHex:	jr $ra
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
