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
CaracterIncorrecto:.asciiz "\nHay caracteres no válidos en la cadena\n"
NumeroGrande:.asciiz "\nUno de los números introducidos no cabe en 32 bits\n"
Desbordamiento:.asciiz "\nHa ocurrido un desbordamiento en una de las operaciones\n"
Syntax:.asciiz "\nHay un error de sintaxis en la cadena\n"

.text

PedirDeNuevo:	li $v0,0
		li $v1,0
		la $a0, PedirCadena
		#Cargo un 4 en $v0 (4-Print String)
		li $v0,4
		syscall
		#Leo la cadena
		la $a0, CadenaLeida
		li $v0, 8
		li $a1, 999
		syscall
		#Quito el salto de línea
		la $a0, CadenaLeida
		jal QuitaLF
		#Quitamos los espacios
		la $a0, CadenaLeida
		la $a1, CadenaSinEspacios
		jal QuitaEspacios
		#Tratamos posibles errores al combinar operadores
		li $v0,0
		li $v1,0
		la $a0, CadenaSinEspacios
		la $a1, CadenaFinal
		jal QuitaMenos
		beq $v1,1,ErrSint
		bne $v0,1,FinBucleErr
		
		
BucleErrores:	li $v0,0
		li $v1,0
		la $a0, CadenaFinal
		la $a1, CadenaFinal
		jal QuitaMenos
		beq $v1,1,ErrSint
		beq $v0,1,BucleErrores
		li $v0,0
		li $v1,0
		
		#Cargamos la dirección inicial de la cadena final en $s0
		#la $s0, CadenaFinal
		#Ahora entramos en un bucle que va leyendo la cadena introducida, mientras encuentra 
		#números los mete en la pila de números, los operadores en la otra, cuando encuentra 
		#operadores sigue las reglas del algoritmo de shunting yard para decidir qué hacer.
		
		#Dirección donde hay que leer de la cadena en $0
FinBucleErr:	la $s0, CadenaFinal
		
		#Dirección de la pila de números en $s1
		la $s1, PilaNumeros
		
		#Dirección de la pila de operadores en $s2
		la $s2, PilaOperadores
		
		#Dirección de la cadena temporal en $s3
		la $s3, CadenaTemporal
		
		#$s4 será 1 si se está leyendo un número hexadecimal
		
		li $s4, 0
			
BuclePrincipal:	#Cargo un byte de la cadena en $t0:
		lb $t0, ($s0)
			
		li $s4,0
		#Comprobamos si es un (, si lo es, lo guardamos en la pila de operadores
		#Y volvemos al inicio del bucle, si no, pasamos a comprobar el siguiente operador
		beq $t0, 40, GuardaParentesisAbrir
		beq $t0, 41, ParentesisCerrar
		beq $t0, 42, GuardaOperador
		beq $t0, 43, GuardaOperador
		beq $t0, 45, GuardaOperador
		beq $t0, 47, GuardaOperador
				
		#Ahora compruebo si es un dígito decimal:
		slti $t2, $t0, 48
		#$t2 tiene que ser 0, si no no es un digito decimal
		slti $t3, $t0, 58
		#Si $t3 no es 1, no es un digito decimal
		#Usando lo anterior, compruebo si no es un dígito decimal y actúo en consecuencia:
		bne $t2, $zero, ErrorCaracter
		beq $t3, $zero, ErrorCaracter
		#Si es un digito decimal lo guarda en la cadena temporal:
		#Después de comprobar que ese dígito no sea el 0 de un 0x:
		bne $t0,48,SigueGuarda
		#Comprueba el siguiente byte para ver si es x o X
		addi $s0,$s0,1
		lb $t9,($s0)
		subi $s0,$s0,1
		beq $t9,120,ActivaHex
		bne $t9,88,SigueGuarda
ActivaHex:	li $s4,1
		addi $s0,$s0,1

SigueGuarda:	move $a0,$s0
		move $a1,$s3
		jal GuardaNumero
		move $s0,$a0
		move $s3,$a1
		#Convertimos el número a decimal y lo guardamos en la pila de números
		#Guardamos el terminador de cadena en la cadena temporal
		sb $zero,($s3)
		#Le pasa la dirección de la cadena temporal a la función que pasa de ASCII a binario
		#O bien a la que pasa de hex a binario
		la $a0,CadenaTemporal
		beq $s4,1,PasaAHex
		jal DecimalABinario
		#Si $v1 es 1 es porque el número era demasiado largo
		beq $v1,1,NumLargo
		j GuardaEnPila
PasaAHex:	jal HexABinario
		#Si $v1 es 1 es porque hay un caracter no hexadecimal
		beq $v1,1,ImprimeError
		
GuardaEnPila:	#Guardamos el resultado en la pila de números
		sw $v0,($s1)
		#Aumentamos en 4 el puntero de la pila de números
		addi $s1,$s1,4
		#Ponemos el puntero de la cadena temporal al principio
		la $s3,CadenaTemporal
		#Volvemos al inicio del bucle
		j BuclePrincipal
		
ParentesisCerrar:#Al encontrar un paréntesis ')' se lee la pila de operadores, al revés,
		#realizando las operaciones hasta que se encuentre el anterior paréntesis '('
		
		#Aumento $s0 en 1:
		addi $s0, $s0, 1
		#Decrementamos en 1 el apuntador de la pila de operadores y leemos el operador anterior
BucleCerrar:	subi $s2, $s2, 1
		lb $t0,($s2)
		#Si el operador anterior era un '(', se vuelve al bucle principal, si no, se llama
		#a CompruebaOperador, que realiza 1 operación
		bne $t0,40,SiguienteOperacion
		#subi $s0, $s0, 1
		j BuclePrincipal
		
		#Si no era un '('
SiguienteOperacion:	
		addi $s2,$s2,1	
		move $a0, $t0
		move $a1, $s1
		move $a2, $s2
		jal CompruebaOperador
		#Cargo los resultados en los registros correspondientes, y resto 1 a la pila
		#de operadores
		la $t5, ResultadosComprobacion
		lw $t4,($t5)
		lw $s1, 4($t5)
		lw $s2, 8($t5)
		lw $t7, 12($t5)
		#Si $t7 es 1 ha ocurrido un desbordamiento y se imprime un mensaje de error
		beq $t7,1,ErrDesbordamiento
		j BucleCerrar
		
		
		
GuardaParentesisAbrir:
		#Aumento $s0 en 1:
		addi $s0, $s0, 1
		#Guarda el paréntesis y avanza el puntero, no hace más operaciones
		#guarda el paréntesis en la pila
		sb $t0,($s2)
		#Aumenta el puntero de la pila
		addi $s2,$s2,1
		#Se vuelve al inicio del bucle
		j BuclePrincipal
		
GuardaOperador:	#Si es un operador, guarda el contenido de la cadena temporal en la pila de números
		#Y el operador en la pila de operadores
		
		#Antes de eso, se comprueba si el operador anterior tenía prioridad frente al que entra
		#Ahora,y así hasta que el aterior no tenga prioridad, hacemos esto con una función que recibe
		#como argumentos el operador leído en $a0, el apuntador de la pila de números en $a1, y el 
		#apuntador de la pila de operadores en $a2, si el anterior tiene prioridad, realizará la operación
		#correspondiente y guardará el resultado en la pila de números, devuelve, a partir de una dirección
		#de memoria (ResultadosComprobacion) pirmero un 1 o un 0, un 1 si el operador anterior tenía
		#precedencia, en cuyo caso se vuelve a realizar la comprobación con el siguiente operador,
		#o un 0  si no, en cuyo caso se sigue el bucle, después de eso irán el nuevo valor del apuntador
		#de la pila de números y después el de la de operadores, que se guardan en $s1 y $s2 respectivamente
		#Por último devuelve  un 1 si ha ocurrido un desbordamiento en alguna operación
		#Aumento $s0 en 1:
		addi $s0, $s0, 1
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
		#Si $t4 es 1, vuelvo a realizar la comprobación
		#De números
		beq $t4,1,GuardaOperadorB
		
		
		#Primero guarda el operador en la pila
		sb $t0,($s2)
		#Aumenta el puntero de la pila
		addi $s2,$s2,1
		
		#Se vuelve al inicio del bucle
		j BuclePrincipal
		
ErrorCaracter:	#Si se ha acabado la cadena, se realizan el resto de operaciones
		#Y se calcula el resultado
		bne $t0,$zero,ImprimeError
		
		#Ahora, si el último operador leído era un ')' decrementamos
		#el puntero de la pila de números
		#lb $t0,($s2)
		#beq $t0,41,NoDecrementa
		
		#Decrementamos en 4 el puntero de la pila de números
		#subi $s1,$s1,4
		
NoDecrementa:	move $a0, $s2
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
		j PedirDeNuevo
		
ErrDesbordamiento:#Si ocurre un desbordamiento, se imprime un mensaje de error y se
		#Sale del programa
		la $a0, Desbordamiento
		li $v0,4
		syscall
		j PedirDeNuevo
		
ErrSint:	#Si la sintaxis está mal, se imprime un mensaje y se sale del programa
		la $a0, Syntax
		li $v0,4
		syscall
		j PedirDeNuevo
		
NumLargo:	#Si uno de los números era demasiado largo, Imprime un mensaje 
		#De error sale del programa
		la $a0, NumeroGrande
		li $v0,4
		syscall
		j PedirDeNuevo
		
FinPrograma:	#Cargo un 10 en $v0
		li $v0, 10
		#Exit
		syscall
		

###########################################################################################################

GuardaNumero:	#Recibe en $a0 el puntero a la cadena introducida y en $a1 el puntero a la cadena temporal,
		#Lee byte a byte la cadena hasta que encuentre un operador y guarda los dígitos encontrados
		#en la cadena temporal
	       	#Cargo un byte de la cadena en $t0:
BucleGuardar:	lb $t0, ($a0)
		#Comprobamos si es un operador
		beq $t0, 40, Operador
		beq $t0, 41, Operador
		beq $t0, 42, Operador
		beq $t0, 43, Operador
		beq $t0, 45, Operador
		beq $t0, 47, Operador
		beq $t0, $zero, Operador
		#Aumento $a0 en 1:
		addi $a0, $a0, 1
		#Lo guarda en la cadena temporal:
		sb $t0,($a1)
		#Aumento el puntero de la cadena temporal
		addi $a1, $a1, 1
		#Volvemos al inicio del bucle
		j BucleGuardar

Operador:	jr $ra
		
###########################################################################################################

CalcularResultado:
		#Aquí se realizan las operaciones restantes 
		#esta función recibe como argumentos el apuntador a la cima de la pila de operadores en $a0,
		#y el apuntador de la pila de números en $a1, va sacando operadores de la pila de operadores hasta 
		#que no queden más, y realizando las operaciones correspondientes, devuelve el resultado final
		#en $v0, y un 1 en $v1 si ha habido desbordamiento en alguna operación
		
BucleOperadores:#Decrementamos en 1 el apuntador de la pila de operadores y leemos el operador anterior
		subi $a0, $a0, 1
		#Cargamos el operador anterior en $t6
		lb $t6,($a0)
		bne $t6,0,SigueOperador
		#Si lo cargado en un 0 (no había un operador anterior) guardamos el resultado en $v0
		#salimos de la función
		####################
		#Caso especial, no hay más operadores
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
		#siempre la tiene también
		
		#Cogemos los dos primeros números de la pila de números y reducimos el apuntador
		#en 8 (el primero va en $t8 y el segundo en $t9)
		lw $t8,-8($a1)
		lw $t9,-4($a1)
		subi $a1, $a1,8
		
		#Comprobamos qué operación es, la hacemos y guardamos el resultado en la pila de números
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
		
Menos:		sub $t9,$zero,$t9
		j Mas
		
DividirMultiplicar:
		
		#Cogemos los dos primeros números de la pila de números y reducimos el apuntador
		#en 8 (el primero va en $t8 y el segundo en $t9)
		lw $t8,-8($a1)
		lw $t9,-4($a1)
		subi $a1, $a1,8
		
		#Comprobamos qué operación es, la hacemos y guardamos el resultado en la pila de números
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
		#Aquí se comprueba si el operador anterior tenía prioridad frente al que entra
		#esta función recibe como argumentos el operador leído en $a0, el apuntador de la pila de números en $a1, y el 
		#apuntador de la pila de operadores en $a2, si el anterior tiene prioridad, realizará la operación
		#correspondiente y guardará el resultado en la pila de números, devuelve, a partir de una dirección
		#de memoria (ResultadosComprobacion) pirmero un 1 o un 0, un 1 si el operador anterior tenía
		#precedencia
		
		#Decrementamos en 1 el apuntador de la pila de operadores y leemos el operador anterior
		subi $a2, $a2, 1
		#Cargamos el operador anterior en $t6
		lb $t6,($a2)
		#Si el operador leído es un '(', no hacemos nada
		beq $t6,40,SalirC
		bne $t6,0,SigueOperadorC
		#Si lo cargado en un 0 (no había un operador anterior) guardamos los resultados y 
		#salimos de la función
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
		#Si el leído es * o /, comprobamos cuál era el anterior, si era + o - salimos
		#Sin hacer nada, si era * o /, realizamos esa operacion

CompruebaAnterior:
		#Si el operador es + o -, el operador anterior siempre va a tener prioridad
		#Ahora comprobamos cual es el operador anterior
		beq $t6, 43, MasMenosC
		bne $t6, 45, CompruebaPrec
														
MasMenosC:	
		#Cogemos los dos primeros números de la pila de números y reducimos el apuntador
		#en 8 (el primero va en $t8 y el segundo en $t9)
		lw $t8,-8($a1)
		lw $t9,-4($a1)
		subi $a1, $a1,8
		
		#Comprobamos qué operación es, la hacemos y guardamos el resultado en la pila de números
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
		
MenosC:		sub $t9,$zero,$t9
		j MasC
		
CompruebaPrec:	#Si el operador es * o /, comprueba si el anterior era + o -, en ese caso,
		#Guarda el operador en la pila y vuelve sin calcular nada
		beq $t6, 43, SalirC
		beq $t6, 45, SalirC
		
DividirMultiplicarC:
		
		#Cogemos los dos primeros números de la pila de números y reducimos el apuntador
		#en 8 (el primero va en $t8 y el segundo en $t9)
		lw $t8,-8($a1)
		lw $t9,-4($a1)
		subi $a1, $a1,8
		
		#Comprobamos qué operación es, la hacemos y guardamos el resultado en la pila de números
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
		#Ahi están comprobados los errores en los que el hi es distinto de 0
		
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
		#addi $a2,$a2,1
		sw $a2,8($t7)
		#Salimos de la función
		jr $ra

#AQUI HAY QUE IMPLEMENTAR LO QUE SE HACE CUANDO EL OPERADOR ES UN * O UN /
		


###########################################################################################################
DecimalABinario:#Esta función recibe como parámetro la dirección de una cadena ascii que contiene un número
		#decimal en $a0, lo convierte a binario y devuelve el resultado en $v0, si hay algún error
		#lo indica con un mensaje en $v1
		
		#Para realizar la conversión, utiliza un bucle controlado por índice para cargar uno a uno los
		#primeros 10 bytes desde $a0, para cada byte, primero comprueba qué caracter es, si es mayor que 47 y menor
		#que 58, será un número del 0 al 9, le resta 48 para obtener el número deseado si no está en el
		#intervalo anterior, es un caracter no válido y se sale de la función con un código de error.
		#Después de lo anterior, se multiplica por 10 el byte cargado varias veces usando un bucle en 
		#función del valor del índice y se suma el resultado a $v0, para multiplicar el número por 10
		#usamos un bucle que lo suma consigo mismo 10 veces
		
		#Primero determino la longitud de la cadena cargando bytes hasta encontarme con
		#el terminador de cadena, si no lo encuentro con este bucle salgo con el código
		#de error de cadena demasiado larga
		
		#leemos el primer caracter de la cadena, si  es 45, pongo $t5 a 1 para indicar que el número
		#es negativo y hay que multiplicar por -1 el número, si es 43 dejo $t5 a 0, en ambos casos después
		#de eso le sumo 1 a $a0 para saltar ese caracter, si no es ni 43 ni 45, el número es positivo y no hay
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
		#Ahora compruebo si es un dígito decimal y lo convierto a binario:
		slti $t2, $t0, 48
		#$t2 tiene que ser 0, si no no es un caracter válido
		slti $t3, $t0, 58
		#Si $t3 no es 1, es un caracter no válido
		#Usando lo anterior, compruebo si se sale y actúo en consecuencia:
		bne $t2, $zero, Error
		beq $t3, $zero, Error
		#Si no hay error, le resto lo que corresponda:
		subi $t0, $t0, 48
		j FinComprobacion
		
Error:		#Si el caracter es el terminador de cadena, pone un 0 en $v0 y vuelve
		beq $t0,0,Devuelve0
		#Pongo el error 2-carácter incorrecto en $v1 y salgo de la función:
		li $v1, 2
		jr $ra
Devuelve0:	jr $ra
		
FinComprobacion:
		#Multiplico por 10 varias veces el byte leído para darle el valor que le corresponde
		
		#Copio el valor del índice en $t3, indica cuántas veces hacer el bucle
		add $t3, $zero, $t1
		#Le resto 1:
		subi $t3,$t3,1
		#Si el índice no es 0, en cuyo caso no hay que hacer nada, entro en el bucle
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
		#Le resto 1 al índice, si el resultado no es 0, repito el bucle
		subi $t3,$t3,1
		beq $t3, $zero, ContinuaBucle
		j Inicia10

ContinuaBucle:	#Le resto 1 al índice:
		subi $t1, $t1, 1
		#Le sumo $t0 a $v0
		add $v0,$v0,$t0
		#Si el índice es 0 salgo de la función
		beq $t1, $zero, FinExtraeDec
		#Si no, vuelvo a hacer el bucle:
		j BucleExtraerBin
FinExtraeDec:	#Si $t5 es 1, devuelvo el opuesto del número
		beq $t5,$zero, Salir
		sub $v0,$zero,$v0
Salir:		jr $ra

		


##############################################################################

QuitaLF:	#Esta función recibe la dirección inicial de una cadena en
		#$a0 y quita el fin de linea si lo hay
		
		#Recorro la cadena y cambio el line feed, si está, por un 0:
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
SigueBucle:	#Le suma 1 a la dirección
		addi $a0, $a0, 1
		#Le resta 1 al índice
		subi $t1, $t1, 1
		beq $t1,$zero,SalirQuita
		j BucleLF
SalirQuita:	jr $ra

##############################################################################

QuitaEspacios:	#Esta función recibe la dirección inicial de una cadena en
		#$a0 y la copia en la dirección que recibe en $a1 sin los espacios
		
		
BucleEspacios:	#Cargo un byte de la cadena en $t0
		lb $t0,($a0)
		beq $t0,$zero,SalirEspacios
		bne $t0, 32, SigueBucleE
		#Si es un espacio, aumenta el puntero en $a0
		addi $a0,$a0,1
		j BucleEspacios
SigueBucleE:	#Guarda el byte leído en la cadena Final
		sb $t0,($a1)
		#Le suma 1 a la dirección de $a0 y $a1
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		j BucleEspacios
SalirEspacios:	jr $ra

##############################################################################

QuitaMenos:	#Esta función recibe la dirección inicial de una cadena en
		#$a0 y la copia en la dirección que recibe en $a1, cambiando
		#los -- por un +, cuando encuentra algo que hay que cambiar,
		#Vuelve indicandolo con un 1 en $v0, de manera que el programa 
		#la seguirá llamando hasta que todos los problemas estén solucionados
		
		#Esta función cambia:
		# -- por +
		# +- y -+ por -
		# ++ por +
		# *+ por *
		# *-X por *(0-X)
		# /+ por /
		# /-X por /(0-X)
		# (-X por (0-X)
		# (+ por (
		
		#Indica un error con un 1 en $v1 
		#Si encuentra:
		# -* ; +* ; -/ ; +/ ; -) ; +) ; *) ; /); /0; ()
		
		#También avisa de un error si el número de paréntesis no es el correcto
		
		#Contador del número de paréntesis abiertos en $t7
		li $t7,0
		
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
		#Si no es un operador guarda el byte leído en la cadena Final
GuardaNormal:	sb $t0,($a1)
		#Le suma 1 a la dirección de $a1 y $a0
		addi $a1, $a1, 1
		addi $a0, $a0, 1
		j BucleMenos

SalirMenos:	bne $t7,0,ErrorSintaxis
		sb $zero,($a1)
		jr $ra

ParCerrar:	subi $t7,$t7,1
		#Comprueba que no se haya cerrado un paréntesis que no se
		#haya abierto previamente
		slt $t9,$t7,$zero
		beq $t9,1,ErrorSintaxis
		j GuardaNormal

ParAbrir:	addi $t7,$t7,1
		#Comprueba el siguiente byte de la cadena
		lb $t1,1($a0)
		#Comprueba si es un -, un +, un *, un / o un )
		beq $t1, 41, ErrorSintaxis
		beq $t1, 42, ErrorSintaxis
		beq $t1, 47, ErrorSintaxis
		addi $t9,$zero,40
		beq $t1, 43, SustituirOperador
		#Si es un - guarda *(0-
		beq $t1, 45, GuardaInverso2
		#Si no es ninguno de esos:
		j GuardaNormal
		
Mult:		#Comprueba el siguiente byte de la cadena
		lb $t1,1($a0)
		#Comprueba si es un -, un +, un *, un / o un )
		beq $t1, 41, ErrorSintaxis
		beq $t1, 42, ErrorSintaxis
		beq $t1, 47, ErrorSintaxis
		addi $t9,$zero,42
		beq $t1, 43, SustituirOperador
		#Si es un - guarda *(0-x)
		addi $t9,$zero,42
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
		#Comprueba si es un -, un +, un *, un 0, un / o un )
		beq $t1, 41, ErrorSintaxis
		beq $t1, 42, ErrorSintaxis
		beq $t1, 47, ErrorSintaxis
		bne $t1, 48, FinCompCero
		#Si es un 0, comprueba si el siguiente byte es una x o X
		lb $t8,2($a0)
		beq $t8,88,FinCompCero
		bne $t8,120,ErrorSintaxis
FinCompCero:	addi $t9,$zero,47
		beq $t1, 43, SustituirOperador
		#Si es un - guarda /(0-x)
		addi $t9,$zero,47
		beq $t1, 45, GuardaInverso
		#Si no es ninguno de esos:
		j GuardaNormal

SustituirOperador:#Guarda el operador indicado en $t9 en la cadena final
		sb $t9,($a1)
		#Aumenta en 1 el indice $a1 y en 2 el de $a2, después, pone $v0 a 
		#1 y guarda el resto de la cadena, corrigiendo posibles errores,
		#sin embargo, hay que volver a llamar a esta función ya que puede haber 
		#errores, por ejemplo, si hay --- esta función lo cambiará a +- en la final
		#pero eso no se cambiará por - hasta la siguiente pasada
		addi $a1,$a1, 1
		addi $a0,$a0, 2
		li $v0,1
		j BucleMenos
		
GuardaInverso:	#Guarda (0-X) en la cadena
		#Guarda el operador indicado (* o /)
		sb $t9,($a1)
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
		
		#Le sumo 2 a $a0 y 3 a $a1
		addi $a0,$a0,2
		addi $a1,$a1,4 
		
		#Cargo un byte de $a0 en $t4
BucleInv:	lb $t4,($a0)
		#compruebo si es un operador:
		slti $t2, $t4, 40
		#$t2 tiene que ser 0, si no no es un operador
		slti $t3, $t4, 48
		#Si $t3 no es 1, no es un operador
		#Usando lo anterior, compruebo si es un operador
		bne $t2, $zero, GuardaFinal
		bne $t3, $zero, GuardaFinal
		#Compruebo que el byte leido no sea el terminador
		beq $t4,$zero,GuardaFinal
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

GuardaInverso2:	#Guarda (0- en la cadena
		#Guarda un (
		li $t1,40
		sb $t1,($a1)
		#guarda un 0
		li $t1,48
		sb $t1,1($a1)
		#Guarda un -
		li $t1,45
		sb $t1,2($a1)
		#Le sumo 2 a $a0 y 3 a $a1
		addi $a0,$a0,2
		addi $a1,$a1,3 
		j BucleMenos

ErrorSintaxis:	#Guarda un 1 en $v1 y un /0 al final de la direcciones
		#donde se guarda la cadena y sale de la función
		subi $a1,$a1,1
		sb $zero,($a1)
		subi $a0,$a0,1
		sb $zero,($a0)
		li $v1,1
		jr $ra
#######################################################################################################

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
		 
BucleExtraerBinH:
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
		beq $t3, $zero, SalirH
MueveDerecha:	#muevo el contenido de $t0 4 posiciones hacia la derecha:
		srl $v0, $v0, 4
		#Le resto 1 al índice, si el resultado no es 0, repito el bucle
		subi $t3,$t3,1
		beq $t3, $zero, SalirH
		j MueveDerecha

Sigue:		#Aumento $a0 en 1:
		addi $a0, $a0, 1
		#Ahora compruebo si es un dígito hexadecimal y lo convierto a binario:
		slti $t2, $t0, 48
		#En cada comprobación $t2 tiene que ser 0, si no no es un caracter válido
		slti $t3, $t0, 58
		#Si $t3 no es 1, se comprueba el siguiente intervalo
		#Usando lo anterior, compruebo si se sale y actúo en consecuencia:
		bne $t2, $zero, ErrorH
		beq $t3, $zero, CompruebaMayus
		#Si no hay error, le resto lo que corresponda:
		subi $t0, $t0, 48
		j FinComprobacionH
		
		#Comprobación del intervalo de las mayúsculas:
CompruebaMayus: slti $t2, $t0, 65
		#En cada comprobación $t2 tiene que ser 0, si no no es un caracter válido
		slti $t3, $t0, 71
		#Si $t3 no es 1, se comprueba el siguiente intervalo
		#Usando lo anterior, compruebo si se sale y actúo en consecuencia:
		bne $t2, $zero, ErrorH
		beq $t3, $zero, CompruebaMinus
		#Si no hay error, le resto lo que corresponda:
		subi $t0, $t0, 55
		j FinComprobacionH
		
		#Comprobación del intervalo de las minúsculas:
CompruebaMinus: slti $t2, $t0, 97
		#En cada comprobación $t2 tiene que ser 0, si no no es un caracter válido
		slti $t3, $t0, 103
		#Si $t3 no es 1, se comprueba el siguiente intervalo
		#Usando lo anterior, compruebo si se sale y actúo en consecuencia:
		bne $t2, $zero, ErrorH
		beq $t3, $zero, ErrorH
		#Si no hay error, le resto lo que corresponda:
		subi $t0, $t0, 87
		j FinComprobacionH
		
ErrorH:		#Pongo el error 1-carácter incorrecto en $v1 y salgo de la función:
		li $v1, 1
		jr $ra
		
FinComprobacionH:
		#Desplazo el byte leído para dejarlo en la posición corespondiente, lo que nos
		#interesa son 4 bits a la derecha del registro, habrá que moverlos más cuanto mayor
		#sea el índice
		
		#Copio el valor del índice en $t3, indica cuánto mover los bits
		add $t3, $zero, $t1
		#Le resto 1:
		subi $t3,$t3,1
		#Si el índice no es 0, en cuyo caso no hay que moverlos, entro en el bucle que los mueve
		beq $t3, $zero,ContinuaBucleH
BucleMoverBits:	#muevo el contenido de $t0 4 posiciones hacia la izquierda:
		sll $t0, $t0, 4
		#Le resto 1 al índice, si el resultado no es 0, repito el bucle
		subi $t3,$t3,1
		beq $t3, $zero, ContinuaBucleH
		j BucleMoverBits


ContinuaBucleH:	#Le resto 1 al índice:
		subi $t1, $t1, 1
		#Hago or de $t0 y $v0:
		or $v0, $t0, $v0
		#Si el índice es 0 salgo de la función
		beq $t1, $zero, FinExtraeBin
		#Si no, vuelvo a hacer el bucle:
		j BucleExtraerBinH
FinExtraeBin:	#Antes de salir cargo un byte más de $a0, si no es 0, es porque la cadena es
		#Demasiado larga:
		lb $t5, ($a0)
		beq $t5, $zero, SalirH
		li $v1, 2
SalirH:		jr $ra

		
		





































