.data
A:.space 1000 #Reservo 1000 bits para cada una de las cadenas 
B:.space 1000
C:.asciiz "Introduce una cadena en min�sculas\n"
D:.asciiz "\nIntroduce un n�mero entero\n"
.text
Main:		addi $v0,$zero,4 #4-Print String
		la $a0,C #Carga la direcci�n inicial de C para imprimirla
		syscall
		add $a0,$zero,$zero #Inizializa $a0
		la $a0,B #Al leer la cadena de teclado, se va a almacenar a partir de la direcci�n contenida en $a0(B)
		addi $a1,$zero,1000 #La cadena le�da va a ser de 1000 caracteres o menos
		addi $v0,$zero,8 #8-Read String
		syscall
		la $a0,B #Le pasa la cadena a la funci�n que quita el retorno de carro
		jal QuitaLF
		addi $v0,$zero,4 #4-Print String
		la $a0,D #Carga la direcci�n inicial de D para imprimirla
		syscall
		addi $v0,$zero,5 #5-Read Int
		syscall
		la $a0,B #Carga en $a0 la direcci�n de B
		jal Mayusculas #Va a la funci�n que pasa la cadena a may�sculas pas�ndole como argumento la direcci�n de B
		add $a0,$zero,$zero #Inicializa $a0
		la $a0,B #Carga en $a0 la direcci�n de B
		la $a1,A #Carga en $a1 la direcci�n de A
		add $a2,$zero,$v0 #Carga en $a2 el entero que se hab�a le�do antes (que estaba en $v0)	
		jal Copia_nB_en_A
		la $a0,A #Carga la direcci�n inicial de A para imprimirla
		addi $v0,$zero,4 #11-Print String
		syscall
		addi $v0,$zero,10 #10-Exit
		syscall

#Esta funci�n quita el retorno de carro de la cadena si lo hay
QuitaLF:	add $t0,$zero,$zero
Bucle:		lb $t1,0($a0)
		beq $t1,10,Fin
		sb $t1,0($a0)
		addi $a0,$a0,1
		bne $t1,$zero,Bucle
Fin:		sb $zero,0($a0) #Guarda un 0 en lugar del retorno de carro
		jr $ra
		
Mayusculas:	#Funci�n que pasa la cadena en la direcci�n contenida en $a0 a may�sculas
BucleMayusculas:lb $t0,0($a0)	 
		slti $t1,$t0,97 #Si la letra es may�scula pone $t2 a 1
		bne $t1,$zero,siguienteletra
		beq $t0,$zero,Exit #Cuando se llega al terminador, no se le resta 32,se pone el terminador al final de B y se sale de la funci�n
		addi $t0,$t0,-32 #Al restarle 32, pasa los caracteres a may�sculas
siguienteletra: addi $t1,$zero,0 #Inicializa $t1
		sb $t0,0($a0)	 #Vuelve a guardar el caracter en la misma posici�n, sobreescribiendo el anterior
		addi $a0,$a0,1	 #Avanza una posici�n en la cadena
		bne $t0,$zero,BucleMayusculas	
Exit:    	addi $a0,$a0,1 #Se escribe el terminador en estas dos l�neas
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
SiguienteCadena:addi $t0,$t0,1   #Le suma 1 al contador que almacena el n�mero de cadenas que se han copiado cada vez que se llega al terminador
		la $a0,B #Vuelve a la direcci�n inicial de B
		bne $t0,$a2,BucleCopia #Si no se ha copiado el n�mero de cadenas n (almacenado en $a2), se copia otra m�s
		addi $a1,$a1,1 #Le suma 1 a la direcci�n de A para guardar el terminador de cadena a continuaci�n
		sb $t1,0($a1) #Escribe el terminador de cadena al final de A
		jr $ra
		
		
