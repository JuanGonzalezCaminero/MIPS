.data
A: .asciiz "Introduce un número entero\n"
B: .asciiz "\n¿En que bit se empieza?\n"
C: .asciiz "\n¿Cuantos bits se cogen?\n"
.text
		#Pide el número
		addi $v0,$zero,4 #4-print string
		la $a0,A #pongo la dirección inicial de A en $a0 para pasárselo al syscall
		syscall
		addi $v0,$zero,5 #5-read int
		syscall
		add $s0,$zero,$v0 #almacena en $s0 el número leído
		#Pide el bit inicial
		addi $v0,$zero,4 #4-print string
		la $a0,B #pongo la dirección inicial de A en $a0 para pasárselo al syscall
		syscall
		addi $v0,$zero,5 #5-read int
		syscall
		add $s1,$zero,$v0 #almacena en $s1 el bit inicial
		#Pide el número de bits que hay que coger
		addi $v0,$zero,4 #4-print string
		la $a0,C #pongo la dirección inicial de A en $a0 para pasárselo al syscall
		syscall
		addi $v0,$zero,5 #5-read int
		syscall
		add $s2,$zero,$v0 #almacena en $s2 el número de bits que hay que coger
		add $t0,$s2,$s1
		slti $t1,$t0,32
		bne $t1,$zero,Else #si n+i es mayor que 32, hace n=32-i
		addi $t0,$zero,32
		sub $s2,$t0,$s1
Else:		add $a0,$zero,$s0 #Carga en $a0 el número leído
		add $a1,$zero,$s1 #Carga en $a1 el bit inicial
		add $a2,$zero,$s2 #Carga en $a2 el número de bits que hay que coger
		jal Cortanumero
		addi $v0,$zero,1 #1-print int
		add $a0,$zero,$v1 #para pasarle al syscall el número a imprimir
		syscall
		addi $v0,$zero,10
		syscall
#Esta función coge los bits que se han indicado y devuelve el número que representan esos bits
Cortanumero:	add $t0,$zero,1 #Almacena un 1 en $t0, así hay un bit a 1 a la derecha
		addi $t1,$zero,0 #Contador para comprobar si se ha llegado al bit inicial
		addi $t3,$zero,0 #Contador para ver si se han cogido todos los bits
		addi $t4,$zero,0 #Contador para ver si se han movido a la derecha los bits necesarios
		add $t5,$zero,$a1 #guarda el bit inicial an $a1
		add $t2,$zero,$zero #Inicializa $t2, que es donde se va a almacenar la mascara
#Este bucle mueve los bits almacenados en $a0 a la derecha el número de posiciones indicado en el bit inicial
#(+1 porque se lo había restado antes para utilizarlo como índice)
Muevelosbitsaladerecha: beq $a1,$t4,AlmacenaMascara #si se han movido a la derecha los bits necesarios, sale del bucle
		srl $a0,$a0,1 #mueve el número leído 1 a la derecha
		addi $t4,$t4,1 #Le suma 1 al contador
		j Muevelosbitsaladerecha      
#Este bucle crea una máscara con n bits a 1 a la derecha, siendon el número de bits que se han pedido(que está en $a2)
AlmacenaMascara:beq $a2,$t1,Exit #si se han almacenado ya el número de bits que se quiere en la máscara, sale del bucle
		or $t2,$t0,$t2 #guarda en $t2 un 1 en la posición que toque
		addi $t1,$t1,1 #Le suma 1 al contador
		sll $t0,$t0,1
		j AlmacenaMascara #Vuelve al inicio del Bucle
Exit:		and $t2,$t2,$a0 #coge los bits necesarios de $a0 usando la máscara
		add $v1,$zero,$t2 #almacena el número en $v1 para devolverlo
		jr $ra