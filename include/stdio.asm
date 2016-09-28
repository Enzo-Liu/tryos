  ;*************************************************
  ;	stdio.inc
  ;		-Input/Output routines
  ;
  ;	OS Development Series
  ;*************************************************

%ifndef __STDIO_INC_67343546FDCC56AAB872_INCLUDED__
%define __STDIO_INC_67343546FDCC56AAB872_INCLUDED__

bits 32

%define	VIDMEM	0xB8000         ; video memory
%define		COLS	80              ; width and height of screen
%define		LINES	25
%define		CHAR_ATTRIB 14  ; character attribute (White text on black background)

_CurX:  db 0                    ; current x/y location
_CurY:  db 0

Putch32:
  pusha

  xor       eax, eax

  mov       cl, COLS
  mov       al, byte [_CurY]
  mul       cl
  mov       cx, ax

  xor       ah, ah
  mov       al, byte [_CurX]

  add       ax, cx
  mov       cx, 2
  mul       cx

  ; pointer is (x + y * cols) * 2 + base
	mov       edi, VIDMEM
	add       edi, eax

  cmp       bl, 0x0A            ; is it a newline character?
	je        .Row                ; yep--go to next row

  mov       dl, bl              ; Get character
	mov       dh, CHAR_ATTRIB     ; the character attribute
	mov       word [edi], dx

  inc       byte [_CurX]
  cmp       byte [_CurX], COLS  ; are we at the end of the line?
	je        .Row                ; yep-go to next row
	jmp       .Done

.Row:
  mov       byte [_CurX], 0
  inc       byte [_CurY]

.Done:
  popa
  ret

Puts32:
  pusha
  mov       edi, ebx
  xor       ebx, ebx

.loop:
	mov       bl, byte [edi]      ; get next character
	cmp       bl, 0               ; is it 0 (Null terminator)?
	je        .done
  call      Putch32

.Next:
	inc       edi                 ; go to next character
	jmp       .loop

.done:

	mov       bh, byte [_CurY]    ; get current position
	mov       bl, byte [_CurX]
	call      MovCur              ; update cursor

	popa				; restore registers, and return
	ret

MovCur:

	pusha

	xor       eax, eax
	mov       ecx, COLS
	mov       al, bh              ; get y pos
	mul       ecx                 ; multiply y*COLS
	add       al, bl              ; Now add x
	mov       ebx, eax

	;--------------------------------------;
	;   Set low byte index to VGA register ;
	;--------------------------------------;

	mov       al, 0x0f            ; Cursor location low byte index
	mov       dx, 0x03D4          ; Write it to the CRT index register
	out       dx, al

	mov       al, bl ; The current location is in EBX. BL contains the low byte, BH high byte
	mov       dx, 0x03D5          ; Write it to the data register
	out       dx, al              ; low byte

	;---------------------------------------;
	;   Set high byte index to VGA register ;
	;---------------------------------------;

	xor       eax, eax

	mov       al, 0x0e            ; Cursor location high byte index
	mov       dx, 0x03D4          ; Write to the CRT index register
	out       dx, al

	mov       al, bh ; the current location is in EBX. BL contains low byte, BH high byte
	mov       dx, 0x03D5          ; Write it to the data register
	out       dx, al              ; high byte

	popa
	ret

Clr32:
  pusha
	cld                           ; clear direction --- make sure the direction is increasing
	mov       edi, VIDMEM
	mov       cx, 2000            ; COLS * LINES = 80 * 25 = 2000
	mov       ah, CHAR_ATTRIB
	mov       al, ' '
  ; stosw: store string word
	rep       stosw ; repeat cx times to copy value in ax to edi:VIDMEM-(VIDMEM+2000)

	mov       byte [_CurX], 0
	mov       byte [_CurY], 0
	popa
	ret

%endif ;__STDIO_INC_67343546FDCC56AAB872_INCLUDED__
