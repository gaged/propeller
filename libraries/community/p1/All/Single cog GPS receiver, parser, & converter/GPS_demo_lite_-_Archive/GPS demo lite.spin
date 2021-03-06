{{┌──────────────────────────────────────────┐
  │ GPS receiver and parser demo             │
  └──────────────────────────────────────────┘
}}                                                                                                                                                
CON
  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000

  GPS_PIN = 1
  BAUD = 4800

OBJ
  fds    : "FullDuplexSerial"
  gps    : "GPS parser lite 1.03"
  gen    : "GPS generator"                              ' Used for testing the parser

PUB start 
  fds.start(31,30,0,115200)
  gps.start(GPS_PIN,BAUD)
  gen.start(GPS_PIN,BAUD)                               ' starts a cog that sends GPS messages for the parser to use
                                                        
  waitcnt(clkfreq + cnt)
  fds.tx($00)
  fds.tx($01)

  repeat
    waitcnt(clkfreq + cnt)
    repeat until gps.setLock                            ' lock the shared registers to ensure all readings come from same update
    fds.tx($00)                                                                                                 
    fds.str(string("Time:",$09))                                                                                
    fds.str(gps.timePtr)                                                                                        
    fds.str(string($0D,"Date:",$09))                                                                            
    fds.str(gps.datePtr)                                                                                        
    fds.str(string($0D,"Lat:",$09))                                                                             
    fds.str(gps.latPtr)                                                                                         
    fds.str(string($0D,"Lon:",$09))                                                                             
    fds.str(gps.lonPtr)                                                                                         
    fds.str(string($0D,"Alt:",$09))                                                                             
    fds.str(gps.altPtr)                                                                                         
    fds.str(string($0D,"Crs:",$09))                                                                             
    fds.str(gps.crsPtr)                                                                                         
    fds.str(string($0D,"Speed:",$09))                                                                           
    fds.str(gps.spdPtr)                                                                                         
    fds.str(string($0D,"Status:",$09))                                                                          
    fds.tx(gps.getStatus)
    fds.str(string($0D,"Satellites:",$09))
    fds.str(gps.satsPtr)                    
    gps.unlock                                        ' unlock to allow shared registers to be updated          
      