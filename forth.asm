; *******************************************************************
; *** This software is copyright 2006 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************

;[RLA] These are defined on the rcasm command line!
;[RLA] #define ELFOS            ; build the version that runs under Elf/OS
;[RLA] #define STGROM           ; build the STG EPROM version
;[RLA] #define PICOROM          ; define for Mike's PIcoElf version

;[RLA]   rcasm doesn't have any way to do a logical "OR" of assembly
;[RLA} options, so define a master "ANYROM" option that's true for
;[RLA} any of the ROM conditions...
	
	;; [gnr] Bug fixes, assembler fixes,and the Exec word

#ifdef MCHIP
#define ANYROM
#define    CODE    02000h
xopenw:    equ     07006h
xopenr:    equ     07009h
xread:     equ     0700ch
xwrite:    equ     0700fh
xclosew:   equ     07012h
xcloser:   equ     07015h
buffer:    equ     08200h
himem:     equ     08300h
rstack:    equ     08302h
tos:       equ     08304h
freemem:   equ     08306h
fstack:    equ     08308h
jump:      equ     0830ah
storage:   equ     0830dh
basen:     equ     08317h
rseed:     equ     082f0h               ; note this limits size of buffer at 8200h to 240 bytes
stack:     equ     081ffh
exitaddr:  equ     07003h
#endif

#ifdef PICOROM
#define ANYROM
#define    CODE    0a000h
xopenw:    equ     08006h
xopenr:    equ     08009h
xread:     equ     0800ch
xwrite:    equ     0800fh
xclosew:   equ     08012h
xcloser:   equ     08015h
buffer:    equ     0200h
himem:     equ     300h
rstack:    equ     302h
tos:       equ     304h
freemem:   equ     306h
fstack:    equ     308h
jump:      equ     30ah
storage:   equ     30dh
basen:     equ     317h
rseed:     equ     02f0h               ; note this limits size of buffer at 200h to 240 bytes
stack:     equ     01ffh
exitaddr:  equ     08003h
#endif

; [GDJ] build: asm02 -i -L -DSTGROM forth.asm
#ifdef STGROM
#define    ANYROM 1
	include config.inc
#define CODE FORTH  		; [gnr] [GDG] says now bigger than 15 pages
	; [gnr] The UART is used in inkey so when using bitbang, no inkey!
#define    UART_SELECT   6             ; UART register select I/O port
#define    UART_DATA     7             ; UART data I/O port


;[RLA] XMODEM entry vectors for the STG EPROM ...
xopenw:    equ     XMODEM + 0*3
xopenr:    equ     XMODEM + 1*3
xread:     equ     XMODEM + 2*3
xwrite:    equ     XMODEM + 3*3
xclosew:   equ     XMODEM + 4*3
xcloser:   equ     XMODEM + 5*3
buffer:    equ     0200h
himem:     equ     300h
rstack:    equ     302h
tos:       equ     304h
freemem:   equ     306h
fstack:    equ     308h
jump:      equ     30ah
storage:   equ     30dh
basen:     equ     317h
rseed:     equ     02f0h               ; note this limits size of buffer at 200h to 240 bytes
stack:     equ     01ffh
exitaddr:  equ     08003h
#endif

#ifdef ELFOS
#define    CODE    02000h
stack:     equ     00ffh
exitaddr:  equ     o_wrmboot
#endif

include    bios.inc

#ifdef ELFOS
include    kernel.inc
           org     8000h
           lbr     0ff00h
           db      'rcforth',0
           dw      9000h
           dw      endrom+7000h
           dw      2000h
           dw      endrom-2000h
           dw      2000h
           db      0
#endif

;  R2   - program stack
;  R3   - Main PC
;  R4   - standard call
;  R5   - standard ret
;  R6   - used by Scall/Sret linkage
;  R7   - general and command table pointer
;  R9   - Data segment
;  RB   - general SCRT return usage and token stream pointer

FWHILE:    equ     81h
FREPEAT:   equ     FWHILE+1
FIF:       equ     FREPEAT+1
FELSE:     equ     FIF+1
FTHEN:     equ     FELSE+1
FVARIABLE: equ     FTHEN+1
FCOLON:    equ     FVARIABLE+1
FSEMI:     equ     FCOLON+1
FDUP:      equ     FSEMI+1
FDROP:     equ     FDUP+1
FSWAP:     equ     FDROP+1
FPLUS:     equ     FSWAP+1
FMINUS:    equ     FPLUS+1
FMUL:      equ     FMINUS+1
FDIV:      equ     FMUL+1
FDOT:      equ     FDIV+1              ; 90h
FUDOT:     equ     FDOT+1
FI:        equ     FUDOT+1
FAND:      equ     FI+1
FOR:       equ     FAND+1
FXOR:      equ     FOR+1
FCR:       equ     FXOR+1
FMEM:      equ     FCR+1
FDO:       equ     FMEM+1
FLOOP:     equ     FDO+1
FPLOOP:    equ     FLOOP+1
FEQUAL:    equ     FPLOOP+1
FUNEQUAL:  equ     FEQUAL+1
FLESS:     equ     FUNEQUAL+1          ; [GDJ]
FULESS:    equ     FLESS+1             ; [GDJ]
FBEGIN:    equ     FULESS+1
FUNTIL:    equ     FBEGIN+1            ; a0h
FRGT:      equ     FUNTIL+1
FGTR:      equ     FRGT+1
FRAT:      equ     FGTR+1              ; [GDJ]
FWORDS:    equ     FRAT+1
FEMIT:     equ     FWORDS+1
FEMITP:    equ     FEMIT+1             ; [GDJ]
FDEPTH:    equ     FEMITP+1
FROT:      equ     FDEPTH+1
FMROT:     equ     FROT+1
FOVER:     equ     FMROT+1
FAT:       equ     FOVER+1
FEXCL:     equ     FAT+1
FCAT:      equ     FEXCL+1
FCEXCL:    equ     FCAT+1
FCMOVE:    equ     FCEXCL+1            ; [GDJ]
FDOTQT:    equ     FCMOVE+1            ; b0h
FKEY:      equ     FDOTQT+1
FKEYQ:     equ     FKEY+1              ; [GDJ]
FALLOT:    equ     FKEYQ+1
FERROR:    equ     FALLOT+1
FSEE:      equ     FERROR+1
FFORGET:   equ     FSEE+1
FEXEC:	   equ     FFORGET+1
FLIST:	   equ     FEXEC+1
FDOTX:	   equ     FLIST+1

T_NUM:     equ     255
T_ASCII:   equ     254

           org     CODE

#ifdef ELFOS
           br      start
include    date.inc
include    build.inc
           db      'Written by Michael H. Riley',0
#endif

#ifdef     ANYROM
           lbr     new
notnew:	
           mov     r2,stack
           mov     r6,old
           lbr     f_initcall
new:       mov     r2,stack
           mov     r6,start
           lbr     f_initcall
#endif

start:     ldi     high himem          ; get page of data segment
           phi     r9                  ; place into r9
#ifdef ANYROM
           ldi     0ch                 ; form feed
           sep     scall               ; clear screen
#ifdef ELFOS
           dw      o_type
#else
           dw      f_type
#endif
#endif
           ldi     high hello          ; address of signon message
           phi     rf                  ; place into r6
           ldi     low hello
           plo     rf
           sep     scall               ; call bios to display message
#ifdef ELFOS
           dw      o_msg
#else
           dw      f_msg               ; function to display a message
#endif

; ************************************************
; **** Determine how much memory is installed ****
; ************************************************
#ifdef ELFOS
           mov     rf,0442h            ; point to high memory pointer
           lda     rf                  ; retrieve it
           phi     rb
           lda     rf
           plo     rb
#else
           sep     scall               ; ask BIOS for memory size
           dw      f_freemem
           mov     rb,rf
#endif

           ldi     low freemem         ; free memory pointer
           plo     r9                  ; place into data pointer
           ldi     storage.1
           str     r9
           inc     r9
           ldi     storage.0
           str     r9

;memlp:     ldi     0                   ; get a zero
;           str     rb                  ; write to memory
;           ldn     rb                  ; recover retrieved byte
;           bnz     memdone             ; jump if not same
;           ldi     255                 ; another value
;           str     rb                  ; write to memory
;           ldn     rb                  ; retrieve it
;           smi     255                 ; compare against written
;           bnz     memdone             ; jump if not same
;           ghi     rb
;           adi     1                   ; point to next page
;           phi     rb                  ; and put it back
;           smi     7fh                 ; prevent from going over 7f00h
;           bnz     memlp
memdone:   ldi     low himem           ; memory pointer
           plo     r9                  ; place into r9
           ghi     rb                  ; get high of last memory
           str     r9                  ; write to data
           phi     r2                  ; and to machine stack
           inc     r9                  ; point to low byte
           glo     rb                  ; get low of himem
           str     r9                  ; and store
           plo     r2
           ldi     low rstack          ; get return stack address
           plo     r9                  ; select in data segment
           ghi     rb                  ; get hi memory
           smi     1                   ; 1 page lower for forth stack
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     rb                  ; get low byte
           str     r9                  ; and store
           ldi     low tos             ; get stack address
           plo     r9                  ; select in data segment
           ghi     rb                  ; get hi memory
           smi     2                   ; 2 page lower for forth stack
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     rb                  ; get low byte
           str     r9                  ; and store
           ldi     low fstack          ; get stack address
           plo     r9                  ; select in data segment
           ghi     rb                  ; get hi memory
           smi     2                   ; 2 page lower for forth stack
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     rb                  ; get low byte
           str     r9                  ; and store
           ldi     high storage        ; point to storage
           phi     rf
           ldi     low storage
           plo     rf
           ldi     0
           str     rf                  ; write zeroes as storage terminator
           inc     rf
           str     rf
           inc     rf
           str     rf
           inc     rf
           str     rf
           inc     rf

           ; [GDJ] create and initialize BASE variable
           mov     r7, 26
           mov     rc, basev
           mov     rd, freemem
nextbase:  lda     rc
           str     rd
           inc     rd
           dec     r7
           glo     r7
           lbnz    nextbase

#ifdef STGROM
           call    clrstacks           ; [GDJ]
#endif

           ; init 32 bit rng seed
           mov     r7, 012A6h
           mov     rf, rseed
           ghi     r7
           str     rf
           glo     r7
           inc     rf
           str     rf
           
           mov     r7, 0DC40h
           mov     rf, rseed+2
           ghi     r7
           str     rf
           glo     r7
           inc     rf
           str     rf


           lbr     mainlp

old: 	   ldi     high himem	; [gnr] fix up r9 since this might be entry point
	   phi     r9
	   ldi     low himem           ; memory pointer
           plo     r9                  ; place into r9
           lda     r9                  ; retreive high memory
           phi     rb
           phi     r2                  ; and to machine stack
           lda     r9
           plo     rb
           plo     r2
           ldi     low rstack          ; get return stack address
           plo     r9                  ; select in data segment
           ghi     rb                  ; get hi memory
           smi     1                   ; 1 page lower for forth stack
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     rb                  ; get low byte
           str     r9                  ; and store
           ldi     low tos             ; get stack address
           plo     r9                  ; select in data segment
           ghi     rb                  ; get hi memory
           smi     2                   ; 2 page lower for forth stack
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     rb                  ; get low byte
           str     r9                  ; and store
           ldi     low fstack          ; get stack address
           plo     r9                  ; select in data segment
           ghi     rb                  ; get hi memory
           smi     2                   ; 2 page lower for forth stack
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     rb                  ; get low byte
           str     r9                  ; and store

; *************************
; *** Main program loop ***
; *************************
mainlp:    ldi     high prompt         ; address of prompt
           phi     rf                  ; place into r6
           ldi     low prompt
           plo     rf
           sep     scall               ; display prompt
#ifdef ELFOS
           dw      o_msg
#else
           dw      f_msg               ; function to display a message
#endif
           ldi     high buffer         ; point to input buffer
           phi     rf
           ldi     low buffer
           plo     rf
           sep     scall               ; read a line
#ifdef ELFOS
           dw      o_input
#else
           dw      f_input             ; function to read a line
#endif

	   sep     scall
	   dw      crlfout
           mov     rf,buffer           ; convert to uppercase
           sep     scall
           dw      touc
           sep     scall               ; call tokenizer
           dw      tknizer

           ldi     low freemem         ; get free memory pointer
           plo     r9                  ; place into data segment
           lda     r9                  ; get free memory pointer
           phi     rb                  ; place into rF
           ldn     r9
           plo     rb
           inc     rb
           inc     rb
           sep     scall
           dw      exec

           lbr     mainlp              ; return to beginning of main loop

crlfout:	
	   push rf
           ldi     high crlf           ; address of CR/LF
           phi     rf                  ; place into r6
           ldi     low crlf  
           plo     rf
           sep     scall               ; call bios
#ifdef ELFOS
           dw      o_msg
#else
           dw      f_msg               ; function to display a message
#endif
	  pop rf
	   sep sret

; **************************************
; *** Display a character, char in D ***
; **************************************
#if 0	
disp:      sep     scall               ; call bios
#ifdef ELFOS
           dw      o_type
#else
           dw      f_type              ; function to type a charactr
#endif
           sep     sret                ; return to caller
#else
#ifdef ELFOS
	lbr o_type
#else
	lbr f_type
#endif	
#endif	

; ********************************
; *** Read a key, returns in D ***
; ********************************
#if 0	
getkey:    sep     scall               ; call bios
#ifdef ELFOS
           dw      o_readkey
#else
           dw      f_read              ; function to read a key
#endif
           sep     sret                ; return to caller
#else
getkey:
#ifdef ELFOS
	lbr o_readkey
#else
	lbr f_read
#endif	
#endif	


; ***************************************************
; *** Function to retrieve value from forth stack ***
; *** Returns R[B] = value                        ***
; ***         DF=0 no error, DF=1 error           ***
; ***************************************************
pop:       sex     r2                  ; be sure x points to stack
           ldi     low fstack          ; get stack address
           plo     r9                  ; select in data segment
           lda     r9
           phi     ra
           ldn     r9
           plo     ra
           ldi     low tos             ; pointer to maximum stack value
           plo     r9                  ; put into data frame
           lda     r9                  ; get high value
           str     r2                  ; place into memory
           ghi     ra                  ; get high byte of forth stack
           sm                          ; check if same
           lbnz    stackok             ; jump if ok
           ldn     r9                  ; get low byte of tos
           str     r2
           glo     ra                  ; check low byte of stack pointer
           sm
           lbnz    stackok             ; jump if ok
           ldi     1                   ; signal error
popret:    shr                         ; shift status into DF
           sep     sret                ; return to caller
stackok:   inc     ra                  ; point to high byte
           lda     ra                  ; get it
           phi     rb                  ; put into r6
           ldn     ra                  ; get low byte
           plo     rb
           ldi     low fstack          ; get stack address
           plo     r9                  ; select in data segment
           ghi     ra                  ; get hi memory
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     ra                  ; get low byte
           str     r9                  ; and store
           ldi     0                   ; signal no error
           lbr     popret              ; and return to caller

; ********************************************************
; *** Function to push value onto stack, value in R[B] ***
; ********************************************************
push:      ldi     low fstack          ; get stack address
           plo     r9                  ; select in data segment
           lda     r9
           phi     ra
           ldn     r9
           plo     ra
           glo     rb                  ; get low byte of value
           str     ra                  ; store on forth stack
           dec     ra                  ; point to next byte
           ghi     rb                  ; get high value
           str     ra                  ; store on forth stack
           dec     ra                  ; point to next byte
           ldi     low fstack          ; get stack address
           plo     r9                  ; select in data segment
           ghi     ra                  ; get hi memory
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     ra                  ; get low byte
           str     r9                  ; and store
           sep     sret                ; return to caller

; ****************************************************
; *** Function to retrieve value from return stack ***
; *** Returns R[B] = value                         ***
; ***         D=0 no error, D=1 error              ***
; ****************************************************
rpop:      sex     r2                  ; be sure x points to stack
           ldi     low rstack          ; get stack address
           plo     r9                  ; select in data segment
           lda     r9
           phi     ra
           ldn     r9
           plo     ra
           inc     ra                  ; point to high byte
           lda     ra                  ; get it
           phi     rb                  ; put into r6
           ldn     ra                  ; get low byte
           plo     rb
           ldi     low rstack          ; get stack address
           plo     r9                  ; select in data segment
           ghi     ra                  ; get hi memory
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     ra                  ; get low byte
           str     r9                  ; and store
           ldi     0                   ; signal no error
           sep     sret                ; and return

; ***************************************************************
; *** Function to push value onto return stack, value in R[B] ***
; ***************************************************************
rpush:     ldi     low rstack          ; get stack address
           plo     r9                  ; select in data segment
           lda     r9
           phi     ra
           ldn     r9
           plo     ra
           glo     rb                  ; get low byte of value
           str     ra                  ; store on forth stack
           dec     ra                  ; point to next byte
           ghi     rb                  ; get high value
           str     ra                  ; store on forth stack
           dec     ra                  ; point to next byte
           ldi     low rstack          ; get stack address
           plo     r9                  ; select in data segment
           ghi     ra                  ; get hi memory
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     ra                  ; get low byte
           str     r9                  ; and store
           sep     sret                ; return to caller

;           org     200h 
; ********************************************
; *** Function to find stored name address ***
; ***  Needs: name to search in R[8]       ***
; ***  returns: R[B] first byte in data    ***
; ***           R[7] Address of descriptor ***
; ***           R[8] first addr after name ***
; ***           DF = 1 if not found        ***
; ********************************************
findname:  ldi     high storage        ; get address of stored data
           phi     rb                  ; put into r6
           ldi     low storage
           plo     rb
           sex     r2                  ; make sure X points to stack
findlp:    ghi     rb                  ; copy address
           phi     r7
           glo     rb
           plo     r7
           lda     rb                  ; get link address
           lbnz    findgo              ; jump if nonzero
           ldn     rb                  ; get low byte
           lbnz    findgo              ; jump if non zero
           ldi     1                   ; not found
findret:   shr                         ; set DF
           sep     sret                ; and return to caller
findgo:    inc     rb                  ; pointing now at type
           inc     rb                  ; pointing at ascii indicator
           inc     rb                  ; first byte of name
           glo     r8                  ; save requested name
           stxd
           ghi     r8
           stxd
findchk:   ldn     r8                  ; get byte from requested name
           str     r2                  ; place into memory
           ldn     rb                  ; get byte from descriptor
           sm                          ; compare equality
           lbnz    findnext            ; jump if not found
           ldn     r8                  ; get byte
           lbz     findfound           ; entry is found
           inc     r8                  ; increment positions
           inc     rb
           lbr     findchk             ; and keep looking
findfound: inc     rb                  ; r6 now points to data
           irx                         ; remove r8 from stack
           irx
           inc     r8                  ; move past terminator in name
           ldi     0                   ; signal success
           lbr     findret             ; and return to caller
findnext:  irx                         ; recover start of requested name
           ldxa
           phi     r8
           ldx
           plo     r8
           lda     r7                  ; get next link address
           phi     rb
           ldn     r7
           plo     rb
           lbr     findlp              ; and check next entry

; *********************************************
; *** Function to multiply 2 16 bit numbers ***
; *********************************************
mul16:     ldi     0                   ; zero out total
           phi     r8
           plo     r8
           phi     rc
           plo     rc
           sex     r2                  ; make sure X points to stack
mulloop:   glo     r7                  ; get low of multiplier
           lbnz    mulcont             ; continue multiplying if nonzero
           ghi     r7                  ; check hi byte as well
           lbnz    mulcont
           ghi     r8                  ; transfer answer
           phi     rb
           glo     r8
           plo     rb
           sep     sret                ; return to caller
mulcont:   ghi     r7                  ; shift multiplier
           shr
           phi     r7
           glo     r7
           shrc
           plo     r7
           lbnf    mulcont2            ; loop if no addition needed
           glo     rb                  ; add 6 to 8
           str     r2
           glo     r8
           add
           plo     r8
           ghi     rb
           str     r2
           ghi     r8
           adc
           phi     r8
           glo     rc                  ; carry into high word
           adci    0
           plo     rc
           ghi     rc
           adci    0
           phi     rc
mulcont2:  glo     rb                  ; shift first number
           shl
           plo     rb
           ghi     rb
           shlc
           phi     rb
           lbr     mulloop             ; loop until done

; ************************************
; *** make both arguments positive ***
; *** Arg1 RB                      ***
; *** Arg2 R7                      ***
; *** Returns D=0 - signs same     ***
; ***         D=1 - signs difer    ***
; ************************************
mdnorm:    ghi     rb                  ; get high byte if divisor
           str     r2                  ; store for sign check
           ghi     r7                  ; get high byte of dividend
           xor                         ; compare
           shl                         ; shift into df
           ldi     0                   ; convert to 0 or 1
           shlc                        ; shift into D
           plo     re                  ; store into sign flag
           ghi     rb                  ; need to see if RB is negative
           shl                         ; shift high byte to df
           lbnf    mdnorm2             ; jump if not
           ghi     rb                  ; 2s compliment on RB
           xri     0ffh
           phi     rb
           glo     rb
           xri     0ffh
           plo     rb
           inc     rb
mdnorm2:   ghi     r7                  ; now check r7 for negative
           shl                         ; shift sign bit into df
           lbnf    mdnorm3             ; jump if not
           ghi     r7                  ; 2 compliment on R7
           xri     0ffh
           phi     r7
           glo     r7
           xri     0ffh
           plo     r7
           inc     r7
mdnorm3:   glo     re                  ; recover sign flag
           sep     sret                ; and return to caller
            
           

; *** RC = RB/R7 
; *** RB = remainder
; *** uses R8 and R9
div16:     sep     scall               ; normalize numbers
           dw      mdnorm
           plo     re                  ; save sign comparison
           ldi     0                   ; clear answer 
           phi     rc
           plo     rc
           phi     r8                  ; set additive
           plo     r8
           inc     r8
           glo     r7                  ; check for divide by 0
           lbnz    d16lp1
           ghi     r7
           lbnz    d16lp1
           ldi     0ffh                ; return 0ffffh as div/0 error
           phi     rc
           plo     rc
           sep     sret                ; return to caller
d16lp1:    ghi     r7                  ; get high byte from r7
           ani     128                 ; check high bit 
           lbnz    divst               ; jump if set
           glo     r7                  ; lo byte of divisor
           shl                         ; multiply by 2
           plo     r7                  ; and put back
           ghi     r7                  ; get high byte of divisor
           shlc                        ; continue multiply by 2
           phi     r7                  ; and put back
           glo     r8                  ; multiply additive by 2
           shl     
           plo     r8
           ghi     r8
           shlc
           phi     r8
           lbr     d16lp1              ; loop until high bit set in divisor
divst:     glo     r7                  ; get low of divisor
           lbnz    divgo               ; jump if still nonzero
           ghi     r7                  ; check hi byte too
           lbnz    divgo
           glo     re                  ; get sign flag
           shr                         ; move to df
           lbnf    divret              ; jump if signs were the same
           ghi     rc                  ; perform 2s compliment on answer
           xri     0ffh
           phi     rc
           glo     rc
           xri     0ffh
           plo     rc
           inc     rc
divret:    sep     sret                ; jump if done
divgo:     ghi     rb                  ; copy dividend
           phi     r9
           glo     rb
           plo     r9
           glo     r7                  ; get lo of divisor
           stxd                        ; place into memory
           irx                         ; point to memory
           glo     rb                  ; get low byte of dividend
           sm                          ; subtract
           plo     rb                  ; put back into r6
           ghi     r7                  ; get hi of divisor
           stxd                        ; place into memory
           irx                         ; point to byte
           ghi     rb                  ; get hi of dividend
           smb                         ; subtract
           phi     rb                  ; and put back
           lbdf    divyes              ; branch if no borrow happened
           ghi     r9                  ; recover copy
           phi     rb                  ; put back into dividend
           glo     r9
           plo     rb
           lbr     divno               ; jump to next iteration
divyes:    glo     r8                  ; get lo of additive
           stxd                        ; place in memory
           irx                         ; point to byte
           glo     rc                  ; get lo of answer
           add                         ; and add
           plo     rc                  ; put back
           ghi     r8                  ; get hi of additive
           stxd                        ; place into memory
           irx                         ; point to byte
           ghi     rc                  ; get hi byte of answer
           adc                         ; and continue addition
           phi     rc                  ; put back
divno:     ghi     r7                  ; get hi of divisor
           shr                         ; divide by 2
           phi     r7                  ; put back
           glo     r7                  ; get lo of divisor
           shrc                        ; continue divide by 2
           plo     r7
           ghi     r8                  ; get hi of divisor
           shr                         ; divide by 2
           phi     r8                  ; put back
           glo     r8                  ; get lo of divisor
           shrc                        ; continue divide by 2
           plo     r8
           lbr     divst               ; next iteration

;           org     300h
; ***************************
; *** Setup for tokenizer ***
; ***************************
tknizer:   ldi     high buffer         ; point to input buffer
           phi     rb
           ldi     low buffer
           plo     rb
           ldi     low freemem         ; get free memory pointer
           plo     r9                  ; place into data segment
           lda     r9                  ; get free memory pointer
           phi     rf                  ; place into rF
           ldn     r9
           plo     rf
           inc     rf
           inc     rf
           sex     r2                  ; make sure x is pointing to stack

; ******************************
; *** Now the tokenizer loop ***
; ******************************
tokenlp:   ldn     rb                  ; get byte from buffer
           lbz     tokendn             ; jump if found terminator
           smi     (' '+1)             ; check for whitespace
           lbdf    nonwhite            ; jump if not whitespace
           inc     rb                  ; move past white space
           lbr     tokenlp             ; and keep looking

; ********************************************
; *** Prepare to check against token table ***
; ********************************************
nonwhite:  ldi     high cmdTable       ; point to comand table
           phi     r7                  ; r7 will be command table pointer
           ldi     low cmdTable
           plo     r7
           ldi     1                   ; first command number
           plo     r8                  ; r8 will keep track of command number
; **************************
; *** Command check loop ***
; **************************
cmdloop:   ghi     rb                  ; save buffer address
           phi     rc
           glo     rb
           plo     rc
; ************************
; *** Check next token ***
; ************************
tokloop:   ldn     r7                  ; get byte from token table
           ani     128                 ; check if last byte of token
           lbnz    cmdend              ; jump if last byte
           ldn     r7                  ; reget token byte
           str     r2                  ; store to stack
           ldn     rb                  ; get byte from buffer
           sm                          ; do bytes match?
           lbnz    toknomtch           ; jump if no match
           inc     r7                  ; incrment token pointer
           inc     rb                  ; increment buffer pointer
           lbr     tokloop             ; and keep looking
; *********************************************************
; *** Token failed match, move to next and reset buffer ***
; *********************************************************
toknomtch: ghi     rc                  ; recover saved address
           phi     rb
           glo     rc
           plo     rb
nomtch1:   ldn     r7                  ; get byte from token
           ani     128                 ; looking for last byte of token
           lbnz    nomtch2             ; jump if found
           inc     r7                  ; point to next byte
           lbr     nomtch1             ; and keep looking
nomtch2:   inc     r7                  ; point to next token
           inc     r8                  ; increment command number
           ldn     r7                  ; get next token byte
           lbnz    cmdloop             ; jump if more tokens to check
           lbr     notoken             ; jump if no token found
; ***********************************************************
; *** Made it to last byte of token, check remaining byte ***
; ***********************************************************
cmdend:    ldn     r7                  ; get byte fro token
           ani     07fh                ; strip off end code
           str     r2                  ; save to stack
           ldn     rb                  ; get byte from buffer
           sm                          ; do they match
           lbnz    toknomtch           ; jump if not
           inc     rb                  ; point to next byte
           ldn     rb                  ; get it
           smi     (' '+1)             ; it must be whitespace
           lbdf    toknomtch           ; otherwise no match
; *************************************************************
; *** Match found, store command number into command buffer ***
; *************************************************************
           glo     r8                  ; get command number
           ori     128                 ; set high bit
           str     rf                  ; write to command buffer
           inc     rf                  ; point to next position
           smi     FDOTQT              ; check for ." function
           lbnz    tokenlp             ; jump if not
           inc     rb                  ; move past first space
           ldi     T_ASCII             ; need an ascii token
tdotqtlp:  str     rf                  ; write to command buffer
           inc     rf
           ldn     rb                  ; get next byte
           smi     34                  ; check for end quote
           lbz     tdotqtdn            ; jump if found
           lda     rb                  ; transfer character to code
           lbr     tdotqtlp            ; and keep looking
tdotqtdn:  ldn     rb                  ; retrieve quote
           str     rf                  ; put quote into output
           inc     rf
           ldi     0                   ; need string terminator
           str     rf
           inc     rf
           inc     rb                  ; move past quote
           lbr     tokenlp             ; then continue tokenizing


; ------------------------------------------------------------------------
;     DECIMAL handler  if not valid decimal then proceed to ascii        ; 
; ------------------------------------------------------------------------

notoken:   ; get number BASE [GDJ]
	mov rc,rb
	ldn rb
	smi '0'
	bnz notokenbase  	; if no leading 0 can't be 0x or 0#
	inc rb
	ldn rb
	smi 'X'
	bz notoken_0   		; 0xHexNumber
	ldn rb
	smi '#'
	bnz notokenbaseadj		; 0#DecNumber
notoken_0:
	ldn rb
	inc rb
	smi 'X'
	bz hexnum
	br decnum
notokenbaseadj:	  dec rb   	; point back at 0
notokenbase:	
           mov     rd, basen
           ldn     rd
           smi     10
           lbnz    hexnum

decnum:
        mov     rc,rb               ; save pointer in case of bad number
	ldi 0
	phi rd
	plo rd
        plo     re
           ldn     rb                  ; get byte
           smi     '-'                 ; is it negative
           lbnz    notoken1            ; jump if not
           inc     rb                  ; move past negative
           ldi     1                   ; set negative flag
           plo     re
           plo     rd
notoken1:  ldn     rb                  ; get byte
           smi     '0'                 ; check for below numbers
           lbnf    nonnumber           ; jump if not a number
           ldn     rb
           smi     ('9'+1)
           lbdf    nonnumber
           ; ghi     rb                  ; save pointer in case of bad number
           ; phi     rc
           ; glo     rb
           ; plo     rc
; **********************
; *** Found a number ***
; **********************
isnumber:  ldi     0                   ; number starts out as zero
           phi     r7                  ; use r7 to compile number
           plo     r7
           sex     r2                  ; make sure x is pointing to stack
numberlp:  ghi     r7                  ; copy number to temp
           phi     r8
           glo     r7
           plo     r8
           glo     r7                  ; mulitply by 2
           shl
           plo     r7
           ghi     r7
           shlc
           phi     r7
           glo     r7                  ; mulitply by 4
           shl
           plo     r7
           ghi     r7
           shlc
           phi     r7
           glo     r8                  ; multiply by 5
           str     r2
           glo     r7
           add
           plo     r7
           ghi     r8
           str     r2
           ghi     r7
           adc
           phi     r7
           glo     r7                  ; mulitply by 10
           shl
           plo     r7
           ghi     r7
           shlc
           phi     r7
           lda     rb                  ; get byte from buffer
           smi     '0'                 ; convert to numeric
           str     r2                  ; store it
           glo     r7                  ; add to number
           add
           plo     r7
           ghi     r7                  ; propagate through high byte
           adci    0
           phi     r7
           ldn     rb                  ; get byte
           smi     (' '+1)             ; check for space
           lbnf    numberdn            ; number also done
           ldn     rb
           smi     '0'                 ; check for below numbers
           lbnf    numbererr           ; jump if not a number
           ldn     rb
           smi     ('9'+1)
           lbdf    numbererr
           lbr     numberlp            ; get rest of number
numbererr: ghi     rc                  ; recover address
           phi     rb
           glo     rc
           plo     rb
           lbr     nonnumber
numberdn:  glo     re                  ; get negative flag
           lbz     numberdn1           ; jump if positive number
           ghi     r7                  ; negative, so 2s compliment number
           xri     0ffh
           phi     r7
           glo     r7
           xri     0ffh
           plo     r7
           inc     r7
numberdn1: ldi     T_NUM               ; code to signify a number
           str     rf                  ; write to code buffer
           inc     rf                  ; point to next position
           ghi     r7                  ; get high byte of number
           str     rf                  ; write to code buffer
           inc     rf                  ; point to next position
           glo     r7                  ; get lo byte of numbr
           str     rf                  ; write to code buffer
           inc     rf                  ; point to next position
           lbr     tokenlp             ; continue reading tokens

; ------------------------------------------------------------------------
;       HEX handler  if not valid decimal then proceed to ascii          ; 
; ------------------------------------------------------------------------
				; [GDJ]
hexnum:    ldi     0h                  ; clear return value
           plo     r7
           phi     r7
           mov     rc,rb               ; save pointer in case of bad number

           ; for first pass we reject non hex chars
           ; in next pass this check has already been done but we
           ; have to deal with the different offsets here for ascii to binary
           ; Note: all strings have been converted to upper case previously
tohexlp:   ldn     rb                  ; get next byte
           smi     '0'                 ; check for bottom of range
           lbnf    nonnumber           ; jump if non-numeric
           ldn     rb                  ; recover byte
           smi     '9'+1               ; upper range of digits
           lbnf    tohexd              ; jump if digit
           ldn     rb                  ; recover character
           smi     'A'                 ; check below uc A
           lbnf    nonnumber           ; jump if not hex character
           ldn     rb                  ; recover character
           smi     'F'+1               ; check for above uc F
           lbdf    nonnumber           ; jump if not hex character
           lbr     tohex
tohexd:    ldn     rb                  ; recover character 0..9
           smi     030h                ; convert to binary       
           lbr     tohexad
tohex:     ldn     rb                  ; recover character A..F
           smi     55                  ; convert to binary
tohexad:   str     r2                  ; store value to add
           ldi     4                   ; need to shift 4 times
           plo     re
tohexal:   glo     r7
           shl
           plo     r7
           ghi     r7
           shlc
           phi     r7
           dec     re                  ; decrement count
           glo     re                  ; get count
           lbnz    tohexal             ; loop until done
           glo     r7                  ; now add in new value
           or                          ; or with stored byte
           plo     r7

           inc     rb
           ldn     rb
           smi     (' '+1)             ; check for space
           lbnf    numberdn1           ; number is complete
           
           ; words that begin with valid hex chars but have
           ; embedded non hex characters get filtered out here
           ldn     rb
           sep     scall               ; check for hex character
           dw      ishex
           lbdf    tohexlp             ; loop back if so else
                                       ; we dont have a hex char
           
           ; we got here since this was not a valid hex number           
nothexnum: mov     rb,rc               ; retrieve pointer


; *************************************************************
; *** Neither token or number found, insert as ascii string ***
; *************************************************************
nonnumber: dec     rb                  ; account for first increment
           mov     rc, basen
           ldn     rc
           smi     10
           lbnz    nonnumber1
           glo     rd
           lbz     nonnumber1
           dec     rb                  ; account for previous minus sign in DECIMAL mode
nonnumber1:
           ldi     T_ASCII             ; indicate ascii to follow
notokenlp: str     rf                  ; write to buffer
           inc     rf                  ; advance to next position
           inc     rb                  ; point to next position
           ldn     rb                  ; get next byte
           smi     (' '+1)             ; check for whitespace
           lbnf    notokwht            ; found whitespace
           ldn     rb                  ; get byte
           lbr     notokenlp           ; get characters til whitespace
notokwht:  ldi     0                   ; need ascii terminator
           str     rf                  ; store into buffer
           inc     rf                  ; point to next position
           lbr     tokenlp             ; and keep looking
tokendn:   ldi     0                   ; need to terminate command string
           str     rf                  ; write to buffer
           sep    sret                 ; return to caller


;           org     500h
; ****************************************************
; *** Execute forth byte codes, RB points to codes ***
; ****************************************************
exec:      ldn     rb                  ; get byte from codestream
           lbz     execdn              ; jump if at end of stream
           smi     T_NUM               ; check for numbers
           lbz     execnum             ; code is numeric
           ldn     rb                  ; recover byte
           smi     T_ASCII             ; check for ascii data
           lbz     execascii           ; jump if ascii
           mov     r8, jump            ; point to jump address
           ldi     0c0h                ; need LBR
           str     r8                  ; store it
           inc     r8
           ldn     rb                  ; recover byte
           ani     07fh                ; strip high bit
           smi     1                   ; reset to origin
           shl                         ; addresses are two bytes
           sex     r2                  ; point X to stack
           str     r2                  ; write offset for addtion
           ldi     low cmdvecs
           add                         ; add offset
           plo     r7
           ldi     high cmdvecs        ; high address of command vectors
           adci    0                   ; propagate carry
           phi     r7                  ; r[7] now points to command vector
           lda     r7                  ; get high byte of vector
           str     r8
           inc     r8
           lda     r7                  ; get low byte of vector
           str     r8
           inc     rb                  ; point rb to next command
           glo     rb                  ; save rb
           stxd
           ghi     rb
           stxd
           lbr     jump
execret:   sex     r2                  ; be sure X poits to stack
           plo     r7                  ; save return code
           irx                         ; recover rb
           lda     r2
           phi     rb
           ldn     r2
           plo     rb
           glo     r7                  ; get result code
           lbz     exec                ; jump if no error
           ldi     high msempty        ; get error message
           phi     rf
           ldi     low msempty
           plo     rf
execrmsg:  			;	sep     scall	
#ifdef ELFOS
           lbr      o_msg
#else
           lbr      f_msg
#endif
	;;            sep     sret                ; return to caller

execnum:   inc     rb                  ; point to number
           ghi     rb
           phi     r7
           glo     rb
           plo     r7
           lda     r7
           phi     rb
           lda     r7
           plo     rb
           sep     scall
           dw      push
           ghi     r7
           phi     rb
           glo     r7
           plo     rb
           lbr     exec                ; execute next code
execascii: inc     rb                  ; move past ascii code
           ghi     rb                  ; transfer name to R8
           phi     r8
           glo     rb
           plo     r8
           sep     scall               ; find entry
           dw      findname
           lbnf    ascnoerr            ; jump if name was found
ascerr:    ldi     high msgerr         ; get error message
           phi     rf
           ldi     low msgerr
           plo     rf
           lbr     execrmsg
ascnoerr:  inc     r7                  ; point to type
           inc     r7
           ldn     r7                  ; get type
           smi     86h                 ; check for variable
           lbz     execvar             ; jump if so
           ldn     r7                  ; get type
           smi     87h                 ; check for function
           lbnz    ascerr              ; jump if not
           sex     r2                  ; be sure X is pointing to stack
           glo     r8                  ; save position
           stxd                        ; and store on stack
           ghi     r8
           stxd
           sep     scall               ; call exec to execute stored program
           dw      exec
           irx                         ; recover pointer
           ldxa
           phi     rb
           ldx
           plo     rb
           lbr     exec                ; and continue execution
execvar:   sep     scall               ; push var address to stack
           dw      push
           ghi     r8                  ; transfer address back to rb
           phi     rb
           glo     r8
           plo     rb
           lbr     exec                ; execute next code
           


;          org     600h
cdup:      sep     scall               ; pop value from forth stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           sep     scall               ; push back twice
           dw      push
goodpush:	
           sep     scall
           dw      push
good:      ldi     0                   ; indicate success
	   lskp
error:	   ldi   1
           lbr     execret             ; return to caller


cdrop:     sep     scall               ; pop value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           lbr     good                ; return
           
cplus:     sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           sex     r2                  ; be sure X points to stack
           glo     r7                  ; perform addition
           str     r2
           glo     rb
           add
           plo     rb
           ghi     r7
           str     r2
           ghi     rb
           adc
goodpushb:	
           phi     rb
	   lbr     goodpush



cminus:    sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           sex     r2                  ; be sure X points to stack
           glo     r7                  ; perform addition
           str     r2
           glo     rb
           sm
           plo     rb
           ghi     r7
           str     r2
           ghi     rb
           smb
	   lbr goodpushb


cdot:      sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ldi     1
typegoode:	
           plo     re                  ; signal signed int
typegood:	
           sep     scall
           dw      typenum             ; [GDJ]
           lbr     good                ; return

cudot:     sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ldi     0
	   br typegoode

cdotx:
	sep scall
	dw pop
	lbdf error
	sep scall
	dw typenumind
	lbr good
	
cand:      sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           sex     r2                  ; be sure X points to stack
           glo     r7                  ; perform and
           str     r2
           glo     rb
           and
           plo     rb
           ghi     r7
           str     r2
           ghi     rb
           and
	   lbr goodpushb


cor:       sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           sex     r2                  ; be sure X points to stack
           glo     r7                  ; perform and
           str     r2
           glo     rb
           or
           plo     rb
           ghi     r7
           str     r2
           ghi     rb
           or
	   lbr     goodpushb

cxor:      sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           sex     r2                  ; be sure X points to stack
           glo     r7                  ; perform and
           str     r2
           glo     rb
           xor
           plo     rb
           ghi     r7
           str     r2
           ghi     rb
           xor
	   lbr    goodpushb


ccr:	   sep scall
	   dw crlfout
           lbr     good                ; return

cswap:     sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r8
           glo     rb
           plo     r8
           ghi     r7                  ; move number 
           phi     rb
           glo     r7
           plo     rb
           sep     scall               ; put answer back on stack
           dw      push
           ghi     r8                  ; move number 
           phi     rb
           glo     r8
goodpushb0:	
           plo     rb
           lbr     goodpush

ci:        sep     scall               ; get value from return stack
           dw      rpop
           sep     scall               ; put back on return stack
           dw      rpush 
	   lbr  goodpush

cmem:      sex     r2                  ; be sure x is pointing to stack
           ldi     low freemem         ; point to free memory pointer
           plo     r9                  ; place into data frame
           lda     r9                  ; get high byte of free memory pointer
           stxd                        ; store on stack
           lda     r9                  ; get low byte
           str     r2                  ; store on stack
           ldi     low fstack          ; get pointer to stack
           plo     r9                  ; set into data frame
           inc     r9                  ; point to lo byte
           ldn     r9                  ; get it
           sm                          ; perform subtract
           plo     rb                  ; put into result
           dec     r9                  ; high byte of stack pointer
           irx                         ; point to high byte os free mem
           ldn     r9                  ; get high byte of stack
           smb                         ; continue subtraction
	   lbr  goodpushb

 

cdo:       sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r8
           glo     rb
           plo     r8
           ghi     r2                  ; get copy of machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; pointing at R[6] value high
           lda     ra                  ; get high of R[6]
           phi     rb                  ; put into r6
           lda     ra
           plo     rb
           sep     scall               ; store inst point on return stack
           dw      rpush
goodrpush78b:	
           ghi     r8                  ; transfer termination to rb
           phi     rb
           glo     r8
           plo     rb
           sep     scall               ; store termination on return stack
           dw      rpush
           ghi     r7                  ; transfer count to rb
           phi     rb
           glo     r7
goodrpushb0:	
           plo     rb
goodrpush:	
           sep     scall
	   dw rpush
	   lbr good


cloop:     sep     scall               ; get top or return stack
           dw      rpop
           inc     rb                  ; add 1 to it
loopcnt:   ghi     rb                  ; move it
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get termination
           dw      rpop
           sex     r2                  ; make sure x is pointing to stack
           glo     rb                  ; get lo of termination
           str     r2                  ; place into memory 
           glo     r7                  ; get count
           sm                          ; perform subtract
           ghi     rb                  ; get hi of termination
           str     r2                  ; place into memory
           ghi     r7                  ; get high of count
           smb                         ; continue subtract
           lbdf    cloopdn             ; jump if loop complete
           ghi     rb                  ; move termination
           phi     r8
           glo     rb
           plo     r8
           sep     scall               ; get loop address
           dw      rpop
           sep     scall               ; keep on stack as well
           dw      rpush
           ghi     r2                  ; get copy of machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; pointing at ra value high
           ghi     rb
           str     ra                  ; and write it
           inc     ra                 
           glo     rb                  ; get rb lo value
           str     ra                  ; and write it
	   lbr goodrpush78b
	
cloopdn:   sep     scall               ; pop off start of loop address
           dw      rpop
           lbr     good                ; and return
cploop:    sep     scall               ; get top or return stack
           dw      rpop
           sex     r2                  ; make sure X points to stack
           ghi     rb                  ; put count into memory
           stxd
           glo     rb
           stxd
           sep     scall               ; get word from data stack
           dw      pop
           lbdf    error
           irx
           glo     rb                  ; add to count
           add
           plo     rb
           ghi     rb
           irx
           adc
           phi     rb
           lbr     loopcnt             ; then standard loop code

cbegin:    ghi     r2                  ; get copy of machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; pointing at ra value high
           lda     ra                  ; get high of ra
           phi     rb                  ; put into rb
           lda     ra
	   lbr goodrpushb0

; [GDJ] corrected logic - BEGIN/UNTIL loop should repeat if flag preceding UNTIL is FALSE
cuntil:    sep     scall               ; get top of stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           glo     rb                  ; [GDJ] check flag LSB - if true were done
           lbnz    untilno             ; [GDJ]
           ghi     rb                  ; [GDJ] check flag MSB
           lbz     untilyes
untilno:   sep     scall               ; pop off begin address
           dw      rpop
           lbr     good                ; we are done, just return
untilyes:  sep     scall               ; get return address - continue looping
           dw      rpop
           sep     scall               ; also keep on stack
           dw      rpush
           ghi     r2                  ; get copy of machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; pointing at ra value high
           ghi     rb
           str     ra                  ; and write it
           inc     ra                 
           glo     rb                  ; get rb lo value
           str     ra                  ; and write it
           lbr     good                ; now return

crgt:      sep     scall               ; get value from return stack
           dw      rpop
	   lbr goodpush


cgtr:      sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
	   lbr goodrpush

cunequal:  sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           sex     r2                  ; be sure X points to stack
           glo     r7                  ; perform and
           str     r2
           glo     rb
           xor
           lbnz    unequal             ; jump if not equal
           ghi     r7
           str     r2
           ghi     rb
           xor
           lbnz    unequal             ; jump if not equal
	   plo     rb
	   lbr goodpushb

unequal:   ldi     0                   ; set return result
           phi     rb
           plo     rb
           inc     rb                  ; it is now 1
           lbr     goodpush


; [GDJ]
; determine if NOS < TOS
cless:     sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r8
           glo     rb
           plo     r8
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           sex     r2                  ; be sure X points to stack

           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7

           ; bias numbers for comparison
           ghi     r7
           xri     080h                ; bias upwards
           phi     r7

           ghi     r8
           xri     080h                ; bias upwards
           phi     r8

           glo     7                   ; subtract them
           str     r2
           glo     r8
           sd
           plo     r7
           ghi     r7
           str     r2
           ghi     r8
           sdb
           phi     r7
gooddf:	
	ldi 0
	phi rb  		; no matter what
	lsnf
	ldi 1			; now D=0 if DF=0 or 1 if DF=1
	plo rb
	lbr goodpush
	




; [GDJ]
culess:    sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           sex     r2                  ; be sure X points to stack

           ghi     rb                  ; move number 
           phi     r8
           glo     rb
           plo     r8

           ; perform subtraction r8-r7  (NOS-TOS) to check for borrow
           glo     r8
           str     r2
           glo     r7
           sd
           plo     r8
           ghi     r8
           str     r2
           ghi     r7
           sdb                         ; subtract with borrow
	   lbr gooddf


cwords:    ldi     high cmdtable       ; point to command table
           phi     r7                  ; put into a pointer register
           ldi     low cmdtable
           plo     r7
	ldi 0
	phi rd
	plo rd
cwordslp:  lda     r7                  ; get byte
           lbz     cwordsdn            ; jump if done
           plo     rb                  ; save it
           ani     128                 ; check for final of token
           lbnz    cwordsf             ; jump if so
           glo     rb                  ; get byte
           sep     scall               ; display it
           dw      disp 
           lbr     cwordslp            ; and loop back
cwordsf:   glo     rb                  ; get byte
           ani     07fh                ; strip high bit
           sep     scall               ; display it
           dw      disp
           ldi     ' '                 ; display a space
           sep     scall               ; display it
           dw      disp
           inc     rd
           glo     rd
           smi     12
           lbnz    cwordslp
	ldi 0
	phi rd
	plo rd
	   sep scall
	   dw crlfout
           lbr     cwordslp            ; and loop back
cwordsdn:  sep scall
	   dw  crlfout
           ldi     high storage        ; get beginning of program memory
           phi     r7
           ldi     low storage
           plo     r7
	ldi 0
	phi rd
	plo rd
cwordslp2: lda     r7                  ; get pointer to next entry
           phi     r8                  ; put into r8
           lda     r7                  ; now pointing at type indicator
           plo     r8                  ; save low of link
           lbnz    cwordsnot           ; jump if not link terminator
           ghi     r8                  ; check high byte too
           lbnz    cwordsnot
cwordsdn1: sep  scall
	   dw   crlfout 
           lbr     good                ; return to caller
cwordsnot: inc     r7                  ; now pointing at ascii indicator
           inc     r7                  ; first character of name
wordsnotl: lda     r7                  ; get byte from string
           lbz     wordsnxt            ; jump if end of string
           sep     scall               ; display it
           dw      disp
           lbr     wordsnotl           ; keep going
wordsnxt:  ldi     ' '                 ; want a space
           sep     scall               ; display it
           dw      disp
           ghi     r8                  ; transfer next word address to r7
           phi     r7
           glo     r8
           plo     r7
           inc     rd
           glo     rd
           smi     8
           lbnz    cwordslp2
	ldi 0
	phi rd
	plo rd
 	   sep     scall
	   dw crlfout
           lbr     cwordslp2           ; and check next word


cemit:     sep     scall               ; get top of stack
           dw      pop
           lbdf    error               ; jump if error
           glo     rb                  ; get low of return value
gooddisp:	
           sep     scall               ; and display ti
           dw      disp
           lbr     good                ; return to caller

; [GDJ]
cemitp:    sep     scall               ; get top of stack
           dw      pop
           lbdf    error               ; jump if error
           glo     rb                  ; get low of return value

           smi     32                  ; check for below space
           lbnf    notprint            ; jump if not printable
           glo     rb
           smi     127                 ; check for above tilde ~
           lsdf               ; jump if not printable (skip 2)
           glo     rb	      
           lskp              ; ok printable so skip ldi .
notprint:  ldi     '.'
emitpout:  lbr gooddisp



cwhile:    sep     scall               ; get top of stack
           dw      pop
           lbdf    error               ; jump if error
           glo     rb                  ; need to check for zero
           lbnz    whileno             ; jump if not zero
           ghi     rb                  ; check high byte
           lbnz    whileno
           ghi     r2                  ; copy machine stack to RA
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; point to R[6]
           lda     ra                  ; get command stream
           phi     rb                  ; put into r6
           ldn     ra
           plo     rb
           ldi     0                   ; set while count to zero
           plo     r7
findrep:   ldn     rb                  ; get byte from stream
           smi     81h                 ; was a while found
           lbnz    notwhile            ; jump if not
           inc     r7                  ; increment while count
notrep:    inc     rb                  ; point to next byte
           lbr     findrep             ; and keep looking
notwhile:  ldn     rb                  ; retrieve byte
           smi     82h                 ; is it a repeat
           lbnz    notrep              ; jump if not
           glo     r7                  ; get while count
           lbz     fndrep              ; jump if not zero
           dec     r7                  ; decrement count
           lbr     notrep              ; and keep looking
fndrep:    inc     rb                  ; move past the while
           glo     rb                  ; now put back into R[6]
           str     ra
           dec     ra
           ghi     rb
           str     ra
           lbr     good                ; then return to caller
whileno:   ghi     r2                  ; copy machine stack to RA
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; now pointing to high byte of R[6]
           lda     ra                  ; get it
           phi     rb                  ; and put into r6
           ldn     ra                  ; get low byte
           plo     rb
           dec     rb                  ; point back to while command
	   lbr goodrpush

crepeat:   sep     scall               ; get address on return stack
           dw      rpop
           ghi     r2                  ; transfer machine stack to RA
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; now pointing at high byte of R[6]
           ghi     rb                  ; get while address
           str     ra                  ; and place into R[6]
           inc     ra
           glo     rb
           str     ra
           lbr     good                ; then return
           
cif:       sep     scall               ; get top of stack 
           dw      pop
           lbdf    error               ; jump if error
           glo     rb                  ; check for zero
           lbnz    good                ; jump if not zero
           ghi     rb                  ; check hi byte too
           lbnz    good                ; jump if not zero
           ghi     r2                  ; transfer machine stack to RA
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; now pointing at R[6]
           lda     ra                  ; get R[6]
           phi     rb
           ldn     ra
           plo     rb
           ldi     0                   ; set IF count
           plo     r7                  ; put into counter
iflp1:     ldn     rb                  ; get next byte
           smi     83h                 ; check for IF
           lbnz    ifnotif             ; jump if not
           inc     r7                  ; increment if count
ifcnt:     inc     rb                  ; point to next byte
           lbr     iflp1               ; keep looking
ifnotif:   ldn     rb                  ; retrieve byte
           smi     84h                 ; check for ELSE
           lbnz    ifnotelse           ; jump if not
           glo     r7                  ; get IF count
           lbnz    ifcnt               ; jump if it is not zero
           inc     rb                  ; move past the else
ifsave:    glo     rb                  ; store back into instruction pointer
           str     ra
           dec     ra
           ghi     rb
           str     ra
           lbr     good                ; and return
ifnotelse: ldn     rb                  ; retrieve byte
           smi     85h                 ; check for THEN
           lbnz    ifcnt               ; jump if not
           glo     r7                  ; get if count
           dec     r7                  ; decrement if count
           lbnz    ifcnt               ; jump if not zero
           lbr     ifsave              ; otherwise found


celse:     ghi     r2                  ; transfer machine stack to ra
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; now pointing at R[6]
           lda     ra                  ; get current R[6]
           phi     rb                  ; and place into r6
           ldn     ra
           plo     rb
           ldi     0                   ; count of IFs
           plo     r7                  ; put into R7
elselp1:   ldn     rb                  ; get next byte from stream
           smi     83h                 ; check for IF
           lbnz    elsenif             ; jump if not if
           inc     r7                  ; increment IF count
elsecnt:   inc     rb                  ; point to next byte
           lbr     elselp1             ; keep looking
elsenif:   ldn     rb                  ; retrieve byte
           smi     85h                 ; is it THEN
           lbnz    elsecnt             ; jump if not
           glo     r7                  ; get IF count
           dec     r7                  ; minus 1 IF
           lbnz    elsecnt             ; jump if not 0
           glo     rb                  ; put into instruction pointer
           str     ra
           dec     ra
           ghi     rb
           str     ra
           lbr     good                ; now pointing at a then


cequal:    sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           sex     r2                  ; be sure X points to stack
           glo     r7                  ; perform and
           str     r2
           glo     rb
           xor
           lbnz    unequal2            ; jump if not equal
           ghi     r7
           str     r2
           ghi     rb
           xor
           lbnz    unequal2            ; jump if not equal
           phi     rb                  ; set return result
           plo     rb
           inc     rb
           lbr goodpush
unequal2:  ldi     0
	   plo     rb
           lbr     goodpushb


cdepth:    sex     r2                  ; be sure x is pointing to stack
           ldi     low fstack          ; point to free memory pointer
           plo     r9                  ; place into data frame
           lda     r9                  ; get high byte of free memory pointer
           stxd                        ; store on stack
           lda     r9                  ; get low byte
           str     r2                  ; store on stack
           ldi     low tos             ; get pointer to stack
           plo     r9                  ; set into data frame
           inc     r9                  ; point to lo byte
           ldn     r9                  ; get it
           sm                          ; perform subtract
           plo     rb                  ; put into result
           dec     r9                  ; high byte of stack pointer
           irx                         ; point to high byte os free mem
           ldn     r9                  ; get high byte of stack
           smb                         ; continue subtraction
           shr                         ; divide by 2
           phi     rb                  ; store answer
           glo     rb                  ; propagate the shift
           shrc
	   lbr goodpushb0

 
crot:      sep     scall               ; get C
           dw      pop
           lbdf    error               ; jump if error
           ghi     rb                  ; transfer to R7
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get B
           dw      pop
           lbdf    error               ; jump if error
           ghi     rb                  ; transfer to R7
           phi     r8
           glo     rb
           plo     r8
           sep     scall               ; get A
           dw      pop
           lbdf    error               ; jump if error
           ghi     rb                  ; transfer to R7
           phi     rc
           glo     rb
           plo     rc
           ghi     r8                  ; get B
           phi     rb
           glo     r8
           plo     rb
           sep     scall               ; put onto stack
           dw      push
           ghi     r7                  ; get C
           phi     rb
           glo     r7
           plo     rb
           sep     scall               ; put onto stack
           dw      push
           ghi     rc                  ; get A
           phi     rb
           glo     rc
	   lbr goodpushb0

 
cmrot:     sep     scall               ; get C
           dw      pop
           lbdf    error               ; jump if error
           ghi     rb                  ; transfer to R7
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get B
           dw      pop
           lbdf    error               ; jump if error
           ghi     rb                  ; transfer to R7
           phi     r8
           glo     rb
           plo     r8
           sep     scall               ; get A
           dw      pop
           lbdf    error               ; jump if error
           ghi     rb                  ; transfer to R7
           phi     rc
           glo     rb
           plo     rc
           ghi     r7                  ; get C
           phi     rb
           glo     r7
           plo     rb
           sep     scall               ; put onto stack
           dw      push
           ghi     rc                  ; get A
           phi     rb
           glo     rc
goodpushb8b:	
           plo     rb
           sep     scall               ; put onto stack
           dw      push
           ghi     r8                  ; get B
           phi     rb
           glo     r8
	   lbr goodpushb0

 
cover:     sep     scall               ; get B
           dw      pop
           lbdf    error               ; jump if error
           ghi     rb                  ; transfer to R7
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get A
           dw      pop
           lbdf    error               ; jump if error
           ghi     rb                  ; transfer to R*
           phi     r8
           glo     rb
           plo     r8
           sep     scall               ; put onto stack
           dw      push
           ghi     r7                  ; get B
           phi     rb
           glo     r7
	   lbr goodpushb8b

           
cat:       sep     scall               ; get address from stack
           dw      pop
           lbdf    error               ; jump on error
           ghi     rb                  ; transfer address
           phi     r7
           glo     rb
           plo     r7
           lda     r7                  ; get word at address
           phi     rb
           ldn     r7
	   lbr goodpushb0

           
cexcl:     sep     scall               ; get address from stack
           dw      pop
           lbdf    error               ; jump on error
           ghi     rb                  ; transfer address
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; date data word from stack
           dw      pop
           lbdf    error               ; jump on error
           ghi     rb                  ; write word to memory
           str     r7
           inc     r7
           glo     rb
           str     r7
           lbr     good                ; and return
           
ccat:      sep     scall               ; get address from stack
           dw      pop
           lbdf    error               ; jump on error
           ghi     rb                  ; transfer address
           phi     r7
           glo     rb
           plo     r7
           ldi     0                   ; high byte is zero
           phi     rb
           lda     r7                  ; get word at address
	   lbr goodpushb0

           
ccexcl:    sep     scall               ; get address from stack
           dw      pop
           lbdf    error               ; jump on error
           ghi     rb                  ; transfer address
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; date data word from stack
           dw      pop
           lbdf    error               ; jump on error
           glo     rb                  ; write byte to memory
           str     r7
           lbr     good                ; and return

cvariable: ghi     r2                  ; transfer machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; point to R[6]
           lda     ra                  ; and retrieve it
           phi     rb
           ldn     ra
           plo     rb
           ldn     rb                  ; get next byte
           smi     T_ASCII             ; it must be an ascii mark
           lbnz    error               ; jump if not
           inc     rb                  ; move into string
varlp1:    lda     rb                  ; get byte
           lbnz    varlp1              ; jump if terminator not found
           inc     rb                  ; allow space for var value
           inc     rb                  ; new value of freemem
           ldi     low freemem         ; get current free memory pointer
           plo     r9                  ; put into data segment
           lda     r9                  ; get current pointer
           phi     r7                  ; place here
           ldn     r9                  ; get low byte
           plo     r7
           ghi     rb                  ; get memory pointer
           str     r7                  ; and store into link list
           inc     r7
           glo     rb
           str     r7
           glo     rb                  ; store new freemem value
           str     r9
           dec     r9
           ghi     rb
           str     r9
           ldi     0                   ; need zero at end of list
           str     rb                  ; store it
           inc     rb
           str     rb
           glo     rb                  ; write back to instruction pointer
           str     ra
           dec     ra
           ghi     rb
           str     ra
           lbr     good                ; return

ccolon:    ghi     r2                  ; transfer machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; point to R[6]
           lda     ra                  ; and retrieve it
           phi     rb
           ldn     ra
           plo     rb
           ldn     rb                  ; get next byte
           smi     T_ASCII             ; it must be an ascii mark
           lbnz    error               ; jump if not
           inc     rb                  ; move into string
colonlp1:  lda     rb                  ; get byte
           smi     88h                 ; look for the ;
           lbnz    colonlp1            ; jump if terminator not found
           ldi     0                   ; want a command terminator
           str     rb                  ; write it
           inc     rb                  ; new value for freemem
           ldi     low freemem         ; get current free memory pointer
           plo     r9                  ; put into data segment
           lda     r9                  ; get current pointer
           phi     r7                  ; place here
           ldn     r9                  ; get low byte
           plo     r7
           ghi     rb                  ; get memory pointer
           str     r7                  ; and store into link list
           inc     r7
           glo     rb
           str     r7
           glo     rb                  ; store new freemem value
           str     r9
           dec     r9
           ghi     rb
           str     r9
           ldi     0                   ; need zero at end of list
           str     rb                  ; store it
           inc     rb
           str     rb
           glo     rb                  ; write back to instruction pointer
           str     ra
           dec     ra
           ghi     rb
           str     ra
cthen:	
csemi:	
           lbr     good                ; return


csee:      ghi     r2                  ; transfer machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; point to R[6]
           lda     ra                  ; and retrieve it
           phi     r8
           ldn     ra
           plo     r8
           ldn     r8                  ; get next byte
           smi     T_ASCII             ; it must be an ascii mark
           lbnz    error               ; jump if not
           inc     r8                  ; move into string
           sep     scall               ; find the name
           dw      findname
           lbdf    error               ; jump if not found
           glo     r8                  ; put new address into inst pointer
           str     ra 
           dec     ra
           ghi     r8
           str     ra
	   sep     scall
	   dw      csee_sub
	   lbr     good                ; otherwise good	
	
	;;  make see callable so we can use it from inside Forth words
	;;  r7= address of descriptor  (main pointer to word; points to next address)
	;;  rb = first byte in data
	;;  user callable csee_sub0 only requires r7. If r7 and rb are set call csee_sub
csee_sub0:
	ghi r7
	phi rb
	glo r7
	plo rb
	inc rb
	inc rb
csub0:	ldn rb    		; set up rb to point correctly
	inc rb
	bnz csub0
csee_sub:
	lda r7          ; move past next address  (store next in in RF for later)
	phi rf
	lda r7
	plo rf
           ldn     r7                  ; get type byte
           smi     86h                 ; check for variable
           lbnz    cseefunc            ; jump if not
	   sep scall
	   dw f_inmsg
	   db 'VARIABLE ',0
	   inc r7		       ; skip variable mark
	   push r7
seevname:
	inc	   r7		       ; point to name
	ldn	   r7
	lbz seeveq
	sep scall
	dw disp
	lbr seevname
seeveq:
	sep scall
	dw crlfout
	;;  need to see if we need an allot here 
	;; if [next]-2 == rb then we do not need it
	dec rf
	dec rf 			; next-2
	glo rf
	str r2
	glo rb   ; (next-2)-dataaddress
	sd
	plo rf
	ghi rf
	str r2
	ghi rb
	sdb
	phi rf   		; now RF is the offset
	str r2
	glo rf
	or
	lbz seevnoa            	; was equal, jump
seevallot:	
	;; ok we need to do the allot here
	push rb
	ghi rf
	shr
	phi rb
	glo rf
	shrc 
	plo rb
	sep scall
	dw typenumind    	; type count

	sep scall
	dw f_inmsg
	db 'ALLOT',10,13,0
	;;   dump all words (rf has byte count which needs +2 for the original word)
	inc rf
	inc rf
	pop rb 			; start address
	ldi 0
	phi rc
	plo rc
seesto:	
	push rb  		; save for addr disp	
	lda rb
	phi r7
	lda rb
	plo rb
	ghi r7
	phi rb
	sep scall
	dw typenumind   	; print data
	
	pop rb
	pop r7
	push r7
	push rb
seevnamea:
	inc	   r7		       ; point to name
	ldn	   r7
	lbz seevdata
	sep scall
	dw disp
	lbr seevnamea
seevdata:
	ldi ' '
	sep scall
	dw disp
	glo rc
	plo rb
	ghi rc
	phi rb
	inc rc
	inc rc    		; increase count
	sep scall
	dw typenumind
	pop rb  		; print n  
	

	sep scall		;print !
	dw f_inmsg
	db '+ !',10,13,0
	inc rb			; point to next word
	inc rb
	dec rf			; two less bytes
	dec rf
	;;  stop when rf is zero (assumes rf was even)
	glo rf
	lbnz seesto
	ghi rf
	lbnz seesto
	pop r7
execdn:	sep sret   		; final CRLF already in place
	
seevnoa:	
           lda     rb                  ; get value
           phi     r7
           lda     rb
           plo     rb
           ghi     r7
           phi     rb
           
           ;sep     scall               ; display the value
           ;dw      intout
           ;   [GDJ]
           sep     scall               ; display the value
           dw      typenumind
	pop r7
seevname1:
	inc r7
	ldn r7
	bz seeveq1
	sep scall
	dw disp
	br seevname1
seeveq1:
	sep scall
	dw f_inmsg
	db ' !',0
seeexit:   sep scall
	   dw crlfout
           sep     sret
cseefunc:  ldi     ':'                 ; start with a colon
           sep     scall               ; display character
           dw      disp
           inc     r7                  ; move address to name
seefunclp: ldi     ' '                 ; need a space
           sep     scall               ; display character
           dw      disp
           ldn     r7                  ; get next token
           lbz     seeexit             ; jump if done
           smi     T_ASCII             ; check for ascii
           lbnz    seenota             ; jump if not ascii
           inc     r7                  ; move into string
seestrlp:  ldn     r7                  ; get next byte
           lbz     seenext             ; jump if done with token
           sep     scall               ; display character
           dw      disp
           inc     r7                  ; point to next character
           lbr     seestrlp            ; and continue til done
seenext:   inc     r7                  ; point to next token
           lbr     seefunclp
seenota:   ldn     r7                  ; reget token
           smi     T_NUM               ; is it a number
           lbnz    seenotn             ; jump if not a number
           inc     r7                  ; move past token
           lda     r7                  ; get number into rb
           phi     rb
           ldn     r7
           plo     rb
           glo     r7                  ; save r7
           stxd
           ghi     r7
           stxd

           ;sep     scall               ; display the number
           ;dw      intout
           ; [GDJ]
           sep     scall
           dw      typenumind             ; display the number
           irx                         ; retrieve r7
           ldxa
           phi     r7
           ldx
           plo     r7
           lbr     seenext             ; on to next token
seenotn:   ldi     high cmdtable       ; point to command table
           phi     rb
           ldi     low cmdtable
           plo     rb
           ldn     r7                  ; get token
           ani     07fh                ; strip high bit
           plo     r8                  ; token counter
seenotnlp: dec     r8                  ; decrement count
           glo     r8                  ; get count
           lbz     seetoken            ; found the token
seelp3:    lda     rb                  ; get byte from token
           ani     128                 ; was it last one?
           lbnz    seenotnlp           ; jump if it was
           lbr     seelp3              ; keep looking
seetoken:  ldn     rb                  ; get byte from token
           ani     128                 ; is it last
           lbnz    seetklast           ; jump if so
           ldn     rb                  ; retrieve byte
           sep     scall               ; display it
           dw      disp
           inc     rb                  ; point to next character
           lbr     seetoken            ; and loop til done
seetklast: ldn     rb                  ; retrieve byte
           ani     07fh                ; strip high bit
           sep     scall               ; display it
           dw      disp
           lbr     seenext             ; jump for next token

cdotqt:    ghi     r2                  ; transfer machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; point to R[6]
           lda     ra                  ; and retrieve it
           phi     r8
           ldn     ra
           plo     r8
           ldn     r8                  ; get next byte
           smi     T_ASCII             ; it must be an ascii mark
           lbnz    error               ; jump if not
           inc     r8                  ; move past ascii mark
cdotqtlp:  lda     r8                  ; get next byte
           lbz     cdotqtdn            ; jump if terinator
           smi     34                  ; check for quote
           lbz     cdotqtlp            ; do not display quotes
           dec     r8
           lda     r8
           sep     scall               ; display byte
           dw      disp
           lbr     cdotqtlp            ; loop back
cdotqtdn:  glo     r8                  ; put pointer back
           str     ra
           dec     ra
           ghi     r8
           str     ra
           lbr     good                ; and return

ckey:
           ldi     0                   ; zero the high byte
           phi     rb
	   sep     scall               ; go and get a key
           dw      getkey
	   lbr     goodpushb0

	;; [GDJ]				
ckeyq:     
	ldi 0
	phi r7
	plo r7
	phi rb

           sep     scall               ; check for key pressed
           dw      inkey
           glo     r7
	   lbr	   goodpushb0

callot:    ldi     high storage        ; get address of storage
           phi     r7
           ldi     low storage
           plo     r7
callotlp1: lda     r7                  ; get next link
           phi     r8
           ldn     r7
           plo     r8
           lda     r8                  ; get value at that link
           phi     rb
           ldn     r8
           dec     r8                  ; keep r8 pointing at link
           lbnz    callotno            ; jump if next link is not zero
           ghi     rb                  ; check high byte
           lbnz    callotno            ; jump if not zero
           lbr     callotyes
callotno:  ghi     r8                  ; transfer link to r7
           phi     r7
           glo     r8
           plo     r7
           lbr     callotlp1           ; and keep looking
callotyes: inc     r7                  ; point to type byte
           ldn     r7                  ; get it
           smi     FVARIABLE           ; it must be a variable
           lbnz    error               ; jump if not
           sep     scall               ; get word from stack
           dw      pop
           lbdf    error               ; jump if error
           glo     rb                  ; multiply by 2
           shl
           plo     rb
           ghi     rb
           shlc
           phi     rb
           sex     r2                  ; be sure X points to stack
           glo     rb                  ; add rb to r8
           str     r2
           glo     r8
           add
           plo     r8
           ghi     rb
           str     r2
           ghi     r8
           adc
           phi     r8
           dec     r7                  ; point back to link
           glo     r8                  ; and write new pointer
           str     r7
           dec     r7
           ghi     r8
           str     r7
           ldi     low freemem         ; need to adjust free memory pointer
           plo     r9                  ; put into data frame
           ghi     r8                  ; and save new memory position
           str     r9
           inc     r9
           glo     r8
           str     r9
           ldi     0                   ; zero new position
           str     r8
           inc     r8
           str     r8
           lbr     good

cmul:      sep     scall               ; get first value from stack
           dw      pop
           lbdf    error               ; jump on error
           ghi     rb                  ; transfer to r7
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get second number
           dw      pop
           lbdf    error               ; jump on error
           sep     scall               ; call multiply routine
           dw      mul16
	   lbr goodpush


cdiv:      sep     scall               ; get first value from stack
           dw      pop
           lbdf    error               ; jump on error
           ghi     rb                  ; transfer to r7
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get second number
           dw      pop
           lbdf    error               ; jump on error
           sex     r2
           ghi     r9
           stxd
           sep     scall               ; call multiply routine
           dw      div16
           irx
           ldx
           phi     r9
           ghi     rc                  ; transfer answer
           phi     rb
           glo     rc
	   lbr goodpushb0

	; [GDJ]
; following org prevents short branch out of page for bn1..bn4
; if any preceding code is added - may need change depending on
; amount of any further additions above
;           org 2e00h 

cef:       ldi     0                   ; start with zero
	   phi rb
           bn1     cef1                ; jump if ef1 not on
           ori     1                   ; signal ef1 is on
cef1:      bn2     cef2                ; jump if ef2 ot on
           ori     2                   ; signal ef2 is on
cef2:      bn3     cef3                ; jump if ef3 not on
           ori     4                   ; signal ef3 is on
cef3:      bn4     cef4                ; jump if ef4 not on
           ori     8
cef4:                       
	   lbr goodpushb0


cforget:   ghi     r2                  ; transfer machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; point to ra
           lda     ra                  ; and retrieve it
           phi     r8
           ldn     ra
           plo     r8
           ldn     r8                  ; get next byte
           smi     T_ASCII             ; it must be an ascii mark
           lbnz    error               ; jump if not
           inc     r8                  ; move into string
           sep     scall               ; find the name
           dw      findname
           lbdf    error               ; jump if not found
           glo     r8
           str     ra
           dec     ra
           ghi     r8
           str     ra
           lda     r7                  ; get next entry
           phi     rb
           ldn     r7
           plo     rb
           dec     r7
           sex     r2                  ; be sure X is pointing to stack
           glo     r7                  ; find difference in pointers
           str     r2
           glo     rb
           sm
           plo     rc
           ghi     r7
           str     r2
           ghi     rb
           smb
           phi     rc                  ; RC now has offset, RB is next descr.
forgetlp1: lda     rb                  ; get pointer
           phi     ra                  ; put into ra
           str     r2
           ldn     rb
           plo     ra
           or                          ; see if it was zero
           lbz     forgetd1            ; jump if it was
           glo     rc                  ; subtract RC from RA
           str     r2
           glo     ra
           sm
           str     rb                  ; store back into pointer
           dec     rb
           ghi     rc
           str     r2
           ghi     ra
           smb
           str     rb
           ghi     ra                  ; transfer value
           phi     rb
           glo     ra
           plo     rb
           lbr     forgetlp1           ; loop until done

forgetd1:  lda     r7                  ; get next entry
           phi     rb
           ldn     r7
           plo     rb
           dec     r7

           ldi     low freemem         ; get end of memory pointer
           plo     r9                  ; and place into data frame
           lda     r9                  ; get free memory position
           phi     r8
           ldn     r9
           plo     r8
           inc     r8                  ; account for zero bytes at end
           inc     r8
           glo     rb                  ; subtract RB from R8
           str     r2
           glo     r8
           sm
           plo     r8
           ghi     rb
           str     r2
           ghi     r8
           smb
           phi     r8                  ; r8 now has number of bytes to move
forgetlp:  lda     rb                  ; get byte from higher memory
           str     r7                  ; write to lower memory
           inc     r7                  ; point to next position
           dec     r8                  ; decrement the count
           glo     r8                  ; check for zero
           lbnz    forgetlp
           ghi     r8
           lbnz    forgetlp
           dec     r7                  ; move back to freemem position
           dec     r7 
           glo     r7                  ; store back into freemem pointer
           str     r9
           dec     r9
           ghi     r7
           str     r9
           lbr     good                ; and return

cerror:    sep     scall               ; get number fro stack
           dw      pop
           lbdf    error               ; jump on error
           glo     rb                  ; get returned value
           lbr     execret             ; return to caller



cout:      sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump on error
           glo     rb
           plo     r8                  ; hold onto it
           sep     scall               ; get port value
           dw      pop
           lbdf    error               ; jump on error
           glo     r8                  ; get value
           str     r2                        ; store into memory for out (assume X=2)
           glo     rb                  ; get port
	   ani     7	               ; value must be 1-7
	   lbz     error
           smi     1                   ; try port 1
	;;  using a jump table is much shorter than old code
	;;  we take port (0-6) *2 and add outtable
	;;  then we shift PC to RB which will do the work and shift back to P=3
	shl  			; *2
	adi low outtable
	plo rf
	ldi high outtable
	adci 0
	phi rf
	sep rf
	dec r2
	lbr good

outtable:
	out 1
	sep r3
	out 2
	sep r3
	out 3
	sep r3
	out 4
	sep r3
	out 5
	sep r3
	out 6
	sep r3
	out 7
	sep r3


cinp:	   sep     scall               ; get port
           dw      pop
           lbdf    error               ; jump on error
           glo     rb                  ; get port
	   ani     7
	   lbz     error
           smi     1                   ; check port 1
  	   shl
	   adi low intable
	   plo rf
	   ldi high intable
	   adci 0
	   phi rf
	   ldi 0
	   phi rb
	   sep rf
	   lbr goodpushb0
	   
	
intable:
	inp 1
	sep r3
	inp 2
	sep r3
	inp 3
	sep r3
	inp 4
	sep r3
	inp 5
	sep r3
	inp 6
	sep r3
	inp 7
	sep r3





; [GDJ]
cspat:     mov     r8,fstack           ; get stack address pointer
           ; get stack address 
           lda     r8
           phi     rb
           ldn     r8
           plo     rb

           ; add 1 byte offset
           mov     r7, 1
           sex     r2                  ; be sure X points to stack
           glo     r7                  ; perform addition
           str     r2
           glo     rb
           add
           plo     rb
           ghi     r7
           str     r2
           ghi     rb
           adc
	   lbr goodpushb


; -----------------------------------------------------------------
; additions April 2022  GDJ
; -----------------------------------------------------------------
ccmove:    sep     scall               ; get top of stack
           dw      pop
           lbdf    error               ; jump if error
           mov     rc,rb               ; rc is count of bytes
           sep     scall               ; get top of stack
           dw      pop
           lbdf    error               ; jump if error
           mov     r8,rb               ; r8 is destination address
           sep     scall               ; get top of stack
           dw      pop
           lbdf    error               ; jump if error
           mov     r7,rb               ; r7 is source address

           ; transfer data
           ; begin check for zero byte count else tragedy could result
cmovelp:   glo     rc
           lbnz    cmovestr
           ghi     rc
           lbnz    cmovestr
           lbr     cmovertn
cmovestr:  lda     r7
           str     r8
           inc     r8
           dec     rc
           lbr     cmovelp
cmovertn:  lbr     good                ; return to caller


csetq:     sep     scall               ; get top of stack
           dw      pop
           lbdf    error               ; jump if error
           glo     rb                  ; get low of return value
	;; while this does add a nop
	;; it saves several bytes over jumping
	   lsz
	   seq
	   nop
	   lsnz
  	   req
	   nop
           lbr good


cdecimal:  mov     rd, basen
           ldi     10
	   br basesave

chex:      mov     rd, basen
           ldi     16
basesave:	
           str     rd
           lbr     good

crat:      sep     scall               ; get value from return stack
           dw      rpop
           sep     scall               ; put back on return stack
           dw      rpush 
	   lbr goodpush


crand:     sep     scall
           dw      randbyte
           ghi     r8
           plo     rb
           ldi     0
	   lbr goodpushb


; VT100 ansi control
; printf("%c[%d;%dH",ESC,y,x);
cgotoxy:   sep     scall               ; get top of stack
           dw      pop
           lbdf    error               ; jump if error
           mov     rd,rb               ; rd is Y coord (row)
           sep     scall               ; get top of stack
           dw      pop
           lbdf    error               ; jump if error
           mov     r8,rb               ; r8 is X coord (col)

           ; send CSI sequence
           sep    scall
           dw     f_inmsg
           db     27, '[', 0

           ; Y
           mov     rf, buffer
           sep     scall
           dw      f_uintout
           ldi     0                   ; write terminator
           str     rf
           mov     rf, buffer
           sep     scall
           dw      f_msg

           ; type separator
           ldi     ';'
           sep     scall               ; call type routine
           dw      f_tty

           ; X
           mov     rf, buffer
           mov     rd,r8
           sep     scall
           dw      f_uintout
           ldi     0                   ; write terminator
           str     rf
           mov     rf, buffer
           sep     scall
           dw      f_msg
           
           ; type ending char
           ldi     'H'
           sep     scall               ; call type routine
           dw      f_tty

           lbr     good


; -----------------------------------------------------------------------------
; 'C' style operators for bit shifting, note no range check on number of shifts
; -----------------------------------------------------------------------------
clshift:   sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           glo     rb                  ; move number 
           plo     r7                  ; number of shifts

           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           mov     r8,rb               ; value to shift left

           glo     r7                  ; zero shift is identity 
           lbnz    lshiftlp
           lbr     lshiftret           ; return with no shift

lshiftlp:  glo     r8
           shl                         ; shift lo byte
           plo     r8
           ghi     r8
           shlc                        ; shift hi byte with carry
           phi     r8
           dec     r7
           glo     r7
           lbnz    lshiftlp

lshiftret: mov     rb,r8
	   lbr goodpush


crshift:   sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           glo     rb                  ; move number 
           plo     r7                  ; number of shifts

           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           mov     r8,rb

           glo     r7                  ; zero shift is identity 
           lbnz    rshiftlp
           lbr     rshiftret           ; return with no shift

rshiftlp:  ghi     r8
           shr                         ; shift hi byte
           phi     r8
           glo     r8
           shrc                        ; shift lo byte with carry
           plo     r8
           dec     r7
           glo     r7
           lbnz    rshiftlp
   
rshiftret: mov     rb,r8
	   lbr goodpush


; delay for approx 1 millisecond on 4MHz 1802
cdelay:    sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           glo     rb                  ; move number 
           plo     r7
           ghi     rb
           phi     r7

delaylp1:  ldi     60
delaylp2:  nop
           smi     1
           lbnz    delaylp2

           dec     r7
           glo     r7
           lbnz    delaylp1
           ghi     r7
           lbnz    delaylp1
           lbr     good

	
cexec:	   sep scall
	   dw pop
  	   lbdf error
           mov     r8, jump            ; point to jump address
           ldi     0c0h                ; lbr
           str     r8                  ; store it
           inc     r8
	   ghi     rb
           str     r8
           inc     r8
	   glo     rb
           str     r8
	   sep     scall
	   dw      cexec0
	;; if we return RB is pushed on stack
	   lbr goodpush
cexec0:	   lbr jump   		; transfer to user code. If it returns, it goes back to my scaller


; -----------------------------------------------------------------------------
; Load contents of dictionary - any session defined words/values will be zapped
; -----------------------------------------------------------------------------

cbload:    push    rf
           push    rd
           push    rc
           
        mov     rf, extblock        ; source address
	mov rd,himem
           mov     rc, endextblock-extblock  ; block size

bloadlp:   lda     rf
           str     rd
           inc     rd
           dec     rc
           glo     rc
           lbnz    bloadlp
           ghi     rc
           lbnz    bloadlp

           pop     rc
           pop     rd
           pop     rf
           lbr     mainlp              ; back to main loop


; -----------------------------------------------------------------


#ifdef ANYROM
csave:     push    rf                  ; save consumed registers
           push    rc
           sep     scall               ; open XMODEM channel for writing
           dw      xopenw
           mov     rf,freemem          ; need pointer to freemem
           lda     rf                  ; get high address of free memory
	   smi     high himem
           phi     rc                  ; store into count
           ldn     rf                  ; get low byte of free memory
           plo     rc                  ; store into count
           inc     rc                  ; account for terminator
           inc     rc
           mov     rf,buffer           ; temporary storage
           ghi     rc                  ; get high byte of count
           str     rf                  ; store it
           inc     rf                  ; point to low byte
           glo     rc                  ; get it
           str     rf                  ; store into buffer
           dec     rf                  ; move back to buffer
           mov     rc,2                ; 2 bytes of length
           sep     scall               ; write to XMODEM channel
           dw      xwrite
           mov     rf,buffer           ; point to where count is
           lda     rf                  ; retrieve high byte
           phi     rc                  ; set into count for write
           ldn     rf                  ; get low byte
           plo     rc                  ; rc now has count of bytes to save
           mov     rf,himem            ; point to forth data
           sep     scall               ; write it all out
           dw      xwrite
           sep     scall               ; close XMODEM channel
           dw      xclosew
           pop     rc                  ; recover consumed registers
           pop     rf
           lbr     good                ; all done
#endif

#ifdef ELFOS
csave:     ghi     r2                  ; transfer machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; point to ra
           lda     ra                  ; and retrieve it
           phi     rb
           ldn     ra
           plo     rb
           ldn     rb                  ; get next byte
           smi     T_ASCII             ; it must be an ascii mark
           lbnz    error               ; jump if not
           inc     rb                  ; move into string
           sep     scall               ; setup file descriptor
           dw      setupfd
           ghi     rb                  ; get filename
           phi     rf
           glo     rb
           plo     rf
           ldi     1                   ; create if nonexistant
           plo     r7
           sep     scall               ; open the file
           dw      o_open
           ldi     high freemem        ; point to control data
           phi     rf
           ldi     low freemem
           plo     rf
           ldi     0                   ; need to write 2 bytes
           phi     rc
           ldi     2
           plo     rc
           sep     scall               ; write the control block
           dw      o_write
           ldi     high storage        ; point to data storage
           phi     rf
           stxd                        ; store copy on stack for sub
           ldi     low storage
           plo     rf
           str     r2
           ldi     low freemem         ; pointer to free memory
           plo     r9                  ; put into data segment pointer
           inc     r9                  ; point to low byte 
           ldn     r9                  ; retrieve low byte 
           sm                          ; subtract start address
           plo     rc                  ; and place into count
           irx                         ; point to high byte
           dec     r9
           ldn     r9                  ; get high byte of free mem
           smb                         ; subtract start
           phi     rc                  ; place into count
           inc     rc                  ; account for terminator
           inc     rc
           sep     scall               ; write the data block
           dw      o_write
           sep     scall               ; close the file
           dw      o_close
           ldi     0                   ; terminate command
           dec     rb
           str     rb
           lbr     good                ; return
#endif

#ifdef ANYROM
cload:     push    rf                  ; save consumed registers
           push    rc
           push    re                  ; [GDJ]
           sep     scall               ; open XMODEM channel for reading
           dw      xopenr
           mov     rf,buffer           ; point to buffer
           mov     rc,2                ; need to read 2 bytes
           sep     scall               ; read them
           dw      xread
           mov     rf,buffer           ; point to buffer
           lda     rf                  ; retrieve count
           phi     rc                  ; into rc
           ldn     rf
           plo     rc                  ; rc now has count of bytes to read
           mov     rf,himem            ; point to forth data
           sep     scall               ; now read program data
           dw      xread
           
           ; temp removal [GDJ]
           ;sep     scall               ; close XMODEM channel
           ;dw      xcloser
           pop     re                  ; [GDJ]
           pop     rc                  ; recover consumed registers
           pop     rf
           ; irx                         ; [GDJ] remove exec portions from stack
           ; irx
           ; irx
           ; irx

           lbr     mainlp              ; back to main loop
#endif

#ifdef ELFOS
cload:     ghi     r2                  ; transfer machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; point to ra
           lda     ra                  ; and retrieve it
           phi     rb
           ldn     ra
           plo     rb
           ldn     rb                  ; get next byte
           smi     T_ASCII             ; it must be an ascii mark
           lbnz    error               ; jump if not
           inc     rb                  ; move into string
           sep     scall               ; setup file descriptor
           dw      setupfd
           ghi     rb                  ; get filename
           phi     rf
           glo     rb
           plo     rf
           ldi     0                   ; create if nonexistant
           plo     r7
           sep     scall               ; open the file
           dw      o_open
           lbdf    error               ; jump if file is not opened
           ldi     high freemem        ; point to control data
           phi     rf
           ldi     low freemem
           plo     rf
           ldi     0                   ; need to read 2 bytes
           phi     rc
           ldi     2
           plo     rc
           sep     scall               ; read the control block
           dw      o_read
           ldi     high storage        ; point to data storage
           phi     rf
           stxd                        ; store copy on stack for sub
           ldi     low storage
           plo     rf
           str     r2
           ldi     low freemem         ; pointer to free memory
           plo     r9                  ; put into data segment pointer
           inc     r9                  ; point to low byte 
           ldn     r9                  ; retrieve low byte 
           sm                          ; subtract start address
           plo     rc                  ; and place into count
           irx                         ; point to high byte
           dec     r9
           ldn     r9                  ; get high byte of free mem
           smb                         ; subtract start
           phi     rc                  ; place into count
           inc     rc                  ; account for terminator
           inc     rc
           sep     scall               ; read the data block
           dw      o_read
           sep     scall               ; close the file
           dw      o_close
           irx                         ; remove exec portions from stack
           irx
           irx
           irx
           lbr     mainlp              ; back to main loop
#endif

cbye:      lbr     exitaddr

#ifdef ELFOS
setupfd:   ldi     high fildes         ; get address of file descriptor
           phi     rd
           ldi     low fildes
           plo     rd
           inc     rd                  ; point to dta entry
           inc     rd
           inc     rd
           inc     rd
           ldi     high dta            ; get address of dta
           str     rd                  ; and store it
           inc     rd
           ldi     low dta
           str     rd
           ldi     high fildes         ; get address of file descriptor
           phi     rd
           ldi     low fildes
           plo     rd
           sep     sret                ; return to caller
#endif


; **********************************************************
; ***** Convert string to uppercase, honor quoted text *****
; **********************************************************
touc:      ldn     rf                  ; check for quote
           smi     022h
           lbz     touc_qt             ; jump if quote
           ldn     rf                  ; get byte from string
           lbz     touc_dn             ; jump if done
           smi     'a'                 ; check if below lc
           lbnf    touc_nxt            ; jump if so
           smi     27                  ; check upper rage
           lbdf    touc_nxt            ; jump if above lc
           ldn     rf                  ; otherwise convert character to lc
           smi     32
           str     rf
touc_nxt:  inc     rf                  ; point to next character
           lbr     touc                ; loop to check rest of string
touc_dn:   sep     sret                ; return to caller
touc_qt:   inc     rf                  ; move past quote
touc_qlp:  lda     rf                  ; get next character
           lbz     touc_dn             ; exit if terminator found
           smi     022h                ; check for quote charater
           lbz     touc                ; back to main loop if quote
           lbr     touc_qlp            ; otherwise keep looking


; [GDJ] type out number according to selected BASE and signed/unsigned flag
typenumind:   ; get BASE  ; enter here to have 0x or 0# put on front
        push    rf                  ; save rf for tokenizer
	ldi '0'
	sep scall
	dw disp
        mov     rd, basen
        ldn     rd
        smi     10
	bz typenuminddec
	ldi 'x'
	lskp
typenuminddec:
	ldi '#'
	sep scall
	dw disp
	ldi 0
	plo re  		; always unsigned here
	br typenumx

typenum:   ; get BASE  ; enter here for normal output
           push    rf                  ; save rf for tokenizer
typenumx:	
           mov     rd, basen
           ldn     rd
           smi     10
           lbnz    typehex
           mov     rd,rb
           mov     rf, buffer
           glo     re
           lbz     typenumU
           sep     scall
           dw      f_intout
           lbr     typeout
typenumU:  sep     scall
           dw      f_uintout
           lbr     typeout

typehex:
	   mov     rd,rb
           mov     rf, buffer
           ghi     rd
           lbz     hexbyte
           sep     scall
           dw      f_hexout4
           lbr     typeout
hexbyte:   sep     scall
           dw      f_hexout2

typeout:   ldi     ' '                 ; add space
           str     rf
           inc     rf
           ldi     0                   ; and terminator
           str     rf
           mov     rf, buffer
           sep     scall
           dw      f_msg
           pop     rf
           sep     sret                ; return to caller



; *************************************
; *** Check if character is numeric ***
; *** D - char to check             ***
; *** Returns DF=1 if numeric       ***
; ***         DF=0 if not           ***
; *************************************
isnum:     plo     re                  ; save a copy
           smi     '0'                 ; check for below zero
           lbnf    fails               ; jump if below
           smi     10                  ; see if above
           lbdf    fails               ; fails if so
passes:    smi     0                   ; signal success
           lskp
fails:     adi     0                   ; signal failure
           glo     re                  ; recover character
           sep     sret                ; and return

err:       smi     0                   ; signal an error
           sep     sret                ; and return
           
           
; **********************************
; *** check D if hex             ***
; *** Returns DF=1 - hex         ***
; ***         DF=0 - non-hex     ***
; **********************************
ishex:     sep     scall               ; see if it is numeric
           dw      isnum
           plo     re                  ; keep a copy
           lbdf    passes              ; jump if it is numeric
           smi     'A'                 ; check for below uppercase a
           lbnf    fails               ; value is not hex
           smi     6                   ; check for less then 'G'
           lbnf    passes              ; jump if so
           glo     re                  ; recover value
           smi     'a'                 ; check for lowercase a
           lbnf    fails               ; jump if not
           smi     6                   ; check for less than 'g'
           lbnf    passes              ; jump if so
           lbr     fails



	; clear tos, himem & rstack blocks
	;; this assumes stuff is at 7C00-7EFF ?? 
clrstacks: mov     r7, 300h            ; clear 768 bytes
#if MCHIP
	;;  assuming this is true [gnr]
	mov rc,0FC00h
#else	
           mov     rc, 7c00h
#endif	
           
clrmemlp:  ldi     0h
           str     rc
           inc     rc
           dec     r7
           glo     r7
           lbnz    clrmemlp
           ghi     r7
           lbnz    clrmemlp
           rtn


;--------------------------------------------------------------
;    Read byte from UART if char available  
;    return in r7.0 - else return null
;
;    from original bios code of Bob Armstrong
;    modified for non-blocking console input
;--------------------------------------------------------------
inkey:  ldi     015h            ; need UART line status register
        str     r2              ; prepare for out
        out     UART_SELECT     ; write to register select port
        dec     r2              ; correct for inc on out
        inp     UART_DATA       ; read line status register
        ani     1               ; mask for data ready bit
        lbz     nokey           ; return if no bytes to read
        ldi     010h            ; select data register
        str     r2              ; prepare for out
        out     UART_SELECT     ; write to register select port
        dec     r2              ; back to free spot
        inp     UART_DATA       ; read UART data register
        plo     r7
        rtn
        
nokey:  ldi     0h
        plo     r7
        rtn


clist:	mov r7,storage
clist0:
	push r7
	ldn r7
	bnz clist1
	inc r7
	ldn r7
	bnz clist1
	pop r7
	lbr good
clist1:	
	pop r7
	push r7
	sep scall
	dw csee_sub0
	pop r7
	ldn r7
	phi rb
	inc r7
	ldn r7
	plo r7
	ghi rb
	phi r7
	lbr clist0
	


;------------------------------------------------------------------
; Generate a psuedo-random byte
;
; IN:       N/A
; OUT:      D=psuedo-random number
; TRASHED:  RA
;
; This PRNG was extracted from AdventureLand
; Copyright (C) 2019 by Richard Goedeken, All Rights Reserved.
;
; modified GDJ 2021 --> return in r8.1, changed r7 to ra
;
; Update1: 23 Jan 2022 no period has been determined, thus 
; far a 320kB file has been checked - 12 minutes on the PicoElf2
; gave 20479 lines of 16 samples --> 327664 bytes
;
; Update2: 25 Feb 2022 translated this code into 'C' and 
; discovered a period of P = 2020966655
; after which the sequence repeats!
; other init params often gave the same period, however the
; initial arrays:
;        {1,3,5,7} gave a period of 543537919
;   {12,137,98,32} gave a period of 1080837375
;------------------------------------------------------------------
randbyte:   mov rd,rseed
            sex rd

            ldn rd      ; D = VarX
            adi 1
            str rd
            inc rd
            lda rd      ; D = VarA
            inc rd
            xor         ; D = VarA XOR VarC
            dec rd
            dec rd
            dec rd
            xor         ; D = VarA XOR VarC XOR VarX
            inc rd
            str rd      ; VarA = D
            inc rd
            add
            stxd
            shr
            xor
            inc rd
            inc rd
            add
            str rd
            phi r8      ; added GDJ

            sex r2      ;    ...
            rtn




hello:     db      'Rc/Forth 0.3'
crlf:      db       10,13,0
prompt:    db      'ok ',0
msempty:   db      'stack empty',10,13,0
msgerr:    db      'err',10,13,0
cmdtable:  db      'WHIL',('E'+80h)
           db      'REPEA',('T'+80h)
           db      'I',('F'+80h)
           db      'ELS',('E'+80h)
           db      'THE',('N'+80h)
           db      'VARIABL',('E'+80h)
           db      (':'+80h)
           db      (';'+80h)
           db      'DU',('P'+80h)
           db      'DRO',('P'+80h)
           db      'SWA',('P'+80h)
           db      ('+'+80h)
           db      ('-'+80h)
           db      ('*'+80h)
           db      ('/'+80h)
           db      ('.'+80h)
           db      'U',('.'+80h)
           db      ('I'+80h)
           db      'AN',('D'+80h)
           db      'O',('R'+80h)
           db      'XO',('R'+80h)
           db      'C',('R'+80h)
           db      'ME',('M'+80h)
           db      'D',('O'+80h)
           db      'LOO',('P'+80h)
           db      '+LOO',('P'+80h)
           db      ('='+80h)
           db      '<',('>'+80h)
           db      ('<'+80h)           ; [GDJ]
           db      'U',('<'+80h)       ; [GDJ]
           db      'BEGI',('N'+80h)
           db      'UNTI',('L'+80h)
           db      'R',('>'+80h)
           db      '>',('R'+80h)
           db      'R',('@'+80h)       ; [GDJ]
           db      'WORD',('S'+80h)
           db      'EMI',('T'+80h)
           db      'EMIT',('P'+80h)    ; [GDJ]
           db      'DEPT',('H'+80h)
           db      'RO',('T'+80h)
           db      '-RO',('T'+80h)
           db      'OVE',('R'+80h)
           db      ('@'+80h)
           db      ('!'+80h)
           db      'C',('@'+80h)
           db      'C',('!'+80h)
           db      'CMOV',('E'+80h)    ; [GDJ]
           db      '.',(34+80h)
           db      'KE',('Y'+80h)
           db      'KEY',('?'+80h)     ; [GDJ]
           db      'ALLO',('T'+80h)
           db      'ERRO',('R'+80h)
           db      'SE',('E'+80h)
           db      'FORGE',('T'+80h)
           db      'OU',('T'+80h)
           db      'IN',('P'+80h)
           db      'E',('F'+80h)
           db      'SET',('Q'+80h)     ; [GDJ]
           db      'SAV',('E'+80h)
           db      'LOA',('D'+80h)
           db      'BY',('E'+80h)
           db      'SP',('@'+80h)      ; [GDJ]
           db      'DECIMA',('L'+80h)  ; [GDJ]
           db      'HE',('X'+80h)      ; [GDJ]
           db      '<',('<'+80h)       ; [GDJ]
           db      '>',('>'+80h)       ; [GDJ]
           db      'DELA',('Y'+80h)    ; [GDJ]
           db      'BLOA',('D'+80h)    ; [GDJ]
           db      'GOTOX',('Y'+80h)   ; [GDJ]
           db      'RAN',('D'+80h)     ; [GDJ]
	   db	   'EXE',('C'+80h) 
	   db      'LIS',('T'+80h)
	   db      'X',('.'+80h)
           db      0                   ; no more tokens

cmdvecs:   dw      cwhile              ; 81h
           dw      crepeat             ; 82h
           dw      cif                 ; 83h
           dw      celse               ; 84h
           dw      cthen               ; 85h
           dw      cvariable           ; 86h
           dw      ccolon              ; 87h
           dw      csemi               ; 88h
           dw      cdup                ; 89h
           dw      cdrop               ; 8ah
           dw      cswap               ; 8bh
           dw      cplus               ; 8ch
           dw      cminus              ; 8dh
           dw      cmul                ; 8eh
           dw      cdiv                ; 8fh
           dw      cdot                ; 90h
           dw      cudot               ; 91h
           dw      ci                  ; 92h
           dw      cand                ; 93h
           dw      cor                 ; 94h
           dw      cxor                ; 95h
           dw      ccr                 ; 96h
           dw      cmem                ; 97h
           dw      cdo                 ; 98h
           dw      cloop               ; 99h
           dw      cploop              ; 9ah
           dw      cequal              ; 9bh
           dw      cunequal            ; 9ch
           dw      cless               ; 9dh [GDJ]
           dw      culess              ; 9eh [GDJ]
           dw      cbegin              ; 9fh
           dw      cuntil              ; a0h
           dw      crgt                ; a1h
           dw      cgtr                ; a2h
           dw      crat                ; a3h [GDJ]
           dw      cwords              ; a4h
           dw      cemit               ; a5h
           dw      cemitp              ; a6h [GDJ]
           dw      cdepth              ; a7h
           dw      crot                ; a8h
           dw      cmrot               ; a9h
           dw      cover               ; aah
           dw      cat                 ; abh
           dw      cexcl               ; ach
           dw      ccat                ; adh
           dw      ccexcl              ; aeh
           dw      ccmove              ; afh [GDJ]
           dw      cdotqt              ; b0h
           dw      ckey                ; b1h
           dw      ckeyq               ; b2h [GDJ]
           dw      callot              ; b3h
           dw      cerror              ; b4h
           dw      csee                ; b5h
           dw      cforget             ; b6h
           dw      cout                ; b7h
           dw      cinp                ; b8h
           dw      cef                 ; b9h
           dw      csetq               ; bah [GDJ]
           dw      csave               ; bbh
           dw      cload               ; bch
           dw      cbye                ; bdh
           dw      cspat               ; beh [GDJ]
           dw      cdecimal            ; bfh [GDJ]
           dw      chex                ; c0h [GDJ]
           dw      clshift             ; c1h [GDJ]
           dw      crshift             ; c2h [GDJ]
           dw      cdelay              ; c3h [GDJ]
           dw      cbload              ; c4h [GDJ]
           dw      cgotoxy             ; c5h [GDJ]
           dw      crand               ; c6h [GDJ]
	   dw      cexec               ; c7h [gnr]
	   dw	   clist	       ; c8h [gnr]
	   dw      cdotx


; this precompiled BASE variable is loaded at startup freemem
; important to zero next word else 'words' may interpret
; startup random data as valid (rarely) which will type garbage 
#ifdef MCHIP
basev:  db 083h, 018h,
        db 07ch, 0ffh, 0c0h, 029h, 040h, 083h, 018h, 086h, ; next word address + VARIABLE
        db 0feh, 042h, 041h, 053h, 045h, 000h, 000h, 00ah  ; T_NUM 'BASE' VALUE
        db 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h  ; zero next word
#else
basev:  db 003h, 018h,					   ; this must be basen+1 word
        db 07ch, 0ffh, 0c0h, 029h, 040h, 003h, 018h, 086h, ; next word address + VARIABLE
        db 0feh, 042h, 041h, 053h, 045h, 000h, 000h, 00ah, ; T_NUM 'BASE' VALUE
        db 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h  ; zero next word
#endif
	

#ifdef STGROM
extblock:
            db  07eh, 0ffh, 07dh, 0ffh, 07ch, 0ffh, 007h, 0c8h, 
            db  07ch, 0ffh, 0c0h, 02fh, 01bh, 003h, 018h, 086h, 
            db  0feh, 042h, 041h, 053h, 045h, 000h, 000h, 00ah, 
            db  003h, 024h, 087h, 0feh, 04eh, 049h, 050h, 000h, 
            db  08bh, 08ah, 088h, 000h, 003h, 031h, 087h, 0feh, 
            db  054h, 055h, 043h, 04bh, 000h, 08bh, 0aah, 088h, 
            db  000h, 003h, 047h, 087h, 0feh, 050h, 049h, 043h, 
            db  04bh, 000h, 0ffh, 000h, 002h, 08eh, 0ffh, 000h, 
            db  002h, 08ch, 0beh, 08ch, 0abh, 088h, 000h, 003h, 
            db  054h, 087h, 0feh, 032h, 044h, 055h, 050h, 000h, 
            db  0aah, 0aah, 088h, 000h, 003h, 062h, 087h, 0feh, 
            db  032h, 044h, 052h, 04fh, 050h, 000h, 08ah, 08ah, 
            db  088h, 000h, 003h, 080h, 087h, 0feh, 032h, 04fh, 
            db  056h, 045h, 052h, 000h, 0ffh, 000h, 003h, 0feh, 
            db  050h, 049h, 043h, 04bh, 000h, 0ffh, 000h, 003h, 
            db  0feh, 050h, 049h, 043h, 04bh, 000h, 088h, 000h, 
            db  003h, 090h, 087h, 0feh, 032h, 053h, 057h, 041h, 
            db  050h, 000h, 0a2h, 0a9h, 0a1h, 0a9h, 088h, 000h, 
            db  003h, 09eh, 087h, 0feh, 054h, 052h, 055h, 045h, 
            db  000h, 0ffh, 000h, 001h, 088h, 000h, 003h, 0adh, 
            db  087h, 0feh, 046h, 041h, 04ch, 053h, 045h, 000h, 
            db  0ffh, 000h, 000h, 088h, 000h, 003h, 0b6h, 087h, 
            db  0feh, 04ah, 000h, 0a3h, 088h, 000h, 003h, 0c3h, 
            db  087h, 0feh, 031h, 02bh, 000h, 0ffh, 000h, 001h, 
            db  08ch, 088h, 000h, 003h, 0d0h, 087h, 0feh, 031h, 
            db  02dh, 000h, 0ffh, 000h, 001h, 08dh, 088h, 000h, 
            db  003h, 0ddh, 087h, 0feh, 032h, 02bh, 000h, 0ffh, 
            db  000h, 002h, 08ch, 088h, 000h, 003h, 0eah, 087h, 
            db  0feh, 032h, 02dh, 000h, 0ffh, 000h, 002h, 08dh, 
            db  088h, 000h, 003h, 0f7h, 087h, 0feh, 030h, 03dh, 
            db  000h, 0ffh, 000h, 000h, 09bh, 088h, 000h, 004h, 
            db  005h, 087h, 0feh, 04eh, 04fh, 054h, 000h, 0feh, 
            db  030h, 03dh, 000h, 088h, 000h, 004h, 010h, 087h, 
            db  0feh, 055h, 03eh, 000h, 08bh, 09eh, 088h, 000h, 
            db  004h, 028h, 087h, 0feh, 055h, 03eh, 03dh, 000h, 
            db  0feh, 032h, 044h, 055h, 050h, 000h, 0feh, 055h, 
            db  03eh, 000h, 0a2h, 09bh, 0a1h, 094h, 088h, 000h, 
            db  004h, 03ch, 087h, 0feh, 055h, 03ch, 03dh, 000h, 
            db  0feh, 055h, 03eh, 03dh, 000h, 0feh, 04eh, 04fh, 
            db  054h, 000h, 088h, 000h, 004h, 046h, 087h, 0feh, 
            db  03eh, 000h, 08bh, 09dh, 088h, 000h, 004h, 057h, 
            db  087h, 0feh, 03ch, 03dh, 000h, 0feh, 03eh, 000h, 
            db  0feh, 04eh, 04fh, 054h, 000h, 088h, 000h, 004h, 
            db  066h, 087h, 0feh, 03eh, 03dh, 000h, 09dh, 0feh, 
            db  04eh, 04fh, 054h, 000h, 088h, 000h, 004h, 075h, 
            db  087h, 0feh, 030h, 03eh, 000h, 0ffh, 000h, 000h, 
            db  0feh, 03eh, 000h, 088h, 000h, 004h, 082h, 087h, 
            db  0feh, 030h, 03ch, 000h, 0ffh, 000h, 000h, 09dh, 
            db  088h, 000h, 004h, 090h, 087h, 0feh, 046h, 052h, 
            db  045h, 045h, 000h, 097h, 091h, 096h, 088h, 000h, 
            db  004h, 09fh, 087h, 0feh, 02bh, 021h, 000h, 08bh, 
            db  0aah, 0abh, 08ch, 08bh, 0ach, 088h, 000h, 004h, 
            db  0afh, 087h, 0feh, 02dh, 021h, 000h, 08bh, 0aah, 
            db  0abh, 08bh, 08dh, 08bh, 0ach, 088h, 000h, 004h, 
            db  0beh, 087h, 0feh, 02ah, 021h, 000h, 08bh, 0aah, 
            db  0abh, 08eh, 08bh, 0ach, 088h, 000h, 004h, 0ceh, 
            db  087h, 0feh, 02fh, 021h, 000h, 08bh, 0aah, 0abh, 
            db  08bh, 08fh, 08bh, 0ach, 088h, 000h, 004h, 0deh, 
            db  087h, 0feh, 043h, 02bh, 021h, 000h, 089h, 0a2h, 
            db  0adh, 08ch, 0a1h, 0aeh, 088h, 000h, 004h, 0efh, 
            db  087h, 0feh, 043h, 02dh, 021h, 000h, 089h, 0a2h, 
            db  0adh, 08bh, 08dh, 0a1h, 0aeh, 088h, 000h, 005h, 
            db  000h, 087h, 0feh, 040h, 02bh, 000h, 089h, 0abh, 
            db  08bh, 0ffh, 000h, 002h, 08ch, 08bh, 088h, 000h, 
            db  005h, 00ah, 087h, 0feh, 03fh, 000h, 0abh, 091h, 
            db  088h, 000h, 005h, 019h, 087h, 0feh, 04eh, 045h, 
            db  047h, 000h, 0ffh, 000h, 000h, 08bh, 08dh, 088h, 
            db  000h, 005h, 030h, 087h, 0feh, 04dh, 049h, 04eh, 
            db  000h, 0feh, 032h, 044h, 055h, 050h, 000h, 0feh, 
            db  03eh, 000h, 083h, 08bh, 085h, 08ah, 088h, 000h, 
            db  005h, 045h, 087h, 0feh, 04dh, 041h, 058h, 000h, 
            db  0feh, 032h, 044h, 055h, 050h, 000h, 09dh, 083h, 
            db  08bh, 085h, 08ah, 088h, 000h, 005h, 05eh, 087h, 
            db  0feh, 055h, 04dh, 049h, 04eh, 000h, 0feh, 032h, 
            db  044h, 055h, 050h, 000h, 0feh, 055h, 03eh, 000h, 
            db  083h, 08bh, 085h, 08ah, 088h, 000h, 005h, 074h, 
            db  087h, 0feh, 055h, 04dh, 041h, 058h, 000h, 0feh, 
            db  032h, 044h, 055h, 050h, 000h, 09eh, 083h, 08bh, 
            db  085h, 08ah, 088h, 000h, 005h, 083h, 087h, 0feh, 
            db  03fh, 044h, 055h, 050h, 000h, 089h, 083h, 089h, 
            db  085h, 088h, 000h, 005h, 099h, 087h, 0feh, 041h, 
            db  042h, 053h, 000h, 089h, 0feh, 030h, 03ch, 000h, 
            db  083h, 0ffh, 000h, 000h, 08bh, 08dh, 085h, 088h, 
            db  000h, 005h, 0a5h, 087h, 0feh, 042h, 04ch, 000h, 
            db  0ffh, 000h, 020h, 088h, 000h, 005h, 0b5h, 087h, 
            db  0feh, 053h, 050h, 041h, 043h, 045h, 000h, 0ffh, 
            db  000h, 020h, 0a5h, 088h, 000h, 005h, 0cbh, 087h, 
            db  0feh, 053h, 050h, 041h, 043h, 045h, 053h, 000h, 
            db  0ffh, 000h, 000h, 098h, 0ffh, 000h, 020h, 0a5h, 
            db  099h, 088h, 000h, 005h, 0f1h, 087h, 0feh, 043h, 
            db  04ch, 053h, 000h, 0ffh, 000h, 01bh, 0a5h, 0ffh, 
            db  000h, 05bh, 0a5h, 0ffh, 000h, 032h, 0a5h, 0ffh, 
            db  000h, 04ah, 0a5h, 0ffh, 000h, 01bh, 0a5h, 0ffh, 
            db  000h, 05bh, 0a5h, 0ffh, 000h, 048h, 0a5h, 088h, 
            db  000h, 006h, 00dh, 087h, 0feh, 04ch, 053h, 048h, 
            db  049h, 046h, 054h, 000h, 089h, 081h, 08bh, 0ffh, 
            db  000h, 002h, 08eh, 08bh, 0ffh, 000h, 001h, 08dh, 
            db  089h, 082h, 08ah, 088h, 000h, 006h, 029h, 087h, 
            db  0feh, 052h, 053h, 048h, 049h, 046h, 054h, 000h, 
            db  089h, 081h, 08bh, 0ffh, 000h, 002h, 08fh, 08bh, 
            db  0ffh, 000h, 001h, 08dh, 089h, 082h, 08ah, 088h, 
            db  000h, 006h, 03ah, 087h, 0feh, 049h, 04eh, 056h, 
            db  045h, 052h, 054h, 000h, 0ffh, 0ffh, 0ffh, 095h, 
            db  088h, 000h, 006h, 054h, 087h, 0feh, 053h, 047h, 
            db  04eh, 000h, 089h, 083h, 0ffh, 080h, 000h, 093h, 
            db  083h, 0ffh, 0ffh, 0ffh, 084h, 0ffh, 000h, 001h, 
            db  085h, 085h, 088h, 000h, 006h, 066h, 087h, 0feh, 
            db  04dh, 04fh, 044h, 000h, 089h, 0a8h, 089h, 0a8h, 
            db  08fh, 0a8h, 08eh, 08dh, 088h, 000h, 006h, 07ah, 
            db  087h, 0feh, 02fh, 04dh, 04fh, 044h, 000h, 0aah, 
            db  0aah, 0feh, 04dh, 04fh, 044h, 000h, 0a9h, 08fh, 
            db  088h, 000h, 006h, 08ch, 087h, 0feh, 047h, 045h, 
            db  054h, 042h, 049h, 054h, 000h, 0c2h, 0ffh, 000h, 
            db  001h, 093h, 088h, 000h, 006h, 09fh, 087h, 0feh, 
            db  053h, 045h, 054h, 042h, 049h, 054h, 000h, 0ffh, 
            db  000h, 001h, 08bh, 0c1h, 094h, 088h, 000h, 006h, 
            db  0b6h, 087h, 0feh, 043h, 04ch, 052h, 042h, 049h, 
            db  054h, 000h, 0ffh, 000h, 001h, 08bh, 0c1h, 0ffh, 
            db  0ffh, 0ffh, 095h, 093h, 088h, 000h, 006h, 0c9h, 
            db  087h, 0feh, 054h, 047h, 04ch, 042h, 049h, 054h, 
            db  000h, 0ffh, 000h, 001h, 08bh, 0c1h, 095h, 088h, 
            db  000h, 006h, 0e7h, 087h, 0feh, 042h, 059h, 054h, 
            db  045h, 053h, 057h, 041h, 050h, 000h, 089h, 0ffh, 
            db  000h, 008h, 0c2h, 08bh, 0ffh, 000h, 0ffh, 093h, 
            db  0ffh, 000h, 008h, 0c1h, 094h, 088h, 000h, 007h, 
            db  001h, 087h, 0feh, 046h, 049h, 04ch, 04ch, 000h, 
            db  08bh, 0a2h, 0aah, 0aeh, 089h, 0feh, 031h, 02bh, 
            db  000h, 0a1h, 0feh, 031h, 02dh, 000h, 0afh, 088h, 
            db  000h, 007h, 016h, 087h, 0feh, 045h, 052h, 041h, 
            db  053h, 045h, 000h, 0ffh, 000h, 000h, 0feh, 046h, 
            db  049h, 04ch, 04ch, 000h, 088h, 000h, 007h, 027h, 
            db  087h, 0feh, 043h, 04ch, 045h, 041h, 052h, 000h, 
            db  0a7h, 081h, 08ah, 0a7h, 082h, 088h, 000h, 007h, 
            db  060h, 087h, 0feh, 02eh, 053h, 000h, 0b0h, 0feh, 
            db  03ch, 020h, 022h, 000h, 0a7h, 0ffh, 000h, 008h, 
            db  0a5h, 090h, 0ffh, 000h, 008h, 0a5h, 0b0h, 0feh, 
            db  03eh, 020h, 022h, 000h, 0a7h, 0feh, 03fh, 044h, 
            db  055h, 050h, 000h, 083h, 089h, 0ffh, 000h, 000h, 
            db  098h, 089h, 092h, 08dh, 0feh, 050h, 049h, 043h, 
            db  04bh, 000h, 090h, 099h, 08ah, 085h, 088h, 000h, 
            db  007h, 07dh, 087h, 0feh, 054h, 059h, 050h, 045h, 
            db  000h, 089h, 083h, 0ffh, 000h, 000h, 098h, 089h, 
            db  0adh, 0a6h, 0ffh, 000h, 001h, 08ch, 099h, 084h, 
            db  08ah, 085h, 08ah, 088h, 000h, 007h, 0c8h, 087h, 
            db  0feh, 044h, 055h, 04dh, 050h, 000h, 096h, 0ffh, 
            db  000h, 005h, 0feh, 053h, 050h, 041h, 043h, 045h, 
            db  053h, 000h, 0ffh, 000h, 010h, 0ffh, 000h, 000h, 
            db  098h, 092h, 090h, 099h, 0ffh, 000h, 000h, 098h, 
            db  096h, 089h, 090h, 0ffh, 000h, 010h, 0ffh, 000h, 
            db  000h, 098h, 089h, 0adh, 090h, 0feh, 031h, 02bh, 
            db  000h, 099h, 089h, 0ffh, 000h, 010h, 08dh, 0ffh, 
            db  000h, 010h, 0feh, 054h, 059h, 050h, 045h, 000h, 
            db  0ffh, 000h, 010h, 09ah, 08ah, 096h, 088h, 000h, 
            db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 
            db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 
            db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 
            db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 
            db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 
            db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 
            db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
endextblock:
#endif

endrom:    equ     $

#ifdef ELFOS
rstack:    dw      0
tos:       dw      0
freemem:   dw      storage
fstack:    dw      0
himem:     dw      0
jump:      ds      3
fildes:    ds      20
dta:       ds      512
buffer:    ds      256
storage:   dw      0
#endif

           end     start


           

