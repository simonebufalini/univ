.globl main

.data
dest: .word case0, case1, case2
A: .byte 1

.text
main:
	lbu t0, A
	slli t0, t0, 2
	la t1, dest
	add t1, t1, t0
	lw t1, 0(t1)
	jr t1
case0:
	li a0, 10
	j end_sw
	
case1:
	li a0, -7
	j end_sw
	
case2:
	li a0, 4
	j end_sw
	
end_sw:
	li a7, 1
	ecall
	li a7, 10
	ecall