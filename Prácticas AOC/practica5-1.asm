.data
Cadena:.asciiz "0xF"
Salida:.asciiz "El n�mero es: "
Error1:.asciiz "Hay caracteres no v�lidos en la cadena"
Error2:.asciiz "Cadena demasiado larga"
.text		
		
		#Cargo la direcci�n donde est� el n�mero en $a0
		la $a0, Cadena
		#Llamo a la funci�n que obtiene el n�mero en binario a partir de la cadena hexadecimal
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
HexABinario:	#Esta funci�n recibe como par�metro la direcci�n de una cadena ascii que contiene un n�mero
		#en hexadecimal en $a0, lo convierte a binario y devuelve el resultado en $v0, si hay alg�n error
		#lo indica con un mensaje en $v1
		#Para realizar la conversi�n, primero adelanta el puntero 2 posiciones para saltarse los dos bytes
		#correspondientes al "0x", despu�s, utiliza un bucle controlado por �ndice para cargar uno a uno los
		#8 bytes siguientes, para cada byte, primero comprueba qu� caracter es, si es mayor que 47 y menor
		#que 58, ser� un n�mero del 0 al 9, le resta 48 para obtener el n�mero deseado, si es mayor que 64 
		#y menor que 71, le resta 55, ya que ser� una letra may�scula, si es mayor que 96 y menor que 103, es
		# una letra min�scula y le resta 87, si no est� en ninguno de los intervalos anteriores, es un caracter no
		#hexadecimal y se sale de la funci�n con un c�digo de error
		#Despu�s de lo anterior, se mueve el byte cargado, que estar� a la derecha del todo, a su posici�n final
		#usando un bucle, y por �ltimo se hace un or con $v0 para colocarlo
		
		#cargo un 8 en $t1 para usarlo de �ndice
		li $t1, 8
		#Aumento en 2 el registro que apunta a la direcci�n inicial de la cadena:
		add $a0, $a0, 2
		 
BucleExtraerBin:
		#Cargo un byte en $t0:
		lb $t0, ($a0)
		#Si el byte cargado es 0 y el �ndice en $t1 no es 0 a�n, es que la cadena era de menos
		#de 8 caracteres, en ese caso muevo el contenido de $v0 a la derecha en funci�n de lo
		#que quede en $t1 y despu�s salgo de la funci�n
		bne $t0, $zero, Sigue
		beq $t1, $zero, Sigue
		#Copio el valor del �ndice en $t3, indica cu�nto mover los bits
		add $t3, $zero, $t1
		#Si el �ndice no es 0, en cuyo caso no hay que moverlos, entro en el bucle que los mueve
		beq $t3, $zero, Salir
MueveDerecha:	#muevo el contenido de $t0 4 posiciones hacia la izquierda:
		srl $v0, $v0, 4
		#Le resto 1 al �ndice, si el resultado no es 0, repito el bucle
		subi $t3,$t3,1
		beq $t3, $zero, Salir
		j MueveDerecha

Sigue:		#Aumento $a0 en 1:
		addi $a0, $a0, 1
		#Ahora compruebo si es un d�gito hexadecimal y lo convierto a binario:
		slti $t2, $t0, 48
		#En cada comprobaci�n $t2 tiene que ser 0, si no no es un caracter v�lido
		slti $t3, $t0, 58
		#Si $t3 no es 1, se comprueba el siguiente intervalo
		#Usando lo anterior, compruebo si se sale y act�o en consecuencia:
		bne $t2, $zero, Error
		beq $t3, $zero, CompruebaMayus
		#Si no hay error, le resto lo que corresponda:
		subi $t0, $t0, 48
		j FinComprobacion
		
		#Comprobaci�n del intervalo de las may�sculas:
CompruebaMayus: slti $t2, $t0, 65
		#En cada comprobaci�n $t2 tiene que ser 0, si no no es un caracter v�lido
		slti $t3, $t0, 71
		#Si $t3 no es 1, se comprueba el siguiente intervalo
		#Usando lo anterior, compruebo si se sale y act�o en consecuencia:
		bne $t2, $zero, Error
		beq $t3, $zero, CompruebaMinus
		#Si no hay error, le resto lo que corresponda:
		subi $t0, $t0, 55
		j FinComprobacion
		
		#Comprobaci�n del intervalo de las min�sculas:
CompruebaMinus: slti $t2, $t0, 97
		#En cada comprobaci�n $t2 tiene que ser 0, si no no es un caracter v�lido
		slti $t3, $t0, 103
		#Si $t3 no es 1, se comprueba el siguiente intervalo
		#Usando lo anterior, compruebo si se sale y act�o en consecuencia:
		bne $t2, $zero, Error
		beq $t3, $zero, Error
		#Si no hay error, le resto lo que corresponda:
		subi $t0, $t0, 87
		j FinComprobacion
		
Error:		#Pongo el error 1-car�cter incorrecto en $v1 y salgo de la funci�n:
		li $v1, 1
		jr $ra
		
FinComprobacion:
		#Desplazo el byte le�do para dejarlo en la posici�n corespondiente, lo que nos
		#interesa son 4 bits a la derecha del registro, habr� que moverlos m�s cuanto mayor
		#sea el �ndice
		
		#Copio el valor del �ndice en $t3, indica cu�nto mover los bits
		add $t3, $zero, $t1
		#Le resto 1:
		subi $t3,$t3,1
		#Si el �ndice no es 0, en cuyo caso no hay que moverlos, entro en el bucle que los mueve
		beq $t3, $zero,ContinuaBucle
BucleMoverBits:	#muevo el contenido de $t0 4 posiciones hacia la izquierda:
		sll $t0, $t0, 4
		#Le resto 1 al �ndice, si el resultado no es 0, repito el bucle
		subi $t3,$t3,1
		beq $t3, $zero, ContinuaBucle
		j BucleMoverBits


ContinuaBucle:	#Le resto 1 al �ndice:
		subi $t1, $t1, 1
		#Hago or de $t0 y $v0:
		or $v0, $t0, $v0
		#Si el �ndice es 0 salgo de la funci�n
		beq $t1, $zero, FinExtraeBin
		#Si no, vuelvo a hacer el bucle:
		j BucleExtraerBin
FinExtraeBin:	#Antes de salir cargo un byte m�s de $a0, si no es 0, es porque la cadena es
		#Demasiado larga:
		lb $t5, ($a0)
		beq $t5, $zero, Salir
		li $v1, 2
Salir:		jr $ra
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
