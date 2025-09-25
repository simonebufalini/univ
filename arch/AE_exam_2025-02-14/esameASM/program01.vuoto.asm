##########################################
# INSERIRE I PROPRI DATI QUI
# Nome:
# Cognome:
# Matricola:
##########################################

# NON MODIFICARE QUESTA PARTE

.data 
N: .word 0
matrix: .word 0:800

.text

# first value is the size of the square matrix
li a7,5
ecall

la t0,matrix         # t0 is also cursor

sw   a0,N,t1         # put N into memory
mv   t1,a0           # N
mul  t1,t1,t1        # NxN number of elements
slli t1,t1,2         # in bytes
add  t1,t1,t0        # t1 is final position in memory


ww:
	bge t0,t1,endww
	ecall
	sw a0,(t0)
	addi t0,t0,4
j ww

endww:
la a0,matrix          # matrix base address in a0 
la a1,N               # N address is in a1
li t1,0
li t0,0
li a7,0

    
##########################################
## INSERIRE IL PROPRIO CODICE QUI

jal func

li a7, 1
ecall
li a7, 10
ecall

func:
lw s0, 0(a1)			# dimensione della matrice
li s1, 1				# registro per controllo successivo
beqz s0, vuota			# controllo se è vuota
beq s0, s1, singolo		# controllo se ha un solo elemento

li t0, 0				# indice di riga
li s1, 2				# limite indice di colonna
li s2, 0				# somma elementi
loop1:
li t1, 0				# indice di colonna
loop2:
mul t2, t0, s0
add t3, t2, t1			# index = i * N_col + j
slli t4, t3, 2
add t5, a0, t4			# address = base + offset
lw t6, 0(t5)
add s2, s2, t6
addi t1, t1, 1
bge t1, s1, exit1
j loop2

exit1:
addi t0, t0, 1
bge t0, s0, exit2
j loop1

exit2:
mv a0, s2
jr ra

vuota:
li a0, 0
jr ra

singolo:
lw a0, 0(a0)
jr ra