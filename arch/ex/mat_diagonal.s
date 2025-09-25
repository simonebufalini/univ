.globl main

.data
m: .word 	-1, 0, 33, 12
		4, 15, -6, -4
		27, -8, -9, 2,
		0, 3, -21, 7
sz: .word 4

.text
main:
	la s0, m
	la s1, sz
	lw t0, 0(s1)	#numero righe e colonne
	li t1, 0	#somma elementi (init = 0)
	li t2, 0	#contatore

#stiamo implementando il calcolo dell'indice generico
#ma per gli elementi della diagonale di una Mat, basta
#aggiungere k ogni volta essendo tutti equidistanti.
#k = dim + 1
loop:
	beq t2, t0, end
	mul t3, t2, t0
	add t3, t3, t2
	slli t3, t3, 2
	add t3, t3, s0
	lw t4, 0(t3)
	add t1, t1, t4
	addi t2, t2, 1
	j loop
	
end:
	mv a0, t1
	li a7, 1
	ecall
	li a7, 10
	ecall