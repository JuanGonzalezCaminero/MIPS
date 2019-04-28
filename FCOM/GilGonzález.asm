.data
A:.ascii "Cadena prueba"
B:.space 12 #Reserva espacio para la cadena en B
.text
		la $s0,A
		add $s1, $zero, $s0	#Guarda la direccion de A en $s1(lo usamos m�s adelante para comprobar que se ha copiado toda la cadena)
		la $s2,B		    
		addi $s3,$zero,32	#El espacio es 32 en ascii (tambien es para comprobar)
Busca_Final:	lb $t0,0($s0)		#Este bucle busca la direcci�n final de la cadena en A para luego recorrerla al rev�s
		beq $t0,$zero,EscribeB  #Sale del bucle cuando se llega al terminador de cadena
		addi $s0,$s0,1          
		bne $t0,$zero,Busca_Final
EscribeB:	addi $s0,$s0,-1		#Escibe en B la cadena de A al rev�s, como le resta 1 a la direcci�n que hay en $s0, no escribe el terminador de cadena al principio
		lb $t0,0($s0)           #Carga un caracter de A
		beq $t0,$s3,Espacio	#Si el caracter es un espacio, se salta la parte de escribirlo en B
		sb $t0,0($s2)
		addi $s2,$s2,1          
Espacio:	bne $s0,$s1,EscribeB	#Se sale del bucle cuando la direcci�n en $s0 es la direcci�n inicial de A
		sb $zero, 0($s2)	#Guarda un byte con 0000 0000 (el terminador de cadena) al final de B
		li $v0, 10
		syscall
		
		