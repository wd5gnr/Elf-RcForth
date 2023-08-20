\ Flash LEDs at random until you lift an input switch
\ Note switches must be at zero for it to run
: DAZZLE BEGIN 4 RAND OUT 100 DELAY 4 INP UNTIL ;
