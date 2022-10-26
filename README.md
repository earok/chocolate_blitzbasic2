# chocolate_blitzbasic2

Update 27/10/2022 - Added Chocolate TED and the new Compile and Quit menu function (Amiga+/)

Update 02/09/2022 - Minor improvement, JSRs to local function are replaced by BSR.s and BSR.w where applicable.

Update 31/08/2022 - Suggested fix in order to make byte and word operations use the same MoveQ fix that long operations do.


Minor update for Blitz Basic 2 (Amiga)

This is a minor update for the main Blitz Basic 2 executable ("chocolate" Blitz in that it's only a minor update over "vanilla" Blitz 2).

It's meant to be a drop in upgrade for anyone still using OG Blitz2 (as opposed to AmiBlitz, which this will not be compatible with), it doesn't include the full install.

Simply grab the "blitz2" and "ted" files from this repository (or compile blitz2.s and ted.s in DevPac) to replace your existing blitz2 and ted file (backup your existing file first!)

Download this rather than the zip -> https://github.com/earok/chocolate_blitzbasic2/blob/main/blitz2?raw=true

The code was sourced from https://github.com/nitrologic/blitz2/tree/master/src215, with a few extraneous files removed.

As of right now, there's only two notable features:

- Removal of the "About" splash screen
- Slightly smaller, faster and more optimized output, as some compiled "Move.l" opcodes are replaced with "MoveQ" opcodes where applicable (there may be more left to do).
- Ability to one click "compile+quit", which compiles to the last saved executable path without asking, disables debug, and quits to workbench.

I've commented all code changes from the original Blitz Basic with "Chocolate"
