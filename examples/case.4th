variable buffer 0#10 allot                                                     
: menu CR ." 1 - count to 10" CR ." 2 - count down from 10" CR ." 3 - quit" CR ;
: prompt ." Your choice: " 0#10 buffer query cr buffer c@ ;                    
: docmd                                                                      
   "1" case? if 0#11 1 do I . loop exit then                                     
   "2" case? if 0#11 1 do 0#11 I - . loop exit then                                
   "3" case? if ." Bye" exit then     
   drop ." Unknown command!" CR ;
: go decimal begin menu prompt docmd buffer c@ "3" = brk? or until ;

