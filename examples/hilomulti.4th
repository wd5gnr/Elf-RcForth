\ This example uses multiple line definitions and comments and 
\ therefore won't work with older versions (see hilo.4th)
VARIABLE GUESS  \ My current guess
VARIABLE TURNS  \ How many tries?
VARIABLE HIGHG  \ My lowest too high guess
VARIABLE LOWG   \ My highest too low guess
\ Initialize game variables
: GAMEINIT 0#500  GUESS ! 0#0  TURNS ! 0#0  LOWG ! 0#1000  HIGHG ! ; 
\ Sign on
: GAMESO ." Think of a number from 1 to 1000 and I will guess it!" CR ; 
\ Explain yourself!
: GAMEHELP ." When I guess, you enter high, low, or correct" CR ; 
: HIGH GUESS @ HIGHG ! MYGUESS ; \ User says too high
: LOW GUESS @ LOWG ! MYGUESS ;   \ User says too low
\ I got it!
: CORRECT
    ." Yay me! It took me only " TURNS @ . ." tries!" CR
    ." Enter play to play again." CR ; 
\ Figure out my next guess
: MYGUESS 0#1  TURNS +!   \ update turn counter
          ." Is it "
          HIGHG @ LOWG @ - 0#2  / LOWG @ +   \ find midpoint of our guesses g=(high-low)/2+low
          DUP GUESS !                       \ store it for HIGH and LOW to use
          . ." ?" CR ;
\ start game
: PLAY
    CLS
    GAMEINIT GAMESO GAMEHELP
    MYGUESS ;
\ Shortcuts for experts
: H HIGH ;
: L LOW ;
: C CORRECT ;
: YES CORRECT ;

