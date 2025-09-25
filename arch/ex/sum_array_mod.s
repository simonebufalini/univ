.globl main

.data
array: .word 2, -3, 17, 11, -8, 8, 0, 9, 33, 1, -47, 22
len: .word 12

.text
main:
	la s0, array
	la s1, len
	lw t1, 0(s1)
	li t2, 0
	li t5, 2
	li s2, 0	#numeri pari
	li s3, 0	#numeri dispari
	
loop:
	beq t2, t1, end
	slli t3, t2, 2
	add t4, s0, t3
	andi t6, t2, 1
	lw s4, 0(t4)
	beqz t6, even
	add s3, s3, s4
	addi t2, t2, 1
	j loop
	
even:
	add s2, s2, s4
	addi t2, t2, 1
	j loop
	
end:
	add a0, s2, zero
	li a7, 1
	ecall
	addi a0, zero, 10
	li a7, 11
	ecall
	add a0, s3, zero
	li a7, 1
	ecall
	li a7, 10
	ecall
	