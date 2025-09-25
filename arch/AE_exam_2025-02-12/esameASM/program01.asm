##########################################
# INSERIRE I PROPRI DATI QUI
# Nome: Simone
# Cognome: Bufalini
# Matricola: 1984850
##########################################

# NON MODIFICARE QUESTA PARTE

.data
    buffer: .space 20
.text
.globl main
#li a0, 0x1003   # Misaligned address (assuming word-aligned memory model)
#lw a1, 0(a0)    # Will fail on strict alignment systems
main:
    li a7, 8       # Code for string input
    la a0, buffer  # Load base address in a0
    li a1, 20      # Allocate at most 20 characters
    ecall          # a0 contains the base address of the string

    
##########################################
## INSERIRE IL PROPRIO CODICE QUI
	
	jal contaOccorrenze
	
	mv a0, a1
	li a7, 1
	ecall
	li a0, 10
	li a7, 11
	ecall
	mv a0, a2
	li a7, 1
	ecall
	li a7, 10
	ecall
	
contaOccorrenze:
	li t0, 1
	li a1, 0
	li a2, 0
	li s1, 10
	li t5, 3
	li t6, 8
	
	lb t2, 0(a0)
    li t3, 10
    beq t2, t3, exit
	
loop:
	add s0, a0, t0
	lb t1, 0(s0)
	beq t1, s1, exit
	addi t1, t1, -48
	bge t1, t5, primo_step
	addi t0, t0, 1
	j loop
	
primo_step:
	ble t1, t6, secondo_step
	addi t0, t0, 1
	j loop
	
secondo_step:
	andi t3, t1, 1
	beqz t3, is_pari
	addi a2, a2, 1
	addi t0, t0, 1
	j loop
	
is_pari:
	addi a1, a1, 1
	addi t0, t0, 1
	j loop
	
exit:
	jr ra