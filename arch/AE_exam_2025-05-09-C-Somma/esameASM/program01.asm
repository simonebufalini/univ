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
    li a7, 8         # Codice per input stringa
    la a0, buffer    # Carica indirizzo base in $a0
    li a1, 26        # Alloca al massimo 24 caratteri + \n + \0
    ecall            # $a0 contiene l'indirizzo base della stringa
# ... A QUI

##########################################
## INSERIRE IL PROPRIO CODICE QUI
    la t0, buffer       		# puntatore
    li t2, 0            		# totale
    li t3, 0            		# parziale
    li t4, 43           		# '+'
    li t5, 10           		# '\n'
read_loop:
    lb t1, 0(t0)        		# carica byte
    beq t1, t5, end     		# se '\n', termina
    beq t1, t4, add_partial  	# se '+', aggiungi il valore parziale al totale
    addi t1, t1, -48    		# converti
    slli t3, t3, 1      		# parziale <<= 1
    add t3, t3, t1      		# parziale += bit corrente
    addi t0, t0, 1
    j read_loop
add_partial:
    add t2, t2, t3      		# totale += parziale
    li t3, 0            		# reset parziale
    addi t0, t0, 1
    j read_loop
end:
    add t2, t2, t3
    mv a0, t2
    li a7, 1
    ecall
