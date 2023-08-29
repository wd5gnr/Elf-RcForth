; Configuration items

; pick EXACTLY one of the next three
;#define NO_BLOAD
#define BLOAD_TEXT
;#define BLOAD_BIN

; if you want to compile to a separate "compile buffer" define this
#define USE_CBUFFER
; If you turn off CBUFFER and use BLOAD_TEXT, you'll need to uncomment some code in cbload...

; if you want to find the last of a multiply-defined user word instead of the first one...
; FIND_LAST is "better" Forth behavior but very inefficient
; Fixing that would require a reorg of the entire dictionary structure
#define FIND_LAST


; option bits
; 1 - Set to supress spaces after output number
; 2 - Set to search dictionary for first def instead of last def
; 4 - Set to output 4 digit hex numbers always
; 32 - SEE/LIST do not dump variable data if set
; 64 - Turn of debugging
; 128 - Turn on debugging
def_option:    equ 0


; You can choose to only load core ext words into ROM by defining LEAN_EXTENDED
; If you don't do this, you get two bloads where 0 BLOAD loads the core external and 1 BLOAD loads the extended 
; On startup, both are loaded
;#define LEAN_EXTENDED
