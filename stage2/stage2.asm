  ;*********************************************
  ;  Stage2.asm
  ;    - Second Stage Bootloader
  ;
  ;  Operating Systems Development Series
  ;*********************************************

bits 16

org 0x500

  jmp	main				; go to start

  ;*******************************************************
  ;	Preprocessor directives
  ;*******************************************************

%include "stdio.asm"			; basic i/o routines
%include "gdt.asm"			; Gdt routines

  ;*******************************************************
  ;	Data Section
  ;*******************************************************

  LoadingMsg db "Preparing to load operating system...hahxx", 0x0D, 0x0A, 0x00
  EnabledA20 db "it has enabled a20", 0dh, 0ah, 0h
  DisabledA20 db "it has disabled a20", 0dh, 0ah, 0h
  NSA20 db "not support for a20", 0dh, 0ah, 0h
  TryMsg db "has try to set a20", 0dh, 0ah, 0h


  ;*******************************************************
  ;	STAGE 2 ENTRY POINT
  ;
  ;		-Store BIOS information
  ;		-Load Kernel
  ;		-Install GDT; go into protected mode (pmode)
  ;		-Jump to Stage 3
  ;*******************************************************

main:

	;-------------------------------;
	;   Setup segments and stack	;
	;-------------------------------;

	cli				; clear interrupts
	xor	ax, ax			; null segments
	mov	ds, ax
	mov	es, ax
	mov	ax, 0x9000		; stack begins at 0x9000-0xffff
	mov	ss, ax
	mov	sp, 0xFFFF
	sti				; enable interrupts

	;-------------------------------;
	;   Print loading message	;
	;-------------------------------;

	mov	si, LoadingMsg
	call	Puts16

	;-------------------------------;
	;   Install our GDT		;
	;-------------------------------;

	call	InstallGDT		; install our GDT

A20Support:
  mov ax, 0x2403
  int 0x15
  jb PrintNSA20
  cmp ah, 0
  jnz PrintNSA20

EnableA20:
  mov ax, 2402h                ;--- A20-Gate Status ---
  int 15h
  jb  PrintDisabledA20              ;couldn't get status
  cmp ah, 0
  jnz PrintDisabledA20
  cmp al, 1
  jz  PrintEnableA20

  mov si, TryMsg
  call Puts16

  mov ax, 0x2401
  int 0x15
  jb PrintDisabledA20
  cmp     ah,0
  jnz  PrintDisabledA20

PrintEnableA20:
  mov si, EnabledA20
  call Puts16
  jmp Pmode

PrintDisabledA20:
  mov si, DisabledA20
  call Puts16
  jmp Pmode

PrintNSA20:
  mov si, NSA20
  call Puts16
  jmp Pmode

	;-------------------------------;
	;   Go into pmode		;
	;-------------------------------;
Pmode:
	cli				; clear interrupts
	mov	eax, cr0		; set bit 0 in cr0--enter pmode
	or	eax, 1
	mov	cr0, eax

	jmp	08h:Stage3		; far jump to fix CS. Remember that the code selector is 0x8!

	; Note: Do NOT re-enable interrupts! Doing so will triple fault!
	; We will fix this in Stage 3.

  ;******************************************************
  ;	ENTRY POINT FOR STAGE 3
  ;******************************************************

bits 32					; Welcome to the 32 bit world!

Stage3:

	;-------------------------------;
	;   Set registers		;
	;-------------------------------;

	mov		ax, 0x10		; set data segments to data selector (0x10)
	mov		ds, ax
	mov		ss, ax
	mov		es, ax
	mov		esp, 90000h		; stack begins from 90000h

  ;*******************************************************
  ;	Stop execution
  ;*******************************************************

STOP:

	cli
	hlt
