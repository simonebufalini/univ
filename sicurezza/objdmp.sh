#!/bin/bash

# estrai i byte
objdump -d bin/zsh_shellcode | grep -Po '\s\K[a-f0-9]{2}(?=\s)' | sed 's/^/\\x/g' | paste -sd ''
