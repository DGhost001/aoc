# Advent of Code for Retro Computers

## Introduction

This repository contains my solutions for the [Advent of Code (AoC)](https://adventofcode.com/) challenge.
The additional challenge I put to my self is, that the solution needs to be computed on a retro Computer.

The current state is:

* A 386 with atleast 7 MB of RAM can compute all the soulutions in resonable time (some may take up to 24h of runtime)
* A 8086 is able to compute nearly all the soultions, except for some days that required more memory than a 8086 can provide. (As of today I still don't have a EMS Card to give my 8086 more memory than the 640kbyte it has). Runtime wise it is still acceptable, as most of the soulutions are computed wihtin a couple of minutes. (If you have a coprocessor it is for some days as quick as the 386 without a coprocessor)
* The Atari STe Port is still very much work in progress, in theory it should be able to achieve the same as a 8086 if you have the stock 1Mbyte Version.

A 8087 Coprocessor is not needed but recommended. It speeds up some of the days quite considerably.

## How to Compile

### Dos ( 8086 / 386 )

You require Turbo Pascal 7 or Borland Pascal 7 (If you find your old license in the shelf) to compile the DOS Version.
Just open the DAY Files and set the UNIT Directory to the UTILS Folder.

### ATARI STe

To compile for your ATARI, you need the ATARI Crosscompiler of FreePascal. With that you can compile the days as follows:

```.sh
ppcross68k -Tatari -Fu../UTILS -Fu../UTILS/ATARI -Mtp DAY01.PAS
```

Unfortunately purePascal crashes with an internal error when compiling some of the support units. So direct compilation on the ATARI is not supported, until I can figure out how to workarround this compiler bug.

## x64

As some portions of the code can already be compiled with FreePascal you can in theory get the code also running on a modern x64 PC.
It should work except for those days that require functions that are only available in assembler.

But keep in mind, this is not the goal of this project.

## How to contribute

If you feel like you have a great Idea that makes this run better on those retro platforms. Just open an Issue and put it into a pull request.
