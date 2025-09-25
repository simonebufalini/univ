.globl main

.data
array: .word 1, 10, -7, 4, 33, -21, 0, 9
len: .word 8

.text
main:
	la s0, array       # base dell'array
	la s1, len
	lw t1, 0(s1)       # lunghezza = 8
	li t2, 0           # indice
	li a7, 1           # syscall: stampa intero
	
loop:
	bge t2, t1, end

	slli t3, t2, 2     # t3 = t2 * 4 (offset in byte)
	add t0, s0, t3     # t4 = indirizzo di array[t2]
	lw a0, 0(t0)       # carica array[t2] in a0
	li a7, 1
	ecall
	
	li a0, 10
	li a7, 11
	ecall

	addi t2, t2, 1     # i++
	j loop
	
end:
	li a7, 10
	ecall
