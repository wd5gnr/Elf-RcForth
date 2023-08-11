VARIABLE GUESS
VARIABLE TURNS
VARIABLE HIGHG
VARIABLE LOWG
: GAMEINIT 0#500  GUESS ! 0#0  TURNS ! 0#0  LOWG ! 0#1000  HIGHG ! ; 
: GAMESO ." Think of a number from 1 to 1000 and I will guess it!" CR ; 
: GAMEHELP ." When I guess, you enter high, low, or correct" CR ; 
: HIGH GUESS @ HIGHG ! MYGUESS ; 
: LOW GUESS @ LOWG ! MYGUESS ; 
: CORRECT ." Yay me! It took me only " TURNS @ . ." tries! Enter play to play again." CR ; 
: PLAY CLS GAMEINIT GAMESO GAMEHELP MYGUESS ; 
: MYGUESS 0#1  TURNS +! ." Is it " HIGHG @ LOWG @ - 0#2  / LOWG @ + DUP GUESS ! . ." ?" CR ; 
