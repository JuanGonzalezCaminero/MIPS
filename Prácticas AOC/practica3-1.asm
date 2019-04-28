.data

Dato:.word 0x01020304
BigEndian:.asciiz"El procesador es Big Endian"
LittleEndian:.asciiz"El procesador es Little Endian"

.text
	#Para conprobar el endianness del procesador declaramos al principio del 
	#programa 32 bits con los valores 0x01020304, cargamos el valor que almacena en 
	#la posición Dato y lo comparamos con el numero 1, si el valor cargado es igual
	#es big endian, si no, little endian
	la $t0, Dato
	#Cargo el byte en la primera dirección en $s0
	lb $s0, ($t0)
	#Cargo un 1 en $t0
	addi $t0,$zero,1
	#Comparo $s0 y $t0
	beq $s0, $t0, BE
	#Cargo un 4 en $v0 (4-Print String)
	li $v0, 4
	la $a0, LittleEndian
	syscall
	li $v0, 10
	syscall
BE:	li $v0, 4
	la $a0, BigEndian
	syscall
	li $v0, 10
	syscall
