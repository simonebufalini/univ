.globl main

.data
input_msg: .asciz "Input: "
output_msg: .asciz "Factorial: "
err_msg: .asciz "Invalid argument"

.text
main:
	la a0, input_msg
	li a7, 4
	ecall
	
	li a7, 5
	ecall
	
	ble a0, zero, error	#controllo input >= zero
	
	mv t0, a0		#valore del fattoriale
	mv t1, a0		#contatore
	
loop:
	addi t1, t1, -1
	beq t1, zero, exit
	mul t0, t0, t1
	j loop
	
exit:
	la a0, output_msg
	li a7, 4
	ecall
	
	mv a0, t0
	li a7, 1
	ecall
	
	li a7, 10
	ecall
	
error:
	la a0, err_msg
	li a7, 4
	ecall
	
	li a7, 10
	ecall