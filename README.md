# chocolate_blitzbasic2
Minor update for Blitz Basic 2 (Amiga)

This is a minor update for the main Blitz Basic 2 executable ("chocolate" Blitz in that it's only a minor update over "vanilla" Blitz 2).

It's meant to be a drop in upgrade for anyone still using OG Blitz2 (as opposed to AmiBlitz, which this will not be compatible with), it doesn't include the full install, nor does it provide any updates to the "TED" or "SuperTED" editors.

Simply grab the "blitz2" file from this repository (or compile blitz2.s in DevPac).

Download this rather than the zip -> https://github.com/earok/chocolate_blitzbasic2/blob/main/blitz2?raw=true

The code was sourced from https://github.com/nitrologic/blitz2/tree/master/src215, with a few extraneous files removed.

As of right now, there's only two notable features:

- Removal of the "About" splash screen
- Slightly smaller, faster and more optimized output, as some compiled "Move.l" opcodes are replaced with "MoveQ" opcodes where applicable (there may be more left to do).

I've commented all code changes from the original Blitz Basic with "Chocolate"
