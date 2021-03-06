{{

┌──────────────────────────────────────────┐
│ RTC_DEMO.spin            Version 1.01    │
│ Author: Mathew Brown                     │               
│ Copyright (c) 2008 Mathew Brown          │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

Demonstation program, to show the use of the "RealTimeClock.spin" object
Sends time, and date data to prop-plug debug port, on clock update, every second.

------------------------------------------------------  
Revision 1.01 changes:-
Added day of week functionality to demonstration   .... To reflect updated RTC object.
------------------------------------------------------

}}

CON ''System Parameters

  _CLKMODE = XTAL1 + PLL16X                             {Clock type HS XTAL, + P.L.L. with 16x multiplier}
  _XINFREQ = 5_000_000                                  {Crystal frequency 5.000Mhz}       
  '(16*5Mhz) = 80.000Mhz clock

  _STACK = 1024                                         {reserve 1K of longs for stack... overkill!!}

CON ''Date string return format type constants..

  UkFormat = 0                                          'False (zero)
  UsaFormat = 1                                         'True (non-zero)
                                                     
VAR

  byte Counter
  byte Secs                                             'Seconds passed

OBJ

  RTC: "RealTimeClock"
  CommPort : "FullDuplexSerial" 
  
PUB Main  'Real time clock demonstration

  'Start debug comm interface, using prop-plug
  CommPort.Start(31, 30, 0, 115200)
  
  'Start Real time clock
  RTC.Start

  'Preset time/date... nice demostration of rollovers..
  RTC.SetTime(23,59,50)                                 '10 seconds to midnight
  RTC.SetDate(31,12,07)                                 'New years eve, 2007

'-------------------------------------------------------------------------------------------------------
'-------------------------------------------------------------------------------------------------------
  
  repeat
  
    'Wait for next second to pass, rather than constantly sending time/date to debug comms
    Secs := RTC.ReadTimeReg(0)                          'Read current second
    repeat while Secs == RTC.ReadTimeReg(0)             'Wait until second changes

'-------------------------------------------------------------------------------------------------------

    'Spit out start of message to terminal
    CommPort.Str(String("Time:"))
        
    'Spit out string time to terminal
    CommPort.Str(RTC.ReadStrTime)

    'Spit out more of message to terminal
    CommPort.Str(String("  ..  Date:"))

     'Spit out string day of week to terminal
    CommPort.Str(RTC.ReadStrWeekday)

     'Spit out padding space
    CommPort.Tx(" ")
              
    'Spit out string date to terminal ... as UK date formatted string
    CommPort.Str(RTC.ReadStrDate(UkFormat))  '<- Change "UkFormat" to "UsaFormat", for USA date formatted string

'-------------------------------------------------------------------------------------------------------

    'Spit out raw data message to terminal
    CommPort.Str(String("  ..  Raw data: "))

    'Spit out time keeping registers raw data
    Repeat Counter from 0 to 6
    
      CommPort.Dec(RTC.ReadTimeReg(Counter))
      
      If Counter == 6
        Commport.tx(13)   '<CR> to terminate transmitted line 
      else
        CommPort.Tx(",")  'Comma seperator
        
'-------------------------------------------------------------------------------------------------------
DAT
     {<end of object code>}
     
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