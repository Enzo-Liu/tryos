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
%include "a20.asm"

  ;*******************************************************
  ;	Data Section
  ;*******************************************************

  LoadingMsg db "Preparing to load operating system...hahxx", 0x0D, 0x0A, 0x00

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
  call  InstallA20    ; install A20 line


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
%define	VIDMEM	0xB8000		; video memory
%define		COLS	80			; width and height of screen
%define		LINES	25
%define		CHAR_ATTRIB 14			; character attribute (White text on black background)

Stage3:

	;-------------------------------;
	;   Set registers		;
	;-------------------------------;

	mov		ax, 0x10		; set data segments to data selector (0x10)
	mov		ds, ax
	mov		ss, ax
	mov		es, ax
	mov		esp, 90000h		; stack begins from 90000h

	mov	edi, VIDMEM		; get pointer to video memory
	mov	byte [edi], 'A'		; print character 'A'
	mov	byte [edi+1], 0x7		; character attribute
	mov	byte [edi+2], 'B'		; print character 'A'
	mov	byte [edi+3], 0x7		; character attribute
  ;*******************************************************
  ;	Stop execution
  ;*******************************************************

STOP:

	cli
	hlt
