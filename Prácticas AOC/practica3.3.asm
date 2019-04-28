.data
Matriz:.byte 0, -1, -2, -3
A:.byte -16, -15, -14, -13	
B:.byte 32, 31, 30, 29
C:.byte -48,-47,-46,-45
.text
		#cargo la dirección inicial de la matriz
		la $a0, Matriz
		#Sumo sus componentes
		jal SumaElementos
		
		#Cargo el dato en $a0
		add $a0,$zero,$v1
		#Cargo un 1 en $v0 (1 - Print Int)
		addi $v0, $zero, 1
		syscall
		
		li $v0, 10
		syscall





SumaElementos:		
	#Recibe la dirección inicial de la primera matriz en $a0
	#Usa un bucle que la recorre y va sumando sus componentes en la misma variable
			#Cargo un 3 en $t0 para compararlo con los indices
			addi $t0, $zero, 3
			#Pongo a 0 $t1 -> i y $t2 -> j
			add $t1, $zero, $zero
			add $t2, $zero, $zero 
BucleiSumar:			
BuclejSumar:		#Calculo la dirección de la posición [i][j]
			#i * 4
			sll $t3, $t1, 2
			#De esta manera conseguimos la dirección inicial de la fila i,
			#Ya que cada fila ocupa 32 bits
			
			#Sumo j a la dirección inicial de la fila obtenida antes
			# y almacenada en $t3
			add $t3,$t2,$t3
			#Le sumo la dirección inicial de la matriz en $a0 a esa dirección
			add $t4, $t3, $a0
			#Cargo el dato en $t5
			lb $t5,($t4)
			#Le sumo el dato a $s7
			add $t7,$t7,$t5
			
			#Compruebo si se ha llegado al final de la fila
			bne $t2,$t0,ContinuaBuclejSumar
			#Si se ha llegado, compruebo si esa era la última fila de la matriz
			bne $t1,$t0,ContinuaBucleiSumar
			#Si era la última fila, salgo del bucle
			#No sin antes cargar el resultado en $v1
			add $v1, $zero, $t7
			jr $ra
ContinuaBuclejSumar:	#Le sumo un 1 al indice j y continuo con el Buclej
			addi $t2,$t2,1
			j BuclejSumar
ContinuaBucleiSumar:	#le sumo un 1 al indice i y continuo el Buclei (y pongo la j a 0)
			addi $t1,$t1,1
			add $t2, $zero, $zero
			j BucleiSumar
