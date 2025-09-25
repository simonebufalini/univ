.globl main

.data
input_msg: .asciz "Input: "

.text
main:
    	# Stampa il messaggio "Input: "
    	la a0, input_msg
    	li a7, 4
    	ecall
	
	# Legge un intero da tastiera
    	li a7, 5
	ecall
    	mv a1, a0       # salva input in a1
	
	# Chiamata a fibonacci
    	mv a0, a1       # carica input in a0 (parametro funzione)
    	jal ra, fibonacci
	
    	# Stampa il risultato (in a0)
    	li a7, 1
    	ecall

    	# Termina il programma
    	li a7, 10
    	ecall

# Funzione ricorsiva: fibonacci(n)
# Parametro: a0
# Ritorna: a0 = fib(n)
fibonacci:
    	addi sp, sp, -12     # spazio per ra, a0, temporanei
    	sw ra, 8(sp)
    	sw a0, 4(sp)

    	li t0, 2
    	blt a0, t0, base_case   # se n < 2 → caso base
	
    	# calcola fib(n-1)
    	addi a0, a0, -1
    	jal ra, fibonacci
    	sw a0, 0(sp)        # salva fib(n-1)
	
    	# carica n originale
    	lw a0, 4(sp)
    	addi a0, a0, -2
    	jal ra, fibonacci   # calcola fib(n-2)
		    	
    	# somma i risultati
	lw t1, 0(sp)        # fib(n-1)
	add a0, a0, t1      # fib(n) = fib(n-1) + fib(n-2)
	
    	# ripristina stack e ritorna
    	lw ra, 8(sp)
    	addi sp, sp, 12
    	jr ra

base_case:
    	li a0, 1
    	lw ra, 8(sp)
    	addi sp, sp, 12
    	jr ra
