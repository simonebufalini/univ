.globl main

.data
array: .word 1, -4, 33, 35, -3, -2, 2, 9, 11
len: .word 9

.text
main:
	la s0, array
	la s1, len
	lw t0, 0(s0)
	lw t1, 0(s1)
	li t2, 1
	
for_loop:
	beq t2, t1, end_loop
	addi s0, s0, 4
	lw t3, 0(s0)
	bge t3, t0, update_max
	addi t2, t2, 1
	j for_loop
	
update_max:
	add t0, t3, zero
	addi t2, t2, 1
	j for_loop
	
end_loop:
	add a0, t0, zero
	li a7, 1
	ecall
	li a7, 10
	ecall