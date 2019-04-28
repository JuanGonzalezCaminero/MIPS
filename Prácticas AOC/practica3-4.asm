.data
Dato:.word 0x00000080
NumeroAComprobar:.float -54874.54
NumPos:.asciiz "El número es positivo"
NumNeg:.asciiz "El número es negativo"
.text
	#Como es little endian el bit de signo estará en el byte de la dirección más
	#alta, y será el primer bit del byte, cargamos el byte en la dirección NumeroAComprobar+3,
	#en el cual está el bit de signo, y hacemos un and de ese dato con 0x00000080, si el resultado
	#es 0 el número es positivo ya que el bit de signo está a 0, si no, es negativo
	la $t0,Dato
	lw $s0,($t0)
	#Cargo el número a comprobar en $s2
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