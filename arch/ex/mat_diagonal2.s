.globl main

.data
mat: .word	10, -3, 2, 1,
		0, 21, -9, 0,
		14, -32, 3, 33,
		41, 0, -7, -8

sz: .word	4

.text
main:
	la s1, mat        # s1 = base della matrice
	lw t0, sz         # t0 = dimensione (N)
	li s0, 0          # s0 = somma totale
	li t3, 0          # t3 = contatore (i)

loop:
	beq t3, t0, exit  # se i == N, esci

	# --- Diagonale principale: offset = 4 * (i * N + i)
	mul t1, t3, t0     # t1 = i * N
	add t1, t1, t3     # t1 = i*N + i
	slli t1, t1, 2     # t1 = offset in byte
	add t4, s1, t1     # indirizzo elemento
	lw t5, 0(t4)
	add s0, s0, t5

	# --- Diagonale secondaria: offset = 4 * (i * N + (N - 1 - i))
	addi t2, t0, -1    # t2 = N - 1
	sub t2, t2, t3     # t2 = N - 1 - i
	mul t6, t3, t0     # t6 = i * N
	add t6, t6, t2     # t6 = i*N + (N-1-i)
	slli t6, t6, 2     # offset in byte
	add t4, s1, t6     # riutilizziamo t4
	lw t5, 0(t4)
	add s0, s0, t5

	addi t3, t3, 1
	j loop

exit:
	mv a0, s0
	li a7, 1
	ecall

	li a7, 10
	ecall
