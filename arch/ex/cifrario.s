.globl main

.data
buffer: .space 0x1A
len: .word 0x18
code: .word 0x06

.text
main:
	la a0, buffer
	la t0, len
	la t1, code
	lw a1, 0x00(t0)
	lw a2, 0x00(t1)
	li a7, 0x08
	ecall
	jal decode
	li a7, 0x04
	ecall
	li a7, 0x0A
	ecall
decode:
	li s0, 0x41
	li s1, 0x61
	sub s2, s1, a2
	li t0, 0x1A			# lettere alfabeto
	li t1, 0x0A			# newline
	li t2, 0x20			# spazio
	li t3, 0x00			# contatore
loop:
	add t4, a0, t3
	lb t5, 0x00(t4)
	beq t5, t1, end_loop
	beq t5, t2, skip_char
	sub t5, t5, a2
	blt t5, s0, upper_case_correction
	blt t5, s1, lower_case_correction
	sb t5, 0(t4)
	addi t3, t3, 0x01
	j loop
upper_case_correction:
	add t5, t5, t0
	sb t5, 0(t4)
	addi t3, t3, 0x01
	j loop
lower_case_correction:
	blt t5, s2, no_correction
	add t5, t5, t0
no_correction:
	sb t5, 0(t4)
	addi t3, t3, 0x01
	j loop
skip_char:
	addi t3, t3, 0x01
	j loop
end_loop:
	jr ra