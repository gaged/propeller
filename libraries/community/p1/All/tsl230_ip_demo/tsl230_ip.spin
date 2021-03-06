{{  tsl230_ip.spin
┌─────────────────────────────────────┬────────────────┬─────────────────────┬───────────────┐
│TSL230 Light2Freq Inter-pulse Driver │ BR             │ (C)2009             │  10 Oct 2009  │
├─────────────────────────────────────┴────────────────┴─────────────────────┴───────────────┤
│ TAOS TSL230 light to frequency sensor driver with manual and auto scaling capabilities.    │
│ Uses the inter-pulse timing method with non-constant sampling rate.  This yields the       │
│ highest possible update rate (~1M samp/s in bright light) and highest possible bandwidth.  │
│ Note that the spin methods that return freq are much slower (can return ~50K samp/s max).  │
│ Thus the "getRawSamplePtr" method is provided in this driver for direct access to output.  │
│                                                                                            │
│ INTER_PULSE TIMING METHOD:                                                                 │
│ •Counts total number of clock cycles between output pulses from TSL230 over a non-fixed    │
│  time interval                                                                             │
│                                                                                            │
│                      |──────────── Tsamp ───────────|                                    │
│    TSL230 out ... ...   │
│  Propeller clk ... ...   │
│    PHSA               +1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1                                     │
│    FRQA               0         5         10          16                                   │
│                                                                                            │
│ NOTES:                                                                                     │
│ •The above timing diagram is exagerated in that the typical duration of a high pulse is    │
│  on the order of 400ns (32 ticks @ 80MHz) while the minimum interpulse period is           │
│  on the order of 600 ns (48 ticks @ 80 MHz) assuming max TSL230 output in bright light.    │
│ •The advantage of this method as compared to the pulse integration method is that this     │
│  driver delivers the highest possible update rate on output frequency..so if highest       │
│  possible measurement data rate is required then use this driver.                          │
│ •The tradeoff is that there is a commensurate decrease in accuracy as compared to the      │
│  pulse integration method.  This object can only measure the inter-pulse period to within  │
│  the nearest clock (12.5ns @ 80 MHz).  At the TSL230's maximum frequency (~1.6 MHz),       │
│  this equates to an accuracy of to 12.5ns/600ns → 1 part in 48 (not so good).  Accuracy    │
│  is better at lower TSL230 output frequencies.  This driver is also more susceptible to    │
│  noise.  If you're planning on using this driver to get high frequency light intensity     │
│  data, a bypass cap on Vdd pin wouldn't hurt...and maybe some digital filtering of the     │
│  output data stream, too.                                                                  │
│ •TSL230 manufacturer datasheet states that max frequency w/o saturation is 1.1 MHz.        │
│  However, for the part used to test this driver, the max frequency output is 1.6 MHz.      │
│  This presumably means that the 1.1-1.6 MHz region is a no-man's land of nonlinearity...   │
│ •Autoscaling constants in this object were selected assuming the more conservative 1.1 MHz │
│  figure.  The autoscale logic is intended to keep output as near to 1.1 MHz as possible    │
│  without going over and with a sufficient hysteresis band to avoid dithering of scale when │
│  autoscale enabled.                                                                        │
│ •The getSample method returns number of ticks in accordance with the current setting of    │
│  the scale parameter(output range is roughly 40 in bright light and ~8,000,000 in dim).    │
│ •getRawSample returns the raw #ticksy w/o scale (output range between 40 and ~800,000)     │
│ •TSL230 pins 7 & 8 (frequency dividers) always assumed to be low since counters easily have│
│  enough bandwidth to keep up with a 1.6 MHz (max freq) signal.   This object should        │
│  probably only be used with a clock frequency of 80 MHz or higher.                         │
│ •This object should be backwards-compatible with Paul's original.                          │
│                                                                                            │
│ See end of file for terms of use.                                                          │
└────────────────────────────────────────────────────────────────────────────────────────────┘
                                                                               
 SCHEMATIC:
─────────────────────────────────────────────────────────────────────────────────────────────  
                    ┌──────────┐
    ctrlpinbase ──│1 o      8│──┳──┐ GND
                    │          │   │  
  ctrlpinbase+1 ──│2        7│──┘ 
                    │    []    │   
                ┌──│3        6│──── inpin
                │   │          │    
            GND ┣──│4        5│──┘ 3.3V   <--NOTE: data sheet recommends a 0.01-0.1 uF 
                   └──────────┘                     bypass cap to reduce noise
─────────────────────────────────────────────────────────────────────────────────────────────  
}}


CON 
  ctrmode = %01100<<26                  'NEG detector
  tickMax = 2_000                       'upper bound on #ticks/samp  increase sensitivity
  tickMin = 200                         'lower bound on #ticks/samp  decrease sensitivity
' tickSat = 73                          'Saturation freq; light-freq relationship assumed nonlinear below this pt

        
VAR
  long freq                             'output
  long scale, cbase, auto               'inputs
  byte cog


PUB Start(inpin, ctrlpinbase, dum, autoscale): okay
''Start method to initialize TSL230 driver, arguments:
''inpin       - Prop pin number to which output of tsl230 is connected
''ctrlpinbase - Prop pin number connected to S0
''              S1 connected to ctrlpinbase + 1
''dum         - Unused argument...for compatibility with tsl230_pi and original tsl230 objects
''autoscale   - Boolean, TRUE  autoscaling turned on
                                          
  scale := %11                          'set inital scale to maximum
  cbase := ctrlpinbase                  'copy parameters
  auto := autoscale                       

  dira := %11 << cbase                  'set control pins to output
  outa := %11 << cbase                  'set scale
  
  mask := |<inpin  
  ctra_ := ctrmode + inpin              'compute counter mode
  
  cog := okay := cognew(@entry, @freq)  'start driver


PUB Stop                                                               
'' Stop driver - frees a cog

    if cog
       cogstop(cog~ -  1)


PUB getSample:val|tmp
''Return scaled intensity measurement in ticks (proportional to light intensity)
''Returns ~40 ticks in bright light, returns ~8M ticks in dim light
''Max data rate ~9000 calls/sec w/ auto enabled & clkfreq=80 (8112 ticks)
 
  val := freq                           'compute raw frequency
  tmp := lookup(scale: 1, 10, 100)
  if auto                               'autoscale based on raw frequency
    if val > tickMax                    'if output exceeds threshold, decrease gain
      scale := ++scale <# 3
    elseif val < tickMin                'if output less than threshold, increase gain
      scale := --scale #> 1
    outa := scale << cbase
  val *= tmp                            'compute scaled frequency


pub getRawSample:val
''Return raw (unscaled) frequency measurement in Hz
''Returns ~40 ticks in bright light, returns ~80K ticks in dim light
''Max data rate ~50000 calls/sec for 1 cog @ clkfreq=80   (1392 ticks)

  return freq

  
pub getRawSamplePtr:val
''Return pointer to raw (unscaled) frequency measurement in Hz
''Use this if >~50000 calls/sec needed.  Scale in freq[3].

  return @freq

  
pub getScale:val
''Return current sensitivity setting, 1 = 1X, 2 = 10X, 3 = 100X

  return scale
  

PUB setScale(range):success
''Manually set sensitivity gain, 1 = 1X, 2 = 10X, 3 = 100X
''Works in autoscale and manual modes, though autoscale may  
''override scale if turned on

  scale := 1 #> range <# 3              'limit argument range to 1,2 or 3
  outa := scale << cbase                'set scale
  return 1


DAT
'--------------------------
'Assembly driver for tsl230
'--------------------------
           org        
entry      mov     ctra,ctra_              'setup counter as neg detector
           mov     frqa,#1                 'increment phsa by 1 per tick
        
:loop      waitpne mask,mask               'wait for next sampling period (falling edge)               '5+
           mov     phsa,#4                 'initialize counter                                         '4
           waitpeq mask,mask               'wait for end of sampling period (rising edge)              '5+ 
           mov     new,phsa                'save number of ticks since falling edge                    '4
           wrlong  new,par                 'write it to hub memory                                     '7..22
           jmp     #:loop                  'play it again, Sam                                         '4


'--------------------------                                                                            
'initialized data
'--------------------------                                                                           
ctra_      long    0
mask       long    0
'uninitialized data
new        res     1

fit 496

{{

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│                                     TERMS OF USE: MIT License                              │                                                            
├────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this        │
│software and associated documentation files (the "Software"), to deal in the Software       │
│without restriction, including without limitation the rights to use, copy, modify, merge,   │
│publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons  │
│to whom the Software is furnished to do so, subject to the following conditions:            │
│                                                                                            │                         
│The above copyright notice and this permission notice shall be included in all copies or    │
│substantial portions of the Software.                                                       │
│                                                                                            │                         
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,         │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR    │
│PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE   │
│FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR        │
│OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER      │                                │
│DEALINGS IN THE SOFTWARE.                                                                   │
└────────────────────────────────────────────────────────────────────────────────────────────┘
}}