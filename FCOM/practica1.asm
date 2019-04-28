# Alonso Gil Bécares
# Juan González Caminero
.data
C: .space 40
.text
	la $s0,C
	addi $s2,$zero,1024
	addi $s1,$zero,1
Bucle:  sw $s1,0($s0)
	addi $s0,$s0,4 #Aumenta la dirección en la que guarda las variables en 1 byte
	sll  $s1,$s1,1 #Multiplica la variable que va a guardar por2
	bne $s1,$s2,Bucle
	la $s0,C #vuelve a poner en $s0 la dirección inicial del vector, que había cambiado en el bucle
	lw $s1,16($s0) #A partir de aquí está el código del ejercicio 5, que suma C[4] con C[8] y almacena el resultado en C[9]
	lw $s2,32($s0)
	add $s1,$s1,$s2
	sw $s1,36($s0)
	li $v0 10
	syscall
	

