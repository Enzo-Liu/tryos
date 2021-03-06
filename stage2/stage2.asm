  ;*********************************************
  ;  Stage2.asm
  ;    - Second Stage Bootloader
  ;
  ;  Operating Systems Development Series
  ;*********************************************

bits 16

org 0x500                       ; loaded at (0x50:0x00) 0x50*0x10+0x00 = 0x500

  jmp       main                ; go to start

  ;***********************       *
  ; Preprocessor directives
  ;*******************************************************

%include "print16.asm"
%include "stdio.asm"
%include "gdt.asm"
%include "a20.asm"

  ;*******************************************************
  ; Data Section
  ;*******************************************************

LoadingMsg: db "Preparing to load operating system...hahxx", 0x0D, 0x0A, 0x00
msg:
  db        0ah, 0ah, "    try the video text mode"
  db        0ah, 0ah, "         ha ha ha       ", 0


  ;*******************************************************
  ; STAGE 2 ENTRY POINT
  ;
  ;   -Store BIOS information
  ;   -Load Kernel
  ;   -Install GDT; go into protected mode (pmode)
  ;   -Jump to Stage 3
  ;*******************************************************

main:

  ;-------------------------------;
  ;   Setup segments and stack  ;
  ;-------------------------------;

  cli                           ; clear interrupts
  xor       ax, ax              ; null segments
  mov       ds, ax
  mov       es, ax
  mov       ax, 0x9000          ; stack begins at 0x9000-0xffff
  mov       ss, ax
  mov       sp, 0xFFFF
  sti                           ; enable interrupts

  ;-------------------------------;
  ;   Print loading message ;
  ;-------------------------------;

  mov       si, LoadingMsg
  call      Print16

  ;-------------------------------;
  ;   Install our GDT   ;
  ;-------------------------------;

  call      InstallGDT          ; install our GDT
  call      InstallA20          ; install A20 line

  ;-------------------------------;
  ;   Go into pmode   ;
  ;-------------------------------;
Pmode:
  cli                           ; clear interrupts
  mov       eax, cr0            ; set bit 0 in cr0--enter pmode
  or        eax, 1
  mov       cr0, eax

  jmp       08h:Stage3 ; far jump to fix CS. Remember that the code selector is 0x8!

  ; Note: Do NOT re-enable interrupts! Doing so will triple fault!
  ; We will fix this in Stage 3.

  ;******************************************************
  ; ENTRY POINT FOR STAGE 3
  ;******************************************************

bits 32         ; Welcome to the 32 bit world!

Stage3:

  ;-------------------------------;
  ;   Set registers   ;
  ;-------------------------------;

  mov       ax, 0x10            ; set data segments to data selector (0x10)
  mov       ds, ax
  mov       ss, ax
  mov       es, ax
  mov       esp, 90000h         ; stack begins from 90000h

  call      Clr32

  mov       ebx, msg
  call      Puts32

  ;*******************************************************
  ; Stop execution
  ;*******************************************************

STOP:
  cli
  hlt
