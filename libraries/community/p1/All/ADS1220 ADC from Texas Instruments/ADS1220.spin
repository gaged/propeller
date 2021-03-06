{{      
************************************************
* Texas Instruments ADS1220 24 bit digitizer   *
*                                              *
* Sample/Test application                      *
*                                              *
* Written by Daniel Rueppel - June 7th, 2018   *
* propeller@danielrueppel.com                  * 
*                                              *
* See end of file for terms of use.            *
************************************************
}}

CON
    _clkmode = xtal1 + pll16x                           
    _xinfreq = 5_000_000

OBJ
'SPI     :       "SPI_Spin"
SPI     :       "SPI_Asm"                               ''The Standalone SPI Assembly engine  
Ser     :       "Parallax Serial Terminal"

CON
        ' Registers
        WREG = $40
        RREG = $20
        RESET = $06

VAR     byte config1
        byte config2
        byte config3
        byte config4
        long DIN
        long DOUT
        long CLK
        long CS
        long DRDY
        byte flag_displayed
        long bitsReturned
        byte inputPin
        byte dataState
        long dataCounter

PUB AD1200|ReturnValue

SPI.start(25, 0)                 
 
' AD1220 Setup
DIN   := 13                     ' DIN  (MOSI)
DOUT  := 14                     ' DOUT (MISO)
CLK   := 12                     ' Clock Pin
CS    := 11                     ' CS Pin
DRDY  := 10                     ' Data Ready                                                                      '

' Set pin directions
DIRA[DRDY]~  ' input
DIRA[DOUT]~  ' input
DIRA[DIN]~~  ' output
DIRA[CLK]~~  ' output
DIRA[CS]~~   ' output

' Start serial communication
Ser.Start(57600)              
 
' Step 1: Reset AD1220
Ser.Str(string("Sending RESET"))
Ser.NewLine
RESET_AD1220
 
waitcnt(clkfreq / 10 + cnt) ' wait 100 ms  

config1 := 0
Ser.Str(string("Reading configuration"))
Ser.NewLine
LOW(CS)
WAIT_FIVE_MS
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, RREG | $00 << 2)
config1 := SPI.SHIFTIN(DOUT, CLK, SPI#MSBPOST, 8)
waitcnt(clkfreq / 10 + cnt) ' wait 100 ms
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, RREG | $01 << 2)
config2 := SPI.SHIFTIN(DOUT, CLK, SPI#MSBPOST, 8)
waitcnt(clkfreq / 10 + cnt) ' wait 100 ms
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, RREG | $02 << 2)
config3 := SPI.SHIFTIN(DOUT, CLK, SPI#MSBPOST, 8)
waitcnt(clkfreq / 10 + cnt) ' wait 100 ms
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, RREG | $03 << 2)
config4 := SPI.SHIFTIN(DOUT, CLK, SPI#MSBPOST, 8)
waitcnt(clkfreq / 10 + cnt) ' wait 100 ms
HIGH(CS)

Ser.Str(string("Config value 1 : "))
Ser.dec(config1)
Ser.NewLine
Ser.Str(string("Config value 2 : "))
Ser.Dec(config2)
Ser.NewLine
Ser.Str(string("Config value 3 : "))
Ser.Dec(config3)
Ser.NewLine
Ser.Str(string("Config value 4 : "))
Ser.Dec(config4)
Ser.NewLine

waitcnt(clkfreq / 10 + cnt) ' wait 100 ms  

' Write the respective register configuration with the WREG command
' (43h, 08h, 04h, 10h, and 00h);
' 43h = 0100 0011
Ser.Str(string("Sending SPI configuration to ADS1220"))
Ser.NewLine
LOW(CS)
waitcnt(clkfreq / 10 + cnt) ' wait 100 ms  
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, WREG | $00 << 2)
'SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, $41)
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, $21)

waitcnt(clkfreq / 10 + cnt) ' wait 100 ms  
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, WREG | $01 << 2)
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, $C4) '$84=330 samples, A4=660 samples
waitcnt(clkfreq / 10 + cnt) ' wait 100 ms  
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, WREG | $02 << 2)
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, $10)
waitcnt(clkfreq / 10 + cnt) ' wait 100 ms  
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, WREG | $03 << 2)
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, $00)
waitcnt(clkfreq / 10 + cnt) ' wait 100 ms  
HIGH(CS)


config1 := 0
Ser.Str(string("Reading configuration"))
Ser.NewLine
LOW(CS)
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, RREG | $00 << 2)
config1 := SPI.SHIFTIN(DOUT, CLK, SPI#MSBPOST, 8)
waitcnt(clkfreq / 10 + cnt) ' wait 100 ms
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, RREG | $01 << 2)
config2 := SPI.SHIFTIN(DOUT, CLK, SPI#MSBPOST, 8)
waitcnt(clkfreq / 10 + cnt) ' wait 100 ms
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, RREG | $02 << 2)
config3 := SPI.SHIFTIN(DOUT, CLK, SPI#MSBPOST, 8)
waitcnt(clkfreq / 10 + cnt) ' wait 100 ms
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, RREG | $03 << 2)
config4 := SPI.SHIFTIN(DOUT, CLK, SPI#MSBPOST, 8)
waitcnt(clkfreq / 10 + cnt) ' wait 100 ms
HIGH(CS)


Ser.Str(string("Config value 1 : "))
Ser.dec(config1)
Ser.NewLine
Ser.Str(string("Config value 2 : "))
Ser.Dec(config2)
Ser.NewLine
Ser.Str(string("Config value 3 : "))
Ser.Dec(config3)
Ser.NewLine
Ser.Str(string("Config value 4 : "))
Ser.Dec(config4)
Ser.NewLine

Ser.Str(string("START/SYNC 00001000"))
Ser.NewLine
LOW(CS)
waitcnt(clkfreq / 10 + cnt) ' wait 100 ms
SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, $08)
waitcnt(clkfreq / 10 + cnt) ' wait 100 ms
LOW(CS)

''Loop
'{
''Wait for DRDY to transition low;
''Take CS low;
''Delay for a minimum of td(CSSC);
''Send 24 SCLK rising edges to read out conversion data on DOUT/DRDY;
''Delay for a minimum of td(SCCS);
''Clear CS to high;
'}

inputPin := 0
dataCounter := 0

repeat
  HIGH(CS)
  ' Wait for DRDY to transition low
  flag_displayed := 0    
  repeat until INA[DRDY] == 0
    if (flag_displayed == 0)
      'Ser.Str(string("W"))
    flag_displayed := 1
  LOW(CS)

  bitsReturned := SPI.SHIFTIN(DOUT, CLK, SPI#MSBPOST, 24)

  IF inputPin == 0
    inputPin := 1
    SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, WREG | $00 << 2)
    SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, $41)
    waitcnt(clkfreq / 500 + cnt) ' wait 2 ms
  
  ELSEIF inputPin == 1
    inputPin := 2
    SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, WREG | $00 << 2)
    SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, $51)
    waitcnt(clkfreq / 500 + cnt) ' wait 2 ms
  
  ELSEIF inputPin == 2
    inputPin := 0
    SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, WREG | $00 << 2)
    SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, $21)
    waitcnt(clkfreq / 500 + cnt) ' wait 2 ms

  IF dataCounter == 2147483646
      dataCounter := 0

  dataCounter := dataCounter + 1
  'waitcnt(clkfreq / 500 + cnt) ' wait 2 ms
  'waitcnt(clkfreq / 500 + cnt) ' wait 2 ms
  'waitcnt(clkfreq / 500 + cnt) ' wait 2 ms

  if inputPin == 0
   'Ser.Str(string("# "))
   Ser.Dec(dataCounter)
   Ser.Str(string(" "))

  'Ser.Str(string("PIN "))
  Ser.Dec(inputPin)
  Ser.Str(string(":"))
  Ser.Dec(bitsReturned)
  
  IF inputPin <> 2
    Ser.Str(string("*"))

  IF inputPin == 2
    Ser.NewLine

  waitcnt(clkfreq / 1000 + cnt)
  
    
PUB WAIT_FIVE_MS
  waitcnt(clkfreq / 200 + cnt) ' wait 5 ms      

PUB RESET_AD1220
  LOW(CS)
  waitcnt(clkfreq / 500 + cnt) ' wait 2 ms
  HIGH(CS)
  waitcnt(clkfreq / 500 + cnt) ' wait 2 ms
  LOW(CS)
  waitcnt(clkfreq / 500 + cnt) ' wait 2 ms
  SPI.SHIFTOUT(DIN, CLK, SPI#MSBFIRST , 8, $06)  
  waitcnt(clkfreq / 500 + cnt) ' wait 2 ms
  HIGH(CS)

PUB HIGH(Pin)
  dira[Pin]~~
  outa[Pin]~~
         
PUB LOW(Pin)
  dira[Pin]~~
  outa[Pin]~


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