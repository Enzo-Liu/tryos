%ifndef __PRINT_16_ASM_INCLUDED__
%define __PRINT_16_ASM_INCLUDED__

bits 16

Print16:
  pusha				; save registers
.Loop1:
  lodsb				; load next byte from string from SI to AL
  or	al, al			; Does AL=0?
  jz	Print16Done		; Yep, null terminator found-bail out
  mov	ah, 0eh			; Nope-Print the character
  int	10h			; invoke BIOS
  jmp	.Loop1			; Repeat until null terminator found
Print16Done:
  popa				; restore registers
  ret				; we are done, so return

%endif ;__PRINT_16_ASM_INCLUDED__
