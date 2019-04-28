.data
Cadena:.asciiz "0xF"
Salida:.asciiz "El número es: "
Error1:.asciiz "Hay caracteres no válidos en la cadena"
Error2:.asciiz "Cadena demasiado larga"
.text		
		
		#Cargo la dirección donde está el número en $a0
		la $a0, Cadena
		#Llamo a la función que obtiene el número en binario a partir de la cadena hexadecimal
		jal HexABinario
		#Compruebo si ha habido errores:
		beq $v1, $zero, ImprimeResultado
		li $t6,1
		bne $v1, $t6, CadLarga
		la $a0, Error1
		#Cargo un 4 en $v0 (4 - Print String)
		li $v0, 4
		syscall
CadLarga:	la $a0, Error2
		#Cargo un 4 en $v0 (4 - Print String)
		li $v0, 4
		syscall
		j FinPrograma
ImprimeResultado:
		add $t7, $zero, $v0
		la $a0, Salida
		#Cargo un 4 en $v0 (4 - Print String)
		li $v0, 4
		syscall
		#Cargo el resultado en $a0
		add $a0,$zero,$t7
		#Cargo un 1 en $v0 (1 - Print Int)
		li $v0,1
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
		
		#cargo un 8 en $t1 para usarlo de índice
		li $t1, 8
		#Aumento en 2 el registro que apunta a la dirección inicial de la cadena:
		add $a0, $a0, 2
		 
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
MueveDerecha:	#muevo el contenido de $t0 4 posiciones hacia la izquierda:
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
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
