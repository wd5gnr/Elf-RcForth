# rc/forth by Mike Riley

 ## with additions by Al Williams and Glenn Jolly

## Version 0.5
Last update: 26 Aug 2023
See [What's New? for news](#new)

## Contents
* [What Is It?](#what)
* [Key Architecctural Items](#key)
* [Words](#words)
* [Notes](#notes)
* [Tutorial](#tutor)
* [What's New?](#new)
* [Extended Word Source](#ext)

[](#what)
## What Is It?
This is a Forth system for the RCA 1802, popular in the "COSMAC ELF" computers, among other things. It is a bit odd, in consideration of the small hardware, but Mike made some interesting design choices. If you know Forth, you won't find anything too surprising and versions 0.2 up keep eradicating some of the surprising things.

If you don't know Forth, there is a short tutorial from the original readme, below. There's plenty of info on the web, too. 
[](#key)
## Key Architectural Items
* The "compiler" actually converts your input into tokens consisting of core words, numbers, and strings. So your words do not get tokens, they are stored as ASCII strings which has some merits and some difficulties
* 16-bit integers
* Limited string support
* Comments are not stored
* Save and load is either via ASCII (think of it as a virtual paper tape punch and reader) or using binary files via XMODEM
* You can select using the first found definition (faster) or the last found (more like normal Forth)
* Extended words are loaded from ROM and can be unloaded for space

[](#words)
## Words

#### Note on stack representation:

In the instructions listed below, the state of the stack is shown in
parentheses.  symbols before the -- represent the stack before the instruction
is executed, symbols after the -- represent the stack after execution.
The top of stack is to the right. Example:  (1 2 -- 3) This shows that 2
is on the top of the stack, and 1 is 2nd from the top, after the instruction
is executed 3 will be on the stack, the 1 and 2 will be consumed.

#### Numbers
NN - positive number in current BASE
-NN - negative decimal number (when BASE=10)
0xNN - unsigned hex number (any BASE; x is not case sensitive)
0#nn - unsigned decimal number (any BASE)
'X' - A single ASCII character pushed on the stack

#### Arithmetic Operators:
```
+        (a b -- c)       - Add top 2 stack entries
-        (a b -- c)       - Subtract top 2 stack entries
*        (a b -- c)       - Multiply top 2 stack entries
=        (a b -- ?)       - Check equality, 1=equal, 0=unequal
<>       (a b -- ?)       - Check inequality, 1-unequal, 0=equal
and      (a b -- c)       - Logically and top 2 stack values
or       (a b -- c)       - Logically or top 2 stack values
xor      (a b -- c)       - Logically xor top 2 stack values
<<       (a n -- b)       - Left shift a by n bits (unsigned)
>>       (a n -- b)       - Right shift a by n bits (unsigned)
<        (a b -- ?)       - Return 1 if a < b else 0
U<       (u1 u2 -- ?)     - Return 1 if u1 < u2 else 0 (unsigned)
```
#### Control Operators:
```
BEGIN    ( -- )           - Beginning of BEGIN-UNTIL loop
UNTIL    (B -- )          - Ending of BEGIN-UNTIL loop
WHILE    (B -- )          - Beginning of while-repeat loop
REPEAT   ( -- )           - End of while-repeat loop
DO       (T S -- )        - Start of DO LOOP
I        ( -- c)          - Put current loop count onto stack
LOOP     ( -- )           - End of DO LOOP
+LOOP    (v -- )          - End of loop with specified increment
IF       (B -- )          - Beginning of IF-ELSE-THEN structure
ELSE     ( -- )           - ELSE portion of IF-ELSE-THEN
THEN     ( -- )           - End of IF-ELSE-THEN
ENDIF    ( -- )           - Same as THEN
>R       (a -- )          - Move top of data stack to return stack
R>       ( -- a)          - Move top of return stack to data stack
R@       ( -- a)          - Copy top of return stack to data stack
```

#### Variables:
```
VARIABLE name                   - Create a variable (not allowed in functions)
@        (a -- v)               - Retrieve value from address
SP@      ( -- a)                - Get address of tos pointer
RP@      ( -- a)                - Get address of return stack
!        (v a -- )              - Store value at address
C@       (a -- v)               - Retrieve byte value from address
C!       (v a -- )              - Store byte value at address
ALLOT    (n -- )                - Increase the last defined vars storage space (Note in bytes now; see CELLS in extended words)
CMOVE    (caddr1 caddr2 u -- )  - Move u bytes from caddr1 to caddr2
HERE     ( -- a)                - Retrieve the current free memory pointer
->HERE   (a -- )                - Set the current free memory pointer (dangerous!)
OPT      ( -- a)                - Address of option variable (bit 0=supress space after numeric output; 1=find first word in dictionary)
```

#### Function definition:
````
: name                    - Create a function
;                         - End of function
````

#### Stack Operators:
```
DUP      (a -- a a)       - Duplicate top stack valueDROP     (a -- )          - Drop top stack value
SWAP     (a b -- b a)     - Swap top 2 stack entries
OVER     (a b -- a b a)   - Copy 2nd stack value to top
ROT      (a b c -- b c a) - Rotate 3rd stack item to top
-ROT     (a b c -- c a b) - Rotate top of stack to 3rd position
DEPTH    ( -- a)          - Get number of items on stack
.        (a -- )          - print top of stack as signed integer
U.       (a -- )          - print top of stack as unsigned integer
X.	 (a -- )              - print top of stack as unsigned integer with 0x or 0# prefix 
EMIT     (a -- )          - print top of stack as ascii character
EMITP    (a -- )          - print top of stack as printable character
```

#### Others:
```
\                         - Comment from here to end of line (needs space after it; not \comment but \ comment)CR       ( -- )           - Print a CR/LF pair
MEM      ( -- a)          - return amount of memory
WORDS    ( -- )           - Display vocabulary words
SEE name                  - See what is bound to a name
LIST     ( -- )           - See all dictionary words/variables
FORGET name               - Remove a variable or function
." text "                 - Print specified text on the terminal
KEY      ( -- v)          - Read a char from the keyboard and place on stack
KEY?     ( -- ?)          - Non blocking keyboard read returns 1 if pressed else 0 (does not work with bit-bang serial)
SETQ     (n -- )          - Set Q line hi/lo for n 1/0 
BASE     ( -- addr)       - Address containing the current numeric radix
RSEED    ( -- addr)       - Address of 32-bit random number seed
DECIMAL  ( -- )           - Set the numeric radix to 10 (takes effect next input line)
HEX      ( -- )           - Set the numeric radix to 16 (takes effect next input line)
DELAY    (n --)           - Blocking delay of n milliseconds
SAVE     ( -- )           - Save dictionary to terminal via Xmodem
LOAD     ( -- )           - Load dictionary to terminal via Xmodem
BLOAD    ( -- )           - Load extensions as binary block included in src code (note: resets to decimal before loading and leaves you in decimal mode) This happens automatically. If you don't want these functions, use NEW (see below).
RAND     ( -- b)          - Returns random byte
EXEC     ( a -- r )       - Do an SCRT call to machine language at address a; Value of RB on return pushed on stack
OUT      ( b p -- )       - Output byte b to port p (e.g., 4 0xaa out)
INP      ( p -- b )       - Input byte b from port p
EF       ( -- v )         - Read value of EF pins
SETQ     ( x -- )         - Set q to value x
BYE      ( -- )           - Exit
NEW      ( -- )           - Wipe dictionary, stack, and reset RNG (careful! no confirmation!)
.TOK     (t -- )          - Prints name of token T and CR (T must be between 0x80 and to last token; unpredictable if out of range). Mainly to support debuggin.
```
#### Extended Functions:
The extended functions are implemented as pre-loaded Forth programs.  As such they
can be viewed with the SEE command and removed with the FORGET command. 

```
NIP      (b a -- a)                 - Drop 2nd item from stack
TUCK     (b a -- a b a)             - Place copy of TOS before 2nd on stack
PICK     (an..a0 k -- an..a0 ak)    - Copy k-th stack element to stack
2DUP     (b a -- b a b a)           - Duplicate top 2 stack values
2DROP    (a b -- )                  - Drop top 2 stack values
2OVER    (a b c d -- a b c d a b)   - Duplicate bottom pair a b to stack
2SWAP    (a b c d -- c d a b)       - Exchange the top two cell pairs
TRUE     ( -- 1)                    - Place true value on stack
FALSE    ( -- 0)                    - Place false value on stack
J        (R:loop ndx -- loop ndx)   - Copy of loop index from return stack
1+       (v -- v)                   - Add 1 to the top of stack
1-       (v -- v)                   - Subtract 1 from the top of stack
2+       (v -- v)                   - Add 2 to the top of stack
2-       (v -- v)                   - Subtract 2 from the top of stack
0=       (v -- v)                   - Returns 1 if TOS is zero, otherwise 0
GOTOXY   (x y -- )                  - Position VT100 cursor at x,y (works even in hex mode)
NOT      (v -- v)                   - Return 0 if TOS <> 0, otherwise 1
U>       (u1 u2 -- ?)               - flag true if u1 is greater than u2
U>=      (u1 u2 -- ?)               - flag true if u1 is greater than or equal to u2
U<=      (u1 u2 -- ?)               - flag true if u1 is less than or equal to u2 
>        (a b -- v)                 - Return 1 if a > b else 0
<=       (a b -- v)                 - Return 1 if a <= b else 0
>=       (a b -- v)                 - Return 1 if a >= b else 0
0>       (v -- v)                   - Return 1 if TOS > 0 else 0
0<       (v -- v)                   - Return 1 if TOS < 0 else 0
FREE     ( -- )                     - Display free memory
+!       (v a -- )                  - Add value to specified variable address
-!       (v a -- )                  - Subtract value from specified variable address
*!       (v a -- )                  - Multiply specified variable address by value
/!       (v a -- )                  - Divide specified variable address by value
C+!      (n caddr -- n+)            - Adds n to value stored at caddr
C-!      (n caddr -- n-)            - Subtracts n from value stored at caddr 
@+       (a -- a v)                 - Like @ except preserve address incremented by 2
?        (a -- )                    - Display value at address
NEG      (v -- v)                   - Negate a number
MIN      (a b -- v)                 - Return smallest of 2 signed numbers
MAX      (a b -- v)                 - Return largest of 2 signed numbers
UMIN     (u1 u2 -- v)               - Return smallest of 2 unsigned numbers
UMAX     (u1 u2 -- v)               - Return largest of 2 unsigned numbers
?DUP     (a -- a | a a)             - Duplicate TOS if nonzero
ABS      (v -- v)                   - Return absolute value of a number
BL       ( -- 32)                   - Place a blank on the stack
SPACE    ( -- )                     - Display a single space
SPACES   (v -- )                    - Display specified number of spaces
CLS      ( -- )                     - Clear screen
LSHIFT   (v c -- )                  - Left shift value v by c bits (signed)
RSHIFT   (v c -- )                  - Right shift value v by c bits (signed)
INVERT   (a -- v)                   - Invert the bits of TOS
SGN      (v -- v)                   - Return sign of number
MOD      (a b -- v)                 - Get remainder of a/b
/MOD     (a b -- r q)               - Perform both mod and functions
GETBIT   (u n -- ?)                 - Get state of nth bit (0..15) of u as flag
SETBIT   (u n -- u)                 - Set nth bit of u
CLRBIT   (u n -- u)                 - Clear nth bit of u
TGLBIT   (u n -- u)                 - Toggle nth bit of u
BYTESWAP (b1b2 -- b2b1)             - Endian conversion for 16 bit int
FILL     (addr n ch -- )            - Fill n bytes with ch starting at addr
ERASE    (addr n -- )               - Zero n bytes of memory starting at addr
CLEAR    ( -- )                     - Clears the stack of all entries
J        ( -- j )                   - Get loop counter from outer loop
.S       ( -- )                     - Display entire contents of stack
TYPE     (addr n -- )               - Display n bytes at addr
DUMP     (addr n -- )               - Display n bytes at addr as 16 byte records
CELLS    (n -- 2n)                  - Converts array index into byte offset
,        (d -- )                    - Use after array definition; see notes
c,       (b -- )                    - Use after array definition; see notes
BASEOUT  (n b --)                   - Output number n in base b (preserves BASE)
#.       (n -- )                    - Output number n in decimal regardless of BASE
$.       (n -- )                    - Output number n in hex regardless of BASE
%.       (n -- )                    - Output number n in binary 
```
[](#notes)
## Notes:
* OPTION is a variable that controls a few optional things. You treat it like any other variable. Currently:
  - Bit 0 - If set, output commands don't put a space after numbers.  For example, if you have two byte variables and try this normally it will look funny:
  ```
  : DISPWORD HIGHPART C@ $. LOWPART C@ $. CR ;
  ```
  But this will fix it:
  ```
  : BETTERDISP 1 OPT ! DISPWORD 0 OPT ! ;
  ```

  Note that SEE, LIST, and DUMP all turn this off while running but then put it back the way they found it.

  - Bit 1 - By default, any user words are searched for the last word defined. So you can override a word  with a new definition and restore the old definition with a forget or by restoring ->HERE. If bit 1 is set  the search finds the first word which means you can't really override anything -- storing new definitions  just wastes space. The reason this is important, though, is it is much faster. If you were doing a turnkey  deployment and want better performance and don't plan to override words, you can set this bit in your init   and enjoy faster performance.
  - Bit 6 - This requests a turn off of debug/trace mode (see bit 7)
  - Bit 7 - If bit 7 is set AND you have a defined word of dbg-hook, that word will run before each execution step and gets the address on the stack. You must clean up the stack or bad things will happen. See debug.4th in the examples directory. This is currently largely untested.

* BLOAD has changed by default, but you can put it back or remove it. 
The previous state was BLOAD loaded a binary blob that included address and all the state variables. So it wipes out everything
and requires fixing if you add/delete/rearrange variables or move the RAM base address. It was hard to add things to the BLOB. You can restore this behavior at the top of forth.asm by defining BLOAD_BIN and undefining BLOAD_TEXT. The blobs have been moved to two parts. A build-specific header and a RAM base list of words. In other words, all machines with RAM at 0 can share the words even if they need different headers for setting
variables. You can also shut off BLOAD with NO_BLOAD (the BLOAD work becomes a synonym with LOAD, in that case, and does not auto run).

The new behavior allows you to put nearly any command you want as 0 separated strings into extended.inc. These can define words, variables, or execute words.
By default, the system does a BLOAD when you start up (disable it by removing the BLOAD_AUTO flag). The end of the strings has a terminating 0 in addition to 
the last's string's terminating zero. See external.inc for examples. You can also do a BLOAD anytime which might make sense after a NEW, for example. Unlike
the old BLOAD, the new BLOAD does not wipe out what you already have.

The only problem is the text can get large. Unless you define NO_TOKEN_COMPRESSION you can use normal command tokens at will in the file to reduce the size.
For example:
```
: makeeven dup 1 and if 1+ then ;
```
You can store this as is (just put a zero at the end). But you can also do this:
```
FCOLON,'makeeven',FDUP,'1 ',FAND,FIF,'1+ ',FTHEN, FSEMI,0
```
This includes the end zero. Note that you have to use strings for numbers and non-core words like 1+. You can mix and match as much as you want. Note, too, that FDOTQT is a bit strange (see the inc file for an example). All of the tokens are at the top of the forth.asm file.

There is a custom.inc file that will be empty on GitHub. You can add your own defs there if you don't want them mixed in with the "factory default" words. There is an empty init word that you can add to, if you like.

* I noticed that the documentation for all the comparison operators looks backwards and is backwards from gforth. What's more is that equality parts are messed up also. This WILL WILL BREAK YOUR CODE from earlier versions. In the same vein. Jolly fixed UNTIL to work properly 
and that also breaks old code.

#### gForth:
```
ok 5 2 < . 
0
ok 5 5 < .
0
```
#### RcForth
```
ok 5 2 < .
1
ok 5 5 < .
1
```

This appears to be in the original Jolly implement of cless and culess (flipped DF). Fixed now (maybe) but will break code and probably breaks some of the examples (will be fixed).

* old-style BLOAD resets the system to decimal before loading.

* DUMP really prefers hex mode for formatting

* If you are in hex mode, a, b, c, d, e, and f are not words. So "VARIABLE A" will fail in hex mode. So will abc, for example.

* SEE emits all integers as unsigned with 0x or 0# prefixes to faciliate reloading correctly
This means that -1 test ! see test will show 0#65535 not -1 but those are the same thing.

* HEX and DECIMAL don't work until AFTER the line is parsed. So you can't say:
```
: doit hex 0f 2 * ;
```
Unless you were already in hex, of course. The hex command would only affect the NEXT line.

However, they do work with output. So a possible definition is:
```
: HEXOUT 0x10 BASE @ -ROT BASE ! . BASE ! ;   \ print number in hex and put BASE back to how it was
```
* To create an array, you can use the comma or c, operators. This has changed recently to be more like normal Forth.
```
VARIABLE MYARRAY 1 , 2 , 3 , 4 ,
```
Note the spaces around the commas and that there is one at the end which will create one extra cell.
```
SEE MYARRAY
VARIABLE MYARRAY
0x08 ALLOT
0x01 MYARRAY 0x00 + !
0x02 MYARRAY 0x02 + !
0x03 MYARRAY 0x04 + !
0x04 MYARRAY 0x06 + !
0x00 MYARRAY 0x08 + !
```
You can also use ALLOT but this is now in bytes not words. Use CELLS or just multiply by 2:
```
VARIABLE thing
25 CELLS ALLOT
```
Of course, if you want bytes, don't use CELLS. This is a good way to initialize a 
machine language program:
```
: CSTORE SWAP c! ;
VARIABLE PGM
PGM 0x7A c, 0x7B c, 0xD5 CSTORE
```
Previous code that used word-sized ALLOT will break

* Comments and line breaks are not stored
[](#tutor)
## Forth Tutorial:

Forth is primarily a stack based language.  Arguments for functions are first
pushed onto the stack and then the instruction is executed.  Pushing a number
onto the stack is done merely by mentioning the number:
   
    ok 5

This instruction will leave 5 on the top of the stack.  the '.' command will
take the top of the stack and display it in signed integer notation:

    ok .
    5 ok

The '.' took the 5 we pushed earlier, removed it from the stack and printed it.
If we execute the command again:

    ok .
    stack empty
    ok

the interpreter will complain about an empty stack and abort any further
processing.

Commands can be placed multiply on a line, with just spaces separating each
command:

    ok 5 4 . .
    4 5 ok

In this example, 4 was the last value pushed onto the stack, therefore the
first value popped off by the first '.' command.

To keep the prompt off the line with the answers, you can use the CR command:

    ok 5 4 . . CR
    4 5
    ok

Note also that commands are executed left to right, there is no order of
operations other than left to right

It is also possible to display text using the ." operator:

    ok ." HELLO WORLD!!!" CR
    HELLO WORLD!!!
    ok

Arithmetic can be performed as well. try this example:

    ok 5 4 + . CR
    9
    ok

Again, notice all the arguments are pushed onto the stack before the
command is executed.

Equality is tested with the = operator:

    ok 5 4 = . CR
    0
    ok 5 5 = . CR
    1

Note that when two numbers are equal, a 1 is left on the stack, whereas 0
is left when they are not equal.

The DEPTH command will place onto the top of the stack the number of items in
the stack:

    ok 4 5 6 DEPTH . CR
    3
    ok

Note that the depth command does not include its own answer in the total.

The top two stack values can be swapped using the SWAP command:

    ok 2 3 . . CR
    3 2
    ok 2 3 SWAP . . CR
    2 3
    ok

The top of the stack can be duplicated using the DUP command:
```
ok 2 . . CR
2 stack empty
ok 3 DUP . . CR
3 3
ok
```
The IF command can be used for conditional exection.  IF examines the top of
the stack to determine what to execute:

    ok 1 IF 1 . THEN 2 . CR
    1 2
    ok 0 IF 1 . THEN 2 . CR
    2
    ok

When IF finds 0 on the stack, execution begins after the matching THEN.  It
is also possible to have an ELSE.  Try these:

    ok 1 IF 1 . ELSE 2 . THEN 3 . CR
    1 3
    ok 0 IF 1 . ELSE 2 . THEN 3 . CR
    2 3

If an ELSE is found before the next THEN on a failed IF test, the ELSE code
block will be executed

There are 3 looping constructs in FORTH.  The first is the DO LOOP.  this is
a controlled loop with a specific start and a specific end.  The I command can
be used inside of a loop to retrieve the loop counter:

    ok 10 0 DO I . LOOP CR
    0 1 2 3 4 5 6 7 8 9
    ok

Notice that the loop terminates once the end condition is reached.  The test
occurs at the LOOP command, therefore the loop is not executed again when I
reaches 10.  Notice also that a loop is always executed at least once:

    ok 10 15 DO I . LOOP CR
    15
    ok

To increment the loop counter by something other than 1, use the +LOOP command:
```
    ok 10 0 DO I . 2 +LOOP CR
    0 2 4 6 8
    ok 10 0 DO I . 3 +LOOP CR
    0 3 6 9
```
The next two loop types are uncontrolled, they loops are executed so long as
the top of stack is non-zero at the time of test.  The BEGIN UNTIL loop
has its test at the end, and therefore just like DO loops, the loop will
always be executed at least once:
```
    ok 5 BEGIN DUP . 1 - DUP UNTIL CR
    5 4 3 2 1
    ok
```
Notice we used the DUP command here first to make a duplicate of our counter
for the . command, and then a second DUP before the UNTIL.  UNTIL takes the
top of the stack in order to determine if another loop is needed.

The second uncontrolled loop is the WHILE REPEAT loop.  This loop has its
test at the beginning, therefore if WHILE finds a 0 on the stack the loop
will not even execute the first time:

    ok 5 DUP WHILE DUP . 1 - DUP REPEAT CR
    5 4 3 2 1 
    ok 0 DUP WHILE DUP . 1 - DUP REPEAT CR
    ok

Variables can be created with the VARIABLE command.  Note, variables should not
be given the same names as built in commands.  Here are some example variables:

    ok VARIABLE A
    ok VARIABLE B

If you execute a WORDS command, you will see that your new variable names now
appear in the list.

To store a value in a variable we use the ! command.  First we push the value
we want to store on the stack, and then mention the variable:

    ok 5 A !
    ok 10 B !

This then stores 5 into A and 10 into B.  To retrieve the values of variables,
use the @ command:
```
    ok A @ . CR
    5
    ok B @ . CR
    10
    ok A @ B @ + . CR
    15
```
To immediately print the value in a variale, you can use the SEE command:
```
    ok SEE A
    5
    ok
```
Note that the SEE command provides its own CR/LF.
```
    ok SEE A SEE B
    5
    10
    ok
```
The real power of forth is that it allows you to define your own commands!
Commands are defined using the : command and terminated with the ; command.
Note. that Rc/Forth requires the entire command to be created in one input
cycle.  try this one:
```
    ok : STARS 0 DO 42 EMIT LOOP ;
    ok
```
If you look at the WORDS now, you will see another new name: STARS.  You can
also use the SEE command on functions to see their definitions:
    ok SEE STARS
    : STARS 0 DO 42 EMIT LOOP ;

This command can now be used just like any other forth command:

    ok 5 STARS CR
    *****
    ok

Custom functions can even be used inside other custom functions:

    ok : PYRAMID 1 DO I STARS CR LOOP ;
    ok

now run it:

    ok 5 PYRAMID
    *
    **
    ***
    ****


You can create and call machine language routines, but you have to be careful not to corrupt things.
When in doubt, save things to the stack and return them to how you found them before exiting.
You will be called using the normal subroutine call with a stack already in place.

The easiest way to do it is create a variable with enough space to hold your code and then load it.

For example, to create 16 bytes to hold code:

You can define helper words:

    hex
    variable pgm
    10 allot

You can define helper words:


    : code! ( a byte -- a+1 ) swap dup rot swap c! !+ ;

This leaves the address for the next call so it is clean to define a word to stop the sequence:


: endcode ( a -- ) drop ;

Let's write AA to the LEDs using the following code:

    SEX R3  ; make X=P
    OUT 4   ; write M(X) RX+1 (that is write the next byte)
    DB AA   ; the byte to write
    SEX R2  ; back to X=2
    D5      ; SCRT return (SEP R5)

In hex, this is E3 64 AA E2 D5, which is 5 bytes. We can fit it in our pgm variable or define a variable with enough space.

Issue the following (be sure you are in hex mode):

    pgm e3 code! 64 code! aa code! e2 code! d5 code! endcode

If you want to verify:

    pgm 10 dump

Now, we can call our code and drop the return value since we don't care about it. Fun fact. If your code doesn't touch the return code it is the call
address. So you can make multiple calls without reloading the address as long as your codes doesn't touch the return value register (RB).

    pgm exec drop

You could make that into a word, of course:


    : mlpgm pgm exec drop ;

You can call many BIOS calls

    variable bioskey
    10 allot
    bioskey f8 code! 0 code! bb code! d4 code! ff code!
    6 code! ab code! d5! endcode

This corresponds to:

    LDI 0 ; zero out top byte of return register
    PHI RB
    CALL bios_key  ; read key (BIOS ff06)
    PLO RB         ; put key in RB.0
    RETURN

In this case we want the return code:
bioskey exec .

You can define a word to drop the return code for the cases that you don't care:


    : exec_ exec drop ;

Another handy word for defining machine code words:


    : ASMCODE DUP 1+ PICK SWAP DUP ROT 1- + SWAP 00  DO DUP ROT SWAP C! 1- LOOP DROP  DROP ;

Use it like this:

    7000 7A 7B 30 00 4 asmcode

Here 7000 is the address, and there are 4 op codes. The top of the stack is the number of opcodes/bytes. Note it works backwards so
it reads "normal." That is: 7000: 7A 7B 30 00. Normally, you would not hard code an address, but would use a variable as above.

This completes this introductory tutorial on Forth.  Experiment with the
commands and you will find it is really easy to pick it up!


[](#new)

## What's New?

* Moved gotoxy to extended words so it can be easily removed.

* You now have options to allow output with no spaces after numbers and 
the ability to search for the LAST user word defined so you can override 
word definitions (or, turn it off for performance). See notes below. Big change along
with the CBUFFER so I bumped the version to 0.5.

* By default USE_CBUFFER is enabled. This uses 256 bytes of RAM as a compile buffer.
So your line is compiled to the buffer and executed. That means colon definitions 
and variables are created in normal memory and don't step on your commands.
This handily prevents problems with ALLOT as described below.

* However, it is a big change so you can compile with it off if you prefer the old behavior.
* You can now put ( ) comments in files you plan to load. They are not saved (same as \ comments).
* 
So:
```
: FOO ( a -- 2a ) 2 * ;  \ You can have this exact line in  a file and the comments are ignored
```
Note the parens are tokens, so you can't have:
```
(My comment)
```
However, you can have:
```
( My comment (see other comments here) )
```
The first ) doesn't "work" becuase it does not have {space)){space} Obviously, don't use FOPAREN in compressed tokens for extended.inc or custom.inc -- makes no sense!

* I have had to back away from the "safe" ALLOT since this is more complex than it appears. 

* You can now include things after a colon definition, a variable, and allot is now safer.
So you can now say:
```
VARIABLE NCC 1701 ALLOT 0 NCC !
```
-or-
```
: SILLY 2 * . ; 10 SILLY
```
* New extended words. OVER bug fixed.

* `0 DELAY` now returns immediately instead of acting like 0x10000 DELAY

* More BLOAD options. A few new extended words when using the new BLOAD.

* No extra spaces in SEE/LIST

* RSEED lets you view/store the random number generation seed

* See rambuild.sh to build a version you can load to RAM at 0 with a ROM at 8000. You can configure in forth.asm for other configurations.

* Restructured BLOAD words

* You can use multiple line colon definitions (see examples/hilomulti.4th). If you are defining a word, the prompt will be :ok instead of ok.
Note the multiple lines are not stored. You wind up with the same definition either way.

* ^C will abort your input line even in a multi-line definition. Good for when you forget to use a semicolon on a single-line entry.
 
* Improved byte output of SEE/LIST for variables

* Fixed long-standing bug with < and U< that affected ABS, and all comparison operators. NOTE: This may break your scripts and may break some of the examples (will fix)

* Size changes. Errata note about comparison operators

I* MPORTANT: ALLOT now deals with bytes not words! See the word CELLS

* Fixed new regression. 

* New words: ENDIF, CELLS, , (Comma), and C,

* You can add comments by entering a \ which ignores the entire rest of the line. This is useful for
files you intend to load. Comments are not stored.

* New words: here and ->here

* Force load the high portion of freememory pointers which could have been the source of intermittent issues with larger programs (not true; reverted)

* Bload now happens when you start Forth new automatically

* If you don't want the extra words, issue NEW. You can issue that anytime to wipe out everything to the core words + BASE

* Simple variables get initialized to 0 automatically

* Numbers can always be written as 0#10 or 0xFF (decimal 10 and hex FF).

* SEE now dumps variables in a way that will recreate them if you read it back in.

* SEE always puts 0# or 0x in front of constants so reading a definition in works regardless of mode.

* LIST dumps everything from the user dictionary in a way that it can be read back in later.

* EXEC does an SCRT call to a machine language subroutime (see examples below)

* X. is like . but puts 0x or 0# in front depending on BASE

* If you pass -DNO_BLOAD to the assembler, you get a smaller version with no bload. Bload is still a word but it resolves to the same as LOAD and, presumably, you'll XMODEM whatever extended words you want or paste them in. No need to consume ROM with the words if you are going to load your own anyway!
[](#ext)
##  Extended Words Source
[See extended.inc in source code.](https://github.com/wd5gnr/Elf-RcForth/blob/main/extended.inc)



