# scratchpad


## I/O

----------------
Text
----------------
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
`mov [0x000B8000], 0x4128` (0x41 2 8 ->"ASCII'A'-FG'green'-BG'dark_grey'")

Second cell (0,1) is 0x000B8000 + 16 = 0x000B8010
