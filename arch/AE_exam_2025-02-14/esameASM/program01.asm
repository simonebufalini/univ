##########################################
# INSERIRE I PROPRI DATI QUI
# Nome: Simone
# Cognome: Bufalini
# Matricola: 1984850
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
mv a0, a2
li a7, 1
ecall
li a7, 10
ecall

func:
lw s0, 0(a1)
beq s0, zero, vuota
li t0, 1
beq s0, t0, singolo
li t0, 0
li s1, 0
loop1:
li t1, 0
loop2:
mv t4, t0
slli t4, t4, 2
mul t2, t4, s0
add t2, t2, t1
add t2, a0, t2
lw t3, 0(t2)
add s1, s1, t3
bgt t1, zero, end_loop2
addi t1, t1, 4
j loop2
end_loop2:
bgt t0, s0, end_loop1
addi t0, t0, 1
j loop1
end_loop1:
mv a2, s1
jr ra
singolo:
lw a2, 0(a0)
jr ra
vuota:
mv a2, zero
jr ra