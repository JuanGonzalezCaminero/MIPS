.text
li $s0,100
mult $s0,$s0
mflo $a0
li $v0, 1
syscall
li $v0, 10
syscall