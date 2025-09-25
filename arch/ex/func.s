.globl main

.data
array: .word 1, 2, 3, 4, 5

.text
main:
	la s0, array
	li t0, 0
	li t1, 5

loop:
	beq t0, t1, exit
	lw a0, 0(s0)
	jal print
	addi s0, s0, 4
	addi t0, t0, 1
	j loop
	
exit:
	li a7, 10
	ecall
	
print:
	li a7, 1
	ecall
	jr ra
