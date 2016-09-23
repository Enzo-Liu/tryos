%ifndef __A20_ASM_67343546FDCC56AAB872_INCLUDED__
%define __A20_ASM_67343546FDCC56AAB872_INCLUDED__

bits	16

  EnabledA20 db "it has enabled a20", 0dh, 0ah, 0h
  DisabledA20 db "it has disabled a20", 0dh, 0ah, 0h
  NSA20 db "not support for a20", 0dh, 0ah, 0h
  TryMsg db "has try to set a20", 0dh, 0ah, 0h

InstallA20:
  pusha                         ; save registers

A20Support:
  mov  ax, 0x2403
  int  0x15
  jb   PrintNSA20
  cmp  ah, 0
  jnz  PrintNSA20

EnableA20:
  mov  ax, 2402h                ;--- A20-Gate Status ---
  int  15h
  jb   PrintDisabledA20         ;couldn't get status
  cmp  ah, 0
  jnz  PrintDisabledA20
  cmp  al, 1
  jz   PrintEnableA20

  mov  si, TryMsg
  call Print16

  mov  ax, 0x2401
  int  0x15
  jb   PrintDisabledA20
  cmp  ah,0
  jnz  PrintDisabledA20

PrintEnableA20:
  mov  si, EnabledA20
  call Print16
  jmp  A20Done

PrintDisabledA20:
  mov  si, DisabledA20
  call Print16
  jmp  A20Done

PrintNSA20:
  mov  si, NSA20
  call Print16
  jmp  A20Done

A20Done:
  popa
  ret

%endif ;__A20_ASM_67343546FDCC56AAB872_INCLUDED__
