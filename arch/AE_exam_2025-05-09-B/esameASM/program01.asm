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

	li s1, 10						# carattere '\n'
	li s2, 47						# carattere '/'
	li t0, -1						# offset carattere
	mv s3, a0						# sposto il base address (mi serve a0 per stampare)
	
setup:
	li s0, 0						# accumulatore somma
	li t1, 1						# contatore coppia
loop:
	addi t0, t0, 1
	add s4, s3, t0					# address = base + offset
	lb t2, 0(s4)					# carico carattere
	beq t2, s1, print_and_exit		# se '\n' allora stampa ed esci
	beq t2, s2, end_number			# se '/' allora stampa e vai a capo
	addi t3, t2, -48				# conversione in numero
	sll t3, t3, t1					# shift sinistro della cifra binaria
	add s0, s0, t3					# accumulo il valore
	beq t1, zero, end_digit			# se seconda cifra binaria, stampo il valore decimale
	addi t1, t1, -1					# riduco contatore coppia
	j loop
	
end_digit:
	mv a0, s0						# sposta in a0 la somma
	li a7, 1						# stampa
	ecall
	j setup
	
end_number:
	bge t1, zero, new_line			# se non ho letto esattamente due cifre binarie, vai solo a capo
	mv a0, s0						# altrimenti stampa la cifra decimale
	li a7, 1
	ecall
new_line:
	mv a0, s1						# sposta il newline in a0
	li a7, 11						# stampa
	ecall
	j setup
	
print_and_exit:
	bge t1, zero, exit				# se non ho letto esattamente due cifre binarie, esci subito
	mv a0, s0						# altrimenti stampa la cifra decimale
	li a7, 1
	ecall
exit:
	li a7, 10
	ecall