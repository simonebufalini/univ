.globl main

.data
msg: .asciz "Input: "

.text
main:
	la a0, msg
	li a7, 4
	ecall
	
	li a7, 5
	ecall
	
	li t0, 2
	jal fibo
	
fibo:
	addi sp, sp, -12
	sw ra, 8(sp)
	sw a0, 4(sp)
	
	blt a0, t0, base
	addi a0, a0, -1
	jal fibo
	#da qui non capisco
	
base:
	li a0, 1
	lw ra, 8(sp)
	addi sp, sp, 12
	jr ra