##########################################
# INSERIRE I PROPRI DATI QUI
# Nome: Simone
# Cognome: Bufalini
# Matricola: 1984850
##########################################

# NON MODIFICARE IL CODICE DA QUI...
.data
    buffer: .space 26

.text

main:
    li a7, 8       # Codice per input stringa
    la a0, buffer  # Carica indirizzo base in $a0
    li a1, 26      # Alloca al massimo 24 caratteri + \n + \0
    ecall          # $a0 contiene l'indirizzo base della stringa
# ... A QUI

##########################################
## INSERIRE IL PROPRIO CODICE QUI

	li s1, 10
	li s2, 47
	li t0, 0
	mv a1, a0
	
setup:
	li s0, 0
	li t1, 2
	
loop:
	add s3, a1, t0
	lb t3, 0(s3)
	beq t3, s1, print_and_exit
	addi t0, t0, 1
	beq t3, s2, end_number
	addi t4, t3, -48
	sll t5, t4, t1
	add s0, s0, t5
	addi t1, t1, -1
	blt t1, zero, end_digit
	j loop
	
end_digit:
	mv a0, s0
	li a7, 1
	ecall
	j setup
	
end_number:
	bge t1, zero, newline
	mv a0, s0
	li a7, 1
	ecall
	
newline:
	mv a0, s1
	li a7, 11
	ecall
	j setup
	
print_and_exit:
	bne t1, zero, exit
	mv a0, s0
	li a7, 1
	ecall
	
exit:
	li a7, 10
	ecall
	