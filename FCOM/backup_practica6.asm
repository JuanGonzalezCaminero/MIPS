.data
Cadena:.space 20



#HAY QUE CAMBIAR EL PROGRAMA PARA QUE EL RESULTADO VAYA EN $V1 Y LOS ERRORES EN $V0



Salida:.asciiz "\nEl n�mero es: "
Error1:.asciiz "Hay caracteres no v�lidos en la cadena\n"
Error2:.asciiz "Cadena demasiado larga"
Pide:.asciiz "Introduce un n�mero decimal: "
.text		
PedirDeNuevo:	#Direccion inicial de la cadena
		la $t0, Cadena
		#Pido el n�mero:
		la $a0, Pide
		#Cargo un 4 en $v0 (4 - Print String)
		li $v0, 4
		syscall
		#Cargo un 8 en $v0 (4 - Read String)
		li $v0, 8
		#El mayor n�mero representable en complemento a 2 con 32 bits es
		# 2^31, es decir, 2.147.483.648, que tiene 10 caracteress
		#Cargo en $a0 la direcci�n donde se almacena y la longitud (11) en $a1
		add $a0, $zero, $t0
		li $a1, 11
		syscall
		#Recorro la cadena y cambio el line feed, si est�, por un 0:
		#Indice en $t1
		li $t1, 10
		#El line feed es un 10
		li $t2, 10
		BucleLF:	#Cargo un byte de la cadena en $t0
		lb $t0,($a0)
		bne $t0, 10, SigueBucle
		#Si es 10, pone un 0 y sale del bucle
		sb $zero, ($a0)
		j SalirBucle
SigueBucle:	#Le suma 1 a la direcci�n
		addi $a0, $a0, 1
		#Le resta 1 al �ndice
		subi $t1, $t1, 1
		beq $t1,$zero,SalirBucle
		j BucleLF
		
SalirBucle:	#Cargo la direcci�n inicial en $a0
		la $a0, Cadena
		#Llamo a la funci�n que obtiene el n�mero en decimal a partir de la cadena ASCII
		jal DecimalABinario
		#Compruebo si ha habido errores:
		beq $v0, $zero, Imprimir
		li $t6,1
		bne $v0, $t6, CadLarga
		la $a0, Error2
		#Cargo un 4 en $v0 (4 - Print String)
		li $v0, 4
		syscall
		#Vuelvo a pedir la entrada:
		j PedirDeNuevo
CadLarga:	la $a0, Error1
		#Cargo un 4 en $v0 (4 - Print String)
		li $v0, 4
		syscall
		j FinPrograma
Imprimir:	
		add $t0,$zero,$v1
		#Imprimo la salida
		li $v0, 4
		la $a0, Salida
		syscall
		
		li $v0, 1
		add $a0, $zero,$t0
		syscall
		
FinPrograma:	#Cargo un 10 en $v0
		li $v0, 10
		#Exit
		syscall
DecimalABinario:#Esta funci�n recibe como par�metro la direcci�n de una cadena ascii que contiene un n�mero
		#decimal en $a0, lo convierte a binario y devuelve el resultado en $v1, si hay alg�n error
		#lo indica con un mensaje en $v0
		#Para realizar la conversi�n, utiliza un bucle controlado por �ndice para cargar uno a uno los
		#primeros 10 bytes desde $a0, para cada byte, primero comprueba qu� caracter es, si es mayor que 47 y menor
		#que 58, ser� un n�mero del 0 al 9, le resta 48 para obtener el n�mero deseado si no est� en el
		#intervalo anterior, es un caracter no v�lido y se sale de la funci�n con un c�digo de error.
		#Despu�s de lo anterior, se multiplica por 10 el byte cargado varias veces usando un bucle en 
		#funci�n del valor del �ndice y se suma el resultado a $v1, para multiplicar el n�mero por 10
		#usamos un bucle que lo suma consigo mismo 10 veces
		
		#Primero determino la longitud de la cadena cargando bytes hasta encontarme con
		#el terminador de cadena, si no lo encuentro con este bucle salgo con el c�digo
		#de error de cadena demasiado larga
		
		add $t7,$zero,$a0
		li $t1,11
Longitud:	#Cargo un byte
		lb $t6,($t7)
		#Si es 0, salgo y calculo la longitud de la cadena a partir de $t1
		beq $t6, $zero, FinLongitud
		#Le resto 1 a $t1 y repito el bucle
		addi $t7,$t7,1
		subi $t1,$t1,1
		beq $t1,$zero,ErrorLarga
		j Longitud
		
ErrorLarga:	addi $v0,$zero,1
		jr $ra

FinLongitud:                  
		#Pongo $v1 a 0
		add $v1, $zero, $zero
		#Cargo la longitud de la cadena en $t1, haciendo $t1 = 10 - ($t1 - 1)
		subi $t1,$t1,1
		li $t6, 10
		sub $t6,$t6,$t1
		add $t1, $zero, $t6
		 
BucleExtraerBin:
		#Cargo un byte en $t0:
		lb $t0, ($a0)
		
		#Aumento $a0 en 1:
		addi $a0, $a0, 1
		#Ahora compruebo si es un d�gito decimal y lo convierto a binario:
		slti $t2, $t0, 48
		#$t2 tiene que ser 0, si no no es un caracter v�lido
		slti $t3, $t0, 58
		#Si $t3 no es 1, es un caracter no v�lido
		#Usando lo anterior, compruebo si se sale y act�o en consecuencia:
		bne $t2, $zero, Error
		beq $t3, $zero, Error
		#Si no hay error, le resto lo que corresponda:
		subi $t0, $t0, 48
		j FinComprobacion
		
Error:		#Pongo el error 2-car�cter incorrecto en $v0 y salgo de la funci�n:
		li $v0, 2
		jr $ra
		
FinComprobacion:
		#Multiplico por 10 varias veces el byte le�do para darle el valor que le corresponde
		
		#Copio el valor del �ndice en $t3, indica cu�ntas veces hacer el bucle
		add $t3, $zero, $t1
		#Le resto 1:
		subi $t3,$t3,1
		#Si el �ndice no es 0, en cuyo caso no hay que hacer nada, entro en el bucle
		beq $t3, $zero,ContinuaBucle
		addi $t6,$zero,0
		#Para la primera iteracion, le sumo a $t6 el contenido de $t0 una vez aqu�:
		add $t6,$t6,$t0
Inicia10:	li $t7, 9
Multiplicar10:	#Le sumo a $t6 el contenido de $t0
		add $t6,$t6,$t0
		#Le resto 1 a $t7
		subi $t7,$t7,1
		bne $t7,0, Multiplicar10
		#Hago $t0=$t6
		add $t0,$t6,$zero
		#Le resto 1 al �ndice, si el resultado no es 0, repito el bucle
		subi $t3,$t3,1
		beq $t3, $zero, ContinuaBucle
		j Inicia10

ContinuaBucle:	#Le resto 1 al �ndice:
		subi $t1, $t1, 1
		#Le sumo $t0 a $v1
		add $v1,$v1,$t0
		#Si el �ndice es 0 salgo de la funci�n
		beq $t1, $zero, FinExtraeDec
		#Si no, vuelvo a hacer el bucle:
		j BucleExtraerBin
FinExtraeDec:	
Salir:		jr $ra

















		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
