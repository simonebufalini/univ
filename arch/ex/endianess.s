.globl main

.data
array: .byte 1,2,3,4		#vedi nella tabella come vengono memorizzati i byte
sz: .byte 4			#confronta con array di word, che sono visti in little endian

.text
main:
	la s0, array
	la s1, sz
	lb t1, 0(s1)
	li t2, 0
	
for_loop:
	bge t2, t1, end_loop
	lbu t0, 0(s0)
	or a0, t0, zero
	li a7, 1
	ecall
	addi t2, t2, 1
	addi s0, s0, 1
	j for_loop
	
end_loop:
	li a7, 10
	ecall