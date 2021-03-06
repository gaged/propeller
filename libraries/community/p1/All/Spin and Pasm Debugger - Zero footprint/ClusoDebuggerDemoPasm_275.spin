'' ┌──────────────────────────────────────────────────────────────────────────┐
'' │  ClusoDebugger      Zero Footprint Propeller PASM Debugger     v0.275    │
'' ├──────────────────────────────────────────────────────────────────────────┤
'' │  Author:            "Cluso99" (Ray Rodrick)                              │
'' │  Copyright (c) 2008 "Cluso99" (Ray Rodrick)                              │
'' │  License            MIT License - See end of file for terms of use       │
'' ├──────────────────────────────────────────────────────────────────────────┤
'' │  Acknowledgements:                                                       │
'' │    Many thanks to Hippy (AiChip Industries) for his original program     │
'' │     using the shadow ram $1F0-1F3 in the cog for debugging and his       │
'' │     program on hacking the interpreter.                                  │
'' │    Thanks to Chip Gracey (Parallax) for publishing his Spin Interpreter. │
'' └──────────────────────────────────────────────────────────────────────────┘
                             
'' RR20080728   Debugger used for debugging ClusoInterpreter, but can be used generally.
''              Uses PST (Propeller Serial Terminal) for debugging
'' RR20080908   Release v0.250
'' RR20080909   v0.251 Fix jmpret/call
''           v260C_004 Add Spin debug section    
''           v260C_006 Fix jmp/jmpret/tj../dj.. src indirect
'' RR2080909    v0.252 Fix jmp/jmpret/tj../dj.. src indirect
'' RR20080922   v275      Release version v0.275
'' RR20090110             Update documentation

'  ┌──────────────────────────────────────────────────────────────────────────┐
'  │    Top Object for debugging PASM                                         │
'  └──────────────────────────────────────────────────────────────────────────┘


CON

  _CLKMODE      = XTAL1 + PLL16x
  _XINFREQ      = 5_000_000

  LED_BLUE      = 24
  LED_GREEN     = 25
  LED_RED       = 26

'
CON           'THESE LINES ARE REQUIRED IN THE TOP OBJECT AND AT THE TOP OF THE CODE !!!
'------------------------------------------------------------------------------------------------------------
' The following is the object offset needed to be added to #@xxxx in Debug_Block pasm instructions (compiler restriction)
  DB            = $10                                          '<=====
 ' The following is the debug code which is held in shadow ram (compiler restriction)
  X_ENTER       = $1F0 ' X_ENTER   RDLONG  X_OPCODE, #D_LMM    'read instruction to be executed 
  X_ADD4        = $1F1 '           ADD     X_ENTER,  #4        'inc to next hub instruction to be executed
  X_OPCODE      = $1F2 ' X_OPCODE  NOP                         'execute the instruction ("SUB X_ENTER,#4 if waiting)
  X_1F3         = $1F3 '           JMP     #X_ENTER            'loop again
DAT           'THESE LINES ARE REQUIRED IN THE TOP OBJECT AND AT THE TOP OF THE CODE !!! 
'------------------------------------------------------------------------------------------------------------
' THIS IS THE DEBUG BLOCK WHICH MUST BE LOCATED IN LOWER HUB RAM (entirely below $200)
' In order to achieve this the DAT block must be at the top of the top object.
'------------------------------------------------------------------------------------------------------------
' Cog execution begins as follows:
'   The bootcode placed into cog $000-003 executes which loads the debug code into cog $1F0-1F3.
'   The debug code executes next, which reloads the original (saved) user code back into cog $000-003.
'   The debug code sets the first instruction for the cog to be $000 and waits for the dubugger code
'     to tell it what to do.
'   Execution is controlled by a simple LMM kernel.
'------------------------------------------------------------------------------------------------------------
Debug_Block             org     0                       '  v0.275   
SAVE_000                nop                             '\ Cog user code $000-003 is saved here
SAVE_001                nop                             '|
SAVE_002                nop                             '|
SAVE_003                nop                             '/
                        org     0
' Debug LMM code executes from Hub (works cooperatively with the Debug LMM code in Cog)
D_LMM_BOOT              rdlong  X_ENTER, #DB+@z_ENTER   '\ copies Debug code
                        rdlong  X_ADD4,  #DB+@z_ADD4    '|   from hub to cog $1F0-1F3
                        rdlong  X_OPCODE,#DB+@z_OPCODE  '| (workaround compiler restriction)
                        rdlong  X_1F3,   #DB+@z_1F3     '/
                        jmp     #X_ENTER
                        org     0
' This is the LMM debug code for the Debug kernel running in cog $1F0-1F3
D_LMM_SAVE              rdlong  SAVE_000,#DB+@SAVE_000  '\ restores the user code
                        rdlong  SAVE_001,#DB+@SAVE_001  '|   from hub to cog $000-003
                        rdlong  SAVE_002,#DB+@SAVE_002  '|
                        rdlong  SAVE_003,#DB+@SAVE_003  '/
' This is the LMM debug execution loop which the Debug kernel will then execute & communicate with the spin debugger
D_LMM_EXEC              sub     X_ENTER,#4-0            'normally #4 (set to #0 by "execute")
D_OPC_EXEC              nop                             'placeholder for the instruction to execute
                        wrbyte  X_ADD4,#DB+@D_LMM_EXEC  'set back to #4 when done
                        movs    X_ENTER,#DB+@D_LMM_EXEC 'simulates jump to D_LMM by changing the hub pointer
' The following are used to store variable data for hub store/load
D_VAL1_EXEC             long    0                       'data value  for cog to hub store/load
D_VAL2_EXEC             long    0                       'data value2 for cog to hub store/load (not used yet)
D_VAL3_EXEC             long    0                       'data value3 for cog to hub store/load (not used yet)
' Debug kernel code runs in cog shadow ram $1F0-1F3
                        org     $0                      'compiler will not allow $1F0 so workaround
z_ENTER                 rdlong  X_OPCODE,#DB+@D_LMM_SAVE
z_ADD4                  add     X_ENTER,#4
z_OPCODE                nop
z_1F3                   jmp     #X_ENTER
'------------------------------------------------------------------------------------------------------------
' Debug kernel code runs in cog $000-003 (bootloader code executes when cog starts)
'   The user code in cog $000-003 is replaced with the code below by spin while still in hub memory.
'   The user code is restored once the Debug kernel is loaded into cog $1F0-1F3.
                        org     0
B_ENTER                 rdlong  B_OPCODE,#DB+@D_LMM_BOOT
B_ADD4                  add     B_ENTER,#4
B_OPCODE                nop
B_003                   jmp     #B_ENTER
'


OBJ

  dbg              : "ClusoDebugger_276"                'Cluso debugger

CON
'  ┌──────────────────────────────────────────────────────────────────────────┐
'  │    ClusoDebugger Launch code                                             │
'  └──────────────────────────────────────────────────────────────────────────┘
VAR

  long  uservars                                        'user variables here

  
PUB Main            

'
  ' START THE DEBUGGER, THEN START THE USER TEST CODE (in pasm)
  dbg.StartDebugger( -1, @Debug_Block, @PasmCode, 0)          'start debugger in a new cog
  PauseMs(200)
  CogNew( @PasmCode, 0 )                                      '<---- YOUR PASM code to be debugged
'
  repeat                                                      '<=== loop here (or stop this cog)


PRI PauseMs( ms )

  waitcnt( CLKFREQ / 1000 * ms + CNT )

'
CON
'  ┌──────────────────────────────────────────────────────────────────────────┐
'  │    PASM Code to be debugged.....  (replace with your code below)         │
'  └──────────────────────────────────────────────────────────────────────────┘
DAT
'
' THIS IS THE USER TEST CODE (in Pasm) to be traced/debugged
' REPLACE WITH YOUR CODE HERE !!!

PasmCode      org       $000

flash_led     mov       f2,f2const              'this code will flash a LED on pin 26
              mov       dira,pinmask26
''            xor       outa,pinmask26          'turn on first  '<=== disabled!!!
f1loop        xor       outa,pinmask26
f2loop        djnz      f2,#f2loop
              mov       f2,f2const
              jmp       #f1loop

pinmask26     long      $1 << 26                'Pin 26 LED_RED (I have a LED connected to this pin)
f2            long      0
f2const       long      8                       '5_000_000   (needs to be small when debugging)

' END OF YOUR CODE.  
'

{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}              