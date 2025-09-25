.globl main

.data
input_msg: .asciz "Input: "
output_msg: .asciz "Factorial: "

.text
main:
    	la a0, input_msg
    	li a7, 4
    	ecall
    	
    	li a7, 5
    	ecall              # Legge input in a0
    	
    	jal factorial      # Chiama factorial
    	
    	# Stampa risultato
	mv a1, a0          # Salva risultato
    	li a7, 4
    	la a0, output_msg
    	ecall              # Stampa "Factorial: "
    	
    	mv a0, a1
    	li a7, 1
    	ecall              # Stampa il numero
    	
    	li a7, 10
    	ecall              # Exit

factorial:
    	beqz a0, base      # 1. Controllo caso base
    	addi sp, sp, -8    # 2. Alloca stack
    	sw ra, 0(sp)       # 3. Salva return address
    	sw a0, 4(sp)       # 4. Salva n corrente
    	addi a0, a0, -1    # 5. Decrementa n
    	jal factorial      # 6. Chiamata ricorsiva
    	
    	# Punto di ritorno (dopo jal)
    	mv a1, a0         # 7. Sposta risultato
    	lw a0, 4(sp)      # 8. Ripristina n
    	lw ra, 0(sp)      # 9. Ripristina ra
    	addi sp, sp, 8    # 10. Dealloca stack
    	mul a0, a0, a1    # 11. Calcola n*fact(n-1)
    	jr ra             # 12. Ritorna al chiamante

base:
    	li a0, 1          # Caso base: fact(0)=1
    	ret               # Equivale a jr ra
