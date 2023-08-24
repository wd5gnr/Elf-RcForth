; rules: All uppercase
; no multiple line definitions
; 0 Ends each string and a zero at the end
; Sometimes (but not always) RC/ASM stops after a double quote
; So '." foo " .',0  -- might stop after the quote. Check the listing to be sure

#ifdef NO_TOKEN_COMPRESSION
  db ': +! TUCK @ + SWAP ! ;',0
;  db ': -! TUCK @ SWAP - SWAP ! ;',0
  db ': -! NEG +! ;',0
  db ': *! TUCK  @ * SWAP ! ;',0
  db ': /! TUCK @ SWAP / SWAP ! ;',0
  db ': /MOD 2DUP MOD -ROT / ;',0
  db ': @+ DUP @ SWAP 2+ SWAP ;',0
  db ': ? @ U. ;',0
  db ': ?DUP DUP IF DUP THEN ;',0
  db ': .S ." < " BS DEPTH . BS ." > " DEPTH ?DUP IF DUP 0 DO DUP I - PICK . LOOP DROP THEN ;',0
  db ': > SWAP < ;',0
  db ': >= < NOT ;',0
  db ': <= > NOT ;',0
  db ': , 2 ALLOT SWAP DUP ROT SWAP ! 2+ ;',0
  db ': 0< 0 < ;',0
  db ': 0> 0 > ;',0
  db ': 0= 0 = ;',0
  db ': 0= 0 = ;',0
  db ': 1+ 1 + ;',0
  db ': 1- 1 - ;',0
  db ': 2+ 2 + ;',0
  db ': 2- 2 - ;',0
  db ': 2DUP OVER OVER ;',0
  db ': 2DROP DROP DROP ;',0
  db ': 2OVER 3 PICK 3 PICK ;',0
  db ': 2SWAP >R -ROT R> -ROT ;',0
  db ': ABS DUP 0< IF NEG THEN ;',0
  db ': BL 0#32 ;',0
  db ': BS 8 EMIT ;',0
  db ': BYTESWAP DUP 8 >> SWAP 0XFF AND 8 << OR ;',0
  db ': C+! DUP >R C@ + R> C! ;',0
  db ': C-! DUP >R C@ SWAP - R> C! ;',0
  db ': C, 1 ALLOT SWAP DUP ROT SWAP C! 1+ ;',0
  db ': CELLS 2 * ;',0
  db ': CLEAR DEPTH WHILE DROP DEPTH REPEAT ;',0
  db ': CLRBIT 1 SWAP << INVERT AND ;',0
;  db ': CLS 0#27 EMIT 0#91 EMIT 0#50 EMIT 0#74 EMIT 0#27 EMIT 0#91 EMIT 0#72 EMIT ;',0
; RC/ASM doesn't like a double quote here so we need the semicolon on a second line
; not sure why because it works in other places
; Also if you embed the escape codes, a see or list will clear the screen here :(
;  db ': CLS ." [2J[H" '
  db ': CLS ESC ." [2J" ESC ." [H"'
  db ' ;',0
  db ': DUMP CR 5 SPACES 0#16 0 DO I . LOOP 0 DO CR DUP . 0#16 0 DO DUP C@ . 1+ LOOP DUP 0#16 - 0#16 TYPE 0#16 +LOOP DROP CR ;',0
  db ': ERASE 0 FILL ;',0
  db ': ESC 0X1B EMIT ;',0
  db ': FALSE 0 ;',0
  db ': FILL SWAP >R OVER C! DUP 1+ R> 1- CMOVE ;',0
  db ': FREE MEM U. CR ;',0
  db ': GETBIT >> 1 AND ;',0
  db ': INVERT 0XFFFF XOR ;',0
  db ': LSHIFT DUP WHILE SWAP 2 * SWAP 1- DUP REPEAT DROP ;',0
  db ': MAX 2DUP < SWAP? DROP ;',0
  db ': MIN 2DUP > SWAP? DROP ;',0
  db ': MOD DUP ROT DUP ROT / ROT * - ;',0
  db ': NEG 0 SWAP - ;',0
  db ': NIP SWAP DROP ;',0
  db ': NOT 0= ;',0
  db ': PICK 2 * 2+ SP@ + @ ;',0
  db ': RSHIFT DUP WHILE SWAP 2 / SWAP 1- DUP REPEAT DROP ;',0
  db ': SETBIT 1 SWAP << OR ;',0
  db ': SGN DUP IF 0X8000 AND IF 0XFFFF ELSE 1 THEN THEN ;',0
  db ': SPACE 0#32 EMIT ;',0
  db ': SPACES 0 DO 0#32 EMIT LOOP ;',0
  db ': SWAP? IF SWAP THEN ;',0 
   db ': TGLBIT 1 SWAP << XOR ;',0
  db ': TRUE 1 ;',0
  db ': TUCK SWAP OVER ;',0
  db ': TYPE DUP IF 0 DO DUP C@ EMITP 1+ LOOP ELSE DROP THEN DROP ;',0
  db ': U> SWAP U< ;',0
  db ': U>= 2DUP U> >R = R> OR ;',0
  db ': U<= U>= NOT ;',0
  db ': UMIN 2DUP U> SWAP? DROP ;',0
  db ': UMAX 2DUP U< SWAP? DROP ;',0
  db ': BASEOUT BASE @ -ROT BASE ! . BASE ! ;',0
  db ': #. 0#10 BASEOUT ;',0
  db ': $. 0X10 BASEOUT ;',0
  db ': %. 0x8000 BEGIN 2DUP AND IF 0x31 ELSE 0x30 THEN EMIT 1 >> DUP NOT UNTIL SPACE ;',0
  include custom.inc
  db '." Ext words loaded" CR',0
#else
; You can put ASCII definitions/command here just as above
; But you can also use the Fxxx words for core words.
; So...
; db ': foo swap drop ;',0
; is the same as:
; db FCOLON,'foo ',FSWAP,FDROP,FSEMI,0
; NOTE: tokens must end in space. So note the above is 'foo ',FSWAP NOT 'foo',FSWAP!
; Also FDOTQT is "odd":  dw FDOTQT,' <-space not printed"100 2 + ',FDOT,FCR,0
; Note the first space is "eaten" and the quote ends the string (no zero), and you do NOT need 
; a space after the quote (although it won't hurt if you do)
; You can also use T_NUM:  db T_NUM,0,0ffh   ; 255
; or T_ASCII: db FCOLON,T_ASCII,'FOO',0,....

  db FCOLON,'+! TUCK ',FAT,FPLUS,FSWAP,FEXCL,FSEMI,0
  db FCOLON,'-! NEG +! ',FSEMI,0
  db FCOLON,'*! TUCK ',FAT,FMUL,FSWAP,FEXCL,FSEMI,0
  db FCOLON,'/! TUCK ',FAT FSWAP FDIV FSWAP FEXCL,FSEMI,0
  db FCOLON,'/MOD 2DUP MOD ',FMROT,FDIV,FSEMI,0
  db FCOLON,'@+ ',FDUP,FAT,FSWAP,'2+ ',FSWAP,FSEMI,0
  db FCOLON,'? ',FAT,FUDOT,FSEMI,0
  db FCOLON,'?DUP ',FDUP,FIF,FDUP,FTHEN,FSEMI,0
  db FCOLON,'.S ." < " BS ',FDEPTH,FDOT,'BS ." > " ',FDEPTH,'?DUP ',FIF,FDUP,'0 ',FDO,FDUP,FI,'- PICK . ',FLOOP,FDROP,FTHEN,FSEMI,0
  db FCOLON,'> ',FSWAP,FLESS,FSEMI,0
  db FCOLON,'>= < NOT ',FSEMI,0
  db FCOLON,'<= > NOT ',FSEMI,0
  db FCOLON,', 2 ',FALLOT,FSWAP,FDUP,FROT,FSWAP,FEXCL,'2+ ',FSEMI,0
  db FCOLON,'0< 0 < ',FSEMI,0
  db FCOLON,'0> 0 > ',FSEMI,0
  db FCOLON,'0= 0 = ',FSEMI,0
  db FCOLON,'0= 0 = ',FSEMI,0
  db FCOLON,'1+ 1 + ',FSEMI,0
  db FCOLON,'1- 1 - ',FSEMI,0
  db FCOLON,'2+ 2 + ',FSEMI,0
  db FCOLON,'2- 2 - ',FSEMI,0
  db FCOLON,'2DUP ',FOVER,FOVER,FSEMI,0
  db FCOLON,'2DROP ',FDROP,FDROP,FSEMI,0
  db FCOLON,'2OVER 3 PICK 3 PICK ',FSEMI,0
  db FCOLON,'2SWAP ',FGTR,FMROT,FRGT,FMROT,FSEMI,0
  db FCOLON,'ABS ',FDUP,'0< ',FIF,'NEG ',FTHEN,FSEMI,0
  db FCOLON,'BL 0X20 ;',0
  db FCOLON,'BS 8 ',FEMIT,FSEMI,0
  db FCOLON,'BYTESWAP ',FDUP,'8 >> ',FSWAP,'0XFF ',FAND,'8 << ',FOR,FSEMI,0
  db FCOLON,'C+! ',FDUP,FGTR,FCAT,FPLUS,FRGT,FCEXCL,FSEMI,0
  db FCOLON,'C-! NEG C+! ',FSEMI,0
  db FCOLON,'C, 1 ',FALLOT,FSWAP,FDUP,FROT,FSWAP,'C! 1+ ',FSEMI,0
  db FCOLON,'CELLS 2* ',FSEMI,0
  db FCOLON,'CLEAR ',FDEPTH,FWHILE,FDROP,FDEPTH,FREPEAT,FSEMI,0
  db FCOLON,'CLRBIT 1 ',FSWAP,' << INVERT ',FAND,FSEMI,0
  db FCOLON,'CLS ESC ." [2J" ESC ." [H"'
  db ' ',FSEMI,0
  db FCOLON 'DUMP ',FCR,'5 SPACES 0#16 0 ',FDO,FI,FDOT,FLOOP,'0 ',FDO,FCR,FDUP,FDOT,'0#16 0 ',FDO,FDUP,FCAT,FDOT,'1+ ',FLOOP,FDUP,'0#16 - 0#16 TYPE 0#16 ',FPLOOP,FDROP,FCR,FSEMI,0
  db FCOLON,'ERASE 0 FILL ',FSEMI,0
  db FCOLON,'ESC 0X1B ',FEMIT,FSEMI,0
  db FCOLON,'FALSE 0 ',FSEMI,0
  db FCOLON,'FILL ',FSWAP,FGTR,FOVER,FCEXCL,FDUP,'1+ ',FRGT,'1- CMOVE ',FSEMI,0
  db FCOLON,'FREE ',FMEM,FUDOT,FCR,FSEMI,0
  db FCOLON,'GETBIT >> 1 ',FAND,FSEMI,0
  db FCOLON,'INVERT ',T_NUM,0ffh,0ffh,FXOR,FSEMI,0
  db FCOLON,'LSHIFT ',FDUP,FWHILE,FSWAP,'2 ',FMUL,FSWAP,'1- ',FDUP,FREPEAT,FDROP,FSEMI,0
  db FCOLON,'MAX 2DUP < SWAP? ',FDROP,FSEMI,0
  db FCOLON,'MIN 2DUP > SWAP? ',FDROP,FSEMI,0
  db FCOLON,'MOD ',FDUP,FROT,FDUP,FROT,FDIV,FROT,FMUL,FMINUS,FSEMI,0
  db FCOLON,'NEG 0 ',FSWAP,FMINUS,FSEMI,0
  db FCOLON,'NIP ',FSWAP,FDROP,FSEMI,0
  db FCOLON,'NOT 0= ',FSEMI,0
  db FCOLON,'PICK 2 * 2+ ',FSPAT,FPLUS,FAT,FSEMI,0
  db FCOLON,'RSHIFT ',FDUP,FWHILE,FSWAP,'2 ',FDIV,FSWAP,'1- ',FDUP,FREPEAT,FDROP,FSEMI,0
  db FCOLON,'SETBIT 1 ',FSWAP,'<< ',FOR,FSEMI,0
  db FCOLON,'SGN ',FDUP,FIF,'0X8000 ',FAND,FIF,T_NUM,0ffh,0ffh,FELSE,'1 ',FTHEN,FTHEN FSEMI,0
  db FCOLON,'SPACE 0#32 ',FEMIT,FSEMI,0
  db FCOLON,'SPACES 0 ',FDO,'0#32 ',FEMIT,FLOOP,FSEMI,0
  db FCOLON,'SWAP? ',FIF,FSWAP,FTHEN,FSEMI,0 
  db FCOLON,'TGLBIT 1 ',FSWAP,'<< ',FXOR,FSEMI,0
  db FCOLON,'TRUE 1 ',FSEMI,0
  db FCOLON,'TUCK ',FSWAP,FOVER,FSEMI,0
  db FCOLON,'TYPE ',FDUP,FIF,'0 ',FDO,FDUP,FCAT,FEMITP,'1+ ',FLOOP,FELSE,FDROP,FTHEN,FDROP,FSEMI,0
  db FCOLON,'U> ',FSWAP,'U< ',FSEMI,0
  db FCOLON,'U>= 2DUP U> >R = R> OR ',FSEMI,0
  db FCOLON,'U<= U>= NOT ',FSEMI,0
  db FCOLON,'UMIN 2DUP U> SWAP? ',FDROP,FSEMI,0
  db FCOLON,'UMAX 2DUP U< SWAP? ',FDROP,FSEMI,0
  db FCOLON,'BASEOUT ',FBASE,FAT,FMROT,FBASE,FEXCL,FDOT,FBASE,FEXCL,FSEMI,0
  db FCOLON,'#. 0#10 BASEOUT ;',0
  db FCOLON,'$. 0X10 BASEOUT ;',0
  db FCOLON,'%. 0X8000 BEGIN 2DUP AND IF 0X31 ELSE 0X30 THEN EMIT 1 >> DUP NOT UNTIL SPACE ;',0
  include custom.inc
  db '." Ext words loaded" CR',0
  db 'INIT',0
#endif

  db  0

