VARIABLE SECRET
VARIABLE TURN
: RAND16U RAND 4 LSHIFT RAND OR ;
: RAND16S RAND16U 0x7FFF AND ;
: GAMEINIT 0#0  TURN ! RAND16S 0#1000  MOD SECRET ! ; 
: GAMESO ." I'm thinking of a number from 0 to 1000. Type your guess and the word 'guess' followed by enter" CR ; 
: LOW ." Sorry, too low. Try again." CR ; 
: RIGHT ." You got it in " TURN @ . ." tries! Good job. Enter play to try again." CR ; 
: PLAY CLS GAMEINIT GAMESO ; 
: GUESS 0#1  TURN +! DUP SECRET @ = IF RIGHT ELSE SECRET @ < IF LOW ELSE HIGH THEN THEN ; 
: HIGH ." Oops, too high. Try again." CR ; 
