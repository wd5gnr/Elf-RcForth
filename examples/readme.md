Examples
===

* Scan and Scanv2 - Run scan with some toggle switches up. The toggle switches set the delay and a zero delay will stop the progrma.

* Hilo and Hilo2 - Games. Enter play and follow instructions. (Note don't try this in hex mode!)

* Hilomulti - Multiline hilo game

* biosinput - Example of calling line input/number parse in BIOS (see also QUERY)

* Hilo3 - Like Hilo2 but uses bios input

* disasm - 1802 disassembler (shows ['] and case statements)
 
* case - Show off case statement

* dazzle - Show off some LEDs

* fact - Factorial 

* random - Random demo of random numbers


About Breakpoints with Exec
===
You can use EXEC to trigger a breakpoint to your monitor. 

For 1802Black:

```
variable breakpt
0x68 breakpt c! 0xd5 breakpt 1+ c!
```

For STG:

```
variable breakpt
1 allot
0x79 breakpt c! 0xd1 breakpt 1+ c! 0xd5 breakpt 2 + c!
```

Either way, now you can define:

```
: bp breakpt exec drop ;
```

Test it out. Define the word test and run it:

```
: test 2 * bp . ;
```
