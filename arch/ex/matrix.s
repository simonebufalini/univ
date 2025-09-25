.globl main

.data
mtx: .word 	1, -2, 13,
		23, -5, 0,	#mtx[1][2] = 0
		7, 3, -9

.text
main:
	la s0, mtx
	li t0, 3		#numero di colonne
				#indice lineare = i * C + j
	li t1, 2		#indice riga (1)
	li t2, 0		#indice colonna (2)
	mul t3, t1, t0		#i * C
	add t3, t3, t2		#i * C + j
	slli t3, t3, 2		#shift dimensione word
	add s0, s0, t3		#indirizzo finale
	
	lw a0, 0(s0)
	li a7, 1
	ecall
	
	li a7, 10
	ecall