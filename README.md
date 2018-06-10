# scratchpad


## I/O

----------------
Text
----------------
```
starting address of memory-mapped I/O for the framebuffer is 0x000B8000
highest 8 bits are ASCII value of the character
bit 7-4 the background and 
bit 3-0 foreground
Bit:     |15 14 13 12 11 10 9 8|7 6 5 4|3 2 1 0|
Content: | ASCII		       | FG    | BG    |

Lets say you want to write 'A'(65,or 0x41) with green 
foreground(2 -see link for colors https://i.imgur.com/bLhytNP.png)
and dark grey background(8) at place (0,0)
you would use this assembly code
"mov [0x000B8000], 0x4128" (0x41 2 8 ->"ASCII'A'-FG'green'-BG'dark_grey'")

Second cell (0,1) is 0x000B8000 + 16 = 0x000B8010
```

## Notes for x86 Assembly
```
Lets make some test files
> nano test.asm
> nasm -f bin test.asm -o test  (apt-get nasm) 
-f specifies the file format of the output file(-o)
   in this case its bin(flat binary output without any extra information
   ,as in assembly code -> machine code(as is, without overhead of metadata) 
Note: using bin format puts nasm by default into 16-bit mode, to enable 32bit
      add "bits 32" at beginning of an nasm source file

we can examine the output using hd(HexDump) 
> hd test
00000000 66 ff e0            |f..|
00000003
We can see that file only consists of 3 bytes : 66 ff e0, which is equivalent 
to the instruction jmp eax

-----------
  Basics
-----------
In next few examples im using 'a' as (labeled memory address)/(register)
mov a,0x1  -> Move hex '1' to 'a'
mov a,[0x1]  -> Move value on location '0x1' to 'a'

add a -> a=a+0x1 | (a=a+1)


------------
   Stack
------------
> push -> add new element on top of the stack
> pop -> remove the top-most element from the stack

x86 uses 'esp' register to point to the top of the stack(the newest element)

```
