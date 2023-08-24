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
              ; [gnr] Bug fixes, assembler fixes,and the Exec word
              ; A few notes as I've gone through the code (GNR)
              ; This isn't done like a conventional Forth
              ; Everything is parsed on processing the input line
              ; First, it checks for core words. If it finds one, it tokenizes it >0x80
              ; Then it checks for a number and, if found marks it with FF
              ; Anything else must be a string, so it gets marked with an FE and terminated with a zero.
              ; The tokenized string is already in the free storage so a VARIABLE or : just bumps up
              ; the pointer to the end of the string (or just past, for a variable)
              ;
              ; The colon operator just grabs the name, and copies everything else. So core words
              ; are tokenized, but variables and user words are not.
              ;
              ; The upside is you don't have a forward ref problem of what to do with words you
              ; don't know yet
              ;
              ; The downside is you can't override the system words. If you did (e.g., search
              ; user space first) you'd have a problem with words compiled before the override
              ; example: 5 2 + 1+ parses out as:
              ; <NUM> 0005 <NUM> 0002 <+> <STR>1+<0>
              ; And
              ;
              ; Parses out as:
              ; <len><colon>example<0><NUM>0005<NUM>0002<+><STR>1+<SEMICOLON><0>
              ;
              ; You can define a word more than once, but only the first one gets used
              ; You can't define words over multiple lines (seems easy to fix)
              ;
              ; Although the semicolon doesn't really do anything, omitting it in a definition will crash
              ; and burn the system (should fix) since you just copy a bunch of stuff over (fixed)
              ;
              ; VARIABLE can't have anything following it
              ; e.g. VARIABLE X X 0 ! -- does not work (now throws an error)
              ; on a word def is ignored also  (now throws an error)
              ;
              ; To catch all these we now define T_EOS 0xFD. The tokenizer marks the end of string with it
              ; and most things ignore it. But colon and varible use it to make sure the string is
              ; complete and doesn't have too much stuff in it, also. As an extra feature, we now
              ; zero out new variables (but not the allot part)s

              ; The old style BLOAD was binary and wipes out your variables
              ; The new style BLOAD takes text strings (more space) but doesn't wipe out variables
              ; Of course, you can reduce space on text by easily removing definitions you 
              ; don't want or need which is harder to do with the binary BLOAD
              ; Doesn't need to change based on RAM addresses
              ; And let's your run things not just define words/variables
              ; Pick one or the other here. Or define NO_BLOAD to make BLOAD act like LOAD
              ; (that is, XMODEM load)
              ; DO NOT DEFINE BLOAD_TEXT and BLOAD_BIN!
              ; BLOAD_AUTO, if defined, makes us run BLOAD at startup (turn off if using NO_BLOAD)
              ; Unless you define NO_TOKEN_COMPRESSION then
              ; The parser will take anything >=80h as a token directly
              ; This allows you to make files (or BLOAD data) that use tokenized or ASCII core words
              ; Example:
              ;   db  FCOLON,'ABC ',FSWAP,FDROP,FSEMI,0
              ;
              ; You don't HAVE to use the tokens, and you can mix and match
              ; However, if you wanted to put these in the data stream
              ; You'd need to set NO_TOKEN_COMPRESSION to allow that data to pass through
              ; Not sure what the use case for that would be, however.


; pick EXACTLY one of the next three
;#define NO_BLOAD
#define BLOAD_TEXT
;#define BLOAD_BIN

; if you want to compile to a separate "compile buffer" define this
#define USE_CBUFFER

#ifndef NO_BLOAD
#define BLOAD_AUTO
#else
#ifdef BLOAD_TEXT
#undef BLOAD_TEXT
#endif

#ifdef BLOAD_BIN
#undef BLOAD_BIN
#endif

#ifdef BLOAD_AUTO
#undef BLOAD_AUTO
#endif

#endif


; For a RAM build you need to set all this up yourself
; you do need BIOS somewhere and if you don't have XMODEM then don't use those commands!
; we assume you have BIOS.INC (since you have a BIOS) and that it is correct
#ifdef        RAM
#define       ANYROM
#define       CODE          06600h
#define       XMODEM        0ed00h
#define       RAMBASE       0h
              ; [gnr] The UART is used in inkey so when using bitbang, no inkey!
#define       UART_SELECT   6                    ; UART register select I/O port
#define       UART_DATA     7                    ; UART data I/O port
;[RLA] XMODEM entry vectors for the STG EPROM ...
xopenw:       equ           XMODEM + 0*3
xopenr:       equ           XMODEM + 1*3
xread:        equ           XMODEM + 2*3
xwrite:       equ           XMODEM + 3*3
xclosew:      equ           XMODEM + 4*3
xcloser:      equ           XMODEM + 5*3
exitaddr:     equ           08003h
; IMPORTANT. YOUR BIOS WILL REPORT TOO MUCH FREE MEMORY if you are using RAM
; So we need an override. This should probably be CODE-1 in most cases
#define       MEMSIZE_OVERRIDE CODE-1
#endif
#ifdef        MCHIP
#define       ANYROM
#define       CODE          02000h
#define       RAMBASE       08000h
xopenw:       equ           07006h
xopenr:       equ           07009h
xread:        equ           0700ch
xwrite:       equ           0700fh
xclosew:      equ           07012h
xcloser:      equ           07015h
exitaddr:     equ           07003h
#endif
#ifdef        PICOROM
#define       ANYROM
#define       CODE          0a000h
#define       RAMBASE       00000h
xopenw:       equ           08006h
xopenr:       equ           08009h
xread:        equ           0800ch
xwrite:       equ           0800fh
xclosew:      equ           08012h
xcloser:      equ           08015h
exitaddr:     equ           08003h
#endif
; [GDJ] build: asm02 -i -L -DSTGROM forth.asm
#ifdef        STGROM
#define       ANYROM        1
              include       config.inc
#define       CODE          FORTH                ; [gnr] [GDG] says now bigger than 15 pages
#define       RAMBASE       00000h
              ; [gnr] The UART is used in inkey so when using bitbang, no inkey!
#define       UART_SELECT   6                    ; UART register select I/O port
#define       UART_DATA     7                    ; UART data I/O port
;[RLA] XMODEM entry vectors for the STG EPROM ...
xopenw:       equ           XMODEM + 0*3
xopenr:       equ           XMODEM + 1*3
xread:        equ           XMODEM + 2*3
xwrite:       equ           XMODEM + 3*3
xclosew:      equ           XMODEM + 4*3
xcloser:      equ           XMODEM + 5*3
exitaddr:     equ           08003h
#endif
#ifdef        ELFOS
#define       CODE          02000h
stack:        equ           00ffh
exitaddr:     equ           o_wrmboot
#else
buffer:       equ           RAMBASE+0200h
#ifdef USE_CBUFFER
cbuffer:      equ           RAMBASE+0300h
himem:        equ           RAMBASE+0400h
#else
himem:        equ           RAMBASE+0300h
#endif
rstack:       equ           himem+2
tos:          equ           rstack+2
freemem:      equ           tos+2
fstack:       equ           freemem+2
jump:         equ           fstack+2
rseed:        equ           jump+3
basev:        equ           rseed+4
basen:        equ           basev+1              ; byte access
eosptr        equ           basev+2
storage:      equ           eosptr+2
stack:        equ           RAMBASE+01ffh
#endif
              include       bios.inc
#ifdef        ELFOS
              include       kernel.inc
              org           8000h
              lbr           0ff00h
              db            'rcforth',0
              dw            9000h
              dw            endrom+7000h
              dw            2000h
              dw            endrom-2000h
              dw            2000h
              db            0
#endif
;  R2   - program stack
;  R3   - Main PC
;  R4   - standard call
;  R5   - standard ret
;  R6   - used by Scall/Sret linkage
;  R7   - general and command table pointer
;  R9   - Data segment
;  RB   - general SCRT return usage and token stream pointer
FWHILE:       equ           81h
FREPEAT:      equ           FWHILE+1
FIF:          equ           FREPEAT+1
FELSE:        equ           FIF+1
FTHEN:        equ           FELSE+1
FVARIABLE:    equ           FTHEN+1
FCOLON:       equ           FVARIABLE+1
FSEMI:        equ           FCOLON+1
FDUP:         equ           FSEMI+1
FDROP:        equ           FDUP+1
FSWAP:        equ           FDROP+1
FPLUS:        equ           FSWAP+1
FMINUS:       equ           FPLUS+1
FMUL:         equ           FMINUS+1
FDIV:         equ           FMUL+1
FDOT:         equ           FDIV+1               ; 90h
FUDOT:        equ           FDOT+1
FI:           equ           FUDOT+1
FAND:         equ           FI+1
FOR:          equ           FAND+1
FXOR:         equ           FOR+1
FCR:          equ           FXOR+1
FMEM:         equ           FCR+1
FDO:          equ           FMEM+1
FLOOP:        equ           FDO+1
FPLOOP:       equ           FLOOP+1
FEQUAL:       equ           FPLOOP+1
FUNEQUAL:     equ           FEQUAL+1
FLESS:        equ           FUNEQUAL+1           ; [GDJ]
FULESS:       equ           FLESS+1              ; [GDJ]
FBEGIN:       equ           FULESS+1
FUNTIL:       equ           FBEGIN+1             ; a0h
FRGT:         equ           FUNTIL+1
FGTR:         equ           FRGT+1
FRAT:         equ           FGTR+1               ; [GDJ]
FWORDS:       equ           FRAT+1
FEMIT:        equ           FWORDS+1
FEMITP:       equ           FEMIT+1              ; [GDJ]
FDEPTH:       equ           FEMITP+1
FROT:         equ           FDEPTH+1
FMROT:        equ           FROT+1
FOVER:        equ           FMROT+1
FAT:          equ           FOVER+1
FEXCL:        equ           FAT+1
FCAT:         equ           FEXCL+1
FCEXCL:       equ           FCAT+1
FCMOVE:       equ           FCEXCL+1             ; [GDJ]
FDOTQT:       equ           FCMOVE+1             ; b0h
FKEY:         equ           FDOTQT+1
FKEYQ:        equ           FKEY+1               ; [GDJ]
FALLOT:       equ           FKEYQ+1
FERROR:       equ           FALLOT+1
FSEE:         equ           FERROR+1
FFORGET:      equ           FSEE+1
FOUT:         equ           FFORGET+1
FINP:         equ           FOUT+1
FEF:          equ           FINP+1
FSETQ:        equ           FEF+1
FSAVE:        equ           FSETQ+1
FLOAD:        equ           FSAVE+1
FBYE:         equ           FLOAD+1
FSPAT:        equ           FBYE+1
FDECIMAL:     equ           FSPAT+1
FHEX:         equ           FDECIMAL+1
FLT:          equ           FHEX+1
FGT:          equ           FLT+1
FDELAY:       equ           FGT+1
FBLOAD:       equ           FDELAY+1
FGOTOXY:      equ           FBLOAD+1   ; should move to extended
FRAND:        equ           FGOTOXY+1
FEXEC:        equ           FRAND+1
FLIST:        equ           FEXEC+1
FDOTX:        equ           FLIST+1
FNEW:         equ           FDOTX+1
FHERE:        equ           FNEW+1
FTOHERE:      equ           FHERE+1
FBASE:        equ           FTOHERE+1
FENDIF:       equ           FBASE+1
FRSEED:       equ           FENDIF+1
FRPAT:        equ           FRSEED+1
FOPAREN:      equ           FRPAT+1

T_EOS:        equ           253                  ; end of command line
T_NUM:        equ           255
T_ASCII:      equ           254
              org           CODE
#ifdef        ELFOS
              br            start
              include       date.inc
              include       build.inc
              db            'Written by Michael H. Riley',0
#endif
#ifdef        ANYROM
              lbr           new                  ; ROM cold entry point
notnew:
              mov           r6, old              ; ROM warm entry point
newornot:
              mov           r2,stack
              sex           r2
              lbr           f_initcall
new:          mov           r6,start
              br            newornot             ; common code for warm or cold start
#endif
; Cold start comes here after initcall
start:        ldi           high himem           ; get page of data segment
              phi           r9                   ; place into r9
#ifdef        ANYROM
              ldi           0ch                  ; form feed to clear screen
#ifdef        ELFOS
              call          o_type
#else
              call          f_type
#endif
#endif
              mov           rf, hello            ; address of signon message
#ifdef        ELFOS
              call          o_msg
#else
              call          f_msg                ; function to display a message
#endif
              call          crlfout
; ************************************************
; **** Determine how much memory is installed ****
; ************************************************
#ifdef        ELFOS
              mov           rf,0442h             ; point to high memory pointer
              lda           rf                   ; retrieve it
              phi           rb
              lda           rf
              plo           rb
#endif
#ifndef       ELFOS
              call          f_freemem            ; ask BIOS for memor size
              mov           rb,rf
#endif
#ifdef        MEMSIZE_OVERRIDE
              mov           rb,MEMSIZE_OVERRIDE
#endif
              ldi           low himem
              plo           r9
              ghi           rb
              str           r9
              phi           r2
              inc           r9
              glo           rb
              str           r9
              plo           r2
              call          fresh
              call          xnew
#ifdef        BLOAD_AUTO
              lbr           cbload               ; should only do this on first time
#else
              br            mainlp
#endif
cnew:         call          xnew                 ; user wants to start over. Do not BLOAD
              br            mainlp
xnew:
              ldi           low freemem          ; set R9 to free memory
              plo           r9
              ldi           high storage         ; point to storage
              str           r9
              inc           r9
              phi           rf
              ldi           low storage
              str           r9
              plo           rf
              ldi           0
              str           rf                   ; write zeroes as storage terminator
              inc           rf
              str           rf
              inc           rf
              str           rf
              inc           rf
              str           rf
              inc           rf
              mov           rf, basev            ; set base to 10
              ldi           0
              str           rf
              inc           rf
              ldi           10
              str           rf
; clrstacks was here but wipes out machine stack too. 
              ; init 32 bit rng seed
 ;             mov           r7, 012A6h
              mov           rf, rseed
              ldi           12h
              str           rf
              inc           rf
              ldi           0a6h 
              str           rf
              inc           rf            
;              mov           r7, 0DC40h
              ldi           0dch 
              str           rf
              inc           rf
              ldi           40h
              str           rf
              rtn
; shared code between new and old
fresh:
              ldi           low jump
              plo           r9
              ldi           0c0h
              str           r9                   ; we use JUMP as a flag. C0 is normal
              ldi           low rstack           ; get return stack address
              plo           r9                   ; select in data segment
              ghi           rb                   ; get hi memory
              smi           1                    ; 1 page lower for forth stack
              str           r9                   ; write to pointer
              inc           r9                   ; point to low byte
              glo           rb                   ; get low byte
              str           r9                   ; and store
              ldi           low tos              ; get stack address
              plo           r9                   ; select in data segment
              ghi           rb                   ; get hi memory
              smi           2                    ; 2 page lower for forth stack
              str           r9                   ; write to pointer
              inc           r9                   ; point to low byte
              glo           rb                   ; get low byte
              str           r9                   ; and store
              ldi           low fstack           ; get stack address
              plo           r9                   ; select in data segment
              ghi           rb                   ; get hi memory
              smi           2                    ; 2 page lower for forth stack
              str           r9                   ; write to pointer
              inc           r9                   ; point to low byte
              glo           rb                   ; get low byte
              str           r9                   ; and store
              rtn
; OLD entry point for warm start (after init)
old:          mov           r9,himem             ; load whole thing since this is an entry point
              lda           r9                   ; retreive high memory
              phi           rb
              phi           r2                   ; and to machine stack
              lda           r9
              plo           rb
              plo           r2
              call          fresh
; fall through to main loop
; *************************
; *** Main program loop ***
; *************************
mainlp:       mov           rf, prompt
              ldi           low jump
              plo           r9
              ldn           r9
              xri           0c0h                 ; normal operations
              bz            mainprompt
              dec           rf                   ; select alternate prompt
mainprompt:
#ifdef        ELFOS
              call          o_msg
#else
              call          f_msg                ; function to display a message
#endif
              mov           rf, buffer
#ifdef        ELFOS
              call          o_input
#else
              call          f_input              ; function to read a line
#endif
              bnf          mainent              ; jump if no ^C
              call          f_inmsg
              db            '^C',10,13,0
              ldi           low jump
              plo           r9
              ldn           r9
              xri           0c0h                 ; test if we are in the middle of a colon def
              bz            mainlp               ; nope!
              ldi           0C0h                 ; yes, turn it off and restore freemem
              str           r9
              inc           r9
              lda           r9
              plo           rf
              ldn           r9
              phi           rf
              ldi           low freemem
              plo           r9
              ghi           rf
              str           r9
              inc           r9
              glo           rf
              str           r9
              br           mainlp
mainent:
              call          crlfout
              mov           rf,buffer            ; convert to uppercase
              call          touc
              call          tknizer
#ifdef USE_CBUFFER
              mov           rb,cbuffer
#else              
              ldi           low freemem          ; set R9 to free memory
              plo           r9
              lda           r9                   ; get free memory pointer
              phi           rb                   ; place into rb
              ldn           r9
              plo           rb
              ldi           low jump             ; check for mid colon definition
              plo           r9
              ldn           r9
              xri           0c0h
              lsnz                               ; don't do next two increments if mid colon def
              inc           rb
              inc           rb
#endif              
              call          exec
              lbr           mainlp               ; return to beginning of main loop
crlfout:
              call          f_inmsg
              db            10,13,0
              rtn
; **************************************
; *** Display a space
; **************************************
dispsp:       ldi           ' '
              br            disp
; **************************************
; *** Display a character, char db after call
; **************************************
dispf:
              lda           r6                   ; get immediate character
              ;  fall through
; **************************************
; *** Display a character, char in D ***
; **************************************
disp:
#ifdef        ELFOS
              lbr           o_type
#else
              lbr           f_type
#endif
; ********************************
; *** Read a key, returns in D ***
; ********************************
getkey:
#ifdef        ELFOS
              lbr           o_readkey
#else
              lbr           f_read
#endif
; There seems to be an assumption throughout that R9.1 is always the same
; This is because it is only used to access the variables like freemem and jump
; so it is assumed they are always on the same page
; ***************************************************
; *** Function to retrieve value from forth stack ***
; *** Returns R[B] = value                        ***
; ***         DF=0 no error, DF=1 error           ***
; ***************************************************
pop:          ldi           low fstack           ; get stack address
              plo           r9                   ; select in data segment
              lda           r9
              phi           ra
              ldn           r9
              plo           ra
              ldi           low tos              ; pointer to maximum stack value
              plo           r9                   ; put into data frame
              lda           r9                   ; get high value
              str           r2                   ; place into memory
              ghi           ra                   ; get high byte of forth stack
              sm                                 ; check if same
              bnz           stackok              ; jump if ok
              ldn           r9                   ; get low byte of tos
              str           r2
              glo           ra                   ; check low byte of stack pointer
              sm
              bnz           stackok              ; jump if ok
              ldi           1                    ; signal error
popret:       shr                                ; shift status into DF
              rtn                                ; return to caller
stackok:      inc           ra                   ; point to high byte
              lda           ra                   ; get it
              phi           rb                   ; put into register
              ldn           ra                   ; get low byte
              plo           rb
              ldi           low fstack           ; get stack address
              plo           r9                   ; select in data segment
              ghi           ra                   ; get hi memory
              str           r9                   ; write to pointer
              inc           r9                   ; point to low byte
              glo           ra                   ; get low byte
              str           r9                   ; and store
              ldi           0                    ; signal no error
              br            popret               ; and return to caller
; ********************************************************
; *** Function to push value onto stack, value in R[B] ***
; ********************************************************
push:         ldi           low fstack           ; get stack address
              plo           r9                   ; select in data segment
              lda           r9
              phi           ra
              ldn           r9
              plo           ra
              glo           rb                   ; get low byte of value
              str           ra                   ; store on forth stack
              dec           ra                   ; point to next byte
              ghi           rb                   ; get high value
              str           ra                   ; store on forth stack
              dec           ra                   ; point to next byte
              ldi           low fstack           ; get stack address
              plo           r9                   ; select in data segment
              ghi           ra                   ; get hi memory
              str           r9                   ; write to pointer
              inc           r9                   ; point to low byte
              glo           ra                   ; get low byte
              str           r9                   ; and store
              rtn                                ; return to caller
; ****************************************************
; *** Function to retrieve value from return stack ***
; *** Returns R[B] = value                         ***
; ***         D=0 no error, D=1 error              ***
; ****************************************************
rpop:         ldi           low rstack           ; get stack address
              plo           r9                   ; select in data segment
              lda           r9
              phi           ra
              ldn           r9
              plo           ra
              inc           ra                   ; point to high byte
              lda           ra                   ; get it
              phi           rb                   ; put into r6
              ldn           ra                   ; get low byte
              plo           rb
              ldi           low rstack           ; get stack address
              plo           r9                   ; select in data segment
              ghi           ra                   ; get hi memory
              str           r9                   ; write to pointer
              inc           r9                   ; point to low byte
              glo           ra                   ; get low byte
              str           r9                   ; and store
              ldi           0                    ; signal no error
              rtn                                ; and return
; ***************************************************************
; *** Function to push value onto return stack, value in R[B] ***
; ***************************************************************
rpush:        ldi           low rstack           ; get stack address
              plo           r9                   ; select in data segment
              lda           r9
              phi           ra
              ldn           r9
              plo           ra
              glo           rb                   ; get low byte of value
              str           ra                   ; store on forth stack
              dec           ra                   ; point to next byte
              ghi           rb                   ; get high value
              str           ra                   ; store on forth stack
              dec           ra                   ; point to next byte
              ldi           low rstack           ; get stack address
              plo           r9                   ; select in data segment
              ghi           ra                   ; get hi memory
              str           r9                   ; write to pointer
              inc           r9                   ; point to low byte
              glo           ra                   ; get low byte
              str           r9                   ; and store
              rtn                                ; return to caller
;           org     200h
; ********************************************
; *** Function to find stored name address ***
; ***  Needs: name to search in R[8]       ***
; ***  returns: R[B] first byte in data    ***
; ***           R[7] Address of descriptor ***
; ***           R[8] first addr after name ***
; ***           DF = 1 if not found        ***
; ********************************************
findname:     mov           rb, storage
findlp:       mov           r7,rb
              lda           rb                   ; get link address
              bnz           findgo               ; jump if nonzero
              ldn           rb                   ; get low byte
              bnz           findgo               ; jump if non zero
              ldi           1                    ; not found
findret:      shr                                ; set DF
              rtn                                ; and return to caller
findgo:       inc           rb                   ; pointing now at type
              inc           rb                   ; pointing at ascii indicator
              inc           rb                   ; first byte of name
              glo           r8                   ; save requested name
              stxd
              ghi           r8
              stxd
findchk:      ldn           r8                   ; get byte from requested name
              str           r2                   ; place into memory
              ldn           rb                   ; get byte from descriptor
              sm                                 ; compare equality
              bnz           findnext             ; jump if not found
              ldn           r8                   ; get byte
              bz            findfound            ; entry is found
              inc           r8                   ; increment positions
              inc           rb
              br            findchk              ; and keep looking
findfound:    inc           rb                   ; rb now points to data
              irx                                ; remove r8 from stack
              irx
              inc           r8                   ; move past terminator in name
              ldi           0                    ; signal success
              br            findret              ; and return to caller
findnext:     irx                                ; recover start of requested name
              ldxa
              phi           r8
              ldx
              plo           r8
              lda           r7                   ; get next link address
              phi           rb
              ldn           r7
              plo           rb
              br            findlp               ; and check next entry
; *********************************************
; *** Function to multiply 2 16 bit numbers ***
; *********************************************
mul16:        ldi           0                    ; zero out total
              phi           r8
              plo           r8
              phi           rc
              plo           rc
mulloop:      glo           r7                   ; get low of multiplier
              bnz           mulcont              ; continue multiplying if nonzero
              ghi           r7                   ; check hi byte as well
              bnz           mulcont
              mov           rb,r8
              rtn                                ; return to caller
mulcont:      ghi           r7                   ; shift multiplier
              shr
              phi           r7
              glo           r7
              shrc
              plo           r7
              bnf           mulcont2             ; loop if no addition needed
              glo           rb                   ; add 6 to 8
              str           r2
              glo           r8
              add
              plo           r8
              ghi           rb
              str           r2
              ghi           r8
              adc
              phi           r8
              glo           rc                   ; carry into high word
              adci          0
              plo           rc
              ghi           rc
              adci          0
              phi           rc
mulcont2:     glo           rb                   ; shift first number
              shl
              plo           rb
              ghi           rb
              shlc
              phi           rb
              lbr           mulloop              ; loop until done
; ************************************
; *** make both arguments positive ***
; *** Arg1 RB                      ***
; *** Arg2 R7                      ***
; *** Returns D=0 - signs same     ***
; ***         D=1 - signs difer    ***
; ************************************
mdnorm:       ghi           rb                   ; get high byte if divisor
              str           r2                   ; store for sign check
              ghi           r7                   ; get high byte of dividend
              xor                                ; compare
              shl                                ; shift into df
              ldi           0                    ; convert to 0 or 1
              shlc                               ; shift into D
              plo           re                   ; store into sign flag
              ghi           rb                   ; need to see if RB is negative
              shl                                ; shift high byte to df
              bnf           mdnorm2              ; jump if not
              ghi           rb                   ; 2s compliment on RB
              xri           0ffh
              phi           rb
              glo           rb
              xri           0ffh
              plo           rb
              inc           rb
mdnorm2:      ghi           r7                   ; now check r7 for negative
              shl                                ; shift sign bit into df
              bnf           mdnorm3              ; jump if not
              ghi           r7                   ; 2 compliment on R7
              xri           0ffh
              phi           r7
              glo           r7
              xri           0ffh
              plo           r7
              inc           r7
mdnorm3:      glo           re                   ; recover sign flag
              rtn                                ; and return to caller
; *** RC = RB/R7
; *** RB = remainder
; *** uses R8 and R9 (which is bad since we assume R9.1 stays the same all the time!)
; the caller saves R9 though (only called in cdiv)
div16:        call          mdnorm               ; normalize numbers
              plo           re                   ; save sign comparison
              ldi           0                    ; clear answer
              phi           rc
              plo           rc
              phi           r8                   ; set additive
              plo           r8
              inc           r8
              glo           r7                   ; check for divide by 0
              bnz           d16lp1
              ghi           r7
              bnz           d16lp1
              ldi           0ffh                 ; return 0ffffh as div/0 error
              phi           rc
              plo           rc
              rtn                                ; return to caller
d16lp1:       ghi           r7                   ; get high byte from r7
              ani           080h                  ; check high bit
              bnz           divst                ; jump if set
              glo           r7                   ; lo byte of divisor
              shl                                ; multiply by 2
              plo           r7                   ; and put back
              ghi           r7                   ; get high byte of divisor
              shlc                               ; continue multiply by 2
              phi           r7                   ; and put back
              glo           r8                   ; multiply additive by 2
              shl
              plo           r8
              ghi           r8
              shlc
              phi           r8
              br            d16lp1               ; loop until high bit set in divisor
divst:        glo           r7                   ; get low of divisor
              bnz           divgo                ; jump if still nonzero
              ghi           r7                   ; check hi byte too
              bnz           divgo
              glo           re                   ; get sign flag
              shr                                ; move to df
              bnf           divret               ; jump if signs were the same
              ghi           rc                   ; perform 2s compliment on answer
              xri           0ffh
              phi           rc
              glo           rc
              xri           0ffh
              plo           rc
              inc           rc
divret:       rtn                                ; jump if done
divgo:        mov           r9,rb
              glo           r7                   ; get lo of divisor
              stxd                               ; place into memory
              irx                                ; point to memory
              glo           rb                   ; get low byte of dividend
              sm                                 ; subtract
              plo           rb                   ; put back into r6
              ghi           r7                   ; get hi of divisor
              stxd                               ; place into memory
              irx                                ; point to byte
              ghi           rb                   ; get hi of dividend
              smb                                ; subtract
              phi           rb                   ; and put back
              bdf           divyes               ; branch if no borrow happened
              mov           rb,r9                ; recover copy
              br            divno                ; jump to next iteration
divyes:       glo           r8                   ; get lo of additive
              stxd                               ; place in memory
              irx                                ; point to byte
              glo           rc                   ; get lo of answer
              add                                ; and add
              plo           rc                   ; put back
              ghi           r8                   ; get hi of additive
              stxd                               ; place into memory
              irx                                ; point to byte
              ghi           rc                   ; get hi byte of answer
              adc                                ; and continue addition
              phi           rc                   ; put back
divno:        ghi           r7                   ; get hi of divisor
              shr                                ; divide by 2
              phi           r7                   ; put back
              glo           r7                   ; get lo of divisor
              shrc                               ; continue divide by 2
              plo           r7
              ghi           r8                   ; get hi of divisor
              shr                                ; divide by 2
              phi           r8                   ; put back
              glo           r8                   ; get lo of divisor
              shrc                               ; continue divide by 2
              plo           r8
              br            divst                ; next iteration

            


; ***************************
; *** Setup for tokenizer ***
; ***************************
tknizer:      mov           rb, buffer
tknizerb:
#ifdef USE_CBUFFER
              mov           rf,cbuffer
#else              
              ldi           low freemem          ; set R9 to free memory
              plo           r9
              lda           r9                   ; get free memory pointer
              phi           rf                   ; place into rF
              ldn           r9
              plo           rf
              ; if we are in the middle of a multiline colon, we do NOT add 2 here
              ldi           low jump
              plo           r9
              ldn           r9
              xri           0c0h
              lsnz
              inc           rf
              inc           rf
#endif
; ******************************
; *** Now the tokenizer loop ***
; ******************************
tokenlp:      ldn           rb                   ; get byte from buffer
              lbz           tokendn              ; jump if found terminator
              smi           (' '+1)              ; check for whitespace
              bdf           nonwhite             ; jump if not whitespace
              inc           rb                   ; move past white space
              br            tokenlp              ; and keep looking
; ********************************************
; *** Prepare to check against token table ***
; ********************************************
nonwhite:
              ldn           rb
#ifndef NO_TOKEN_COMPRESSION
              smi           T_NUM                 ; check for T_NUM
              bnz           tkstrck
              lda           rb                   ; load tokenized number
              str           rf
              inc           rf
              lda           rb
              str           rf
              inc           rf
              lda           rb
copytoken:              
              str           rf
              inc           rf
              br            tokenlp              ; go get more 

tkstrck:                                        ; test for string token
              ldn           rb
              smi           T_ASCII
              bnz           tkcompck
tkstrcpy:
              lda           rb                  ; found a string
              str           rf
              inc           rf
              bnz           tkstrcpy
              br            tokenlp


tkcompck:              
              ldn           rb              
              smi           07fh
              lda           rb  
              lbdf           copycmdtk           ; will handle ." but needs a space after: db FDOTQT,20h,T_ASCII,'foo"',...
              dec           rb
              ldn           rb
#endif
              smi           '\'                  ; possible comment
              bnz           noncom
              inc           rb
              ldn           rb
              dec           rb
              smi           (' '+1)
              bdf           nonwhite             ; nope, not a comment, just something that starts with \
              ldi           0
              str           rb
              lbr           tokendn              ; zero it and ignore all else
noncom:
              mov           r7,cmdTable
              ldi           1                    ; first command number
              plo           r8                   ; r8 will keep track of command number
; **************************
; *** Command check loop ***
; **************************
cmdloop:      mov           rc,rb                ; save buffer address
; ************************
; *** Check next token ***
; ************************
tokloop:      ldn           r7                   ; get byte from token table
              ani           128                  ; check if last byte of token
              lbnz           cmdend               ; jump if last byte
              ldn           r7                   ; reget token byte
              str           r2                   ; store to stack
              ldn           rb                   ; get byte from buffer
              sm                                 ; do bytes match?
              lbnz           toknomtch            ; jump if no match
              inc           r7                   ; incrment token pointer
              inc           rb                   ; increment buffer pointer
              lbr            tokloop              ; and keep looking
; *********************************************************
; *** Token failed match, move to next and reset buffer ***
; *********************************************************
toknomtch:    mov           rb,rc                ; recover saved address
nomtch1:      ldn           r7                   ; get byte from token
              ani           128                  ; looking for last byte of token
              bnz           nomtch2              ; jump if found
              inc           r7                   ; point to next byte
              br            nomtch1              ; and keep looking
nomtch2:      inc           r7                   ; point to next token
              inc           r8                   ; increment command number
              ldn           r7                   ; get next token byte
              lbnz          cmdloop              ; jump if more tokens to check
              br            notoken              ; jump if no token found
; ***********************************************************
; *** Made it to last byte of token, check remaining byte ***
; ***********************************************************
cmdend:       ldn           r7                   ; get byte fro token
              ani           07fh                 ; strip off end code
              str           r2                   ; save to stack
              ldn           rb                   ; get byte from buffer
              sm                                 ; do they match
              bnz           toknomtch            ; jump if not
              inc           rb                   ; point to next byte
              ldn           rb                   ; get it
              smi           (' '+1)              ; it must be whitespace
              bdf           toknomtch            ; otherwise no match
; *************************************************************
; *** Match found, store command number into command buffer ***
; *************************************************************
              glo           r8                   ; get command number
              ori           128                  ; set high bit            
copycmdtk:    plo           r8                   ; redundant UNLESS we jump to copycmdtk from elsewhere
              smi          FOPAREN
              bnz          tksto
tkcomloop:              
              lda          rb
              smi          (' '+1)
              bdf          tkcomloop             ; must be <space>)<space> to close
              lda          rb                    
              sdi          ')'
              bnz          tkcomloop
              lda          rb
              smi           (' '+1)              ; check for whitespace
              bdf          tkcomloop   
              dec          rb                    ; let tokenizer swallow the space (might be the last one)          
              lbr          tokenlp
tksto:      
              glo           r8          
              str           rf                   ; write to command buffer
              
#ifndef USE_CBUFFER
              smi           FSEMI
              bz            copycmdpl3           ; need to save 3 extra bytes for this token
              glo           r8
              smi           FVARIABLE            ; we need to bump position by 4 for this token
              bnz           copycmdckq
              inc           rf
copycmdpl3:
              inc           rf
              inc           rf
              inc           rf                   ; point to next position
#endif              
copycmdckq:
              inc           rf
              glo           r8
              smi           FDOTQT               ; check for ." function
              lbnz          tokenlp              ; jump if not
              inc           rb                   ; move past first space
              ldi           T_ASCII              ; need an ascii token
tdotqtlp:     str           rf                   ; write to command buffer
              inc           rf
              smi           022h                 ; read to quote
              bz            tdotqtdn             ; jump if found
              lda           rb                   ; transfer character to code
              br            tdotqtlp             ; and keep looking
tdotqtdn:     ldi           0                    ; need string terminator
              str           rf
              inc           rf
              lbr           tokenlp              ; then continue tokenizing
; ------------------------------------------------------------------------
;     DECIMAL handler  if not valid decimal then proceed to ascii        ;
; ------------------------------------------------------------------------
notoken:                                         ; get number BASE [GDJ]
              mov           rc,rb
              ldn           rb
              smi           '0'
              bnz           notokenbase          ; if no leading 0 can't be 0x or 0#
              inc           rb
              ldn           rb
              smi           'X'
              bz            notoken_0            ; 0xHexNumber
              ldn           rb
              smi           '#'
              bnz           notokenbaseadj       ; 0#DecNumber
notoken_0:
              ldn           rb
              inc           rb
              smi           'X'
              lbz            hexnum
              br            decnum
notokenbaseadj: dec           rb                   ; point back at 0
notokenbase:
              mov           rd, basen
              ldn           rd
              smi           10
              lbnz           hexnum
decnum:
              mov           rc,rb                ; save pointer in case of bad number
              ldi           0
              phi           rd
              plo           rd
              plo           re
              ldn           rb                   ; get byte
              smi           '-'                  ; is it negative
              bnz           notoken1             ; jump if not
              inc           rb                   ; move past negative
              ldi           1                    ; set negative flag
              plo           re
              plo           rd
notoken1:     ldn           rb                   ; get byte
              smi           '0'                  ; check for below numbers
              lbnf          nonnumber            ; jump if not a number
              ldn           rb
              smi           ('9'+1)
              lbdf          nonnumber
; **********************
; *** Found a number ***
; **********************
isnumber:     ldi           0                    ; number starts out as zero
              phi           r7                   ; use r7 to compile number
              plo           r7
numberlp:     ghi           r7                   ; copy number to temp (don't use MOV because we need to know LOW was last)
              phi           r8
              glo           r7
              plo           r8
              ; already loaded r7
;      glo     r7		;mulitply by 2
              shl
              plo           r7
              ghi           r7
              shlc
              phi           r7
              glo           r7                   ; mulitply by 4
              shl
              plo           r7
              ghi           r7
              shlc
              phi           r7
              glo           r8                   ; multiply by 5
              str           r2
              glo           r7
              add
              plo           r7
              ghi           r8
              str           r2
              ghi           r7
              adc
              phi           r7
              glo           r7                   ; mulitply by 10
              shl
              plo           r7
              ghi           r7
              shlc
              phi           r7
              lda           rb                   ; get byte from buffer
              smi           '0'                  ; convert to numeric
              str           r2                   ; store it
              glo           r7                   ; add to number
              add
              plo           r7
              ghi           r7                   ; propagate through high byte
              adci          0
              phi           r7
              ldn           rb                   ; get byte
              smi           (' '+1)              ; check for space
              bnf           numberdn             ; number also done
              ldn           rb
              smi           '0'                  ; check for below numbers
              bnf           numbererr            ; jump if not a number
              ldn           rb
              smi           ('9'+1)
              bdf           numbererr
              br            numberlp             ; get rest of number
numbererr:    mov           rb,rc                ; recover address
              lbr           nonnumber
numberdn:     glo           re                   ; get negative flag
              bz            numberdn1            ; jump if positive number
              ghi           r7                   ; negative, so 2s compliment number
              xri           0ffh
              phi           r7
              glo           r7
              xri           0ffh
              plo           r7
              inc           r7
numberdn1:    ldi           T_NUM                ; code to signify a number
              str           rf                   ; write to code buffer
              inc           rf                   ; point to next position
              ghi           r7                   ; get high byte of number
              str           rf                   ; write to code buffer
              inc           rf                   ; point to next position
              glo           r7                   ; get lo byte of numbr
              str           rf                   ; write to code buffer
              inc           rf                   ; point to next position
              lbr           tokenlp              ; continue reading tokens
; ------------------------------------------------------------------------
;       HEX handler  if not valid decimal then proceed to ascii          ;
; ------------------------------------------------------------------------
              ; [GDJ]
hexnum:       ldi           0h                   ; clear return value
              plo           r7
              phi           r7
              mov           rc,rb                ; save pointer in case of bad number
              ; for first pass we reject non hex chars
              ; in next pass this check has already been done but we
              ; have to deal with the different offsets here for ascii to binary
              ; Note: all strings have been converted to upper case previously
tohexlp:      ldn           rb                   ; get next byte
              smi           '0'                  ; check for bottom of range
              lbnf           nonnumber            ; jump if non-numeric
              ldn           rb                   ; recover byte
              smi           '9'+1                ; upper range of digits
              bnf           tohexd               ; jump if digit
              ldn           rb                   ; recover character
              smi           'A'                  ; check below uc A
              bnf           nonnumber            ; jump if not hex character
              ldn           rb                   ; recover character
              smi           'F'+1                ; check for above uc F
              bdf           nonnumber            ; jump if not hex character
              br            tohex
tohexd:       ldn           rb                   ; recover character 0..9
              smi           '0'                  ; convert to binary
              br            tohexad
tohex:        ldn           rb                   ; recover character A..F
              smi           55                   ; convert to binary ('A'-10)
tohexad:      str           r2                   ; store value to add
              ldi           4                    ; need to shift 4 times
              plo           re
tohexal:      glo           r7
              shl
              plo           r7
              ghi           r7
              shlc
              phi           r7
              dec           re                   ; decrement count
              glo           re                   ; get count
              bnz           tohexal              ; loop until done
              glo           r7                   ; now add in new value
              or                                 ; or with stored byte
              plo           r7
              inc           rb
              ldn           rb
              smi           (' '+1)              ; check for space
              lbnf          numberdn1            ; number is complete
              ; words that begin with valid hex chars but have
              ; embedded non hex characters get filtered out here
              ldn           rb
              call          ishex                ; check for hex character
              bdf           tohexlp              ; loop back if so else
              ; we dont have a hex char
              ; we got here since this was not a valid hex number
nothexnum:    mov           rb,rc                ; retrieve pointer
; *************************************************************
; *** Neither token or number found, insert as ascii string ***
; *************************************************************
nonnumber:    dec           rb                   ; account for first increment
              mov           rc, basen
              ldn           rc
              smi           10
              bnz           nonnumber1
              glo           rd
              bz            nonnumber1
              dec           rb                   ; account for previous minus sign in DECIMAL mode
nonnumber1:
              ldi           T_ASCII              ; indicate ascii to follow
notokenlp:    str           rf                   ; write to buffer
              inc           rf                   ; advance to next position
              inc           rb                   ; point to next position
              ldn           rb                   ; get next byte
              smi           (' '+1)              ; check for whitespace
              bnf           notokwht             ; found whitespace
              ldn           rb                   ; get byte
              br            notokenlp            ; get characters til whitespace
notokwht:     ldi           0                    ; need ascii terminator
              str           rf                   ; store into buffer
              inc           rf                   ; point to next position
              lbr           tokenlp              ; and keep looking
tokendn:      ldi           T_EOS
              str           rf
              inc           rf 
              ldi           0                    ; need to terminate command string
              str           rf                   ; write to buffer
; Set eosptr in case we have to move the command line later
              ldi           low eosptr
              plo           r9
              ghi           rf
              str           r9
              inc           r9
              glo           rf
              str           r9 
              rtn                                ; return to caller
  

; **************************************************** 
; *** Execute forth byte codes, RB points to codes ***
; ****************************************************
exec:
              ldn           rb                   ; get byte from codestream
              lbz           execdn               ; jump if at end of stream
              smi           T_EOS
              lbz           execdn
              ldi           low jump             ; see if we are in the middle of a colon definitino
              plo           r9
              ldn           r9
              xri           0c0h
              bz            execnorm
              glo           rb                   ; save rb
              stxd
              ghi           rb
              stxd
              lbr           ccolon
execnorm:
              ldn           rb
              smi           T_NUM                ; check for numbers
              bz            execnum              ; code is numeric
              ldn           rb                   ; recover byte
              smi           T_ASCII              ; check for ascii data
              bz            execascii            ; jump if ascii
              mov           r8, jump             ; point to jump address
              ldi           0c0h                 ; need LBR
              str           r8                   ; store it
              inc           r8
              ldn           rb                   ; recover byte
              ani           07fh                 ; strip high bit
              smi           1                    ; reset to origin
              shl                                ; addresses are two bytes
              str           r2                   ; write offset for addtion
              ldi           low cmdvecs
              add                                ; add offset
              plo           r7
              ldi           high cmdvecs         ; high address of command vectors
              adci          0                    ; propagate carry
              phi           r7                   ; r[7] now points to command vector
              lda           r7                   ; get high byte of vector
              str           r8
              inc           r8
              lda           r7                   ; get low byte of vector
              str           r8
              inc           rb                   ; point rb to next command
              glo           rb                   ; save rb
              stxd
              ghi           rb
              stxd
              lbr           jump
execret:
              plo           r7                   ; save return code
              irx                                ; recover rb
              lda           r2
              phi           rb
              ldn           r2
              plo           rb
              glo           r7                   ; get result code
              bz            exec                 ; jump if no error
              mov           rf, msempty
execrmsg:
#ifdef        ELFOS
              lbr           o_msg                ; and return
#else
              lbr           f_msg                ; and return
#endif
execnum:      inc           rb                   ; point to number
              mov           r7,rb
              lda           r7
              phi           rb
              lda           r7
              plo           rb
              call          push
              mov           rb,r7
              br            exec                 ; execute next code
execascii:    inc           rb                   ; move past ascii code
              mov           r8,rb                ; xfer name to R8
              call          findname             ; find entry
              lbnf           ascnoerr             ; jump if name was found
ascerr:       mov           rf, msgerr           ; error message
              lbr            execrmsg
ascnoerr:     inc           r7                   ; point to type
              inc           r7
              ldn           r7                   ; get type
              smi           FVARIABLE            ; check for variable
              lbz           execvar              ; jump if so
              ldn           r7                   ; get type
              smi           FCOLON               ; check for function
              lbnz           ascerr               ; jump if not
              glo           r8                   ; save position
              stxd                               ; and store on stack
              ghi           r8
              stxd
              call          exec                 ; call exec to execute stored program
              irx                                ; recover pointer
              ldxa
              phi           rb
              ldx
              plo           rb
              lbr           exec                 ; and continue execution
execvar:      call          push                 ; push var address to stack
              mov           rb,r8                ; address back to RB
              lbr           exec                 ; execute next code
; helper return calls to save space:
; goodpush - push RB, indicate no error, continue exec
; good - indicate no error, continue exec
; error - indicate error, continue exec
; goodpushb - D->RB.1, goodpush
; goodpushb0 - D->RB.0, goodpush
; typegoode - D->RE.0, call typenum, goto good
; typegood - call typenum, goto good
; goodrpush - rpush rb, good
; goodrpush78b - r8->rb rpush r7->rb, rpush, good
; goodrpush0 - D->RB.0 rpush
; gooddf - DF->RB, push
; goodisp - call disp, good
; goodpushb8b - D->RB.0, push r8->rb, goodpushb0
;
;          org     600h
cdup:         call          pop                  ; pop value from forth stack
              bdf           error                ; jump if stack was empty
              call          push                 ; push back twice
goodpush:                                        ; other things come here to push once
              call          push
good:         ldi           0                    ; indicate success
              lskp
error:        ldi           1
              lbr           execret              ; return to caller
cdrop:        call          pop                  ; pop value from stack
              bdf           error                ; jump if stack was empty
              br            good                 ; return
cplus:        call          pop                  ; get value from stack
              bdf           error                ; jump if stack was empty
              mov           r7,rb
              call          pop                  ; next number
              bdf           error                ; jump if stack was empty
              glo           r7                   ; perform addition
              str           r2
              glo           rb
              add
              plo           rb
              ghi           r7
              str           r2
              ghi           rb
              adc
goodpushb:
              phi           rb
              br            goodpush
cminus:       call          pop                  ; get value from stack
cmerr:        bdf           error                ; jump if stack was empty
              mov           r7,rb                ; move number
              call          pop                  ; next number
              bdf           cmerr                ; jump if stack was empty
              glo           r7                   ; perform addition
              str           r2
              glo           rb
              sm
              plo           rb
              ghi           r7
              str           r2
              ghi           rb
              smb
              br            goodpushb
cdot:         call          pop                  ; get value from stack
cdoterr:      bdf           error                ; jump if stack was empty
              ldi           1
typegoode:
              plo           re                   ; signal signed int
typegood:
              call          typenum
              br            good                 ; return
cudot:        call          pop
              bdf           cdoterr              ; jump if stack was empty
              ldi           0
              br            typegoode
cdotx:
              call          pop
              bdf           cdoterr
              call          typenumind
              br            good
cand:         call          pop
canderr:      bdf           error                ; jump if stack was empty
              mov           r7,rb                ; move number
              call          pop
              bdf           canderr              ; jump if stack was empty
              glo           r7                   ; perform and
              str           r2
              glo           rb
              and
              plo           rb
              ghi           r7
              str           r2
              ghi           rb
              and
              br            goodpushb
cor:          call          pop
              bdf           canderr              ; jump if stack was empty
              mov           r7,rb                ; move number
              call          pop
              bdf           canderr              ; jump if stack was empty
              glo           r7                   ; perform and
              str           r2
              glo           rb
              or
              plo           rb
              ghi           r7
              str           r2
              ghi           rb
              or
              br            goodpushb
cxor:         call          pop
cxorerr:      bdf           error                ; jump if stack was empty
              mov           r7,rb                ; move number
              call          pop
              bdf           cxorerr              ; jump if stack was empty
              glo           r7                   ; perform and
              str           r2
              glo           rb
              xor
              plo           rb
              ghi           r7
              str           r2
              ghi           rb
              xor
              br            goodpushb
ccr:          call          crlfout
              br            good                 ; return
cswap:        call          pop
cserr:        bdf           error                ; jump if stack was empty
              mov           r7,rb                ; move number
              call          pop
              lbdf           error                ; jump if stack was empty
              mov           r8,rb                ; move number
              mov           rb,r7                ; restore first number
              call          push                 ; put answer back on stack
              ghi           r8                   ; move number
              phi           rb
              glo           r8
goodpushb0:
              plo           rb
              lbr            goodpush
crat:
ci:           call          rpop                 ; get value from return stack
              call          rpush                ; put it back
              lbr            goodpush
cmem:
              ldi           low freemem          ; set R9 to free memory
              plo           r9
              lda           r9                   ; get high byte of free memory pointer
              stxd                               ; store on stack
              lda           r9                   ; get low byte
              str           r2                   ; store on stack
              ldi           low fstack           ; get pointer to stack
              plo           r9                   ; set into data frame
              inc           r9                   ; point to lo byte
              ldn           r9                   ; get it
              sm                                 ; perform subtract
              plo           rb                   ; put into result
              dec           r9                   ; high byte of stack pointer
              irx                                ; point to high byte os free mem
              ldn           r9                   ; get high byte of stack
              smb                                ; continue subtraction
              lbr           goodpushb
cdo:          call          pop
cdoerr:       lbdf          error                ; jump if stack was empty
              mov           r7,rb
              call          pop
              lbdf          error               ; jump if stack was empty
              mov           r8,rb
              mov           ra,r2
              inc           ra                   ; pointing at R[6] value high
              lda           ra                   ; get high of R[6]
              phi           rb                   ; put into r6
              lda           ra
              plo           rb
              call          rpush                ; store inst point on return stack
goodrpush78b:
              mov           rb,r8                ; termination to rb
              call          rpush                ; store termination on return stack
              ghi           r7                   ; transfer count to rb
              phi           rb
              glo           r7
goodrpushb0:
              plo           rb
goodrpush:
              call          rpush
              lbr           good
cloop:        call          rpop
              inc           rb                   ; add 1 to it
loopcnt:      mov           r7,rb
              call          rpop                 ; get termination
              glo           rb                   ; get lo of termination
              str           r2                   ; place into memory
              glo           r7                   ; get count
              sm                                 ; perform subtract
              ghi           rb                   ; get hi of termination
              str           r2                   ; place into memory
              ghi           r7                   ; get high of count
              smb                                ; continue subtract
              bdf           cloopdn              ; jump if loop complete
              mov           r8,rb
              call          rpop                 ; get loop address
              call          rpush                ; keep on stack as well
              mov           ra,r2
              inc           ra                   ; pointing at ra value high
              ghi           rb
              str           ra                   ; and write it
              inc           ra
              glo           rb                   ; get rb lo value
              str           ra                   ; and write it
              br            goodrpush78b
cloopdn:      call          rpop                 ; pop off start of loop address
              lbr           good                 ; and return
cploop:       call          rpop                 ; get top or return stack
              ghi           rb                   ; put count into memory
              stxd
              glo           rb
              stxd
              call          pop                  ; get word from data stack
              lbdf          error
              irx
              glo           rb                   ; add to count
              add
              plo           rb
              ghi           rb
              irx
              adc
              phi           rb
              br            loopcnt              ; then standard loop code
cbegin:       mov           ra,r2
              inc           ra                   ; pointing at ra value high
              lda           ra                   ; get high of ra
              phi           rb                   ; put into rb
              lda           ra
              br            goodrpushb0
; [GDJ] corrected logic - BEGIN/UNTIL loop should repeat if flag preceding UNTIL is FALSE
cuntil:       call          pop                  ; get top of stack
              lbdf          error                ; jump if stack was empty
              glo           rb                   ; [GDJ] check flag LSB - if true were done
              bnz           untilno              ; [GDJ]
              ghi           rb                   ; [GDJ] check flag MSB
              bz            untilyes
untilno:      call          rpop                 ; pop off begin address
              lbr           good                 ; we are done, just return
untilyes:     call          rpop                 ; get return address - continue looping
              call          rpush                ; also keep on stack
              mov           ra,r2
              inc           ra                   ; pointing at ra value high
              ghi           rb
              str           ra                   ; and write it
              inc           ra
              glo           rb                   ; get rb lo value
              str           ra                   ; and write it
              lbr           good                 ; now return
crgt:         call          rpop                 ; get value from return stack
              lbr           goodpush
cgtr:         call          pop
              lbdf          error                ; jump if stack was empty
              br            goodrpush
cunequal:     call          pop
              bdf           cunerr               ; jump if stack was empty
              mov           r7,rb
              call          pop
cunerr:       lbdf          error                ; jump if stack was empty
              glo           r7                   ; perform and
              str           r2
              glo           rb
              xor
              bnz           unequal              ; jump if not equal
              ghi           r7
              str           r2
              ghi           rb
              xor
              bnz           unequal              ; jump if not equal
              plo           rb
              lbr           goodpushb
unequal:      ldi           0                    ; set return result
              phi           rb
              plo           rb
              inc           rb                   ; it is now 1
              lbr           goodpush
; [GDJ]
; determine if NOS < TOS
cless:        call          pop
              lbdf          error                ; jump if stack was empty
              mov           r8,rb
              call          pop
              lbdf          error                ; jump if stack was empty
              mov           r7,rb
              ; bias numbers for comparison
              ghi           r7
              xri           080h                 ; bias upwards
              phi           r7
              ghi           r8
              xri           080h                 ; bias upwards
              phi           r8
              glo           7                    ; subtract them
              str           r2
              glo           r8
              sd
              plo           r7
              ghi           r7
              str           r2
              ghi           r8
              sdb
              phi           r7
gooddf:
              ldi           0
              phi           rb                   ; no matter what
              lsdf
              ldi           1                    ; now D=0 if DF=0 or 1 if DF=1
              plo           rb
              lbr           goodpush
; [GDJ]
culess:       call          pop
              lbdf          error                ; jump if stack was empty
              mov           r7,rb
              call          pop
              lbdf          error                ; jump if stack was empty
              mov           r8,rb
              ; perform subtraction r8-r7  (NOS-TOS) to check for borrow
              glo           r8
              str           r2
              glo           r7
              sd
              plo           r8
              ghi           r8
              str           r2
              ghi           r7
              sdb                                ; subtract with borrow
              br            gooddf
cwords:       mov           r7, cmdtable
              ldi           0
              phi           rd
              plo           rd
cwordslp:     lda           r7                   ; get byte
              bz            cwordsdn             ; jump if done
              plo           rb                   ; save it
              ani           128                  ; check for final of token
              bnz           cwordsf              ; jump if so
              glo           rb                   ; get byte
              call          disp
              br            cwordslp             ; and loop back
cwordsf:      glo           rb                   ; get byte
              ani           07fh                 ; strip high bit
              call          disp
              call          dispsp
              inc           rd
              glo           rd
              smi           12                   ; items per line
              bnz           cwordslp
              ldi           0
              phi           rd
              plo           rd
              call          crlfout
              br            cwordslp             ; and loop back
cwordsdn:     call          crlfout
              mov           r7,storage
              ldi           0
              phi           rd
              plo           rd
cwordslp2:    lda           r7                   ; get pointer to next entry
              phi           r8                   ; put into r8
              lda           r7                   ; now pointing at type indicator
              plo           r8                   ; save low of link
              bnz           cwordsnot            ; jump if not link terminator
              ghi           r8                   ; check high byte too
              bnz           cwordsnot
cwordsdn1:    lbr           ccr                  ; CR and done
cwordsnot:    inc           r7                   ; now pointing at ascii indicator
              inc           r7                   ; first character of name
wordsnotl:    lda           r7                   ; get byte from string
              bz            wordsnxt             ; jump if end of string
              call          disp
              br            wordsnotl            ; keep going
wordsnxt:     call          dispsp
              mov           r7,r8                ; r7=next word address
              inc           rd
              glo           rd
              smi           8
              bnz           cwordslp2
              ldi           0
              phi           rd
              plo           rd
              call          crlfout
              br            cwordslp2            ; and check next word
cemit:        call          pop
              lbdf          error                ; jump if error
              glo           rb                   ; get low of return value
gooddisp:
              call          disp
              lbr           good                 ; return to caller
; [GDJ]
cemitp:       call          pop
              lbdf          error                ; jump if error
              glo           rb                   ; get low of return value
              smi           32                   ; check for below space
              bnf           notprint             ; jump if not printable
              glo           rb
              smi           127                  ; check for above tilde ~
              lsdf                               ; jump if not printable (skip 2)
              glo           rb
              lskp                               ; ok printable so skip ldi .
notprint:     ldi           '.'
emitpout:     br            gooddisp
cwhile:       call          pop
              lbdf          error                ; jump if error
              glo           rb                   ; need to check for zero
              lbnz           whileno              ; jump if not zero
              ghi           rb                   ; check high byte
              lbnz           whileno
              mov           ra,r2
              inc           ra                   ; point to R[6]
              lda           ra                   ; get command stream
              phi           rb                   ; put into r6
              ldn           ra
              plo           rb
              ldi           0                    ; set while count to zero
              plo           r7
findrep:      ldn           rb                   ; get byte from stream
              smi           FWHILE               ; was a while found
              lbnz           notwhile             ; jump if not
              inc           r7                   ; increment while count
notrep:       inc           rb                   ; point to next byte
              lbr            findrep              ; and keep looking
notwhile:     ldn           rb                   ; retrieve byte
              smi           FREPEAT              ; is it a repeat
              lbnz           notrep               ; jump if not
              glo           r7                   ; get while count
              lbz            fndrep               ; jump if not zero
              dec           r7                   ; decrement count
              lbr            notrep               ; and keep looking
fndrep:       inc           rb                   ; move past the while
              glo           rb                   ; now put back into R[6]
              str           ra
              dec           ra
              ghi           rb
              str           ra
              lbr           good                 ; then return to caller
whileno:      mov           ra,r2
              inc           ra                   ; now pointing to high byte of R[6]
              lda           ra                   ; get it
              phi           rb                   ; and put into r6
              ldn           ra                   ; get low byte
              plo           rb
              dec           rb                   ; point back to while command
              lbr           goodrpush
crepeat:      call          rpop                 ; get address on return stack
              mov           ra,r2
              inc           ra                   ; now pointing at high byte of R[6]
              ghi           rb                   ; get while address
              str           ra                   ; and place into R[6]
              inc           ra
              glo           rb
              str           ra
              lbr           good                 ; then return
cif:          call          pop
              lbdf          error                ; jump if error
              glo           rb                   ; check for zero
              lbnz          good                 ; jump if not zero
              ghi           rb                   ; check hi byte too
              lbnz          good                 ; jump if not zero
              mov           ra,r2
              inc           ra                   ; now pointing at R[6]
              lda           ra                   ; get R[6]
              phi           rb
              ldn           ra
              plo           rb
              ldi           0                    ; set IF count
              plo           r7                   ; put into counter
iflp1:        ldn           rb                   ; get next byte
              smi           FIF                  ; check for IF
              bnz           ifnotif              ; jump if not
              inc           r7                   ; increment if count
ifcnt:        inc           rb                   ; point to next byte
              br            iflp1                ; keep looking
ifnotif:      ldn           rb                   ; retrieve byte
              smi           FELSE                ; check for ELSE
              bnz           ifnotelse            ; jump if not
              glo           r7                   ; get IF count
              bnz           ifcnt                ; jump if it is not zero
              inc           rb                   ; move past the else
ifsave:       glo           rb                   ; store back into instruction pointer
              str           ra
              dec           ra
              ghi           rb
              str           ra
              lbr           good                 ; and return
ifnotelse:    ldn           rb                   ; retrieve byte
              smi           FTHEN                ; check for THEN
              bnz           ifcnt                ; jump if not
              glo           r7                   ; get if count
              dec           r7                   ; decrement if count
              bnz           ifcnt                ; jump if not zero
              br            ifsave               ; otherwise found
celse:        mov           ra,r2
              inc           ra                   ; now pointing at R[6]
              lda           ra                   ; get current R[6]
              phi           rb                   ; and place into r6
              ldn           ra
              plo           rb
              ldi           0                    ; count of IFs
              plo           r7                   ; put into R7
elselp1:      ldn           rb                   ; get next byte from stream
              smi           FIF                  ; check for IF
              bnz           elsenif              ; jump if not if
              inc           r7                   ; increment IF count
elsecnt:      inc           rb                   ; point to next byte
              br            elselp1              ; keep looking
elsenif:      ldn           rb                   ; retrieve byte
              smi           FTHEN                ; is it THEN
              bnz           elsecnt              ; jump if not
              glo           r7                   ; get IF count
              dec           r7                   ; minus 1 IF
              bnz           elsecnt              ; jump if not 0
              glo           rb                   ; put into instruction pointer
              str           ra
              dec           ra
              ghi           rb
              str           ra
              lbr           good                 ; now pointing at a then
cequal:       call          pop
              lbdf          error                ; jump if stack was empty
              mov           r7,rb
              call          pop
              lbdf          error                ; jump if stack was empty
              glo           r7                   ; perform and
              str           r2
              glo           rb
              xor
              bnz           unequal2             ; jump if not equal
              ghi           r7
              str           r2
              ghi           rb
              xor
              bnz           unequal2             ; jump if not equal
              phi           rb                   ; set return result
              plo           rb
              inc           rb
              lbr           goodpush
unequal2:     ldi           0
              plo           rb
              lbr           goodpushb
cdepth:
              ldi           low fstack           ; point to free memory pointer
              plo           r9                   ; place into data frame
              lda           r9                   ; get high byte of free memory pointer
              stxd                               ; store on stack
              lda           r9                   ; get low byte
              str           r2                   ; store on stack
              ldi           low tos              ; get pointer to stack
              plo           r9                   ; set into data frame
              inc           r9                   ; point to lo byte
              ldn           r9                   ; get it
              sm                                 ; perform subtract
              plo           rb                   ; put into result
              dec           r9                   ; high byte of stack pointer
              irx                                ; point to high byte os free mem
              ldn           r9                   ; get high byte of stack
              smb                                ; continue subtraction
              shr                                ; divide by 2
              phi           rb                   ; store answer
              glo           rb                   ; propagate the shift
              shrc
              lbr           goodpushb0
crot:         call          pop                  ; get C
              lbdf          error                ; jump if error
              mov           r7,rb
              call          pop                  ; get B
              lbdf          error                ; jump if error
              mov           r8,rb
              call          pop                  ; get A
              lbdf          error                ; jump if error
              mov           rc,rb
              ;  load and push B
              mov           rb,r8
              call          push
              ;  and C
              mov           rb,r7
              call          push
              ghi           rc                   ; get A
              phi           rb
              glo           rc
              lbr           goodpushb0
cmrot:        call          pop                  ; get C
              lbdf          error                ; jump if error
              mov           r7,rb
              call          pop                  ; get B
              lbdf          error                ; jump if error
              mov           r8,rb
              call          pop                  ; get A
              lbdf          error                ; jump if error
              mov           rc,rb
              mov           rb,r7                ; C
              call          push
              ghi           rc                   ; get A
              phi           rb
              glo           rc
goodpushb8b:
              plo           rb
              call          push
              ghi           r8                   ; get B
              phi           rb
              glo           r8
              lbr           goodpushb0
cover:        call          pop                  ; get B
              lbdf          error                ; jump if error
              mov           r7,rb
              call          pop                  ; get A
              lbdf          error                ; jump if error
              mov           r8,rb
              call          push                 ; put onto stack
              ghi           r7                   ; get B
              phi           rb
              glo           r7
              br            goodpushb8b
cat:          call          pop
              lbdf          error                ; jump on error
              mov           r7,rb
              lda           r7                   ; get word at address
catcomm:
              phi           rb
              ldn           r7
              lbr           goodpushb0
cexcl:        call          pop
              lbdf          error                ; jump on error
              mov           r7,rb
              call          pop                  ; date data word from stack
              lbdf          error                ; jump on error
              ghi           rb                   ; write word to memory
              str           r7
              inc           r7
goodexcl:
              glo           rb
              str           r7
              lbr           good                 ; and return
ccat:         call          pop                  ; get address from stack
              lbdf          error                ; jump on error
              mov           r7,rb
              ldi           0                    ; high byte is zero
              br            catcomm
ccexcl:       call          pop
              lbdf          error                ; jump on error
              mov           r7,rb
              call          pop                  ; date data word from stack
              lbdf          error                ; jump on error
              br            goodexcl
cvariable:    
#idef USE_CBUFFER
; easier.. we just copy the FVARIABLE FASCII String and then bump up two bytes and go
              mov           ra,r2
              inc           ra                   ; point to R[6]
              lda           ra                   ; and retrieve it
              phi           rb
              ldn           ra
              plo           rb                   ; RB=Pointer to input bytestream
              ldn           rb                   ; get next byte
              smi           T_ASCII              ; it must be an ascii mark
              lbnz          error                ; jump if not
              dec           rb                   ; point back to FVARIABLE
              ldi           low freemem          ; set R9 to free memory
              plo           r9
              lda           r9                   ; get current pointer
              phi           r7                   ; place here
              ldn           r9                   ; get low byte
              plo           r7                   ; R7=start of variable
              inc           r7
              inc           r7                   ; make room for link
cvarlp: 
              lda           rb                   ; copy from cbuffer to working memory
              str           r7
              inc           r7
              bnz           cvarlp
              push          rb                   ; RB (on stack)= next input token
                                                 ; R7 = area for variable
              ldi           0 
              str           r7                   ; make sure variable is set to zero (extra feature!)
              inc           r7                   
              str           r7
              inc           r7                   ; R7 now new free pointer

              
              ldn           r9                   ; R9 = low byte of freemem
              plo           rf
              dec           r9
              ldn           r9
              phi          rf
              dec           r9
              ghi           r7                  ; get memory pointer
              str           rf       
              str           r9
              inc           r9
              inc           rf           
              glo           r7
              str           rf
              str           r9

              ldi           0                    ; need zero at end of list
              str           r7                   ; store it
              inc           r7
              str           r7
              pop           rb
              glo           rb                   ; write back to instruction pointer
              str           ra
              dec           ra
              ghi           rb
              str           ra
              lbr           good                 ; return
#else
              mov           ra,r2
              inc           ra                   ; point to R[6]
              lda           ra                   ; and retrieve it
              phi           rb
              ldn           ra
              plo           rb
; since we preallocated variable space between the var and the string, we have to skip that here
; and we will move the string back later so the variable space is at the end (important for allot)              
              inc           rb
              inc           rb
              inc           rb
              inc           rb
              ldn           rb                   ; get next byte
              smi           T_ASCII              ; it must be an ascii mark
              lbnz          error                ; jump if not
; move T_ASCII and text back by two              
varlp1:       ldn           rb                   ; get byte
              dec           rb
              dec           rb
              dec           rb
              dec           rb
              str           rb
              inc           rb
              inc           rb
              inc           rb
              inc           rb
              inc           rb
              bnz           varlp1               ; jump if terminator not found
              ; next must be T_EOS
;              ldn           rb
;              smi           T_EOS
;              lbnz          error
; to allow more things on the line, we need to allocate space
; after the string so we either needed to account for that in the tokenizer
; or move the rest of the parsed input line here
; Moving it is a pain because we need to know the length of the rest of the line
; However, the tokenizer can't easily know what strings go with a variable. Our compromise
; is to allocate two extra bytes after VARIABLE in the tokenizer and then move the name bytes back by two
; as we scan
; so now we are pointing to the end so we need to back up 4
              dec           rb
              dec           rb
              dec           rb
              dec           rb
              ldi           0
              str           rb                   ; make sure variable is set to zero (extra feature!)
              inc           rb                   ; new value of freemem
              str           rb
              inc           rb
              ldi           low freemem          ; set R9 to free memory
              plo           r9
              lda           r9                   ; get current pointer
              phi           r7                   ; place here
              ldn           r9                   ; get low byte
              plo           r7
              ghi           rb                   ; get memory pointer
              str           r7                   ; and store into link list
              inc           r7
              glo           rb
              str           r7
;              glo           rb                   ; store new freemem value
              str           r9
              dec           r9
              ghi           rb
              str           r9
              ldi           0                    ; need zero at end of list
              str           rb                   ; store it
              inc           rb
              str           rb
              inc           rb
              glo           rb                   ; write back to instruction pointer
              str           ra
              dec           ra
              ghi           rb
              str           ra
              lbr           good                 ; return
#endif              
ccolon:
#ifdef USE_CBUFFER
; almost the same excep we copy cbuffer to free mem and we have to update within cbuffer not within
              mov           ra,r2
              inc           ra                   ; point to R[6]
              lda           ra                   ; and retrieve it
              phi           rb
              ldn           ra
              plo           rb
; we have to copy from CBUFFER to  either FSEMI or T_EOS
              ldi          low freemem
              plo          r9
              lda          r9
              phi          rf
              ldn          r9
              plo          rf
              ldi          low jump
              plo          r9
              ldn          r9
              xri          0c0h
              bnz          ccmulti               ; don't skip link for lines 2-n, only line 1
              inc          rf                    ; skip link
              inc          rf
              dec          rb                    ; point back at FCOLON
ccmulti:              
              push         rf                    ; we will pop back to RB

              
ccolcpy:      lda          rb
              str          rf
              inc          rf
              plo          re                     ; hold temp
              smi          FSEMI
              lbz           ccolcpydn
              glo          re
              smi          T_EOS
              lbnz          ccolcpy
ccolcpydn:    
              glo          rb
              str          ra
              dec          ra
              ghi          rb
              str          ra       ; set up exec to go after the semi or whatever
              pop          rb       ; this was RF but now points to free mem area
              inc          rb       ; skip FCOLON
; after that it is almost normal 
              ldi           low jump             ; we use this as a flag for multiline ops
              plo           r9
              lda           r9
              xri           0c0h
              lbnz           colonlp1             ; multiline, just keep it going
 ; if first line, assume it MIGHT be multline
              dec           rb                    ; go back after all
              dec           rb
              dec           rb
              glo           rb
              str           r9
              inc           r9
              ghi           rb                   ; yes this is backward for "historical" reasons
              str           r9
              inc           rb
              inc           rb
              inc           rb                   ; put it back

              ldn           rb                   ; get next byte
              smi           T_ASCII              ; it must be an ascii mark
              lbnz          error                ; jump if not
              inc           rb                   ; move into string
colonlp1:                                        ; here for both cases
              ldn           rb
              smi           T_EOS
              lbz           colonmark
              lda           rb
              smi           FSEMI                ; look for the ;
              lbnz           colonlp1             ; jump if terminator not found
              ldi           0                    ; want a command terminator
              str           rb                   ; write it
              inc           rb                   ; new value for freemem
              ldi           low jump
              plo           r9
              ldn           r9
              xri           0C0h
              bz           colonpreline         ; single line
; end of multiline
              ldi           02
              str           r9                  ; end of multi marker ([JUMP]==2)
              inc           r9
              lda           r9
              stxd
              ldn           r9
              str           r2
              ldi           low freemem
              plo           r9
              lda           r2
              str           r9
              inc           r9
              ldn           r2
              str           r9
; now the freemem is back to the beginning of the multiline (or we jumped here on a single line)
colonpreline:
              ldi           low freemem          ; set R9 to free memory
              plo           r9
              lda           r9                   ; get current pointer
              phi           r7                   ; place here
              ldn           r9                   ; get low byte
              plo           r7
              ghi           rb                   ; get memory pointer
              str           r7                   ; and store into link list
              inc           r7
              glo           rb
              str           r7
ccolonpmult:                                     ; come here to only update freemem
              glo           rb                   ; store new freemem value
              str           r9
              dec           r9
              ghi           rb
              str           r9
              ldi           low jump
              plo           r9
              ldn           r9
              xri           1
              bz            colonnend
              ldi           0                    ; need zero at end of list (only if finished)
              str           rb                   ; store it
              inc           rb
              str           rb
colonnend:
;           ldi     low jump    ; already loaded!
;           plo     r9
              ldn           r9
              xri           2                    ; end of multiline
              bnz           csemi
              ldi           0c0h
              str           r9                   ; mark back to normal
#else
              mov           ra,r2
              inc           ra                   ; point to R[6]
              lda           ra                   ; and retrieve it
              phi           rb
              ldn           ra
              plo           rb
              ldi           low jump             ; we use this as a flag for multiline ops
              plo           r9
              ldn           r9
              xri           0c0h
              lbnz           colonlp1             ; multiline, just keep it going
              ldn           rb                   ; get next byte
              smi           T_ASCII              ; it must be an ascii mark
              lbnz          error                ; jump if not
              inc           rb                   ; move into string
colonlp1:                                        ; lda     rb                  ; get byte
              ldn           rb
              smi           T_EOS
              bz           colonmark
              lda           rb
              smi           FSEMI                ; look for the ;
              lbnz           colonlp1             ; jump if terminator not found
              ; check this is really the end
;              ldn           rb
;              smi           T_EOS
;              lbnz          error
              ldi           0                    ; want a command terminator
              str           rb                   ; write it
              inc           rb                   ; new value for freemem
              ldi           low jump
              plo           r9
              ldn           r9
              xri           0C0h
              bz           colonpreline         ; single line
; end of multiline
              ldi           02
              str           r9
              inc           r9
              lda           r9
              stxd
              ldn           r9
              str           r2
              ldi           low freemem
              plo           r9
              lda           r2
              str           r9
              inc           r9
              ldn           r2
              str           r9
; now the freemem is back to the beginning of the multiline (or we jumped here on a single line)
colonpreline:
              ldi           low freemem          ; set R9 to free memory
              plo           r9
              lda           r9                   ; get current pointer
              phi           r7                   ; place here
              ldn           r9                   ; get low byte
              plo           r7
              ghi           rb                   ; get memory pointer
              str           r7                   ; and store into link list
              inc           r7
              glo           rb
              str           r7
ccolonpmult:                                     ; come here to only update freemem
              glo           rb                   ; store new freemem value
              str           r9
              dec           r9
              ghi           rb
              str           r9
              ldi           low jump
              plo           r9
              ldn           r9
              xri           1
              bz            colonnend
              ldi           0                    ; need zero at end of list (only if finished)
              str           rb                   ; store it
              inc           rb
              str           rb
colonnend:
              inc rb                             ; point at next part of exec (may not be end of string!)
              glo           rb                   ; write back to instruction pointer
              str           ra
              dec           ra
              ghi           rb
              str           ra
;           ldi     low jump    ; already loaded!
;           plo     r9
              ldn           r9
              xri           2                    ; end of multiline
              bnz           csemi
              ldi           0c0h
              str           r9                   ; mark back to normal
#endif              
cthen:
csemi:
              lbr           good                 ; return
colonmark:
              ldi           0
              str           rb
              inc           rb
              str           rb                   ; temporary end mark
              dec           rb
              ldi           low jump
              plo           r9
              ldn           r9
              xri           0c0h
              bnz           colonmcont           ; already marked
              ldi           1
              str           r9
#ifndef USE_CBUFFER              
              inc           r9
              ldn           ra                   ; low part
              smi           3                    ; point back to very start
              str           r9
              inc           r9
              dec           ra
              lda           ra
              smbi          0
              str           r9
#endif              
colonmcont:
              ldi           low freemem+1
              plo           r9                   ; set up for main code
              br            ccolonpmult
clist:        mov           r7,storage
clist0:
              push          r7
              ldn           r7
              bnz           clist1
              inc           r7
              ldn           r7
              bnz           clist1
              pop           r7
              lbr           good
clist1:
              pop           r7
              push          r7
              call          csee_sub0
              pop           r7
              ldn           r7
              phi           rb
              inc           r7
              ldn           r7
              plo           r7
              ghi           rb
              phi           r7
              br            clist0
csee:         mov           ra,r2
              inc           ra                   ; point to R[6]
              lda           ra                   ; and retrieve it
              phi           r8
              ldn           ra
              plo           r8
              ldn           r8                   ; get next byte
              smi           T_ASCII              ; it must be an ascii mark
              lbnz          error                ; jump if not
              inc           r8                   ; move into string
              call          findname             ; find the name
              lbdf          error                ; jump if not found
              glo           r8                   ; put new address into inst pointer
              str           ra
              dec           ra
              ghi           r8
              str           ra
              call          csee_sub
              lbr           good                 ; otherwise good
              ;  make see callable so we can use it from inside Forth words
              ; points to next address)
              ;  rb = first byte in data
              ;  user callable csee_sub0 only requires r7. If r7 and rb are set call csee_sub
csee_sub0:
              mov           rb,r7
              inc           rb
              inc           rb
csub0:        ldn           rb                   ; set up rb to point correctly
              inc           rb
              bnz           csub0
csee_sub:
              lda           r7                   ; move past next address  (store next in in RF for later)
              phi           rf
              lda           r7
              plo           rf
              ldn           r7                   ; get type byte
              smi           86h                  ; check for variable
              bnz          cseefunc             ; jump if not
              call          f_inmsg
              db            'VARIABLE ',0
              inc           r7                   ; skip variable mark
              push          r7
seevname:
              inc           r7                   ; point to name
              ldn           r7
              bz            seeveq
              call          disp
              br            seevname
seeveq:
              call          crlfout
              ;  need to see if we need an allot here
              ; if [next]-2 == rb then we do not need it
              dec           rf
              dec           rf                   ; next-2
              glo           rf
              str           r2
              glo           rb                   ; (next-2)-dataaddress
              sd
              plo           rf
              ghi           rf
              str           r2
              ghi           rb
              sdb
              phi           rf                   ; now RF is the offset
              str           r2
              glo           rf
              or
              lbz           seevnoa              ; was equal, jump
seevallot:
              ; ok we need to do the allot here
              push          rb
              ghi           rf
#ifdef        ALLOT_WORDS
              shr
#endif
              phi           rb
              glo           rf
#ifdef        ALLOT_WORDS
              shrc
#endif
              plo           rb
              call          typenumind           ; type count
              call          f_inmsg
              db            'ALLOT',10,13,0
              ;   dump all words (rf has byte count which needs +2 for the original word)
              inc           rf
              inc           rf
; we should check if the length is odd. If so, we do one C! at the start and the rest we do !
; with full words to minimize the amount of data we spit out
              pop           rb                   ; start address
              ldi           0
              phi           rc
              plo           rc
seesto:
              push          rb                   ; save for addr disp
              lda           rb
              plo           re
; check for odd count
              glo           rf
              ani           1
              bz            seeeven
              glo           re
              plo           rb                   ; move for
              ldi           0                    ; byte only
              phi           rb
              br            seeodd
seeeven:
              lda           rb
              plo           rb
              glo           re
              phi           rb
seeodd:
              call          typenumind           ; print data
              pop           rb
              pop           r7
              push          r7
              push          rb
seevnamea:
              inc           r7                   ; point to name
              ldn           r7
              bz            seevdata
              call          disp
              br            seevnamea
seevdata:
              call          dispsp
              mov           rb,rc
              call          typenumind
              pop           rb                   ; print n
              call          f_inmsg
              db            '+ ',0
              glo           rf
              ani           1
              bz            seeeven1
              dec           rf                   ; now it is even
              call          dispf
              db            'C'
              inc           rc                   ; increase count
              inc           rb
              br            seecont
seeeven1:
              inc           rc
              inc           rc
              inc           rb
              inc           rb
              dec           rf
              dec           rf
seecont:
              call          f_inmsg
              db            '!',10,13,0
              ;  stop when rf is zero (assumes rf was even or made even)
              glo           rf
              bnz           seesto
              ghi           rf
              bnz           seesto
              pop           r7
execdn:       rtn                                ; final CRLF already in place
seevnoa:
              lda           rb                   ; get value
              phi           r7
              lda           rb
              plo           rb
              ghi           r7
              phi           rb
              call          typenumind
              pop           r7
seevname1:
              inc           r7
              ldn           r7
              bz            seeveq1
              call          disp
              br            seevname1
seeveq1:
              call          f_inmsg
              db            ' !',0
seeexit:      lbr           crlfout              ; and return
cseefunc:     call          dispf
              db            ':'
              inc           r7                   ; move address to name
seefunclp:    call          dispsp
seefunclpns:
              ldn           r7                   ; get next token
              bz            seeexit              ; jump if done
              smi           T_ASCII              ; check for ascii
              lbnz           seenota              ; jump if not ascii
              inc           r7                   ; move into string
seestrlp:     ldn           r7                   ; get next byte
              bz            seenext              ; jump if done with token
              call          disp
              inc           r7                   ; point to next character
              br            seestrlp             ; and continue til done
seenext:      inc           r7                   ; point to next token
              lbr            seefunclp
seenota:      ldn           r7                   ; reget token
              smi           T_NUM                ; is it a number
              bnz           seenotn              ; jump if not a number
              inc           r7                   ; move past token
              lda           r7                   ; get number into rb
              phi           rb
              ldn           r7
              plo           rb
              glo           r7                   ; save r7
              stxd
              ghi           r7
              stxd
              call          typenumind           ; display the number
              irx                                ; retrieve r7
              ldxa
              phi           r7
              ldx
              plo           r7
              inc           r7
              lbr            seefunclpns          ; next token with no space
seenotn:      mov           rb,cmdtable
              ldn           r7                   ; get token
              ani           07fh                 ; strip high bit
              plo           r8                   ; token counter
seenotnlp:    dec           r8                   ; decrement count
              glo           r8                   ; get count
              bz            seetoken             ; found the token
seelp3:       lda           rb                   ; get byte from token
              ani           128                  ; was it last one?
              bnz           seenotnlp            ; jump if it was
              br            seelp3               ; keep looking
seetoken:     ldn           rb                   ; get byte from token
              ani           128                  ; is it last
              bnz           seetklast            ; jump if so
              ldn           rb                   ; retrieve byte
              call          disp
              inc           rb                   ; point to next character
              br            seetoken             ; and loop til done
seetklast:    ldn           rb                   ; retrieve byte
              ani           07fh                 ; strip high bit
              call          disp
              br            seenext              ; jump for next token
cdotqt:       mov           ra,r2
              inc           ra                   ; point to R[6]
              lda           ra                   ; and retrieve it
              phi           r8
              ldn           ra
              plo           r8
              ldn           r8                   ; get next byte
              smi           T_ASCII              ; it must be an ascii mark
              lbnz          error                ; jump if not
              inc           r8                   ; move past ascii mark
cdotqtlp:     lda           r8                   ; get next byte
              bz            cdotqtdn             ; jump if terinator
              smi           34                   ; check for quote
              bz            cdotqtlp             ; do not display quotes
              dec           r8
              lda           r8
              call          disp
              br            cdotqtlp             ; loop back
cdotqtdn:     glo           r8                   ; put pointer back
              str           ra
              dec           ra
              ghi           r8
              str           ra
              lbr           good                 ; and return
ckey:
              ldi           0                    ; zero the high byte
              phi           rb
              call          getkey
              lbr           goodpushb0
              ; [GDJ]
ckeyq:
              ldi           0
              phi           r7
              plo           r7
              phi           rb
              call          inkey
              glo           r7
              lbr           goodpushb0
; see note below about this aborted attempt to improve callot
#ifdef OLD_CODE_BAD_IDEA           
callot:       mov           r7,storage
callotlp1:    lda           r7                   ; get next link
              phi           r8
              ldn           r7
              plo           r8
              lda           r8                   ; get value at that link
              phi           rb
              ldn           r8
              dec           r8                   ; keep r8 pointing at link
              bnz           callotno             ; jump if next link is not zero
              ghi           rb                   ; check high byte
              bnz           callotno             ; jump if not zero
              br            callotyes
callotno:     mov           r7,r8                ; r7=link
              br            callotlp1            ; and keep looking
callotyes:    inc           r7                   ; point to type byte
              ldn           r7                   ; get it
              smi           FVARIABLE            ; it must be a variable
              lbnz          error                ; jump if not
              call          pop
              lbdf          error                ; jump if error
;;#ifdef        ALLOT_WORDS                        ; note: enable this and you break see/list
              glo           rb                   ; multiply by 2
              shl
              plo           rb
              ghi           rb
              shlc
              phi           rb
;;#endif

; while the below is true, it is also more complicated. If ALLOT appears inside a word
; then you are hosed, because you need to move this still, but you have no way to find it
; an arbitrary number of levels away.
; So, for now, at least, I think I am just going to declare ALLOT as risky which is no worse than it was before.

; The problem here is that if you have something like 10 ALLOT <other stuff> is that if the "other stuff" fills in 
; those 10 cells it will start to wipe out your parsed input line.
; So... we know eosptr and where we are (the value on the stack) plus the # of bytes (RB)
; So... we need to copy # of bytes backward from now to where we will be later
; We need to do this now before the free pointer gets updated and don't forget to update the eosptr
; HOWEVER if we have allot inside a word, the instruction pointer may be < here at which point
; forget it

              mov           ra,r2               ; the top item on the stack is 
              push          r7                  ; our current position in the bytecode stream
              inc           ra                  ; we need to move that part of the line down to account for the allot
              lda           ra
              phi           r7
              ldn           ra
              plo           r7   
              ; if r7<r8 then we don't need to do jack but pop r7 and go
              ghi           r8
              str           r2
              ghi           r7
              sd
              bz            allheretest
              bdf           allotpop7
allheretest:  glo           r8       
              str           r2
              glo           r7
              sdb
              bdf           allotpop7       
; ok we gotta move

                                ; source copy to save input line in R7 (but we saved old R7)
              glo           rb  ; old except *  ; r8 is the top of free space, we add that to the total count
              str           r2                  ; however, the pointer will be used, too, so we can -2 from the count
              glo           r8                  
              add
              plo           r8
              ghi           rb
              str           r2
              ghi           r8
              adc
              phi           r8
; new
              ; need to read/update eos ptr and exec ptr and compute rc 
              push         rc
              ldi          low eosptr+1
              plo          r9
              ldn          r9
              str          r2
              glo          r7          ; [eosptr]-R7 gives count
              sd
              plo          rc
              dec          r9
              ldn          r9
              str          r2
              ghi          r7
              sdb
              phi          rc    ; now we have the count
              inc          rc 
              inc          r9    ; update eosptr
              sex          r9  
              glo          rc
              add
              stxd         
              ghi          rc
              adc
              str          r9
              sex          r2
              push         r8
              inc          R8
              inc          R8
              ; update exec with count also
              glo          r8
              str          ra
              dec          ra
              ghi          r8
              str          ra
; so now, RC=count, R7=src, R8=dst   
              call          cmover
              pop           r8
              pop           rc
allotpop7:              
              pop           r7
; as you were           
    
              dec           r7                   ; point back to link
              glo           r8                   ; and write new pointer
              str           r7
              dec           r7
              ghi           r8
              str           r7
              ldi           low freemem          ; need to adjust free memory pointer
              plo           r9                   ; put into data frame
              ghi           r8                   ; and save new memory position
              str           r9
              inc           r9
              glo           r8
              str           r9
              ldi           0                    ; zero new position
              str           r8
              inc           r8
              str           r8
              lbr           good
              ; end of bad experimental code
#endif
#ifdef USE_CBUFFER
; very simple. Make sure we are in a good place and adjust the here pointer
callot:       mov           r7,storage
callotlp1:    lda           r7                   ; get next link
              phi           r8
              ldn           r7
              plo           r8
              lda           r8                   ; get value at that link
              phi           rb
              ldn           r8
              dec           r8                   ; keep r8 pointing at link
              bnz           callotno             ; jump if next link is not zero
              ghi           rb                   ; check high byte
              bnz           callotno             ; jump if not zero
              br            callotyes
callotno:     mov           r7,r8                ; r7=link
              br            callotlp1            ; and keep looking
callotyes:    inc           r7                   ; point to type byte
              ldn           r7                   ; get it
              smi           FVARIABLE            ; it must be a variable
              lbnz          error                ; jump if not
              call          pop
              lbdf          error                ; jump if error
; here R8 points to the zero and R7 points to the FVARIABLE. RB has the amount to adjust
              dec          r7           ; point to low part

              ldi          low freemem+1
              plo          r9
              glo          rb
              str          r2
              glo          r8
              add
              str          r9
              str          r7
              plo          rf
              dec          r9
              dec          r7
              ghi          rb
              str          r2
              ghi          r8
              adc
              str          r9
              str          r7
              phi          rf
              ldi          0
              str          rf
              inc          rf
              str          rf
              lbr          good


#else
; this is the code we use isntead of the above
callot:       mov           r7,storage
callotlp1:    lda           r7                   ; get next link
              phi           r8
              ldn           r7
              plo           r8
              lda           r8                   ; get value at that link
              phi           rb
              ldn           r8
              dec           r8                   ; keep r8 pointing at link
              bnz           callotno             ; jump if next link is not zero
              ghi           rb                   ; check high byte
              bnz           callotno             ; jump if not zero
              br            callotyes
callotno:     mov           r7,r8                ; r7=link
              br            callotlp1            ; and keep looking
callotyes:    inc           r7                   ; point to type byte
              ldn           r7                   ; get it
              smi           FVARIABLE            ; it must be a variable
              lbnz          error                ; jump if not
              call          pop
              lbdf          error                ; jump if error
              glo           rb                   ; add rb to r8
              str           r2
              glo           r8
              add
              plo           r8
              ghi           rb
              str           r2
              ghi           r8
              adc
              phi           r8
              dec           r7                   ; point back to link
              glo           r8                   ; and write new pointer
              str           r7
              dec           r7
              ghi           r8
              str           r7
              ldi           low freemem          ; need to adjust free memory pointer
              plo           r9                   ; put into data frame
              ghi           r8                   ; and save new memory position
              str           r9
              inc           r9
              glo           r8
              str           r9
              ldi           0                    ; zero new position
              str           r8
              inc           r8
              str           r8
              lbr           good
#endif

cmul:         call          pop
              lbdf          error                ; jump on error
              mov           r7,rb
              call          pop
              lbdf          error                ; jump on error
              call          mul16
              lbr           goodpush
cdiv:         call          pop
              lbdf          error                ; jump on error
              mov           r7,rb
              call          pop
              lbdf          error                ; jump on error
              ghi           r9
              stxd
              call          div16
              irx
              ldx
              phi           r9
              ghi           rc                   ; transfer answer
              phi           rb
              glo           rc
              lbr           goodpushb0
cforget:      mov           ra,r2
              inc           ra                   ; point to ra
              lda           ra                   ; and retrieve it
              phi           r8
              ldn           ra
              plo           r8
              ldn           r8                   ; get next byte
              smi           T_ASCII              ; it must be an ascii mark
              lbnz          error                ; jump if not
              inc           r8                   ; move into string
              call          findname
              lbdf          error                ; jump if not found
              glo           r8
              str           ra
              dec           ra
              ghi           r8
              str           ra
              lda           r7                   ; get next entry
              phi           rb
              ldn           r7
              plo           rb
              dec           r7
              glo           r7                   ; find difference in pointers
              str           r2
              glo           rb
              sm
              plo           rc
              ghi           r7
              str           r2
              ghi           rb
              smb
              phi           rc                   ; RC now has offset, RB is next descr.
forgetlp1:    lda           rb                   ; get pointer
              phi           ra                   ; put into ra
              str           r2
              ldn           rb
              plo           ra
              or                                 ; see if it was zero
              bz            forgetd1             ; jump if it was
              glo           rc                   ; subtract RC from RA
              str           r2
              glo           ra
              sm
              str           rb                   ; store back into pointer
              dec           rb
              ghi           rc
              str           r2
              ghi           ra
              smb
              str           rb
              mov           rb,ra
              br            forgetlp1            ; loop until done
forgetd1:     lda           r7                   ; get next entry
              phi           rb
              ldn           r7
              plo           rb
              dec           r7
              ldi           low freemem          ; get end of memory pointer
              plo           r9                   ; and place into data frame
              lda           r9                   ; get free memory position
              phi           r8
              ldn           r9
              plo           r8
              inc           r8                   ; account for zero bytes at end
              inc           r8
              glo           rb                   ; subtract RB from R8
              str           r2
              glo           r8
              sm
              plo           r8
              ghi           rb
              str           r2
              ghi           r8
              smb
              phi           r8                   ; r8 now has number of bytes to move
forgetlp:     lda           rb                   ; get byte from higher memory
              str           r7                   ; write to lower memory
              inc           r7                   ; point to next position
              dec           r8                   ; decrement the count
              glo           r8                   ; check for zero
              bnz           forgetlp
              ghi           r8
              bnz           forgetlp
              dec           r7                   ; move back to freemem position
              dec           r7
              glo           r7                   ; store back into freemem pointer
              str           r9
              dec           r9
              ghi           r7
              str           r9
              lbr           good                 ; and return
cerror:       call          pop
              lbdf          error                ; jump on error
              glo           rb                   ; get returned value
              lbr           execret              ; return to caller
cef:          ldi           0                    ; start with zero
              phi           rb
              bn1           cef1                 ; jump if ef1 not on
              ori           1                    ; signal ef1 is on
cef1:         bn2           cef2                 ; jump if ef2 ot on
              ori           2                    ; signal ef2 is on
cef2:         bn3           cef3                 ; jump if ef3 not on
              ori           4                    ; signal ef3 is on
cef3:         bn4           cef4                 ; jump if ef4 not on
              ori           8
cef4:
              lbr           goodpushb0
cout:         call          pop                  ; value
              lbdf          error                ; jump on error
              glo           rb
              plo           r8                   ; hold onto it
              call          pop                  ; port
              lbdf          error                ; jump on error
              glo           r8                   ; get value
              str           r2                   ; store into memory for out (assume X=2)
              glo           rb                   ; get port
              ani           7                    ; value must be 1-7
              lbz           error
              smi           1                    ; convert to 0-6
              ;  using a jump table is much shorter than old code
              ;  we take port (0-6) *2 and add outtable
              ;  then we shift PC to RB which will do the work and shift back to P=3
              shl                                ; *2
              adi           low outtable
              plo           rf
              ldi           high outtable
              adci          0                    ; could save some code if we KNEW the table were on one page
              phi           rf
              sep           rf
              dec           r2
              lbr           good
outtable:
              out           1
              sep           r3
              out           2
              sep           r3
              out           3
              sep           r3
              out           4
              sep           r3
              out           5
              sep           r3
              out           6
              sep           r3
              out           7
              sep           r3
cinp:         call          pop
              lbdf          error                ; jump on error
              glo           rb                   ; get port
              ani           7
              lbz           error
              smi           1                    ; check port 1
              shl
              adi           low intable
              plo           rf
              ldi           high intable
              adci          0
              phi           rf
              ldi           0
              phi           rb
              sep           rf
              lbr           goodpushb0
intable:
              inp           1
              sep           r3
              inp           2
              sep           r3
              inp           3
              sep           r3
              inp           4
              sep           r3
              inp           5
              sep           r3
              inp           6
              sep           r3
              inp           7
              sep           r3
; [GDJ]
cspat:        mov           r8,fstack            ; get stack address pointer
              ; get stack address
addat:              
              lda           r8
              phi           rb
              ldn           r8
              plo           rb
              ; add 1 byte offset
              mov           r7, 1
              glo           r7                   ; perform addition
              str           r2
              glo           rb
              add
              plo           rb
              ghi           r7
              str           r2
              ghi           rb
              adc
              lbr           goodpushb
crpat:        mov           r8,rstack   
              lbr            addat           
; -----------------------------------------------------------------
; additions April 2022  GDJ
; -----------------------------------------------------------------
ccmove:       call          pop
              lbdf          error                ; jump if error
              mov           rc,rb                ; rc is count of bytes
              call          pop
              lbdf          error               ; jump if error
              mov           r8,rb                ; r8 is destination address
              call          pop
ccmerr:       lbdf          error                ; jump if error
              mov           r7,rb                ; r7 is source address
              call          cmover
              lbr           good

              ; transfer data subroutine for general use: RC=count, R7=SRC R8=DST
              ; begin check for zero byte count else tragedy could result
              ; for our internal purposes, we will always move forward so we need to do it backward
              ; the original code always moved forward. It would be smarter to figure out which way to go
              ; based on src<dst move back to front, dst<src move front to back
cmover:
              glo           rc
              str           r2
              glo           r7
              add
              plo           r7
              ghi           rc
              str           r2
              ghi           r7
              adc
              phi           r7
              dec           r7
              glo           rc
              str           r2
              glo           r8
              add
              plo           r8
              ghi           rc
              str           r2
              ghi           r8
              adc
              phi           r8
              dec           r8

cmovelp:      glo           rc
              bnz           cmovestr
              ghi           rc
              bnz           cmovestr
              rtn              
cmovestr:     ldn           r7
              dec           r7
              str           r8
              dec           r8
              dec           rc
              br            cmovelp
csetq:        call          pop
              lbdf          error                ; jump if error
              glo           rb                   ; get low of return value
              bz            qoff
              seq
              skp
qoff:         req
              lbr           good
cdecimal:     ldi           10
              lskp
chex:         ldi           16
              plo           rf
              mov           rd, basen
              glo           rf
              str           rd
              lbr           good
crand:        call          randbyte
              ghi           r8
              plo           rb
              ldi           0
              lbr           goodpushb
              ;  call f_msg but first store terminator and reset f to buffer
f_msg_term:   ldi           0
              str           rf
              mov           rf, buffer
              lbr           f_msg
; VT100 ansi control
; printf("%c[%d;%dH",ESC,y,x);
; Note this directly calls f_uintout so should not matter if you are in hex mode or not
cgotoxy:      call          pop
xyerr:        lbdf          error                ; jump if error
              mov           rd,rb                ; rd is Y coord (row)
              call          pop
              lbdf          error                ; jump if error
              mov           r8,rb                ; r8 is X coord (col)
              ; send CSI sequence
              call          f_inmsg
              db            27, '[', 0
              ; Y
              mov           rf, buffer
              call          f_uintout
              call          f_msg_term
              ; type separator
              call          dispf
              db            ';'
              ; X
              mov           rf, buffer
              mov           rd,r8
              call          f_uintout
              call          f_msg_term
              ; type ending char
              ldi           'H'
              lbr           gooddisp
; -----------------------------------------------------------------------------
; 'C' style operators for bit shifting, note no range check on number of shifts
; -----------------------------------------------------------------------------
clshift:      call          pop
              lbdf          error                ; jump if stack was empty
              glo           rb                   ; move number
              plo           r7                   ; number of shifts
              call          pop
              lbdf          error                ; jump if stack was empty
              mov           r8,rb                ; value to shift left
              glo           r7                   ; zero shift is identity
              lbz            lshiftret
; fall through
lshiftlp:     glo           r8
              shl                                ; shift lo byte
              plo           r8
              ghi           r8
              shlc                               ; shift hi byte with carry
              phi           r8
              dec           r7
              glo           r7
              bnz           lshiftlp
lshiftret:    mov           rb,r8
              lbr           goodpush
crshift:      call          pop
              lbdf          error                ; jump if stack was empty
              glo           rb                   ; move number
              plo           r7                   ; number of shifts
              call          pop
              lbdf          error                ; jump if stack was empty
              mov           r8,rb
              glo           r7                   ; zero shift is identity
              bz            rshiftret            ; return with no shift
; fall through
rshiftlp:     ghi           r8
              shr                                ; shift hi byte
              phi           r8
              glo           r8
              shrc                               ; shift lo byte with carry
              plo           r8
              dec           r7
              glo           r7
              bnz           rshiftlp
rshiftret:    mov           rb,r8
              lbr           goodpush
; delay for approx 1 millisecond on 4MHz 1802
cdelay:       call          pop
              lbdf          error                ; jump if stack was empty
; 0 delay turns out to be the same as 0x10000 delay so special case it
              glo           rb
              plo           r7
              bnz           delaynz
              ghi           rb 
              lbz           good
delaynz:      ghi           rb                  ; redundant unless you skipped from above
              phi           r7
delaylp1:     ldi           60
delaylp2:     nop
              smi           1
              lbnz          delaylp2
              dec           r7
              glo           r7
              lbnz          delaylp1
              ghi           r7
              lbnz          delaylp1
              lbr           good

cexec:        call          pop
              lbdf          error
              mov           r8, jump             ; point to jump address
              ldi           0c0h                 ; lbr
              str           r8                   ; store it
              inc           r8
              ghi           rb
              str           r8
              inc           r8
              glo           rb
              str           r8
              call          cexec0
              ; if we return RB is pushed on stack
              lbr           goodpush
cexec0:       lbr           jump                 ; transfer to user code. If it returns, it goes back to my caller
; -----------------------------------------------------------------------------
; Load contents of dictionary - any session defined words/values will be zapped
; -----------------------------------------------------------------------------
#ifdef BLOAD_BIN
cbload:       push          rf
              push          rd
              push          rc
              mov           rf, extblock         ; source address
              mov           rd,himem
              mov           rc, endextblock-extblock  ; block size
bloadlp:      lda           rf
              str           rd
              inc           rd
              dec           rc
              glo           rc
              bnz           bloadlp
              ghi           rc
              bnz           bloadlp
              pop           rc
              pop           rd
              pop           rf
              lbr           mainlp               ; back to main loop
#endif

#ifdef BLOAD_TEXT
cbload:       mov           rb,loadtext
cbload2:      ldn           rb
              lbz           mainlp
              ;call          dispf
              ;db '.'  ; Just for debugging print a dot for each line loaded
              call          tknizerb
              push          rb
#ifndef USE_CBUFFER
              ldi           low freemem
              plo           r9
              lda           r9
              phi           rb
              ldn           r9
              plo           rb
              inc           rb
              inc           rb
#else
              mov           rb,cbuffer
#endif                            
              call          exec
              pop           rb
              inc           rb
              br            cbload2

#endif

; -----------------------------------------------------------------
#ifdef        ANYROM
csave:        push          rf                   ; save consumed registers
              push          rc
              call          xopenw               ; open write channel
              mov           rf,freemem           ; need pointer to freemem
              lda           rf                   ; get high address of free memory
              smi           high himem
              phi           rc                   ; store into count
              ldn           rf                   ; get low byte of free memory
              plo           rc                   ; store into count
              inc           rc                   ; account for terminator
              inc           rc
              mov           rf,buffer            ; temporary storage
              ghi           rc                   ; get high byte of count
              str           rf                   ; store it
              inc           rf                   ; point to low byte
              glo           rc                   ; get it
              str           rf                   ; store into buffer
              dec           rf                   ; move back to buffer
              mov           rc,2                 ; 2 bytes of length
              call          xwrite
              mov           rf,buffer            ; point to where count is
              mov           rc,rf
              mov           rf,himem             ; point to forth data
              call          xwrite
              call          xclosew
              pop           rc                   ; recover consumed registers
              pop           rf
              lbr           good                 ; all done
#endif
#ifdef        ELFOS
csave:        mov           ra,r2
              inc           ra                   ; point to ra
              lda           ra                   ; and retrieve it
              phi           rb
              ldn           ra
              plo           rb
              ldn           rb                   ; get next byte
              smi           T_ASCII              ; it must be an ascii mark
              lbnz          error                ; jump if not
              inc           rb                   ; move into string
              call          setupfd
              mov           rf,rb                ; file name
              ldi           1                    ; create if nonexistant
              plo           r7
              call          o_open
              mov           rf, freemem
              ldi           0                    ; need to write 2 bytes
              phi           rc
              ldi           2
              plo           rc
              call          o_write
              ldi           high storage         ; point to data storage
              phi           rf
              stxd                               ; store copy on stack for sub
              ldi           low storage
              plo           rf
              str           r2
              ldi           low freemem          ; pointer to free memory
              plo           r9                   ; put into data segment pointer
              inc           r9                   ; point to low byte
              ldn           r9                   ; retrieve low byte
              sm                                 ; subtract start address
              plo           rc                   ; and place into count
              irx                                ; point to high byte
              dec           r9
              ldn           r9                   ; get high byte of free mem
              smb                                ; subtract start
              phi           rc                   ; place into count
              inc           rc                   ; account for terminator
              inc           rc
              call          o_write
              call          o_close
              ldi           0                    ; terminate command
              dec           rb
              str           rb
              lbr           good                 ; return
#endif
#ifdef        ANYROM
cload:        push          rf                   ; save consumed registers
              push          rc
              push          re                   ; [GDJ]
              call          xopenr               ; open XMODEM read channel
              mov           rf,buffer            ; point to buffer
              mov           rc,2                 ; need to read 2 bytes
              call          xread
              mov           rf,buffer            ; point to buffer
              lda           rf                   ; retrieve count
              phi           rc                   ; into rc
              ldn           rf
              plo           rc                   ; rc now has count of bytes to read
              mov           rf,himem             ; point to forth data
              call          xread
              call          xcloser
              pop           re                   ; [GDJ]
              pop           rc                   ; recover consumed registers
              pop           rf
              lbr           mainlp               ; back to main loop
#endif
#ifdef        ELFOS
cload:        mov           ra,r2
              inc           ra                   ; point to ra
              lda           ra                   ; and retrieve it
              phi           rb
              ldn           ra
              plo           rb
              ldn           rb                   ; get next byte
              smi           T_ASCII              ; it must be an ascii mark
              lbnz          error                ; jump if not
              inc           rb                   ; move into string
              call          setupfd
              mov           rf,rb                ; file name
              ldi           0                    ; create if nonexistant
              plo           r7
              call          o_open
              lbdf          error                ; jump if file is not opened
              mov           rf, freemem
              ldi           0                    ; need to read 2 bytes
              phi           rc
              ldi           2
              plo           rc
              call          o_read
              ldi           high storage         ; point to data storage
              phi           rf
              stxd                               ; store copy on stack for sub
              ldi           low storage
              plo           rf
              str           r2
              ldi           low freemem          ; pointer to free memory
              plo           r9                   ; put into data segment pointer
              inc           r9                   ; point to low byte
              ldn           r9                   ; retrieve low byte
              sm                                 ; subtract start address
              plo           rc                   ; and place into count
              irx                                ; point to high byte
              dec           r9
              ldn           r9                   ; get high byte of free mem
              smb                                ; subtract start
              phi           rc                   ; place into count
              inc           rc                   ; account for terminator
              inc           rc
              call          o_read
              call          o_close
              irx                                ; remove exec portions from stack
              irx
              irx
              irx
              lbr           mainlp               ; back to main loop
#endif
cbye:         lbr           exitaddr
cbase:        ldi           low basev
              plo           rb
              ldi           high basev           ; don't use mov so we can save a byte by calling goodpushb
              lbr           goodpushb
crseed:       ldi           low rseed
              plo           rb
              ldi           high rseed           ; don't use mov so we can save a byte by calling goodpushb
              lbr           goodpushb
#ifdef        ELFOS
setupfd:      mov           rd, fildes
              inc           rd                   ; point to dta entry
              inc           rd
              inc           rd
              inc           rd
              ldi           high dta             ; get address of dta
              str           rd                   ; and store it
              inc           rd
              ldi           low dta
              str           rd
              mov           rd, fildes
              rtn                                ; return to caller
#endif
; **********************************************************
; ***** Convert string to uppercase, honor quoted text *****
; **********************************************************
touc:         ldn           rf                   ; check for quote
              smi           022h
              bz            touc_qt              ; jump if quote
              ldn           rf                   ; get byte from string
              bz            touc_dn              ; jump if done
              smi           'a'                  ; check if below lc
              bnf           touc_nxt             ; jump if so
              smi           27                   ; check upper rage
              bdf           touc_nxt             ; jump if above lc
              ldn           rf                   ; otherwise convert character to lc
              smi           32
              str           rf
touc_nxt:     inc           rf                   ; point to next character
              br            touc                 ; loop to check rest of string
touc_dn:      rtn                                ; return to caller
touc_qt:      inc           rf                   ; move past quote
touc_qlp:     lda           rf                   ; get next character
              bz            touc_dn              ; exit if terminator found
              smi           022h                 ; check for quote charater
              bz            touc                 ; back to main loop if quote
              br            touc_qlp             ; otherwise keep looking
; [GDJ] type out number according to selected BASE and signed/unsigned flag
typenumind:
              push          rf                   ; save rf for tokenizer
typenos:
              call          dispf
              db            '0'
              mov           rd, basen
              ldn           rd
              smi           10
              bz           typenuminddec
              ldi           'x'
              lskp
typenuminddec:
              ldi           '#'
              call          disp                 ; Do not use dispf here because we have an lskp above!
              ldi           0
              plo           re                   ; always unsigned here
              br            typenumx
typenum:                                         ; get BASE  ; enter here for normal output
              push          rf                   ; save rf for tokenizer
typenumx:
              mov           rd, basen
              ldn           rd
              smi           10
              bnz           typehex
              mov           rd,rb
              mov           rf, buffer
              glo           re
              bz            typenumU
              call          f_intout
              br            typeout
typenumU:     call          f_uintout
              br            typeout
typehex:
              mov           rd,rb
              mov           rf, buffer
              ghi           rd
              bz            hexbyte
              call          f_hexout4
              br            typeout
hexbyte:      call          f_hexout2
typeout:      ldi           ' '                  ; add space
              str           rf
              inc           rf
nospace:
              call          f_msg_term
              pop           rf
              rtn                                ; return to caller
; *************************************
; *** Check if character is numeric ***
; *** D - char to check             ***
; *** Returns DF=1 if numeric       ***
; ***         DF=0 if not           ***
; *************************************
isnum:        plo           re                   ; save a copy
              smi           '0'                  ; check for below zero
              bnf           fails                ; jump if below
              smi           10                   ; see if above
              bdf           fails                ; fails if so
passes:       smi           0                    ; signal success
              lskp
fails:        adi           0                    ; signal failure
              glo           re                   ; recover character
              rtn                                ; and return
err:          smi           0                    ; signal an error
              rtn                                ; and return
; **********************************
; *** check D if hex             ***
; *** Returns DF=1 - hex         ***
; ***         DF=0 - non-hex     ***
; **********************************
ishex:        call          isnum
              plo           re                   ; keep a copy
              bdf           passes               ; jump if it is numeric
              smi           'A'                  ; check for below uppercase a
              bnf           fails                ; value is not hex
              smi           6                    ; check for less then 'G'
              bnf           passes               ; jump if so
              glo           re                   ; recover value
              smi           'a'                  ; check for lowercase a
              bnf           fails                ; jump if not
              smi           6                    ; check for less than 'g'
              bnf           passes               ; jump if so
              br            fails
              ; clear tos, himem & rstack blocks
              
;--------------------------------------------------------------
;    Read byte from UART if char available
;    return in r7.0 - else return null
;
;    from original bios code of Bob Armstrong
;    modified for non-blocking console input
;--------------------------------------------------------------
inkey:        ldi           015h                 ; need UART line status register
              str           r2                   ; prepare for out
              out           UART_SELECT          ; write to register select port
              dec           r2                   ; correct for inc on out
              inp           UART_DATA            ; read line status register
              ani           1                    ; mask for data ready bit
              lbz            nokey                ; return if no bytes to read
              ldi           010h                 ; select data register
              str           r2                   ; prepare for out
              out           UART_SELECT          ; write to register select port
              dec           r2                   ; back to free spot
              inp           UART_DATA            ; read UART data register
              plo           r7
              rtn
nokey:        ldi           0h
              plo           r7
              rtn
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
randbyte:     mov           rd,rseed
              sex           rd
              ldn           rd                   ; D = VarX
              adi           1
              str           rd
              inc           rd
              lda           rd                   ; D = VarA
              inc           rd
              xor                                ; D = VarA XOR VarC
              dec           rd
              dec           rd
              dec           rd
              xor                                ; D = VarA XOR VarC XOR VarX
              inc           rd
              str           rd                   ; VarA = D
              inc           rd
              add
              stxd
              shr
              xor
              inc           rd
              inc           rd
              add
              str           rd
              phi           r8                   ; added GDJ
              sex           r2                   ; ...
              rtn
chere:        ldi           low freemem          ; set R9 to free memory
              plo           r9
              lda           r9
              phi           rb
              ldn           r9
              plo           rb
              lbr           goodpush
ctohere:      call          pop
              lbdf          error
              ldi           low freemem          ; set R9 to free memory
              plo           r9
              ghi           rb
              str           r9
              inc           r9
              glo           rb
              str           r9
              lbr           good
hello:        db            'Rc/Forth 0.4',0
aprompt:      db            ':'                  ; no zero, adds to prompt (must be right before prompt)
prompt:       db            'ok ',0
msempty:      db            'stack empty',10,13,0
msgerr:       db            'err',10,13,0
cmdtable:     db            'WHIL',('E'+80h)
              db            'REPEA',('T'+80h)
              db            'I',('F'+80h)
              db            'ELS',('E'+80h)
              db            'THE',('N'+80h)
              db            'VARIABL',('E'+80h)
              db            (':'+80h)
              db            (';'+80h)
              db            'DU',('P'+80h)
              db            'DRO',('P'+80h)
              db            'SWA',('P'+80h)
              db            ('+'+80h)
              db            ('-'+80h)
              db            ('*'+80h)
              db            ('/'+80h)
              db            ('.'+80h)
              db            'U',('.'+80h)
              db            ('I'+80h)
              db            'AN',('D'+80h)
              db            'O',('R'+80h)
              db            'XO',('R'+80h)
              db            'C',('R'+80h)
              db            'ME',('M'+80h)
              db            'D',('O'+80h)
              db            'LOO',('P'+80h)
              db            '+LOO',('P'+80h)
              db            ('='+80h)
              db            '<',('>'+80h)
              db            ('<'+80h)            ; [GDJ]
              db            'U',('<'+80h)        ; [GDJ]
              db            'BEGI',('N'+80h)
              db            'UNTI',('L'+80h)
              db            'R',('>'+80h)
              db            '>',('R'+80h)
              db            'R',('@'+80h)        ; [GDJ]
              db            'WORD',('S'+80h)
              db            'EMI',('T'+80h)
              db            'EMIT',('P'+80h)     ; [GDJ]
              db            'DEPT',('H'+80h)
              db            'RO',('T'+80h)
              db            '-RO',('T'+80h)
              db            'OVE',('R'+80h)
              db            ('@'+80h)
              db            ('!'+80h)
              db            'C',('@'+80h)
              db            'C',('!'+80h)
              db            'CMOV',('E'+80h)     ; [GDJ]
              db            '.',(34+80h)
              db            'KE',('Y'+80h)
              db            'KEY',('?'+80h)      ; [GDJ]
              db            'ALLO',('T'+80h)
              db            'ERRO',('R'+80h)
              db            'SE',('E'+80h)
              db            'FORGE',('T'+80h)
              db            'OU',('T'+80h)
              db            'IN',('P'+80h)
              db            'E',('F'+80h)
              db            'SET',('Q'+80h)      ; [GDJ]
              db            'SAV',('E'+80h)
              db            'LOA',('D'+80h)
              db            'BY',('E'+80h)
              db            'SP',('@'+80h)       ; [GDJ]
              db            'DECIMA',('L'+80h)   ; [GDJ]
              db            'HE',('X'+80h)       ; [GDJ]
              db            '<',('<'+80h)        ; [GDJ]
              db            '>',('>'+80h)        ; [GDJ]
              db            'DELA',('Y'+80h)     ; [GDJ]
              db            'BLOA',('D'+80h)     ; [GDJ]
              db            'GOTOX',('Y'+80h)    ; [GDJ]
              db            'RAN',('D'+80h)      ; [GDJ]
              db            'EXE',('C'+80h)
              db            'LIS',('T'+80h)
              db            'X',('.'+80h)
              db            'NE',('W'+80h)
              db            'HER',('E'+80h)
              db            '->HER',('E'+80h)
              db            'BAS',('E'+80h)
              db            'ENDI',('F'+80h)
              db            'RSEE',('D'+80h)
              db            'RP',('@'+80h)
              db            ('('+80h)
              db            0                    ; no more tokens
cmdvecs:      dw            cwhile               ; 81h
              dw            crepeat              ; 82h
              dw            cif                  ; 83h
              dw            celse                ; 84h
              dw            cthen                ; 85h
              dw            cvariable            ; 86h
              dw            ccolon               ; 87h
              dw            csemi                ; 88h
              dw            cdup                 ; 89h
              dw            cdrop                ; 8ah
              dw            cswap                ; 8bh
              dw            cplus                ; 8ch
              dw            cminus               ; 8dh
              dw            cmul                 ; 8eh
              dw            cdiv                 ; 8fh
              dw            cdot                 ; 90h
              dw            cudot                ; 91h
              dw            ci                   ; 92h
              dw            cand                 ; 93h
              dw            cor                  ; 94h
              dw            cxor                 ; 95h
              dw            ccr                  ; 96h
              dw            cmem                 ; 97h
              dw            cdo                  ; 98h
              dw            cloop                ; 99h
              dw            cploop               ; 9ah
              dw            cequal               ; 9bh
              dw            cunequal             ; 9ch
              dw            cless                ; 9dh [GDJ]
              dw            culess               ; 9eh [GDJ]
              dw            cbegin               ; 9fh
              dw            cuntil               ; a0h
              dw            crgt                 ; a1h
              dw            cgtr                 ; a2h
              dw            crat                 ; a3h [GDJ]
              dw            cwords               ; a4h
              dw            cemit                ; a5h
              dw            cemitp               ; a6h [GDJ]
              dw            cdepth               ; a7h
              dw            crot                 ; a8h
              dw            cmrot                ; a9h
              dw            cover                ; aah
              dw            cat                  ; abh
              dw            cexcl                ; ach
              dw            ccat                 ; adh
              dw            ccexcl               ; aeh
              dw            ccmove               ; afh [GDJ]
              dw            cdotqt               ; b0h
              dw            ckey                 ; b1h
              dw            ckeyq                ; b2h [GDJ]
              dw            callot               ; b3h
              dw            cerror               ; b4h
              dw            csee                 ; b5h
              dw            cforget              ; b6h
              dw            cout                 ; b7h
              dw            cinp                 ; b8h
              dw            cef                  ; b9h
              dw            csetq                ; bah [GDJ]
              dw            csave                ; bbh
              dw            cload                ; bch
              dw            cbye                 ; bdh
              dw            cspat                ; beh [GDJ]
              dw            cdecimal             ; bfh [GDJ]
              dw            chex                 ; c0h [GDJ]
              dw            clshift              ; c1h [GDJ]
              dw            crshift              ; c2h [GDJ]
              dw            cdelay               ; c3h [GDJ]
#ifndef       NO_BLOAD
              dw            cbload               ; c4h [GDJ]
#else
              dw            cload
#endif
              dw            cgotoxy              ; c5h [GDJ]
              dw            crand                ; c6h [GDJ]
              dw            cexec                ; c7h [gnr]
              dw            clist                ; c8h [gnr]
              dw            cdotx                ; c9h [gnr]
              dw            cnew                 ; cah [gnr]
              dw            chere
              dw            ctohere
              dw            cbase
              dw            cthen                ; alias ENDIF=then (as in gforth)
              dw            crseed
              dw            crpat
              dw            0


#ifdef        STGROM
#define       EBLOCK 
#define       STGROMBLOAD  
#endif
#ifdef        RAM  
#define       EBLOCK 
#define       RAMBLOAD
#endif
#ifdef        NO_BLOAD
#undef        EBLOCK
#endif

#ifdef BLOAD_TEXT
loadtext:
   include extended.inc
#ifdef STGROMBLOAD
#undef STGROMBLOAD
#endif
#ifdef RAMBLOAD
#undef RAMBLOAD
#endif
#endif

#ifdef BLOAD_BIN
extblock:
#endif

#ifdef        STGROMBLOAD
              include       stgrombload.inc
#endif
#ifdef        RAMBLOAD
              include       rambload.inc
#endif

#ifdef        BLOAD_BIN
endextblock:
#endif
endrom:       equ           $
#ifdef        ELFOS
rstack:       dw            0
tos:          dw            0
freemem:      dw            storage
fstack:       dw            0
himem:        dw            0
jump:         ds            3
fildes:       ds            20
dta:          ds            512
buffer:       ds            256
storage:      dw            0
#endif
              end           start
