##########################################
# INSERIRE I PROPRI DATI QUI
# Nome: Simone
# Cognome: Bufalini
# Matricola: 1984850
##########################################

# NON MODIFICARE IL CODICE DA QUI...
.data
    buffer: .space 26
    output: .byte  0,0,0,0,0,0,0,0,0  # Un carattere extra per la fine della stringa

.text

main:
    li a7, 8       # Codice per input stringa
    la a0, buffer  # Carica indirizzo base in $a0
    li a1, 26      # Alloca al massimo 24 caratteri + \n + \0
    ecall          # $a0 contiene l'indirizzo base della stringa
    la a2, output
# ... A QUI

##########################################
## INSERIRE IL PROPRIO CODICE QUI

    jal codificaOttale
    # stampa output
    mv a0, a2
    li a7, 4
    ecall
    #stampa newline
    li a0, 10
    li a7, 11
    ecall
    # stampa padding
  	mv a0, a3
  	li a7, 1
  	ecall
  	# stampa newline
  	li a0, 10
    li a7, 11
    ecall
  	# stampa numero cifre ottali
  	mv a0, a4
  	li a7, 1
  	ecall
  	#esci
    li a7, 10
    ecall
    
codificaOttale:
	li s0, 10	# '\n'
	li t0, 0	# indice input
	li t1, 0	# indice output
	li t2, 2	# shift
	li t3, 0	# somma ottale
loop:
	add s1, a0, t0
	lb t4, 0(s1)
	beq t4, s0, esci
	addi t4, t4, -48
	sll t4, t4, t2
	add t3, t3, t4
	beq t2, zero, fineTerzina
	addi t0, t0, 1
	addi t2, t2, -1
	j loop
fineTerzina:
	addi t3, t3, 48
	add s2, a2, t1
	sb t3, 0(s2)
	addi t0, t0, 1
	addi t1, t1, 1
	li t2, 2
	li t3, 0
	j loop
esci:
	li s4, 2
	beq t2, s4, esciSubito
	li a3, 1
	addi t3, t3, 48
	add s2, a2, t1
	sb t3, 0(s2)
	addi t1, t1, 1
esciSubito:
	add s2, a2, t1
	sb zero, 0(s2)
	mv a4, t1
	jr ra
	