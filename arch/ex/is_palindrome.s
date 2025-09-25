.globl main

.data
message: .asciz "Input: "
msg_false: .asciz "Not palindrome\n"
msg_true: .asciz "Palindrome\n"
buffer: .space 64

.text
main:
	la a0, message
	li a7, 4
	ecall
	li a1, 64
	la a0, buffer
	li a7, 8
	ecall
	jal str_len
	la s0, buffer		#s0 = indirizzo base della stringa
	mv s1, a1		#s1 = lunghezza effettiva (senza \n e \0) ---> non necessario
	li t0, 0		#t0 = offset del primo char
	addi t1, s1, -1		#t1 = offset dell'ultimo char (lunghezza - 1)
main_loop:
	bge t0, t1, exit
	add t2, s0, t0
	add t3, s0, t1
	lbu t2, 0(t2)
	lbu t3, 0(t3)
	bne t2, t3, false
	addi t0, t0, 1
	addi t1, t1, -1
	j main_loop
false:
	la a0, msg_false
	li a7, 4
	ecall
	li a7, 10
	ecall
exit:
	la a0, msg_true
	li a7, 4
	ecall
	li a7, 10
	ecall
str_len:
	mv t0, a0
	mv t1, a1
	li t2, 0
loop:
	beq t2, t1, end_loop
	add t3, t0, t2
	lbu t4, 0(t3)
	beqz t4, end_loop
	addi t2, t2, 1
	j loop
end_loop:
	mv a1, t2
	addi sp, sp, -4
	sw ra, 0(sp)
	jal del_newline
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra
del_newline:
	mv t0, a0
	li t1, 10
	li t2, 0
loop2:
	add t3, a0, t2
	lbu t4, 0(t3)
	beq t4, t1, return
	addi t2, t2, 1
	j loop2
return:
	sb zero, 0(t3)
	mv a1, t2
	jr ra