.data
A:.space 1000 #Reservo 1000 bits para cada una de las cadenas 
B:.space 1000
C:.asciiz "Introduce una cadena en minúsculas\n"
D:.asciiz "\nIntroduce un número entero\n"
.text
Main:		addi $v0,$zero,4 #4-Print String
		la $a0,C #Carga la dirección inicial de C para imprimirla
		syscall
		add $a0,$zero,$zero #Inizializa $a0
		la $a0,B #Al leer la cadena de teclado, se va a almacenar a partir de la dirección contenida en $a0(B)
		addi $a1,$zero,1000 #La cadena leída va a ser de 1000 caracteres o menos
		addi $v0,$zero,8 #8-Read String
		syscall
		la $a0,B #Le pasa la cadena a la función que quita el retorno de carro
		jal QuitaLF
		addi $v0,$zero,4 #4-Print String
		la $a0,D #Carga la dirección inicial de D para imprimirla
		syscall
		addi $v0,$zero,5 #5-Read Int
		syscall
		la $a0,B #Carga en $a0 la dirección de B
		jal Mayusculas #Va a la función que pasa la cadena a mayúsculas pasándole como argumento la dirección de B
		add $a0,$zero,$zero #Inicializa $a0
		la $a0,B #Carga en $a0 la dirección de B
		la $a1,A #Carga en $a1 la dirección de A
		add $a2,$zero,$v0 #Carga en $a2 el entero que se había leído antes (que estaba en $v0)	
		jal Copia_nB_en_A
		la $a0,A #Carga la dirección inicial de A para imprimirla
		addi $v0,$zero,4 #11-Print String
		syscall
		addi $v0,$zero,10 #10-Exit
		syscall

#Esta función quita el retorno de carro de la cadena si lo hay
QuitaLF:	add $t0,$zero,$zero
Bucle:		lb $t1,0($a0)
		beq $t1,10,Fin
		sb $t1,0($a0)
		addi $a0,$a0,1
		bne $t1,$zero,Bucle
Fin:		sb $zero,0($a0) #Guarda un 0 en lugar del retorno de carro
		jr $ra
		
Mayusculas:	#Función que pasa la cadena en la dirección contenida en $a0 a mayúsculas
BucleMayusculas:lb $t0,0($a0)	 
		slti $t1,$t0,97 #Si la letra es mayúscula pone $t2 a 1
		bne $t1,$zero,siguienteletra
		beq $t0,$zero,Exit #Cuando se llega al terminador, no se le resta 32,se pone el terminador al final de B y se sale de la función
		addi $t0,$t0,-32 #Al restarle 32, pasa los caracteres a mayúsculas
siguienteletra: addi $t1,$zero,0 #Inicializa $t1
		sb $t0,0($a0)	 #Vuelve a guardar el caracter en la misma posición, sobreescribiendo el anterior
		addi $a0,$a0,1	 #Avanza una posición en la cadena
		bne $t0,$zero,BucleMayusculas	
Exit:    	addi $a0,$a0,1 #Se escribe el terminador en estas dos líneas
		sb $zero,0($a0)
		jr $ra
		
		
#Copia la cadena que empieza en B en A n veces, B en $a0, A en $a1, n en $a2
Copia_nB_en_A:	addi $t0,$zero,0 #Para comprobar si se ha llegado a n
BucleCopia:	lb $t1,0($a0)
		beq $t1,$zero,SiguienteCadena #Cuando se llega al terminador de cadena, no se copia y se comprueba si hay que acabar el bucle
		sb $t1,0($a1)
		addi $a0,$a0,1
		addi $a1,$a1,1
		bne $t1,$zero,BucleCopia #Si no se ha llegado al final, se sigue copiando
SiguienteCadena:addi $t0,$t0,1   #Le suma 1 al contador que almacena el número de cadenas que se han copiado cada vez que se llega al terminador
		la $a0,B #Vuelve a la dirección inicial de B
		bne $t0,$a2,BucleCopia #Si no se ha copiado el número de cadenas n (almacenado en $a2), se copia otra más
		addi $a1,$a1,1 #Le suma 1 a la dirección de A para guardar el terminador de cadena a continuación
		sb $t1,0($a1) #Escribe el terminador de cadena al final de A
		jr $ra
		
		
