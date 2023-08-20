\ The random number seed can be saved or changed using RSEED (32-bit variable)
variable oldseed
1 cells allot
: saveseed rseed @ oldseed !   \ save first word
    rseed 1 cells + @ oldseed 1 cells + !  \ and second word
;
: restoreseed oldseed @ rseed ! oldseed 1 cells + @ rseed 1 cells + ! ;
saveseed
rand . cr
restoreseed
rand . cr
\ you can also change the seed based on a timer, user input, etc
