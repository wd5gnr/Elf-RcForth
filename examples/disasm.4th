\ Disassembler - Williams
\ The idea is that each opcode YX has a handler named DIS:YX (e.g., DIS:0X or DIS:AX)
\ A vector table sends each handler an address and expect the top of stack to have
\ the next address afterwards
\ There are some helpers like DIS:NEXT and DIS:REG or DIS:7XX which do further processing
\ Usage: Load this file and then to disassemble 20 instructions at f800 (assuming hex mode):
\ f800 20 disassem
: DIS:0X DUP C@ DUP 0= IF ." IDL" DROP ELSE ." LDN " DIS:REG THEN DIS:NEXT ; 
: DIS:NEXT 1+ CR ;    \ next line
: DIS:REG ." R" 0XF AND DUP 0x0A < IF 0x30 + ELSE 0x0A - 0x41 + THEN EMIT BL EMIT ;   \ generic register
: DIS:1X DUP C@ ." INC " DIS:REG DIS:NEXT ; 
: DIS:2X DUP C@ ." DEC " DIS:REG DIS:NEXT ; 
: DIS:4X DUP C@ ." LDA " DIS:REG DIS:NEXT ; 
: DIS:5X DUP C@ ." STR " DIS:REG DIS:NEXT ; 
: DIS:8X DUP C@ ." GLO " DIS:REG DIS:NEXT ; 
: DIS:9X DUP C@ ." GHI " DIS:REG DIS:NEXT ; 
: DIS:AX DUP C@ ." PLO " DIS:REG DIS:NEXT ; 
: DIS:BX DUP C@ ." PHI " DIS:REG DIS:NEXT ; 
: DIS:DX DUP C@ ." SEP " DIS:REG DIS:NEXT ; 
: DIS:EX DUP C@ ." SEX " DIS:REG DIS:NEXT ; 
: DIS:BRANCH 0x0F AND
    0x00 CASE? IF ." R" EXIT THEN
    0x01 CASE? IF ." Q" EXIT THEN
    0x02 CASE? IF ." Z" EXIT THEN
    0x03 CASE? IF ." DF" EXIT THEN
    0x04 CASE? IF ." B1" EXIT THEN
    0x05 CASE? IF ." B2" EXIT THEN
    0x06 CASE? IF ." B3" EXIT THEN
    0x07 CASE? IF ." B4" EXIT THEN
    0x09 CASE? IF ." NQ" EXIT THEN
    0x0A CASE? IF ." NZ" EXIT THEN
    0x0B CASE? IF ." NF" EXIT THEN
    0x0C CASE? IF ." N1" EXIT THEN
    0x0D CASE? IF ." N2" EXIT THEN
    0x0E CASE? IF ." N3" EXIT THEN
    0x0F CASE? IF ." N4" EXIT THEN
    DROP ; 
: DIS:3X DUP C@ DUP 0x38 = IF ." SKP" DROP ELSE ." B" DIS:BRANCH 1+ DUP C@ BL EMIT $. DIS:NEXT ; 
    : DIS:6X DUP C@ DUP
	0x60 = IF
	            DIS:IRX
 	       ELSE DUP
		    0x68 = IF
			       DIS:XXX
		           ELSE DUP
			       0x67 > IF ." INP "
			       ELSE ." OUT "
			       THEN 0x07 AND 0x30 + EMIT
			   THEN
		   THEN DIS:NEXT ;
: DIS:IRX ." IRX" DROP  ;                                                             
: DIS:XXX ." XXX" DROP ;
: DIS:IMM8 1+ DUP C@ $. ;
: DIS:7XX
    0x00 CASE? IF ." RET" EXIT THEN
    0x01 CASE? IF ." DIS" EXIT THEN
    0x02 CASE? IF ." LDXA" EXIT THEN
    0x03 CASE? IF ." STXD" EXIT THEN
    0x04 CASE? IF ." ADC" EXIT THEN
    0x05 CASE? IF ." SDB" EXIT THEN
    0x06 CASE? IF ." SHRC" EXIT THEN
    0x07 CASE? IF ." SMB" EXIT THEN
    0x08 CASE? IF ." SAV" EXIT THEN
    0x09 CASE? IF ." MARK" EXIT THEN
    0x0A CASE? IF ." REQ" EXIT THEN
    0x0B CASE? IF ." SEQ" EXIT THEN
    0x0C CASE? IF ." ADCI " DIS:IMM8  EXIT THEN
    0x0D CASE? IF ." SDBI " DIS:IMM8 EXIT THEN
    0x0E CASE? IF ." SHLC" EXIT THEN
    0x0F CASE? IF ." SMBI " DIS:IMM8 EXIT THEN
    DROP ; 
: DIS:7X DUP C@ 0x0F AND DIS:7XX DIS:NEXT ;
: DIS:FXX
    0x00 CASE? IF ." LDX" EXIT THEN
    0x01 CASE? IF ." OR" EXIT THEN
    0x02 CASE? IF ." AND" EXIT THEN
    0x03 CASE? IF ." XOR" EXIT THEN
    0x04 CASE? IF ." ADD" EXIT THEN
    0x05 CASE? IF ." SD" EXIT THEN
    0x06 CASE? IF ." SHR" EXIT THEN
    0x07 CASE? IF ." SM" EXIT THEN
    0x08 CASE? IF ." LDI " DIS:IMM8 EXIT THEN
    0x09 CASE? IF ." ORI " DIS:IMM8 EXIT THEN
    0x0A CASE? IF ." ANI " DIS:IMM8 EXIT THEN
    0x0B CASE? IF ." XRI " DIS:IMM8 EXIT THEN
    0x0C CASE? IF ." ADI " DIS:IMM8 EXIT THEN
    0x0D CASE? IF ." SDI " DIS:IMM8 EXIT THEN
    0x0E CASE? IF ." SHL" EXIT THEN
    0x0F CASE? IF ." SMI " DIS:IMM8 EXIT THEN
    DROP ; 
: DIS:FX DUP C@ 0x0F AND DIS:FXX DIS:NEXT ;
: DIS:CX DUP C@ 0xC8 = if ." LSKP" else DUP C@ 0xF AND  DUP 4 AND if DIS:C-SKP else DIS:C-BR 1+ DUP @ $. 1+ then then  dis:next ;
: DIS:C-SKP
    4 case? IF ." NOP" exit then
    5 case? IF ." LSNQ" exit then
    6 case? IF ." LSNZ" exit then
    7 case? IF ." LSNF" exit then
    0xc case? IF ." LSIE" exit then
    0xd case? IF ." LSQ" exit then
    0xe case? IF ." LSZ" exit then
    0xf case? IF ." LSDF" exit then
    drop ;
: DIS:C-BR
    0 case? If ." LBR " exit then
    1 case? If ." LBQ " exit then
    2 case? if ." LBZ " exit then
    3 case? IF ." LBDF " exit then
    9 case? IF ." LBNQ " exit then
    0xA case? IF ." LBNZ " exit then
    0xB case? IF ." LBNF " exit then
    drop ;

create vector ['] DIS:0X , ['] DIS:1X , ['] DIS:2X ,  ['] DIS:3X , 
['] DIS:4X , ['] DIS:5X , ['] DIS:6X ,  ['] DIS:7X ,
['] DIS:8X , ['] DIS:9X , ['] DIS:AX ,  ['] DIS:BX ,
['] DIS:CX , ['] DIS:DX , ['] DIS:EX ,  ['] DIS:FX , 

\ we could shift 3 times but that isn't as clear
: DIS:disasmi dup C@ 4 >> CELLS VECTOR + @ EXECUTE ;

\ ( add ct -- )
: disassem CR 0 DO DUP $. 9 EMIT DIS:DISASMI LOOP ;
