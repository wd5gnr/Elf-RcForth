; words uncompressed (not well-maintained!)

  db ': +! TUCK @ + SWAP ! ;',0
;  db ': -! TUCK @ SWAP - SWAP ! ;',0
  db ': -! NEG +! ;',0
  db ': *! TUCK  @ * SWAP ! ;',0
  db ': /! TUCK @ SWAP / SWAP ! ;',0
  db ': /MOD 2DUP MOD -ROT / ;',0
  db ': @+ DUP @ SWAP 2+ SWAP ;',0
  db ': ? @ U. ;',0
  db ': ?DUP DUP IF DUP THEN ;',0
  db ': .S OPT @ DUP >R 1 OR OPT ! ." <"DEPTH . ." > "0 OPT ! DEPTH ?DUP IF DUP 0 DO DUP I - PICK . LOOP DROP THEN R> OPT ! ;',0
  db ': > SWAP < ;',0
  db ': >= < NOT ;',0
  db ': <= > NOT ;',0
  db ': , HERE 2 ALLOT 2- ! ;',0
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
  db ': C, HERE 1 ALLOT 1- C! ;',0
  db ': CELLS 2 * ;',0
  db ': CLEAR DEPTH WHILE DROP DEPTH REPEAT ;',0
  db ': CLRBIT 1 SWAP << INVERT AND ;',0
;  db ': CLS 0#27 EMIT 0#91 EMIT 0#50 EMIT 0#74 EMIT 0#27 EMIT 0#91 EMIT 0#72 EMIT ;',0
; RC/ASM doesn't like a double quote here so we need the semicolon on a second line
; not sure why because it works in other places
; Also if you embed the escape codes, a see or list will clear the screen here :(
;  db ': CLS ." [2J[H" '
  db  ': CLS ESC ." [2J"ESC ." [H"',0
  db  ';',0
  db ': DUMP OPT @ >R 0 OPT ! CR 5 SPACES 0X10 0 DO I . LOOP 0 DO CR DUP . 0X10 0 DO DUP C@ . 1+ LOOP DUP 0X10 - 0X10 TYPE 0X10 +LOOP DROP CR R> OPT ! ;',0
  db ': ERASE 0 FILL ;',0
  db ': ESC 0X1B EMIT ;',0
  db ': FALSE 0 ;',0
  db ': FILL SWAP >R OVER C! DUP 1+ R> 1- CMOVE ;',0
  db ': FREE MEM U. CR ;',0
  db ': GETBIT >> 1 AND ;',0
  db ': GOTOXY BASE @ -ROT OPT @ -ROT 0#10 BASE ! 1 OPT ! ESC ." [". ." ;". ." H"OPT ! BASE ! ;',0
  db ': J RP@ 6 + @ ;',0
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
  db ': %. 0x8000 BEGIN 2DUP AND IF 0x31 ELSE 0x30 THEN EMIT 1 >> DUP NOT UNTIL SPACE DROP DROP ;',0
  include custom.inc
  db '." Ext words loaded"CR INIT',0
  db 0
