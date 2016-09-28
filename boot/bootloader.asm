bits  16            ; we are in 16 bit real mode

org  0            ; we will set regisers later

start:  jmp  main          ; jump to start of bootloader

  ;*********************************************
  ;  BIOS Parameter Block
  ;*********************************************

  ; BPB Begins 3 bytes from start. We do a far jump, which is 3 bytes in size.
  ; If you use a short jump, add a "nop" after it to offset the 3rd byte.

bpbOEM: db "TRY OS  "      ; OEM identifier (Cannot exceed 8 bytes!)
bpbBytesPerSector:    DW 512
bpbSectorsPerCluster:   DB 1
bpbReservedSectors:   DW 1
bpbNumberOfFATs:   DB 2
bpbRootEntries:   DW 224
bpbTotalSectors:   DW 2880
bpbMedia:     DB 0xf8  ;; 0xF1
bpbSectorsPerFAT:   DW 9
bpbSectorsPerTrack:   DW 18
bpbHeadsPerCylinder:   DW 2
bpbHiddenSectors:   DD 0
bpbTotalSectorsBig:     DD 0
bsDriveNumber:           DB 0
bsUnused:     DB 0
bsExtBootSignature:   DB 0x29
bsSerialNumber:          DD 0xa0a1a2a3
bsVolumeLabel:           DB "TOS FLOPPY "
bsFileSystem:           DB "FAT12   "

ImageName:  db "TRYOS   SYS"
msgCRLF:  db 0x0D, 0x0A, 0x00
msgLoading: db 0x0D, 0x0A, "Loading Boot Image ", 0x0D, 0x0A, 0x00
msgProgress:  db ".", 0x00
msgFailure: db 0x0D, 0x0A, "ERROR : Press Any Key to Reboot", 0x0A, 0x00

%include "print16.asm"
%include "fat12.asm"

  ;************************************************;
  ; Reads a series of sectors
  ; CX=>Number of sectors to read
  ; AX=>Starting sector
  ; ES:BX=>Buffer to read to
  ;************************************************;

main:

  ;----------------------------------------------------
  ; code located at 0000:7C00, adjust segment registers
  ;----------------------------------------------------

  cli            ; disable interrupts
  mov     ax, 0x07C0        ; setup registers to point to our segment
  mov     ds, ax
  mov     es, ax
  mov     fs, ax
  mov     gs, ax

  ;----------------------------------------------------
  ; create stack
  ;----------------------------------------------------

  mov     ax, 0x0000        ; set the stack
  mov     ss, ax
  mov     sp, 0xFFFF
  sti            ; restore interrupts

  ;----------------------------------------------------
  ; Load root directory table
  ;----------------------------------------------------
  call LOAD_ROOT
  jc REBOOT

  mov     si, msgCRLF
  call    Print16

  ; test with call 0x50:0x00, seems to be the same
  ; since call will push current address in the stack
  ; maybe jmp is more appropriate
  jmp 0x50:0x00
  ; I don't really get the pointer why to use retf, so
  ; comment it out and test with jmp
  ; push    WORD 0x0050
  ; push    WORD 0x0000
  ; retf

REBOOT:
  mov     si, msgFailure
  call    Print16

  mov     ah, 0x00
  int     0x16                                ; await keypress
  int     0x19                                ; warm boot computer


  TIMES 510-($-$$) DB 0
  DW 0xAA55
