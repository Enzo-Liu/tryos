  ;*************************************************
  ;	stdio.inc
  ;		-Input/Output routines
  ;
  ;	OS Development Series
  ;*************************************************

%ifndef __STDIO_INC_67343546FDCC56AAB872_INCLUDED__
%define __STDIO_INC_67343546FDCC56AAB872_INCLUDED__

  ;************************************************;
  ;	Puts16 ()
  ;		-Prints a null terminated string
  ;	DS=>SI: 0 terminated string
  ;************************************************;

bits	16

Puts16:
  pusha				; save registers
.Loop1:
  lodsb				; load next byte from string from SI to AL
  or	al, al			; Does AL=0?
  jz	Puts16Done		; Yep, null terminator found-bail out
  mov	ah, 0eh			; Nope-Print the character
  int	10h			; invoke BIOS
  jmp	.Loop1			; Repeat until null terminator found
Puts16Done:
  popa				; restore registers
  ret				; we are done, so return

bits 32
%define	VIDMEM	0xB8000		; video memory
%define		COLS	80			; width and height of screen
%define		LINES	25
%define		CHAR_ATTRIB 14			; character attribute (White text on black background)

  _CurX db 0					; current x/y location
  _CurY db 0

Putch32:
  pusha
	mov	edi, VIDMEM		; get pointer to video memory
  xor eax, eax

  mov cl, COLS
  mov al, byte [_CurY]
  mul cl
  mov ecx, eax

  xor eax, eax
  mov al, byte [_CurX]

  add eax, ecx
  mov ecx, 2
  mul ecx

	add	edi, eax

  cmp	bl, 0x0A		; is it a newline character?
	je	.Row			; yep--go to next row

  mov	dl, bl			; Get character
	mov	dh, CHAR_ATTRIB		; the character attribute
	mov	word [edi], dx

  inc byte [_CurX]
  cmp	byte [_CurX], COLS		; are we at the end of the line?
	je	.Row			; yep-go to next row
	jmp	.Done

.Row:
  mov byte [_CurX], 0
  inc byte [_CurY]

.Done:
  popa
  ret

Puts32:
  pusha
  mov edi, ebx
  xor ebx, ebx

.loop:
	mov	bl, byte [edi]		; get next character
	cmp	bl, 0			; is it 0 (Null terminator)?
	je	.done
  call	Putch32

.Next:
	inc	edi			; go to next character
	jmp	.loop

.done:

	; mov	bh, byte [_CurY]	; get current position
	; mov	bl, byte [_CurX]
	; call	MovCur			; update cursor

	popa				; restore registers, and return
	ret

Clr32:
  pusha
	cld
	mov	edi, VIDMEM
	mov	cx, 2000
	mov	ah, CHAR_ATTRIB
	mov	al, ' '
	rep	stosw

	mov	byte [_CurX], 0
	mov	byte [_CurY], 0
	popa
	ret

%endif ;__STDIO_INC_67343546FDCC56AAB872_INCLUDED__
