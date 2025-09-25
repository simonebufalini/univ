.globl main

.data
array: .word 1, 2, -6, 22, -1, 1, 7, 0, -3, 4
len: .word 10
sum: .word 0

.text
main:
	la s0, array
	la s1, len
	la s2, sum
	lw t1, 0(s1)
	li t2, 0
	li t3, 0
	
loop:
	beq t3, t1, end
	slli t4, t3, 2
	add t4, t4, s0
	lw t0, 0(t4)
	add t2, t2, t0
	addi t3, t3, 1
	j loop
	
end:
	add a0, t2, zero
	li a7, 1
	ecall
	la s3, sum
	sw t2, 0(s3)
	li a7, 10
	ecall