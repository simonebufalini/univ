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

	jal len
	add t0, a0, a2
	addi t0, t0, -1
	li t1, 43
	li t2, 0	# totale
	li t3, 0	# parziale
	li t4, 0	# shift
main_loop:
	blt t0, a0, end_main
	lb t5, 0(t0)
	beq t5, t1, end_group
	addi t5, t5, -48
	sll t5, t5, t4
	add t3, t3, t5
	addi t4, t4, 1
	addi t0, t0, -1
	j main_loop
end_group:
	add t2, t2, t3
	li t4, 0
	li t3, 0
	addi t0, t0, -1
	j main_loop
end_main:
	beq t4, zero, end
	add t2, t2, t3
end:
	mv a0, t2
	li a7, 1
	ecall
	li a7, 10
	ecall
len:
	li t0, 0
	li t1, 10
loop:
	add t2, a0, t0
	lb t3, 0(t2)
	beq t3, t1, end_loop
	addi t0, t0, 1
	j loop
end_loop:
	mv a2, t0
	jr ra