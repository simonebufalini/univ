CC=gcc
CFLAGS=-m32 -no-pie -g -z execstack -fno-stack-protector -fno-pie -mpreferred-stack-boundary=2
SRC=src/vuln.c
OUT=bin/vuln

SHELLCODE_SRC=src/shellcode.asm
SHELLCODE_OBJ=build/shellcode.o
SHELLCODE_BIN=bin/zsh_shellcode

all: $(OUT)

$(OUT): $(SRC)
	@mkdir -p bin
	$(CC) $(CFLAGS) -o $@ $<

#assembla shellcode
$(SHELLCODE_OBJ): $(SHELLCODE_SRC)
	@mkdir -p build
	nasm -f elf32 -o $@ $<

#link shellcode
$(SHELLCODE_BIN): $(SHELLCODE_OBJ)
	@mkdir -p bin
	ld -m elf_i386 -o $@ $<

#target per compilare lo shellcode
shellcode: $(SHELLCODE_BIN)


clean:
	rm -f $(OUT) $(SHELLCODE_OBJ) $(SHELLCODE_BIN)
	rm -rf build

disable-aslr:
	@echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
	@echo "ASLR disabled"

enable-aslr:
	@echo 2 | sudo tee /proc/sys/kernel/randomize_va_space
	@echo "ASLR enabled"

status-aslr:
	@echo -n "current ASLR: "
	@cat /proc/sys/kernel/randomize_va_space

.PHONY: all clean disable-aslr enable-aslr status-aslr shellcode extract-shellcode
