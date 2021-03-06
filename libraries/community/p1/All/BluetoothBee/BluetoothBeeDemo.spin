{{

  Demo file for BluetoothBee object

  PIO0 is optional, but if connected will allow forced disconnects (instead of waiting for timeout if you reboot device)

  prop                bluetooth bee
  ---------------------------------
  pin21 *-----------* PIO0 (optional)
  pin22 *-----------* DIN
  pin23 *-----------* DOUT
  3.3v  *-----------* VCC
  GND   *-----------* GND
  
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  BT_OUT            = 22
  BT_IN             = 23
  PIO0              = 21
  
  TERM_TX           = 30
  TERM_RX           = 31

  TV_BASE_PIN       = 12
  
OBJ

  term        : "TV_Text"  
  bt          : "BluetoothBee"

  
PUB init | ok, ptr1, scan_results

  {-------------------------------------------
   | send data via serial
   -------------------------------------------}

  term.start(12) 
  
  ok := bt.start(PIO0, BT_IN, BT_OUT, bt#_baud_38400, 1, 0, 1)
  if ok > -1
    term.str(string("bt started in master mode", 13))
  else
    term.str(string("bt error:", 13))
    term.str(bt.get_error)

  ' this is my iPad bluetooth mac address
  ok := bt.connect(string("7c,6d,62,ac,47,f8"))
  
  if ok > -1
    term.str(string("sent connect request", 13))
  else
    term.str(string("connect:", 13))
    term.str(bt.get_error)

  repeat
    bt.dec(cnt)
    bt.str(string(13))
    waitcnt(clkfreq + cnt)
    


  
{
  {-------------------------------------------
   | scan for devices
   -------------------------------------------}
  term.start(12) 
  
  ok := bt.start(PIO0, BT_IN, BT_OUT, bt#_baud_38400, 1, 0, 1)
  if ok > -1
    term.str(string("bt started in master mode", 13))
  else
    term.str(string("bt error:", 13))
    term.str(bt.get_error)

  term.str(string("scanning for devices (blocking 10 seconds)", 13))
   
  ' blocks for 10 seconds           
  scan_results := bt.scan

  term.str(string("scan complete, results:", 13))

  term.str(scan_results)
  
  
  repeat
}


 {
   
  {-------------------------------------------
   | pairing example
   -------------------------------------------}
  term.start(12) 
  
  ok := bt.start(BT_IN, BT_OUT, bt#_baud_38400, 0, 0, 1)
  if ok > -1
    term.str(string("bt started in slave mode", 13))
  else
    term.str(string("bt error:", 13))
    term.str(bt.get_error)
    
  ok := bt.set_name(string("BTBeeDemo"))

  if ok > -1
    term.str(string("set name to BTBeeDemo", 13))
  else
    term.str(string("set name error:", 13))
    term.str(bt.get_error)

  ok := bt.set_pin(string("1234"))

  if ok > -1
    term.str(string("set pin to 1234", 13))
  else
    term.str(string("set pin error:", 13))
    term.str(bt.get_error)

  ok := bt.inquire_on
 
  ok := bt.connect(string("f0,b4,79,12,63,15"))
  
  if ok > -1
    term.str(string("sending connect request", 13))
  else
    term.str(string("connect:", 13))
    term.str(bt.get_error)


  ' go to PC or other device and enter PIN for pairing
  repeat
 
   }


  repeat

DAT

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