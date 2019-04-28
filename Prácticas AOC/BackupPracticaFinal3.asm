.data
PilaNumeros:.space 10000
PilaOperadores:.space 1000
CadenaLeida:.space 1000
CadenaSinEspacios:.space 1000
CadenaFinal:.space 1000
CadenaTemporal:.space 1000
ResultadosComprobacion:.space 100
PedirCadena:.asciiz "\nIntroduce operaciones\n"
CadenaSalida:.asciiz "\nEl resultado es: "
CaracterIncorrecto:.asciiz "\nHay caracteres no v�lidos en la cadena\n"
NumeroGrande:.asciiz "\nUno de los n�meros introducidos no cabe en 32 bits\n"
Desbordamiento:.asciiz "\nHa ocurrido un desbordamiento en una de las operaciones\n"
Syntax:.asciiz "\nHay un error de sintaxis en la cadena\n"
#ESTA CADENA DE MOMENTO NO SE USA PARA NADA:
Destino:.space 10

.text

		la $a0, PedirCadena
		#Cargo un 4 en $v0 (4-Print String)
		li $v0,4
		syscall
		#Leo la cadena
		la $a0, CadenaLeida
		li $v0, 8
		li $a1, 999
		syscall
		#Quito el salto de l�nea
		la $a0, CadenaLeida
		jal QuitaLF
		#Quitamos los espacios
		la $a0, CadenaLeida
		la $a1, CadenaSinEspacios
		jal QuitaEspacios
		#Tratamos posibles errores al combinar operadores
		la $a0, CadenaLeida
		la $a1, CadenaFinal
		jal QuitaMenos
		
BucleErrores:	li $v0,0
		li $v1,0
		la $a0, CadenaFinal
		la $a1, CadenaFinal
		jal QuitaMenos
		beq $v1,1,ErrSint
		beq $v0,1,BucleErrores
		
		li $v0,0
		li $v1,0
		
		#Cargamos la direcci�n inicial de la cadena final en $s0
		#la $s0, CadenaFinal
		#Ahora entramos en un bucle que va leyendo la cadena introducida, mientras encuentra 
		#n�meros los mete en la pila de n�meros, los operadores en la otra, cuando encuentra 
		#operadores sigue las reglas del algoritmo de shunting yard para decidir qu� hacer.
		
		#Direcci�n donde hay que leeer de la cadena en $0
		la $s0, CadenaFinal
		
		#Direcci�n de la pila de n�meros en $s1
		la $s1, PilaNumeros
		
		#Direcci�n de la pila de operadores en $s2
		la $s2, PilaOperadores
		
		#Direcci�n de la cadena temporal en $s3
		la $s3, CadenaTemporal
		 
		
BuclePrincipal:	#Cargo un byte de la cadena en $t0:
		lb $t0, ($s0)
		
		#Aumento $a0 en 1:
		addi $s0, $s0, 1
			
		#Comprobamos si es un (, si lo es, lo guardamos en la pila de operadores
		#Y volvemos al inicio del bucle, si no, pasamos a comprobar el siguiente operador
		beq $t0, 40, GuardaParentesisAbrir
		beq $t0, 41, ParentesisCerrar
		beq $t0, 42, GuardaOperador
		beq $t0, 43, GuardaOperador
		beq $t0, 45, GuardaOperador
		beq $t0, 47, GuardaOperador
				
		#Ahora compruebo si es un d�gito decimal:
		slti $t2, $t0, 48
		#$t2 tiene que ser 0, si no no es un digito decimal
		slti $t3, $t0, 58
		#Si $t3 no es 1, no es un digito decimal
		#Usando lo anterior, compruebo si no es un d�gito decimal y act�o en consecuencia:
		bne $t2, $zero, ErrorCaracter
		beq $t3, $zero, ErrorCaracter
		#Si es un digito decimal lo guarda en la cadena temporal:
		sb $t0,($s3)
		#Aumento el puntero de la cadena temporal
		addi $s3, $s3, 1
		#Volvemos al inicio del bucle
		j BuclePrincipal
		
ParentesisCerrar:#Al encontrar un par�ntesis ')' se lee la pila de oreradores, al rev�s,
		#realizando las operaciones hasta que se encuentre el anterior par�ntesis '('
		
		#Decrementamos en 1 el apuntador de la pila de operadores y leemos el operador anterior
		subi $s2, $s2, 1
		lb $t0,($s2)
		#Si el operador anterior era un '(', se vuelve al bucle principal, si no, se llama
		#a CompruebaOperador, que realiza 1 operaci�n
		
		#Antes de volver al bucle principal, guardo un ')' en la posici�n del '(', pero no 
		#aumento el puntero, de manera que si hay m�s operadores lo sobreescribir�n, y si este es 
		#el �ltimo lo puedo comprobar al final del programa para actuar en consecuencia 
		bne $t0,40,SiguienteOperacion
		li $t0, 41
		sb $t0,($s2)
		j BuclePrincipal
		
		#Si no era un '('
SiguienteOperacion:		
		addi $s2,$s2,1
		
		#Si la cadena temporal no est� vac�a, guarda el n�mero en la pila de n�meros
		subi $s3,$s3,1
		lb $t7,($s3)
		addi $s3,$s3,1
		beq $t7,0,FinGuardar
		
		#Guardamos el operador le�do en $s7
		move $s7,$t0
		#Guardamos el terminador de cadena en la cadena temporal
		sb $zero,($s3)
		#Le pasa la direcci�n de la cadena temporal a la funci�n que pasa de ASCII a binario
		la $a0,CadenaTemporal
		jal DecimalABinario
		#Si $v1 es 1 es porque el n�mero era demasiado largo
		beq $v1,1,NumLargo
		#Guardamos el resultado en la pila de n�meros
		sw $v0,($s1)
		#Aumentamos en 4 el puntero de la pila de n�meros
		addi $s1,$s1,4
		#Ponemos el puntero de la cadena temporal al principio
		la $s3,CadenaTemporal
		#Devuelvo el operador s $t0
		move $t0,$s7
		
FinGuardar:	move $a0, $t0
		move $a1, $s1
		move $a2, $s2
		jal CompruebaOperador
		#Cargo los resultados en los registros correspondientes, y resto 1 a la pila
		#de operadores
		la $t5, ResultadosComprobacion
		lw $t4,($t5)
		lw $s1, 4($t5)
		lw $s2, 8($t5)
		subi $s2,$s2,1
		
		lw $t7, 12($t5)
		#Si $t7 es 1 ha ocurrido un desbordamiento y se imprime un mensaje de error
		beq $t7,1,ErrDesbordamiento
		
		j ParentesisCerrar
		
		
		
GuardaParentesisAbrir:
		#Guarda el par�ntesis y avanza el puntero, no hace m�s operaciones
		#guarda el par�ntesis en la pila
		sb $t0,($s2)
		#Aumenta el puntero de la pila
		addi $s2,$s2,1
		#Se vuelve al inicio del bucle
		j BuclePrincipal
		
GuardaOperador:	#Si es un operador, guarda el contenido de la cadena temporal en la pila de n�meros
		#Y el operador en la pila de operadores
		
		#Antes de eso, se comprueba si el operador anterior ten�a prioridad frente al que entra
		#Ahora,y as� hasta que el aterior no tenga prioridad, hacemos esto con una funci�n que recibe
		#como argumentos el operador le�do en $a0, el apuntador de la pila de n�meros en $a1, y el 
		#apuntador de la pila de operadores en $a2, si el anterior tiene prioridad, realizar� la operaci�n
		#correspondiente y guardar� el resultado en la pila de n�meros, devuelve, a partir de una direcci�n
		#de memoria (ResultadosComprobacion) pirmero un 1 o un 0, un 1 si el operador anterior ten�a
		#precedencia, en cuyo caso se vuelve a realizar la comprobaci�n con el siguiente operador,
		#o un 0  si no, en cuyo caso se sigue el bucle, despu�s de eso ir�n el nuevo valor del apuntador
		#de la pila de n�meros y despu�s el de la de operadores, que se guardan en $s1 y $s2 respectivamente
		#Por �ltimo devuelve  un 1 si ha ocurrido un desbordamiento en alguna operaci�n
		
		
		#Si la cadena temporal no est� vac�a, guarda el n�mero en la pila de n�meros
		subi $s3,$s3,1
		lb $t7,($s3)
		addi $s3,$s3,1
		beq $t7,0,GuardaOperadorB
		
		#Guardamos el operador le�do en $s7
		move $s7,$t0
		#Guardamos el terminador de cadena en la cadena temporal
		sb $zero,($s3)
		#Le pasa la direcci�n de la cadena temporal a la funci�n que pasa de ASCII a binario
		la $a0,CadenaTemporal
		jal DecimalABinario
		#Si $v1 es 1 es porque el n�mero era demasiado largo
		beq $v1,1,NumLargo
		#Guardamos el resultado en la pila de n�meros
		sw $v0,($s1)
		#Aumentamos en 4 el puntero de la pila de n�meros
		addi $s1,$s1,4
		#Ponemos el puntero de la cadena temporal al principio
		la $s3,CadenaTemporal
		#Devuelvo el operador s $t0
		move $t0,$s7
		
GuardaOperadorB:move $a0, $t0
		move $a1, $s1
		move $a2, $s2
		jal CompruebaOperador
		#Cargo los resultados en los registros correspondientes
		la $t5, ResultadosComprobacion
		lw $t4,($t5)
		lw $s1, 4($t5)
		lw $s2, 8($t5)
		lw $t7, 12($t5)
		#Si $t7 es 1 ha ocurrido un desbordamiento y se imprime un mensaje de error
		beq $t7,1,ErrDesbordamiento
		#Si $t4 es 1, vuelvo a realizar la comprobaci�n, pero sin guardar un 0 en la pila
		#De n�meros
		beq $t4,1,GuardaOperadorB
		
		
		#Primero guarda el operador en la pila
		sb $t0,($s2)
		#Aumenta el puntero de la pila
		addi $s2,$s2,1
		
		#Se vuelve al inicio del bucle
		j BuclePrincipal
		
ErrorCaracter:	#Si se ha acabado la cadena, se realizan el resto de operaciones
		#Y se calcula el resultado, despu�s de guardar en la pila de n�meros lo que quedara
		#en la direcci�n temporal
		bne $t0,$zero,ImprimeError
		
		#Si la cadena temporal no est� vac�a, guarda el n�mero en la pila de n�meros
		subi $s3,$s3,1
		lb $t7,($s3)
		addi $s3,$s3,1
		beq $t7,0,SigueError
		
		#Guardamos el terminador de cadena en la cadena temporal
		sb $zero,($s3)
		#Le pasa la direcci�n de la cadena temporal a la funci�n que pasa de ASCII a binario
		la $a0,CadenaTemporal
		jal DecimalABinario
		#Si $v1 es 1 es porque el n�mero era demasiado largo
		beq $v1,1,NumLargo
		#Guardamos el resultado en la pila de n�meros
		sw $v0,($s1)
		
SigueError:	#Ahora, si el �ltimo operador le�do era un ')' no aumentamos
		#el puntero de la pila de n�meros
		lb $t0,($s2)
		beq $t0,41,NoAumenta
		
		#Aumentamos en 4 el puntero de la pila de n�meros
		addi $s1,$s1,4
		
NoAumenta:	move $a0, $s2
		move $a1, $s1
		jal CalcularResultado
		#Si ha habido desbordamiento imprime un mensaje de error
		beq $v1,1,ErrDesbordamiento
		move $a0, $v0
		li $v0,1
		syscall
		j FinPrograma
ImprimeError:	#Si no, se imprime un mensaje de error y se sale del programa
		la $a0, CaracterIncorrecto
		li $v0,4
		syscall
		j FinPrograma
		
ErrDesbordamiento:#Si ocurre un desbordamiento, se imprime un mensaje de error y se
		#Sale del programa
		la $a0, Desbordamiento
		li $v0,4
		syscall
		j FinPrograma
		
ErrSint:	#Si la sintaxis est� mal, se imprime un mensaje y se sale del programa
		la $a0, Syntax
		li $v0,4
		syscall
		j FinPrograma
		
NumLargo:	#Si uno de los n�meros era demasiado largo, Imprime un mensaje 
		#De error sale del programa
		la $a0, NumeroGrande
		li $v0,4
		syscall
		
FinPrograma:	#Cargo un 10 en $v0
		li $v0, 10
		#Exit
		syscall
		

		
		

###########################################################################################################
CalcularResultado:
		#Aqu� se realizan las operaciones restantes 
		#esta funci�n recibe como argumentos el apuntador a la cima de la pila de operadores en $a0,
		#y el apuntador de la pila de n�meros en $a1, va sacando operadores de la pila de operadores hasta 
		#que no queden m�s, y realizando las operaciones correspondientes, devuelve el resultado final
		#en $v0, y un 1 en $v1 si ha habido desbordamiento en alguna operaci�n
		
BucleOperadores:#Decrementamos en 1 el apuntador de la pila de operadores y leemos el operador anterior
		subi $a0, $a0, 1
		#Cargamos el operador anterior en $t6
		lb $t6,($a0)
		bne $t6,0,SigueOperador
		#Si lo cargado en un 0 (no hab�a un operador anterior) guardamos el resultado en $v0
		#salimos de la funci�n
		####################
		#Caso especial, no hay m�s operadores
		subi $a1,$a1,4
		lw $v0, ($a1)
		jr $ra
		####################
HayDesbordamiento:
		li $v1,1
		jr $ra
		####################
SigueOperador:	#Si es un + o un -

		beq $t6, 43, MasMenos
		bne $t6, 45, DividirMultiplicar
		
						
MasMenos:	#Si en + o - el operador anterior siempre va a tener prioridad,
		#Ya  que un + o un - a la izquierda tiene prioridad, y un * o un /
		#siempre la tiene tambi�n
		
		#Cogemos los dos primeros n�meros de la pila de n�meros y reducimos el apuntador
		#en 8 (el primero va en $t8 y el segundo en $t9)
		lw $t8,-8($a1)
		lw $t9,-4($a1)
		subi $a1, $a1,8
		
		#Comprobamos qu� operaci�n es, la hacemos y guardamos el resultado en la pila de n�meros
		beq $t6, 43, Mas
		beq $t6, 45, Menos
		
Mas:		addu $t5,$t8,$t9
		
		li $t6,0x80000000
		and $t2,$t8,$t6
		and $t3,$t9,$t6
		and $t4,$t5,$t6

		#Se comprueba si ha habido desbordamiento
		bne $t2,$t3,SigueMas
		bne $t2,$t4,HayDesbordamiento
		
SigueMas:	add $t5,$t8,$t9
		sw $t5,($a1)
		addi $a1,$a1,4
		j BucleOperadores
		
Menos:		subu $t5,$t8,$t9
		li $t6,0x80000000
		and $t2,$t8,$t6
		and $t3,$t9,$t6
		and $t4,$t5,$t6
		
		#Se comprueba si ha habido desbordamiento
		bne $t2,$t3,SigueMenos
		bne $t2,$t4,HayDesbordamiento
		
SigueMenos:	sub $t5,$t8,$t9
		sw $t5,($a1)
		addi $a1,$a1,4
		j BucleOperadores
		
		
DividirMultiplicar:
		
		#Cogemos los dos primeros n�meros de la pila de n�meros y reducimos el apuntador
		#en 8 (el primero va en $t8 y el segundo en $t9)
		lw $t8,-8($a1)
		lw $t9,-4($a1)
		subi $a1, $a1,8
		
		#Comprobamos qu� operaci�n es, la hacemos y guardamos el resultado en la pila de n�meros
		beq $t6, 42, Multiplicar
		beq $t6, 47, Dividir
		
Multiplicar:	mul $t5,$t8,$t9

		#Comprobamos si ambos eran positivos y el resultado negativo
		slt $t6,$t8,$zero
		slt $t7,$t9,$zero
		bne $t6,$zero,CompruebaHi
		bne $t7,$zero,CompruebaHi
		#Si son iguales:
		slt $t6,$t5,$zero
		bne $t6,$t7,HayDesbordamiento
		
		#Comprobamos si ambos eran negativos y el resultado negativo
		slt $t6,$t8,$zero
		slt $t7,$t9,$zero
		beq $t6,$zero,CompruebaHi
		beq $t7,$zero,CompruebaHi
		#Si son iguales:
		slt $t6,$t5,$zero
		beq $t6,$t7,HayDesbordamiento
		
		#Comprobamos si hi no es 0
CompruebaHi:	mfhi $t6
		beq $t6,$zero,SigueMul 
		li $t8,0xFFFFFFFF
		bne $t6,$t8,HayDesbordamiento
		slt $t8,$t5,$zero
		beq $t8,$zero,HayDesbordamiento
	
SigueMul:	sw $t5,($a1)
		addi $a1,$a1,4
		j BucleOperadores
		
Dividir:	div $t5,$t8,$t9
		sw $t5,($a1)
		addi $a1,$a1,4
		j BucleOperadores
		

###########################################################################################################
CompruebaOperador:
		#Aqu� se comprueba si el operador anterior ten�a prioridad frente al que entra
		#esta funci�n recibe como argumentos el operador le�do en $a0, el apuntador de la pila de n�meros en $a1, y el 
		#apuntador de la pila de operadores en $a2, si el anterior tiene prioridad, realizar� la operaci�n
		#correspondiente y guardar� el resultado en la pila de n�meros, devuelve, a partir de una direcci�n
		#de memoria (ResultadosComprobacion) pirmero un 1 o un 0, un 1 si el operador anterior ten�a
		#precedencia
		
		#Decrementamos en 1 el apuntador de la pila de operadores y leemos el operador anterior
		subi $a2, $a2, 1
		#Cargamos el operador anterior en $t6
		lb $t6,($a2)
		#Si el operador le�do es un '(', no hacemos nada
		beq $t6,40,SalirC
		bne $t6,0,SigueOperadorC
		#Si lo cargado en un 0 (no hab�a un operador anterior) guardamos los resultados y 
		#salimos de la funci�n
		####################
		#Caso especial, no hay un operador antes, el anterior tiene preferencia o el anterior es un '('
SalirC:		la $t7, ResultadosComprobacion
		sw $zero,($t7)
		sw $a1,4($t7)
		addi $a2,$a2,1
		sw $a2,8($t7)
		jr $ra
		####################
SalirDesbordamiento:
		la $t7, ResultadosComprobacion
		li $t4,1
		sw $t4,12($t7)
		jr $ra
		####################
SigueOperadorC:
		beq $a0, 43, CompruebaAnterior
		bne $a0, 45, CompruebaPrec
		#Si el le�do es * o /, comprobamos cu�l era el anterior, si era + o - salimos
		#Sin hacer nada, si era * o /, realizamos esa operacion

CompruebaAnterior:
		#Si el operador es + o -, el operador anterior siempre va a tener prioridad
		#Ahora comprobamos cual es el operador anterior
		beq $t6, 43, MasMenosC
		bne $t6, 45, CompruebaPrec
														
MasMenosC:	
		#Cogemos los dos primeros n�meros de la pila de n�meros y reducimos el apuntador
		#en 8 (el primero va en $t8 y el segundo en $t9)
		lw $t8,-8($a1)
		lw $t9,-4($a1)
		subi $a1, $a1,8
		
		#Comprobamos qu� operaci�n es, la hacemos y guardamos el resultado en la pila de n�meros
		beq $t6, 43, MasC
		beq $t6, 45, MenosC
		
MasC:		addu $t5,$t8,$t9
		
		li $t6,0x80000000
		and $t2,$t8,$t6
		and $t3,$t9,$t6
		and $t4,$t5,$t6

		#Se comprueba si ha habido desbordamiento
		bne $t2,$t3,SigueMasC
		bne $t2,$t4,SalirDesbordamiento
		
SigueMasC:	add $t5,$t8,$t9
		sw $t5,($a1)
		addi $a1,$a1,4
		li $t1,1
		sb $zero($a2)
		j FinC
		
MenosC:		subu $t5,$t8,$t9
		li $t6,0x80000000
		and $t2,$t8,$t6
		and $t3,$t9,$t6
		and $t4,$t5,$t6
		
		#Se comprueba si ha habido desbordamiento
		bne $t2,$t3,SigueMenosC
		bne $t2,$t4,SalirDesbordamiento
		
SigueMenosC:	sub $t5,$t8,$t9
		sw $t5,($a1)
		addi $a1,$a1,4
		li $t1,1
		sb $zero($a2)
		j FinC
		
CompruebaPrec:	#Si el operador es * o /, comprueba si el anterior era + o -, en ese caso,
		#Guarda el operador en la pila y vuelve sin calcular nada
		beq $t6, 43, SalirC
		beq $t6, 45, SalirC
		
DividirMultiplicarC:
		
		#Cogemos los dos primeros n�meros de la pila de n�meros y reducimos el apuntador
		#en 8 (el primero va en $t8 y el segundo en $t9)
		lw $t8,-8($a1)
		lw $t9,-4($a1)
		subi $a1, $a1,8
		
		#Comprobamos qu� operaci�n es, la hacemos y guardamos el resultado en la pila de n�meros
		beq $t6, 42, MultiplicarC
		beq $t6, 47, DividirC
		
MultiplicarC:	mul $t5,$t8,$t9
		
		#Comprobamos si ambos eran positivos y el resultado negativo
		slt $t6,$t8,$zero
		slt $t7,$t9,$zero
		bne $t6,$zero,CompruebaHiC
		bne $t7,$zero,CompruebaHiC
		#Si son iguales:
		slt $t6,$t5,$zero
		bne $t6,$t7,SalirDesbordamiento
		
		#Comprobamos si ambos eran negativos y el resultado negativo
		slt $t6,$t8,$zero
		slt $t7,$t9,$zero
		beq $t6,$zero,CompruebaHiC
		beq $t7,$zero,CompruebaHiC
		#Si son iguales:
		slt $t6,$t5,$zero
		beq $t6,$t7,SalirDesbordamiento
		
		
		#Comprobamos si hi es distinto de 0 
CompruebaHiC:	mfhi $t6
		beq $t6,$zero,SigueMulC 
		li $t8,0xFFFFFFFF
		bne $t6,$t8,SalirDesbordamiento
		slt $t8,$t5,$zero
		beq $t8,$zero,SalirDesbordamiento
		#Ahi est�n comprobados los errores en los que el hi es distinto de 0
		
SigueMulC:	sw $t5,($a1)
		addi $a1,$a1,4
		li $t1,1
		sb $zero($a2)
		j FinC
		
DividirC:	div $t5,$t8,$t9
		sw $t5,($a1)
		addi $a1,$a1,4
		li $t1,1
		sb $zero($a2)
		j FinC
		
		

		
		
FinC:		#Ahora guardamos en memoria los resultados correspondientes
		la $t7, ResultadosComprobacion
		sw $t1,($t7)
		sw $a1,4($t7)
		addi $a2,$a2,1
		sw $a2,8($t7)
		#Salimos de la funci�n
		jr $ra

#AQUI HAY QUE IMPLEMENTAR LO QUE SE HACE CUANDO EL OPERADOR ES UN * O UN /
		


###########################################################################################################
DecimalABinario:#Esta funci�n recibe como par�metro la direcci�n de una cadena ascii que contiene un n�mero
		#decimal en $a0, lo convierte a binario y devuelve el resultado en $v0, si hay alg�n error
		#lo indica con un mensaje en $v1
		
		#Para realizar la conversi�n, utiliza un bucle controlado por �ndice para cargar uno a uno los
		#primeros 10 bytes desde $a0, para cada byte, primero comprueba qu� caracter es, si es mayor que 47 y menor
		#que 58, ser� un n�mero del 0 al 9, le resta 48 para obtener el n�mero deseado si no est� en el
		#intervalo anterior, es un caracter no v�lido y se sale de la funci�n con un c�digo de error.
		#Despu�s de lo anterior, se multiplica por 10 el byte cargado varias veces usando un bucle en 
		#funci�n del valor del �ndice y se suma el resultado a $v0, para multiplicar el n�mero por 10
		#usamos un bucle que lo suma consigo mismo 10 veces
		
		#Primero determino la longitud de la cadena cargando bytes hasta encontarme con
		#el terminador de cadena, si no lo encuentro con este bucle salgo con el c�digo
		#de error de cadena demasiado larga
		
		#leemos el primer caracter de la cadena, si  es 45, pongo $t5 a 1 para indicar que el n�mero
		#es negativo y hay que multiplicar por -1 el n�mero, si es 43 dejo $t5 a 0, en ambos casos despu�s
		#de eso le sumo 1 a $a0 para saltar ese caracter, si no es ni 43 ni 45, el n�mero es positivo y no hay
		#caracter de signo en la cadena, en ese caso no sumo nada a $a0
		li $t6, 45
		lb $t7, ($a0)
		bne $t6,$t7, CompruebaPos
		li $t5, 1
		addi $a0,$a0,1
		j FinSigno
		
CompruebaPos:	li $t6, 43
		lb $t7, ($a0)
		li $t5, 0
		bne $t6,$t7, FinSigno
		addi $a0,$a0,1
		
FinSigno:	add $t7,$zero,$a0
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
		
ErrorLarga:	addi $v1,$zero,1
		jr $ra

FinLongitud:	
		
		#Pongo $v0 a 0
		add $v0, $zero, $zero
		#Cargo la longitud de la cadena en $t1, haciendo $t1 = 10 - ($t1 - 1)
		subi $t1,$t1,1
		li $t6, 10
		sub $t6,$t6,$t1
		add $t1, $zero, $t6
		#Si la longitud es mayor que 10, la cadena es demasiado larga
		slti $t7,$t1, 11
		bne $t7,$zero,BucleExtraerBin
		#Si es mayor, sale con un error
		j ErrorLarga
		
		 
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
		
Error:		#Si el caracter es el terminador de cadena, pone un 0 en $v0 y vuelve
		beq $t0,0,Devuelve0
		#Pongo el error 2-car�cter incorrecto en $v1 y salgo de la funci�n:
		li $v1, 2
		jr $ra
Devuelve0:	jr $ra
		
FinComprobacion:
		#Multiplico por 10 varias veces el byte le�do para darle el valor que le corresponde
		
		#Copio el valor del �ndice en $t3, indica cu�ntas veces hacer el bucle
		add $t3, $zero, $t1
		#Le resto 1:
		subi $t3,$t3,1
		#Si el �ndice no es 0, en cuyo caso no hay que hacer nada, entro en el bucle
		beq $t3, $zero,ContinuaBucle
		addi $t6,$zero,10
Inicia10:	li $t7, 9
Multiplicar10:	#Multiplico $t0*10 
		mul $t0,$t6,$t0
		#Comprobamos si ha habido overflow
		mflo $t8
		li $t9, 0x80000000
		and $t8,$t8,$t9
		bne $t8,$zero,ErrorLarga
		#Le resto 1 al �ndice, si el resultado no es 0, repito el bucle
		subi $t3,$t3,1
		beq $t3, $zero, ContinuaBucle
		j Inicia10

ContinuaBucle:	#Le resto 1 al �ndice:
		subi $t1, $t1, 1
		#Le sumo $t0 a $v0
		add $v0,$v0,$t0
		#Si el �ndice es 0 salgo de la funci�n
		beq $t1, $zero, FinExtraeDec
		#Si no, vuelvo a hacer el bucle:
		j BucleExtraerBin
FinExtraeDec:	#Si $t5 es 1, devuelvo el opuesto del n�mero
		beq $t5,$zero, Salir
		sub $v0,$zero,$v0
Salir:		jr $ra

		


##############################################################################

QuitaLF:	#Esta funci�n recibe la direcci�n inicial de una cadena en
		#$a0 y quita el fin de linea si lo hay
		
		#Recorro la cadena y cambio el line feed, si est�, por un 0:
		#Indice en $t1
		li $t1, 1000
		#El line feed es un 10
		li $t2, 10
BucleLF:	#Cargo un byte de la cadena en $t0
		lb $t0,($a0)
		bne $t0, 10, SigueBucle
		#Si es 10, pone un 0 y sale del bucle
		sb $zero, ($a0)
		jr $ra
SigueBucle:	#Le suma 1 a la direcci�n
		addi $a0, $a0, 1
		#Le resta 1 al �ndice
		subi $t1, $t1, 1
		beq $t1,$zero,SalirQuita
		j BucleLF
SalirQuita:	jr $ra

##############################################################################

QuitaEspacios:	#Esta funci�n recibe la direcci�n inicial de una cadena en
		#$a0 y la copia en la direcci�n que recibe en $a1 sin los espacios
		
		
BucleEspacios:	#Cargo un byte de la cadena en $t0
		lb $t0,($a0)
		beq $t0,$zero,SalirEspacios
		bne $t0, 32, SigueBucleE
		#Si es un espacio, aumenta el puntero en $a0
		addi $a0,$a0,1
		j BucleEspacios
SigueBucleE:	#Guarda el byte le�do en la cadena Final
		sb $t0,($a1)
		#Le suma 1 a la direcci�n de $a0 y $a1
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		j BucleEspacios
SalirEspacios:	jr $ra

##############################################################################

QuitaMenos:	#Esta funci�n recibe la direcci�n inicial de una cadena en
		#$a0 y la copia en la direcci�n que recibe en $a1, cambiando
		#los -- por un +, cuando encuentra algo que hay que cambiar,
		#Vuelve indicandolo con un 1 en $v0, de manera que el programa 
		#la seguir� llamando hasta que todos los problemas est�n solucionados
		
		#Esta funci�n cambia:
		# -- por +
		# +- y -+ por -
		# ++ por +
		# *+ por *
		# *-X por *(0-X)
		# /+ por /
		# /-X por /(0-X)
		# (-X por ((0-X)
		# (+ por (
		
		#Indica un error con un 1 en $v1 
		#Si encuentra:
		# -* ; +* ; -/ ; +/ ; -) ; +) ; *) ; /)
		
BucleMenos:	#Cargo un byte de la cadena en $t0
		lb $t0,($a0)
		beq $t0,$zero,SalirMenos
SigueBucleM:	#Comprueba si es un operador, si lo es, lo trata
		beq $t0, 40, ParAbrir
		beq $t0, 41, ParCerrar
		beq $t0, 42, Mult
		beq $t0, 43, Sum
		beq $t0, 45, Rest
		beq $t0, 47, Div
		#Si no es un operador guarda el byte le�do en la cadena Final
GuardaNormal:	sb $t0,($a1)
		#Le suma 1 a la direcci�n de $a1 y $a0
		addi $a1, $a1, 1
		addi $a0, $a0, 1
		j BucleMenos
SalirMenos:	sb $zero,($a1)
		jr $ra

ParAbrir:
ParCerrar:
Mult:		#Comprueba el siguiente byte de la cadena
		lb $t1,1($a0)
		#Comprueba si es un -, un +, un *, un / o un )
		beq $t1, 41, ErrorSintaxis
		beq $t1, 42, ErrorSintaxis
		beq $t1, 47, ErrorSintaxis
		addi $t9,$zero,42
		beq $t1, 43, SustituirOperador
		#Si es un - guarda *(0-x)
		beq $t1, 45, GuardaInverso
		#Si no es ninguno de esos:
		j GuardaNormal
		
Sum:		#Comprueba el siguiente byte de la cadena
		lb $t1,1($a0)
		#Comprueba si es un -, un +, un *, un / o un )
		beq $t1, 41, ErrorSintaxis
		beq $t1, 42, ErrorSintaxis
		beq $t1, 47, ErrorSintaxis
		addi $t9,$zero,43
		beq $t1, 43, SustituirOperador
		addi $t9,$zero,45
		beq $t1, 45, SustituirOperador
		#Si no es ninguno de esos:
		j GuardaNormal
		
Rest:		#Comprueba el siguiente byte de la cadena
		lb $t1,1($a0)
		#Comprueba si es un -, un +, un *, un / o un )
		beq $t1, 41, ErrorSintaxis
		beq $t1, 42, ErrorSintaxis
		beq $t1, 47, ErrorSintaxis
		addi $t9,$zero,45
		beq $t1, 43, SustituirOperador
		addi $t9,$zero,43
		beq $t1, 45, SustituirOperador
		#Si no es ninguno de esos:
		j GuardaNormal
		
Div:		#Comprueba el siguiente byte de la cadena
		lb $t1,1($a0)
		#Comprueba si es un -, un +, un *, un / o un )
		beq $t1, 41, ErrorSintaxis
		beq $t1, 42, ErrorSintaxis
		beq $t1, 47, ErrorSintaxis
		addi $t9,$zero,47
		beq $t1, 43, SustituirOperador
		#Si es un - guarda *(0-x)
		beq $t1, 45, GuardaInverso
		#Si no es ninguno de esos:
		j GuardaNormal

SustituirOperador:#Guarda el operador indicado en $t9 en la cadena final
		sb $t9,($a1)
		#Aumenta en 1 el indice $a1 y en 2 el de $a2, despu�s, pone $v0 a 
		#1 y guarda el resto de la cadena, corrigiendo posibles errores,
		#sin embargo, hay que volver a llamar a esta funci�n ya que puede haber 
		#errores, por ejemplo, si hay --- esta funci�n lo cambiar� a +- en la final
		#pero eso no se cambiar� por - hasta la siguiente pasada
		addi $a1,$a1, 1
		addi $a0,$a0, 2
		li $v0,1
		j BucleMenos
		
GuardaInverso:	#Guarda (0-X) en la cadena
		#Guarda el *
		li $t1,42
		sb $t1,($a1)
		#Guarda un (
		li $t1,40
		sb $t1,1($a1)
		#guarda un 0
		li $t1,48
		sb $t1,2($a1)
		#Guarda un -
		li $t1,45
		sb $t1,3($a1)
		#Ahora guarda bytes de la cadena original hasta encontrar un
		#operador, esto es asumiendo que no se hayan introducido cosas
		#como *--, por ejemplo
		
		#PARA HACER QUE FUNCIONE CON HEX, EN VEZ DE GUARDAR BYTES MIENTRAS 
		#SEAN DIGITOS, HACER QUE GUARDE BYTES HASTA ENCONTRAR UN OPERADOR
		
		#Le sumo 2 a $a0 y 3 a $a1
		addi $a0,$a0,2
		addi $a1,$a1,4 
		
		#Cargo un byte de $a0 en $t4
BucleInv:	lb $t4,($a0)
		#compruebo si es un d�gito decimal:
		slti $t2, $t4, 48
		#$t2 tiene que ser 0, si no no es un digito decimal
		slti $t3, $t4, 58
		#Si $t3 no es 1, no es un digito decimal
		#Usando lo anterior, compruebo si no es un d�gito decimal
		bne $t2, $zero, GuardaFinal
		beq $t3, $zero, GuardaFinal
		#Guardo el digito en la cadena y compruebo el siguiente
		sb $t4,($a1)
		addi $a0,$a0,1
		addi $a1,$a1,1
		j BucleInv
GuardaFinal:	#Guarda un ) en la cadena
		li $t1,41
		sb $t1,($a1)
		addi $a1,$a1,1
		j BucleMenos

ErrorSintaxis:	#Guarda un 1 en $v1 y sale de la funci�n
		li $v1,1
		jr $ra
#######################################################################################################


CadenaDec :	#Esta funci�n recibe un n�mero en $a0 y una direcci�n de memoria en $a1,
		#Genera una cadena ASCII cuyos caracteres son la representaci�n en decimal
		#del n�mero y la guarda a partir de la direcci�n proporcionada.
		
		#Para ello primero calcula el resto de dividir el n�mero en $a0 entre 10, y
		#le suma 48 al resultado para obtener la representaci�n ASCII de ese n�mero,
		#y despu�s guarda el resultado en memoria, por �ltimo, divide el n�mero en 
		#$a0 entre 10 y se repite todo de nuevo
		
		#Para calcular el resto utiliza div, que deja el resto en hi, para dividir entre
		#10 simplemente se utiliza div con 3 argumentos, que deja el resultado en rd
		
		 
BucleExtraerDec1:
		#Calculo el resto de dividir el n�mero en $a0 entre 10 y lo almaceno en $t0
		li $t7, 10
		div $a0,$t7
		mfhi $t0
		
		#Le sumo 48 al n�mero le�do:
		add $t0, $t0, 48
		#Guardo el resultado en la direcci�n indicada
		sb $t0, ($a1)
		#Divido el n�mero en $a0 entre 10
		div $a0, $a0, $t7
		#Si el resultado en $a0 es 0, invertimos la cadena y salimos de la funci�n
		beq $a0, $zero, FinExtraeDec1
		#Si no, vuelvo a hacer el bucle:
		#Le sumamos 1 a la direcci�n donde hay que almacenarlo
		addi $a1, $a1, 1
		j BucleExtraerDec1
		
FinExtraeDec1:	move $t5,$ra
		jal InvierteCadena
		move $ra,$t5
		jr $ra

######################################################################################
InvierteCadena:	#Esta fuci�n carga una direcci�n en $a0 y recibe otra en $a1, copia el byte en 
		#$a0 a $a1 y viceversa, y suma 1 a $a0 y resta 1 a $a0, cuando se cruzen,
		#es decir, cuando $a1 sea menor que $a0 o ambos sean iguales, se sale de la 
		#funci�n
		la $a0, Destino
BucleInvierte:	#Carga un byte de $a0 
		lb $t0, ($a0)
		#Carga un byte de $a1
		lb $t1, ($a1)
		#Guarda lo cargado de $a0 en $a1 y viceversa
		sb $t1,($a0)
		sb $t0,($a1)
		#le resta 1 a $a1 y le suma 1 a $a0
		addi $a0, $a0, 1
		addi $a1, $a1, -1
		#Comprueba si son iguales, si lo son, sale de la funci�n
		bne $a1,$a0,SigueInvierte
		jr $ra
SigueInvierte:	#Comprueba si $a1 es menor que $a0, si lo es, sale de la funci�n, si no,
		#Continua
		slt $t3, $a1, $a0
		bne $t3, 1, BucleInvierte
		jr $ra
		
###################################################################################

		
		





































