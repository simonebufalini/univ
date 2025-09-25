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
	