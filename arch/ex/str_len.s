.globl main

.data
string: .asciz "Hello, World!\n"

.text
main:
	la a0, string
	li a1, 0
	jal len
	mv a0, a1
	li a7, 1
	ecall
	li a7, 10
	ecall
	
len:
	li t0, 0
	li t1, 10
loop:
	lb t2, 0(a0)
	beq t2, t1, end
	addi a0, a0, 1
	addi t0, t0, 1
	j loop
end:
	mv a1, t0
	jr ra