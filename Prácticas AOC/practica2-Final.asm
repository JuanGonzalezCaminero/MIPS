.data

Matriz1:.space 64

Matriz2:.space 64

MatrizDestino:.space 64
#Reservo 64 bytes

espacio:.asciiz "  "
newline:.asciiz "\n"
Pide1:.asciiz "Introduce el elemento ["
corchete:.asciiz "]["
PidePrimera:.asciiz "] de la primera matriz: "
PideSegunda:.asciiz "] de la segunda matriz: "



.text			#Cargo la dirección de la primera matriz en $a0 y un o en $a1
			la $a0, Matriz1
			addi $a1, $zero,0
			jal PideMatriz
			#Cargo la dirección de la segunda y un 1
			la $a0, Matriz2
			addi $a1, $zero,1
			jal PideMatriz
			
			#Cargo las direcciones de las matrices 1,2 y destino en $a0,1 y 2
			la $a0, Matriz1
			la $a1, Matriz2
			la $a2, MatrizDestino
			#Hago la suma
			jal SumaMatrices
			
			#Cargo la dirección de la matriz en $s0
			la $s0, MatrizDestino
			#Cargo la dirección de la matriz en $a0 para pasarla como argumento
			add $a0,$zero,$s0
			#Llamo a la función que traspone la matriz
			jal TrasponerMatriz
			#Cargo la dirección de la matriz en $a0 para pasarla como argumento
			add $a0,$zero,$s0
			#Imprimo la matriz
			jal ImprimeMatriz
			
			#Cargo un 10 en $v0 (10-Exit)
			addi $v0,$zero,10
			syscall
			
PideMatriz:
	 #Usa un bucle para pedir los elementos de una matriz, recibe la dirección de la matriz
	 #en $a0 y en $a1 un 0 o un 1 para cambiar el mensaje que se imprime por pantalla al pedirla
	 
	 		#Guargo la dirección inicial de la matriz en $s7 ya que voy a usar $a0
			add $s7,$zero,$a0
			#Cargo un 3 en $t0 para compararlo con los indices
			addi $t0, $zero, 3
			#Pongo a 0 $t1 -> i y $t2 -> j
			add $t1, $zero, $zero
			add $t2, $zero, $zero 
BucleiPedir:			
BuclejPedir:		#Calculo la dirección de la posición A[i][j]
			#i * 4
			sll $t3, $t1, 2
			#i * 4 * 4
			sll $t3, $t3, 2
			
			#multiplico j * 4 y se lo sumo a la dirección inicial de la fila obtenida antes
			# y almacenada en $t3
			sll $t4,$t2,2
			add $t3,$t4,$t3
			#Le sumo la dirección inicial de la matriz a esa dirección
			add $t3, $t3, $s7
			#Imprimo las cadenas que piden el dato
			
			#Cargo un 4 en $v0 (4 - Print String)
			addi $v0, $zero, 4
			la $a0,Pide1
			syscall
			#Cargo un 1 en $v0 (1 - Print Int)
			addi $v0, $zero, 1
			add $a0,$zero,$t1
			syscall
			#Cargo un 4 en $v0 (4 - Print String)
			addi $v0, $zero, 4
			la $a0, corchete
			syscall
			#Cargo un 1 en $v0 (1 - Print Int)
			addi $v0, $zero, 1
			add $a0,$zero,$t2
			syscall
			
			bne $a1,$zero,Pide2
			#Cargo un 4 en $v0 (4 - Print String)
			addi $v0, $zero, 4
			la $a0, PidePrimera
			syscall
			j Continua
Pide2:			#Cargo un 4 en $v0 (4 - Print String)
			addi $v0, $zero, 4
			la $a0, PideSegunda
			syscall
			
Continua:		#Cargo un 5 en $v0 (5 - Read Int)
			addi $v0, $zero, 5
			syscall
			#Guardo el entero leído en la matriz
			sw $v0,($t3)
			
			
			#Compruebo si se ha llegado al final de la fila
			bne $t2,$t0,ContinuaBuclejPedir
			#Si se ha llegado, compruebo si esa era la última fila de la matriz
			bne $t1,$t0,ContinuaBucleiPedir
			#Si era la última fila, salgo del bucle
			jr $ra
ContinuaBuclejPedir:	#Le sumo un 1 al indice j y continuo con el Buclej
			addi $t2,$t2,1
			j BuclejPedir
ContinuaBucleiPedir:	#le sumo un 1 al indice i y continuo el Buclei (y pongo la j a 0)
			addi $t1,$t1,1
			add $t2, $zero, $zero
			j BucleiPedir
	 

TrasponerMatriz:	
	#Para trasponer la matriz, uso dos bucles para recorrerla (como dos bucles for normales), ambos 
	#controlados por índice, haciendo que el segundo bucle empieze a recorrer cada fila en la posición
	#i+1, de manera que solo se recorran las posiciones encima de la diagonal de la matriz
	
	#Para cada posición cojo el dato almacenado y lo guardo en una variable temporal, después cojo
	#el dato en la posición contraria (si la posición es [i][j], el dato en [j][i]) y lo pongo en 
	#[i][j], por último pongo el dato que estaba en [i][j] en [j][i]
	
	#El código en java sería el siguiente:
	#for(int i = 0 ; i < matriz.length ; i++){
	#	for(int j = i+1 ; j < matriz[i].length ; j++){
	#		int temporal = matriz[i][j];
	#		matriz[i][j] = matriz[j][i];
	#		matriz[j][i] = temporal;
	#		}
	#	}
	
			#Cargo un 3 en $t0 para compararlo con el indice j
			addi $t0, $zero, 3
			#Cargo un 2 en $t8 para compararlo con el indice i, ya que
			#cuando i=2 hay que terminar el bucle porque no quedan más elementos 
			#encima de la diagonal
			addi $t8, $zero, 2
			
			#Pongo a 0 $t1 -> i y $t2 -> j
			add $t1, $zero, $zero
			add $t2, $zero, $zero 
Buclei:			
			#Hago j = i+1
			addi $t2, $t1, 1
Buclej:			
			#Ahora necesito hallar la dirección del dato que tengo 
			#que cargar, para eso:
			
			#multiplico i * 4 * 4, el primer 4 porque las direcciones son 
			#de 4 bytes, el segundo porque hay 4 columnas en la matriz, al multiplicar
			#por 4 llegas a la dirección inicial de la fila que te interesa
			
			#i * 4
			sll $t3, $t1, 2
			#i * 4 * 4
			sll $t3, $t3, 2
			
			#multiplico j * 4 y se lo sumo a la dirección inicial de la fila obtenida antes
			# y almacenada en $t3
			sll $t4,$t2,2
			add $t3,$t4,$t3
			#Le sumo la dirección inicial de la matriz a esa dirección
			add $t3, $t3, $a0
			#En este punto tenemos la dirección A[i][j] en $t3
			#Guardo el dato en esa dirección en $t4
			lw $t4,($t3)
			
			#Ahora calculo la dirección [j][i] de la misma manera que antes y la guardo en $t5
			#j * 4
			sll $t5, $t2, 2
			#j * 4 * 4
			sll $t5, $t5, 2
			#i * 4
			sll $t6, $t1, 2
			#Guardo la dirección en $t5
			add $t5, $t5, $t6
			#Le sumo la dirección inicial de la matriz a esa dirección
			add $t5, $t5, $a0
			#Cargo el dato en A[j][i] y lo guardo en A[i][j]
			lw $t7,($t5)
			sw $t7,($t3)
			#Guardo el dato de A[i][j] en A[j][i]
			sw $t4,($t5)
			#Compruebo si se ha llegado al final de la fila
			bne $t2,$t0,ContinuaBuclej
			#Si se ha llegado, compruebo si esa era la última fila de la matriz
			bne $t1,$t8,ContinuaBuclei
			#Si era la última fila, salgo del bucle
			jr $ra
ContinuaBuclej:		#Le sumo un 1 al indice j y continuo con el Buclej
			addi $t2,$t2,1
			j Buclej
ContinuaBuclei:		#le sumo un 1 al indice i y continuo el Buclei
			addi $t1,$t1,1
			j Buclei

SumaMatrices:		
	#Recibe la dirección inicial de la primera matriz en $a0, la segunda en $a1 y el destino en $a2
	#Para sumarlas, usa un bucle como el de la función que imprime las matrices, primero calcula lo que
	#hay que sumarle a la dirección inicial de cada matriz, que será lo mismo para todas ya que se suman
	#las mismas posiciones, y después se lo va sumando a la dirección inicial de cada una para cargar los
	#datos y para hallar la dirección en la que hay que poner el resultado
			#Cargo un 3 en $t0 para compararlo con los indices
			addi $t0, $zero, 3
			#Pongo a 0 $t1 -> i y $t2 -> j
			add $t1, $zero, $zero
			add $t2, $zero, $zero 
BucleiSumar:			
BuclejSumar:		#Calculo la dirección de la posición [i][j]
			#i * 4
			sll $t3, $t1, 2
			#i * 4 * 4
			sll $t3, $t3, 2
			
			#multiplico j * 4 y se lo sumo a la dirección inicial de la fila obtenida antes
			# y almacenada en $t3
			sll $t4,$t2,2
			add $t3,$t4,$t3
			#Le sumo la dirección inicial de la matriz en $a0 a esa dirección
			add $t4, $t3, $a0
			#Cargo el primer dato en $t5
			lw $t5,($t4)
			#Calculo la dirección de esa posición para la matriz en $a1
			add $t4, $t3, $a1
			#Cargo el segundo dato en $t6
			lw $t6,($t4)
			#Sumo ambos datos y dejo el resultado en $t5
			add $t5, $t5, $t6
			#Calculo la dirección de destino en la matriz en $a2
			add $t4, $t3, $a2
			#Almaceno el resultado en esa dirección
			sw $t5,($t4)
			
			#Compruebo si se ha llegado al final de la fila
			bne $t2,$t0,ContinuaBuclejSumar
			#Si se ha llegado, compruebo si esa era la última fila de la matriz
			bne $t1,$t0,ContinuaBucleiSumar
			#Si era la última fila, salgo del bucle
			jr $ra
ContinuaBuclejSumar:	#Le sumo un 1 al indice j y continuo con el Buclej
			addi $t2,$t2,1
			j BuclejSumar
ContinuaBucleiSumar:	#le sumo un 1 al indice i y continuo el Buclei (y pongo la j a 0)
			addi $t1,$t1,1
			add $t2, $zero, $zero
			j BucleiSumar
	

ImprimeMatriz:
	#Esta función recibe la dirección inicial de la matriz en $a0 y la imprime por pantalla
			#Guargo la dirección inicial de la matriz en $s7 ya que voy a usar $a0
			add $s7,$zero,$a0
			#Cargo un 3 en $t0 para compararlo con los indices
			addi $t0, $zero, 3
			#Pongo a 0 $t1 -> i y $t2 -> j
			add $t1, $zero, $zero
			add $t2, $zero, $zero 
			#Cargo la dirección inicial de la cadena con el espacio en 
			#$t7
			la $t7, espacio
BucleiImprimir:			
BuclejImprimir:		#Calculo la dirección de la posición A[i][j]
			#i * 4
			sll $t3, $t1, 2
			#i * 4 * 4
			sll $t3, $t3, 2
			
			#multiplico j * 4 y se lo sumo a la dirección inicial de la fila obtenida antes
			# y almacenada en $t3
			sll $t4,$t2,2
			add $t3,$t4,$t3
			#Le sumo la dirección inicial de la matriz a esa dirección
			add $t3, $t3, $s7
			#Cargo el dato en esa posición en $a0
			lw $a0,($t3)
			#Cargo un 1 en $v0 (1 - Print Int)
			addi $v0, $zero, 1
			syscall
			#Cargo un 4 en $v0 (4 - Print String)
			addi $v0, $zero, 4
			#Cargo en $a0 la dirección del espacio
			add $a0, $zero, $t7
			syscall
			
			#Compruebo si se ha llegado al final de la fila
			bne $t2,$t0,ContinuaBuclejImprimir
			#Si se ha llegado, compruebo si esa era la última fila de la matriz
			bne $t1,$t0,ContinuaBucleiImprimir
			#Si era la última fila, salgo del bucle
			#Aantes de salir imprimo un par de saltos de línea
			#Cargo un 4 en $v0 (4 - Print String)
			addi $v0, $zero, 4
			#Cargo en $a0 la dirección del salto de línea
			la $a0, newline
			syscall
			syscall
			jr $ra
ContinuaBuclejImprimir:	#Le sumo un 1 al indice j y continuo con el Buclej
			addi $t2,$t2,1
			j BuclejImprimir
ContinuaBucleiImprimir:	#le sumo un 1 al indice i y continuo el Buclei (y pongo la j a 0)
			#Imprimo el salto de línea
			#Cargo un 4 en $v0 (4 - Print String)
			addi $v0, $zero, 4
			#Cargo en $a0 la dirección del salto de línea
			la $a0, newline
			syscall
			
			addi $t1,$t1,1
			add $t2, $zero, $zero
			j BucleiImprimir
	

	
	
	
	
	
	
	
	
	
