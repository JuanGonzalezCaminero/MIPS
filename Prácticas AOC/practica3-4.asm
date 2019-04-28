.data
Dato:.word 0x00000080
NumeroAComprobar:.float -54874.54
NumPos:.asciiz "El n�mero es positivo"
NumNeg:.asciiz "El n�mero es negativo"
.text
	#Como es little endian el bit de signo estar� en el byte de la direcci�n m�s
	#alta, y ser� el primer bit del byte, cargamos el byte en la direcci�n NumeroAComprobar+3,
	#en el cual est� el bit de signo, y hacemos un and de ese dato con 0x00000080, si el resultado
	#es 0 el n�mero es positivo ya que el bit de signo est� a 0, si no, es negativo
	la $t0,Dato
	lw $s0,($t0)
	#Cargo el n�mero a comprobar en $s2
	la $s2, NumeroAComprobar
	lb $s2, 3($s2)
	and $s1, $s0, $s2
	beq $s1, $zero, Positivo
	#Cargo un 4 en $v0 (4-Print String)
	li $v0, 4
	la $a0, NumNeg
	syscall
	li $v0, 10
	syscall
Positivo:
	#Cargo un 4 en $v0 (4-Print String)
	li $v0, 4
	la $a0, NumPos
	syscall
	li $v0, 10
	syscall