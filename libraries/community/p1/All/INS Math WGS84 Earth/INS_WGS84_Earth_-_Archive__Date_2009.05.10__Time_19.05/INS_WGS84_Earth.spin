{{
┌─────────────────────────────┬────────────────────┬─────────────────────┐
│  INS_WGS84_Earth.spin v2.0  │ Author: I. Kövesdi │  Rel.: 10 May 2009  │  
├─────────────────────────────┴────────────────────┴─────────────────────┤
│                    Copyright (c) 2009 CompElit Inc.                    │               
│                   See end of file for terms of use.                    │               
├────────────────────────────────────────────────────────────────────────┤
│  This application demonstrates a 250 Hz Inertial Navigation System     │
│ (INS) processor in full WGS84 rotating Earth calculations. Strapdown 3D│
│ acceleration and 3D rate gyro readings or linear acceleration and      │
│ angular velocity outputs from flight simulation algorithm (coming soon)│
│ are injected by the SPIN program into a uM-FPU V3.1 Floating Point     │
│ Coprocessor which does the  number crunching using quaternion algebra  │           
│ and North-East-Down (NED) navigation frame related equations. Calling  │
│ user defined functions in the FPU, the navigation state update cycle   │
│ time is less than 3.5 ms. The system can integrate in real time the    │
│ body angular rates and the specific force data of a 6 Degree Of Freedom│
│ (6DOF) strapdown Inertial Measurement Unit (IMU) with 250 Hz data rate.│
│                                                                        │
│ * * * *  NEW  * * *  NEW  * * *  NEW  * * *  NEW  * * *  NEW  * * * *  │
│                                                                        │
│  The acompanying new 2.0 version of the FPU functions contains a       │
│ comprehensive set of coordinate transformation utilities.  With these  │
│ new functions the user can perform any transformation between the most │
│ common four coordinate frames used in INS navigational calculations.   │
│ These four frames are the WGS84, ECEF, NED(Navigation) and BODY ones.  │
│                                                                        │
├────────────────────────────────────────────────────────────────────────┤
│ Background and Detail:                                                 │
│  After the output raw data of inertial sensors, like acceleration and  │
│ angular velocity, is compensated for errors e.g. bias and scale factor,│ 
│ it is passed through navigation algorithms that determine position,    │
│ velocity and attitude. This application presents such full navigation  │
│ algorithm for the rotating WGS84 Earth without approximations.         │
│                                                                        │
│  The Strapdown INS navigation algorithm is an essential part of all    │
│ sophisticated flight simulations, too. The numerical solution of the   │
│ dynamic equations, using the aerodynamic model of the aircraft and the │
│ control inputs, yields the linear acceleration along the X, Y and Z    │
│ body axes and (after integration) the angular velocities around those  │
│ body axes. This is exactly the same data that inertial sensors would   │
│ provide for the  INS algorithm to obtain attitude, position and        │
│ velocity of the simulated aircraft.                                    │
│                                                                        │
│  The algorithm is realized with user defined functions of the FPU and  │
│ uses almost each of it's 128 registers. In this way the communication  │
│ overhead between the Propeller and the FPU is effectively decreased.   │
│                                                                        │ 
│  The algorithm proceeds, in short terms, as follows:                   │
│  During one navigation update cycle the INS processor initially        │
│ calculates the Omega_n_en transport rate from the NED Navigation frame │
│ velocities and the WGS84 geographic position. The Earth rotation rate  │
│ is then projected into the Navigation frame to obtain Omega_n_ie.      │
│ Subsequently, the Earth rotation rate and the transport rate are       │
│ combined in Omega_n_in. Omega_n_ie is then added to Omega_n_in to      │
│ obtain the Coriolis rotation vector.                                   │
│  Before the attitude integration is performed it is essential that the │
│ gyro readings be adjusted to account for the rotation of the Navigation│
│ frame relative to the Inertial frame. To achieve this Omega_n_in is    │
│ projected into the Body frame using the transpose of the Cbn Direction │
│ Cosine Matrix (DCM). This rotation value is converted to angle         │
│ increments then utilized to adjust the gyro readings.                  │                                                                         
│  Then the attitude quaternion is updated using quaternion algebra.     │
│ Subsequently, the new Body to Navigation frame Cbn is calculated from  │
│ the new quaternion values.                                             │
│  The velocity and position integration begins with the application of  │
│ first order sculling correction of the accelerometer readings. Then    │
│ comes the translation of the corrected readings from Body to Navigation│
│ frame using the updated Body to Navigation frame DCM. The velocity     │
│ increments in the Navigation frame are obtained after applying Coriolis│
│ and gravity corrections.                                               │
│  In the Coriolis correction the skew symmetric matrix form of the      │
│ Coriolis vector is used to obtain cross product with the previous      │
│ Navigation frame velocity.                                             │
│  For the gravity correction the Earth's gravitation is calculated using│
│ J2 approximation and ECEF coordinates. Gravity correction includes the │
│ centripetal acceleration effect due to the rotation of the Earth.      │
│  Velocity integration is then performed by simple addition of the      │
│ corrected velocity increments.                                         │
│  Then the rate of change of the WGS84 geographic coordinates is        │
│ calculated  from the position and the NED Navigation frame velocity.   │   
│  Finally, the geographic positions are integrated using 2nd order      │
│ Runge-Kutta method.                                                    │                                                                        
│  After this new rotating WGS84 Earth navigation update cycle begins.   │
│                                                                        │
│ Coordinate transformations                                             │
│ ==========================                                             │
│  Navigational system states - position, velocity and attitude - or     │
│ physical vectors - like magnetic field or gravitation - are defined    │
│ with reference to coordinate frames. There are number of different     │
│ frames in current use. Four of the most common ones are the WGS-84     │
│ Geographic, the Earth-Centered-Earth-Fixed (ECEF), the North-East-Down │
│ (NED) Local Navigation and the Body frames. The CT_ functions in the   │ 
│ COMP_INS_MATH.fpu package establish a two-directional path between any │
│ of them via the routes shown here:                                     │
│                                                                        │
│                                                                        │
│                                             ┌─────────┐                │
│                                             │         │                │
│                                             │ B O D Y │                │
│                                             │         │                │
│                                             └─────────┘                │
│                                            /                           │
│                                           /                            │
│                                          /                             │
│                                         /                              │
│        ┌──────────┐          ┌─────────┐                               │
│        │          │          │         │                               │
│        │ W G S 84 │ -------- │ E C E F │                               │
│        │          │          │         │                               │
│        └──────────┘          └─────────┘                               │
│                                         \                              │
│                                          \                             │
│                                           \                            │
│                                            \                           │
│                                             ┌─────────┐                │
│                                             │         │                │
│                                             │  N E D  │                │
│                                             │         │                │
│                                             └─────────┘                │
│                                                                        │
│                                       │   
│                                                                      │ 
│     This is a Geographic      These three frames are orthogonal        │
│     system with Latitude,     right-handed cartesian frames with       │
│     Longitude and Altitude    X, Y and Z coordinates. In the NED       │
│                               local navigational frame these axes      │
│                               are called as                            │
│                                    N(orth), E(ast) and D(own)          │
│                                                                        │
│                                                                        │
│ References:                                                            │
│ •Robert M. Rogers "Applied Mathematics in Integrated Navigation        │
│ Systems", Second Edition" (AIAA) 2003.                                 │
│ •Casper Ebensen Shultz "INS and GPS integration", Tech. Univ. Denmark  │
│ MM-MSc 2006.                                                           │
│ •Jordan Crittenden, Parker Evans "MEMS Inertial Navigation System",    │
│ Design Project Report, Cornell Univ., 2008.                            │
│ •J. M.Cooke et. al. "NPSNET: Flight Simulation Dynamic Modeling Using  │
│ Quaternioms", in Presence, V1, No. 4., 1994.                           │
│                                                                        │
├────────────────────────────────────────────────────────────────────────┤
│ Note:                                                                  │
│ -The source code for the necessary user defined functions in the FPU is│
│ included in this release under the name "COMP_INS_MATH.fpu v2.0".  You │
│ have to program these functions into the Flash memory of the FPU using │
│ the IDE that can be downloaded from the site of Micromega Corporation. │
│ I used the latest 2.0 beta 6 version of this IDE with the hardware     │
│ depicted next to this text.                                            │
│                                                                        │ 
│ -You can use HyperTerminal or PST with this application. When using PST│
│ uncheck the [10] = Line Feed option in the Preferences/Function window.│
│                                                                        │
│ -Central Navigation System units, comprising an INS processor, a KF    │
│ (Kalman Filter) processor, a GPS data processor, a GMAG (Gravity and   │
│ geoMAGnetic) processor, an AD (Air Data) processor and several MUs     │
│ (Measurements Units like inertial, magnetic, pitot-static), do a lot of│
│ floating point calculations and high speed data transfer. Most of these│
│ calculations and data flow can, however, be parallelized and that is   │
│ the point where the unique and powerful parallel processing ability of │
│ the Propeller chip will enter and govern the picture. But, before the  │
│ Propeller will orchestrate those processing and measurement units, we  │
│ have to build and verify them. This object is a major step towards that│
│ goal.                                                                  │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘

Hardware:
 
                                  3.3V
                                   │
  │                           4K7  │        
 P├A0────────────────────┳───────╋─────────────────┐     
 X│                      │         │                 │
 3├A1─────────────┐      │         │  All C=0.1uF    │
 2│               │      │         │                 │
 A├A2─┳─┐         │      │         │                 ┣─────────────┐ 
  │   │ │         │      │         │                 │              C
      │ │┌────────┴──────┴────┐    │        ┌────────┴─────────┐   │                
    1K ││     SCLK|16  MCLR|1│    │    ┌───┤1|C1+  VDD|16 V+|2├───┘
      │ ││                    │    │  C    │                  │
      │ └┤12|SIN       AVDD|18├────┫    └───┤3|C1-             │
      └──┤11|SOUT       VDD|14├────┫    ┌───┤4|C2+             │    DB9-F  
         │                    │    │  C    │      MAX3232     │    ┌───\
         │    uM-FPU 3.1      │ 4K7    └───┤5|C2-             │    │   \
         │                    │    │ ┌──────┤9|R2OUT     R2IN|8├────┼2  │
      ┌──┤4|CS         SERIN|9├────┻─┘┌─────┤10|T2IN    T2OUT|7├────┼3  │
      ┣──┤17|AVSS     SEROUT|8├───────┘ ┌──┤6|V-              │    │   │
      ┣──┤13|VSS              │       C ┣───┤8|VSS             │  ┌─┼5  /
      ┴  └────────────────────┘         ┴   └──────────────────┘  ┴ └───/
     GND                               GND                       GND


- The CS pin of the FPU is tied to LOW to select SPI mode at Reset and
must remain LOW during operation. For this Demo the 2-wire SPI connection
was used, where the SOUT(11) and SIN(12) pins were connected through a 1K
resistor and the A2 pin(3) of the Propeller was connected to the SIN(12)
of the FPU.

-The Debug Monitor of the FPU is enabled if the SERIN pin is high at
Reset. As FPU is connected to an active idle RS232 port - which sets high
level on the SERIN pin - switch on will start the Debug monitor. You can
after this disable/enable the Debug monitor and the serial interface via
software.

-Note that this Propeller application disables the serial interface of the
FPU at the beginning of it's runtime and enables it only at the end of the
program. When you want to write the flash memory of the FPU you have to
wait for the Propeller to finish the code of the "INS_Math_WGS84_Earth" or
run a Propeller application that does not disable the serial interface of
the FPU.

-The MAX3232 bit-level shifter IC is a 3.3V device, do not mix it with the
5V MAX232 version. It provides two RS232 transmitters and two RS232
receivers. Here we exploit only half of it's capabilities, since the FPU's
serial interface does not use flow control.

}}


CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

'Hardware
_FPU_MCLR    = 0                     'PROP pin to MCLR pin of FPU
_FPU_CLK     = 1                     'PROP pin to SCLK pin of FPU 
_FPU_DIO     = 2                     'PROP pin to SIN(-1K-SOUT) of FPU

'_FPU_MCLR    = 3                     'PROP pin to MCLR pin of FPU
'_FPU_CLK     = 4                     'PROP pin to SCLK pin of FPU 
'_FPU_DIO     = 5                     'PROP pin to SIN(-1K-SOUT) of FPU

'Dbg
_DBGDEL      = 80_000_000
'_DBGDEL      = 20_000_000

'-------------------- uM-FPU Register Definitions ------------------------
'See COMP_INS_MATH.fpu v2.0 source code for detailed descriptions
_Dt                  = 1         
_TIME                = 2         

_LAT                 = 3         
_LON                 = 4         
_ALT                 = 5         
_DLAT                = 6         
_DLON                = 7         
_DALT                = 8         
_TLAT                = 9         
_TLON                = 10        
_TALT                = 11        

_ECEF_X              = 12        
_ECEF_Y              = 13        
_ECEF_Z              = 14        
_NED_N               = 15        
_NED_E               = 16        
_NED_D               = 17
_BODY_X              = 18
_BODY_Y              = 19
_BODY_Z              = 20         

_ROLL                = 21        
_PITCH               = 22        
_YAW                 = 23        
_Cbn_0_0             = 24        
_Cbn_0_1             = 25        
_Cbn_0_2             = 26        
_Cbn_1_0             = 27        
_Cbn_1_1             = 28        
_Cbn_1_2             = 29        
_Cbn_2_0             = 30        
_Cbn_2_1             = 31        
_Cbn_2_2             = 32        
_Q_0                 = 33        
_Q_1                 = 34        
_Q_2                 = 35        
_Q_3                 = 36        

_Vn                  = 37        
_Ve                  = 38        
_Vd                  = 39        
_DVn                 = 40        
_DVe                 = 41        
_DVd                 = 42        
_TVn                 = 43        
_TVe                 = 44        
_TVd                 = 45        

_Vlat                = 46        
_Vlon                = 47        
_Valt                = 48        

_Ax                  = 49        
_Ay                  = 50        
_Az                  = 51        
_P                   = 52        
_Q                   = 53        
_R                   = 54        

_Omega_n_en_0        = 55        
_Omega_n_en_1        = 56        
_Omega_n_en_2        = 57        
_Omega_n_ie_0        = 58        
_Omega_n_ie_1        = 59        
_Omega_n_ie_2        = 60        
_Omega_n_in_0        = 61        
_Omega_n_in_1        = 62        
_Omega_n_in_2        = 63        
_Coriolis_0          = 64        
_Coriolis_1          = 65        
_Coriolis_2          = 66        

_G_n                 = 67        
_G_e                 = 68        
_G_d                 = 69        

_Re                  = 70        
_Eps2                = 71        
_Re1mEps2            = 72        
_Omega_ie            = 73        
_GWGS0               = 74        
_GWGS1               = 75        
_GWGSMU              = 76        
_GWGSJ2              = 77        
_Cos_Lat             = 78        
_Sin_Lat             = 79        
_Cos_Lon             = 80        
_Sin_Lon             = 81        
_Sin2_Lat            = 82        
_Rdenom12            = 83        
_Rdenom32            = 84        
_Nphi                = 85        
_Mphi                = 86        

'-------------------- uM-FPU Function Definitions ------------------------
'See COMP_INS_MATH.fpu v2.0 source code for detailed descriptions

_BOOT_UP             = 0         

'Functions for the INS calculations---------------------------------------  
_INS_CALC_WGS84_AUX  = 1         
_INS_INIT_FLAT_E     = 2         
_INS_INIT_WGS84_E    = 3         
_INS_EULER_2_DCM     = 4         
_INS_DCM_2_QUAT      = 5         
_INS_QUAT_2_EULER    = 6         
_INS_G_FLAT_EARTH    = 7         
_INS_G_WGS84_J2      = 8         
_INS_WGS84_2_ECEF    = 9         
_INS_CALC_OMEGA_NEN  = 10        
_INS_CALC_OMEGA_NIE  = 11        
_INS_CALC_OMEGA_NIN  = 12        
_INS_CALC_CORIOLIS   = 13        
_INS_GYRO_CORR       = 14        
_INS_QUAT_UPDATE     = 15        
_INS_QUAT_2_DCM      = 16        
_INS_SCULLING_CORR   = 17        
_INS_GRAVITY_CORR    = 18        
_INS_CORIOLIS_CORR   = 19        
_INS_UPDATE_FLAT_E   = 20        
_INS_UPDATE_WGS84_E  = 21

'Functions for Coordinate Transformations--------------------------------
_CT_WGS84_2_ECEF     = 22
_CT_ECEF_2_WGS84     = 23
_CT_NED2ECEF_DCM     = 24
_CT_POS_NED_2_ECEF   = 25
_CT_VEC_NED_2_ECEF   = 26
_CT_VEC_ECEF_2_NED   = 27
_CT_ECEF2BODY_DCM    = 28
_CT_POS_BODY_2_ECEF  = 29
_CT_VEC_BODY_2_ECEF  = 30
_CT_VEC_ECEF_2_BODY  = 31     

 
OBJ

DBG     : "FullDuplexSerialPlus"   'From Parallax Inc.
                                   'Propeller Education Kit
                                   'Objects Lab v1.1

FPU     : "FPU_SPI_Driver"         'v2.0

  
VAR

LONG     fpu3

LONG     acc_Ax
LONG     acc_Ay
LONG     acc_Az

LONG     gyro_P
LONG     gyro_Q
LONG     gyro_R


DAT '------------------------Start of SPIN code---------------------------

  
PUB DoIt | c                               
'-------------------------------------------------------------------------
'----------------------------------┌──────┐-------------------------------
'----------------------------------│ DoIt │-------------------------------
'----------------------------------└──────┘-------------------------------
'-------------------------------------------------------------------------
''     Action: -Starts driver objects,
''             -Makes a MASTER CLEAR of the FPU and
''             -Calls INS calculation demo that uses WGS84 rotating Earth
''             mathematics 
'' Parameters: None
''    Results: None
''+Reads/Uses: /Hardware constants from CON section
''    +Writes: fpu
''      Calls: FullDuplexSerialPlus---->DBG.Start
''                                      DBG.Str
''             FPU_SPI_Driver --------->FPU.StartCOG
''                                      FPU.StopCOG
''             FPU.Check
''             INS_WGS84_Demo 
'-------------------------------------------------------------------------
'Start FullDuplexSerialPlus Dbg terminal
DBG.Start(31, 30, 0, 57600)
  
WAITCNT(6 * CLKFREQ + CNT)

DBG.Tx(16)
DBG.Tx(1)
DBG.Str(STRING("INS Math for WGS84 Earth Demo...", 13))

WAITCNT(CLKFREQ + CNT)

fpu3 := FALSE

'FPU Master Clear...
DBG.Str(STRING(13, "FPU MASTER CLEAR...", 13, 13))
OUTA[_FPU_MCLR]~~ 
DIRA[_FPU_MCLR]~~
OUTA[_FPU_MCLR]~
WAITCNT(CLKFREQ + CNT)
OUTA[_FPU_MCLR]~~
DIRA[_FPU_MCLR]~

fpu3 := FPU.StartCOG(_FPU_DIO, _FPU_CLK, @c)

IF fpu3
  DBG.Str(STRING("FPU SPI Driver started...", 13))
  WAITCNT(CLKFREQ + CNT)
  FPU_Check
  'FPU should contain the stored function package "COMP_INS_MATH.fpu" v2.0
  'The previous simple check does not check this!  
  INS_WGS84_Demo
  WAITCNT(CLKFREQ + CNT) 
  'CT_Check1
  DBG.Str(STRING(13,"INS Math WGS84 Earth Demo terminated normally..."))
  DBG.Tx(13)
  WAITCNT(CLKFREQ + CNT)
  FPU.StopCOG
  DBG.Stop
ELSE
  DBG.Str(STRING("FPU SPI Driver Start failed!"))
  REPEAT                    'Until power-off or restart 
'-------------------------------------------------------------------------    


PRI FPU_Check | oKay, char, strPtr
'-------------------------------------------------------------------------
'-------------------------------┌───────────┐-----------------------------
'-------------------------------│ FPU_Check │-----------------------------
'-------------------------------└───────────┘-----------------------------
'-------------------------------------------------------------------------
'     Action: -Makes a software reset of the FPU
'             -Cheks response to _SYNC command 
' Parameters: None
'    Results: Boolean
'+Reads/Uses: /Some constants from the FPU object
'    +Writes: None
'      Calls: FullDuplexSerialPlus->DBG.Str
'                                   DBG.Dec
'             FPU_SPI_Driver ------>FPU.Reset
'                                   FPU.ReadSyncChar
'                                   FPU.WriteCmd
'                                   FPU.ReadStr
'-------------------------------------------------------------------------
oKay := FPU.Reset
DBG.Str(STRING(16, 1)) 
IF okay
  DBG.Str(STRING("FPU Software Reset done..."))
  DBG.Str(STRING(13, 13))
ELSE
  DBG.Str(STRING("FPU Software Reset failed..."))
  DBG.Str(STRING(13, 13))
  DBG.Str(STRING("Please check hardware and restart..."))
  REPEAT                   'Until power-off or reset

WAITCNT(CLKFREQ + CNT)

char := FPU.ReadSyncChar
DBG.Str(STRING("Response to _SYNC: "))
DBG.Dec(char)
IF (char == FPU#_SYNC_CHAR)
  DBG.Str(STRING("      (OK)"))
  DBG.Str(STRING(13, 13))
  WAITCNT(CLKFREQ + CNT)   
ELSE
  DBG.Str(STRING("     Not OK!"))   
  DBG.Str(STRING(13, 13))
  DBG.Str(STRING("Please check hardware and restart..."))
  
  REPEAT                   'Until power-off or reset
'-------------------------------------------------------------------------


PRI INS_WGS84_Demo|ok,ch,ts,te,t1,t2,la,lo,al,n,e,d,vn,ve,vd,r,p,y,dt
'-------------------------------------------------------------------------
'-----------------------------┌───────────────┐---------------------------
'-----------------------------│ INS_WGS84_Demo│---------------------------
'-----------------------------└───────────────┘---------------------------
'-------------------------------------------------------------------------
'     Action: Demonstrates the speed and correctness of INS computations
'             for 6DOF IMU data in rotating WGS84 Earth   
' Parameters: None
'    Results: None
'+Reads/Uses: None
'    +Writes: acc_Ax, acc_Ay, acc_Az, gyro_P, gyro_Q, gyro_R 
'      Calls: FullDuplexSerialPlus------>DBG.Str
'                                        DBG.Dec
'             FPU_SPI_Driver------------>FPU.Reset
'                                        FPU.ReadSyncChar
'                                        FPU.WriteCmdByte
'                                        FPU.WriteCmd2Bytes
'                                        FPU.WriteCmdFloat
'                                        FPU.WriteCmdLong
'             Init_Nav_State
'             Disp_NED_Gravity 
'             Inject_6DOF_IMU_Data
'             Disp_Nav_State_Header
'             Disp_Nav_State
'-------------------------------------------------------------------------
DBG.Str(STRING(16, 1))
DBG.Str(STRING("-----INS Math for WGS84 rotating Earth Demo-----"))
DBG.Tx(13) 

WAITCNT(CLKFREQ + CNT)

'Switch off Debug Monitor and the serial interface of the FPU
FPU.WriteCmd2Bytes(FPU#_SEROUT, 0, 1) 'Debug mode disabled
                                      'Serial port enabled
FPU.WriteCmdByte(FPU#_SERIN, 0)       'Serial port disabled
                                      'No debug, no serial. This saves
                                      'some interrupt processing time                               


DBG.Str(STRING(16, 1))
DBG.Str(STRING("**Speed Test of the WGS84 Earth nav. state update**"))
DBG.Tx(13)
DBG.Tx(13) 
DBG.Str(STRING("FPU Speed test with nonzero acceleration and", 13))
DBG.Str(STRING("rate gyro data: First the data transfer time", 13))
DBG.Str(STRING("of the SPIN program is determined without of", 13))
DBG.Str(STRING("the INS state update. 2000 6DOF IMU data will", 13))
DBG.Str(STRING("be sent to the FPU...", 13))  

la := 45.0
lo := 45.0
al := 1000.0
n := 10.0
e := 20.0
d := -30.0
vn := 30.0
ve := -20.0
vd := 10.0
r := 10.0
p := 20.0
y := 30.0
Init_Nav_State(la, lo, al, n, e, d, vn, ve, vd, r, p, y)

FPU.WriteCmdByte(FPU#_FCALL, _BOOT_UP)
FPU.WriteCmdByte(FPU#_FCALL, _INS_INIT_WGS84_E)
FPU.WriteCmdByte(FPU#_FCALL, _INS_G_WGS84_J2)

dt := 0.004
FPU.WriteCmdByte(FPU#_SELECTA, _Dt)
FPU.WriteCmdFloat(FPU#_FWRITEA, dt)

'Setup nonzero IMU readings
acc_Ax := 1.234
acc_Ay := 2.345
acc_Az := -3.456
gyro_P := 0.123
gyro_Q := -0.234
gyro_R := 0.345

DBG.Str(STRING(13, "From Start ..."))
ts := CNT
  
REPEAT 2000
  Inject_6DOF_IMU_Data(acc_Ax,acc_Ay,acc_Az,gyro_P,gyro_Q,gyro_R)
  'State update is deliberatly missing from here

'Calculate execution time
te := CNT
t1 := te - ts
FPU.WriteCmdByte(FPU#_SELECTA, 127)
FPU.WriteCmdLong(FPU#_LWRITEA, CLKFREQ)
FPU.WriteCmd(FPU#_FLOAT)
FPU.WriteCmdByte(FPU#_SELECTA, 126)
FPU.WriteCmdLong(FPU#_LWRITEA, t1)
FPU.WriteCmd(FPU#_FLOAT)
FPU.WriteCmdByte(FPU#_FDIV, 127)

FPU.Wait
FPU.WriteCmd(FPU#_FREADA)
t1 := FPU.ReadReg
DBG.Str(STRING(" to Stop = "))             
DBG.Str(FPU.ReadRaFloatAsStr(63))
DBG.Str(STRING(" sec"))
DBG.Tx(13)

DBG.Tx(13)
DBG.Str(STRING("Now the same number of 2000 cycles will be done,"))
DBG.Tx(13)  
DBG.Str(STRING("but now with inserted navigation state update in"))
DBG.Tx(13)
DBG.Str(STRING("full rotating WGS84 Earth calculation..."))
DBG.Tx(13)   

la := 45.0
lo := 45.0
al := 1000.0
n := 10.0
e := 20.0
d := -30.0
vn := 30.0
ve := -20.0
vd := 10.0
r := 10.0
p := 20.0
y := 30.0
Init_Nav_State(la, lo, al, n, e, d, vn, ve, vd, r, p, y)

FPU.WriteCmdByte(FPU#_FCALL, _BOOT_UP)
FPU.WriteCmdByte(FPU#_FCALL, _INS_INIT_WGS84_E)
FPU.WriteCmdByte(FPU#_FCALL, _INS_G_WGS84_J2)

dt := 0.0025
FPU.WriteCmdByte(FPU#_SELECTA, _Dt)
FPU.WriteCmdFloat(FPU#_FWRITEA, dt)

'Setup nonzero IMU readings
acc_Ax := 1.234
acc_Ay := 2.345
acc_Az := -3.456
gyro_P := 0.123
gyro_Q := -0.234
gyro_R := 0.345

DBG.Str(STRING(13, "From Start ..."))
ts := CNT
  
REPEAT 2000
  Inject_6DOF_IMU_Data(acc_Ax,acc_Ay,acc_Az,gyro_P,gyro_Q,gyro_R)
  'INS State update
  FPU.WriteCmdByte(FPU#_FCALL, _INS_UPDATE_WGS84_E)
  FPU.Wait

'Calculate elapsed time  
te := CNT
t2 := te - ts
FPU.WriteCmdByte(FPU#_SELECTA, 127)
FPU.WriteCmdLong(FPU#_LWRITEA, CLKFREQ)
FPU.WriteCmd(FPU#_FLOAT)
FPU.WriteCmdByte(FPU#_SELECTA, 126)
FPU.WriteCmdLong(FPU#_LWRITEA, t2)
FPU.WriteCmd(FPU#_FLOAT)
FPU.WriteCmdByte(FPU#_FDIV, 127)

FPU.Wait
FPU.WriteCmd(FPU#_FREADA)
t2 := FPU.ReadReg
DBG.Str(STRING(" to Stop = "))             
DBG.Str(FPU.ReadRaFloatAsStr(63))
DBG.Str(STRING(" sec"))
DBG.Tx(13)

WAITCNT(2 * _DBGDEL + CNT) 

DBG.Tx(13)
DBG.Str(STRING("The difference between the two durations is", 13))
DBG.Str(STRING("the time needed for the 2000 INS state update."))
DBG.Tx(13)
DBG.Str(STRING("I.e. one full WGS84 INS update takes"))

FPU.WriteCmdByte(FPU#_SELECTA, 127)
FPU.WriteCmdFloat(FPU#_FWRITEA, t1)
FPU.WriteCmdByte(FPU#_SELECTA, 126)
FPU.WriteCmdFloat(FPU#_FWRITEA, t2)
FPU.WriteCmdByte(FPU#_FSUB, 127)
FPU.WriteCmdByte(FPU#_FDIVI, 2)
DBG.Str(FPU.ReadRaFloatAsStr(62))
DBG.Str(STRING(" msec."))
DBG.Tx(13)

WAITCNT(8 * _DBGDEL + CNT) 

DBG.Str(STRING(16, 1))
DBG.Str(STRING("*************************************************"))
DBG.Tx(13)
DBG.Str(STRING("'Free Fall' test: All sensor inputs are zero."))
DBG.Tx(13)
DBG.Str(STRING("Starting speed is zero, starting position is"))
DBG.Tx(13)
DBG.Str(STRING("Lat: 45 deg, Lon: 0 deg, Alt: 0 m. This position"))
DBG.Tx(13)
DBG.Str(STRING("is on the northern hemisphere. The craft is"))
DBG.Tx(13)
DBG.Str(STRING("oriented North and is leveled. Time step is"))
DBG.Tx(13)
DBG.Str(STRING("0.01 sec. Navigation state, such as NED velocity,"))
DBG.Tx(13)
DBG.Str(STRING("the change in geographic coordinates and the"))
DBG.Tx(13) 
DBG.Str(STRING("attitude Euler angles are listed once per second."))
DBG.Tx(13)
DBG.Str(STRING("Notes before the test: We expect negative change in"))
DBG.Tx(13)
DBG.Str(STRING("the altitude and a uniformly increasing positive"))
DBG.Tx(13)
DBG.Str(STRING("downspeed. But will we 'sense' the Earth's rotation?"))
DBG.Tx(13)

WAITCNT(20 * _DBGDEL + CNT) 

FPU.WriteCmdByte(FPU#_FCALL, _BOOT_UP)

la := 45.0
lo := 0.0
al := 0.0
n := 0.0
e := 0.0
d := 0.0
vn := 0.0
ve := 0.0
vd := 0.0
r := 0.0
p := 0.0
y := 0.0
Init_Nav_State(la, lo, al, n, e, d, vn, ve, vd, r, p, y)  

FPU.WriteCmdByte(FPU#_FCALL, _INS_INIT_WGS84_E)
FPU.WriteCmdByte(FPU#_FCALL, _INS_G_WGS84_J2)

Disp_NED_Gravity
   
WAITCNT(4 * _DBGDEL + CNT)

dt := 0.01
FPU.WriteCmdByte(FPU#_SELECTA, _Dt)
FPU.WriteCmdFloat(FPU#_FWRITEA, dt)

Disp_Nav_State_Header

'Setup IMU sensor readings     
acc_Ax := 0.0  
acc_Ay := 0.0  
acc_Az := 0.0   
gyro_P := 0.0  
gyro_Q := 0.0   
gyro_R := 0.0

REPEAT 10
  REPEAT 100
    Inject_6DOF_IMU_Data(acc_Ax,acc_Ay,acc_Az,gyro_P,gyro_Q,gyro_R)
    'State update
    FPU.WriteCmdByte(FPU#_FCALL, _INS_UPDATE_WGS84_E)
    FPU.Wait
    
  Disp_Nav_State

WAITCNT(12 * _DBGDEL + CNT)

DBG.Tx(13)
DBG.Str(STRING("Notes after the test: One can see the free-fall and"))
DBG.Tx(13)
DBG.Str(STRING("a small eastward drift because the falling craft"))
DBG.Tx(13)
DBG.Str(STRING("is getting closer to the Earth's center while"))
DBG.Tx(13)
DBG.Str(STRING("keeping it's somewhat larger West to East radial"))
DBG.Tx(13)
DBG.Str(STRING("velocity from above. One can see a slight change in"))
DBG.Tx(13)
DBG.Str(STRING("the attitude since the craft conserves it's attitude"))
DBG.Tx(13)
DBG.Str(STRING("relative to the inertial frame(s) while the Earth,"))
DBG.Tx(13)
DBG.Str(STRING("and the 'new' NED frames pinned to it change their"))
DBG.Tx(13)
DBG.Str(STRING("orientation relative to the inertial frame(s)."))
DBG.Tx(13)
DBG.Str(STRING("Since all sensor inputs are zero, these results are"))
DBG.Tx(13)
DBG.Str(STRING("obtained only by the appropriate rotation and"))
DBG.Tx(13)
DBG.Str(STRING("Coriolis compensations done by the INS algorithm."))
DBG.Tx(13)

WAITCNT(20 * _DBGDEL + CNT)

DBG.Str(STRING(16, 1))
DBG.Str(STRING("************************************************"))
DBG.Tx(13)
DBG.Str(STRING("'Coriolis' test: All sensor inputs are zero."))
DBG.Tx(13)
DBG.Str(STRING("Starting speed is 100 m/s, starting position is"))
DBG.Tx(13)
DBG.Str(STRING("Lat: 45 deg, Lon: 0 deg, Alt: 0 m. This position"))
DBG.Tx(13)
DBG.Str(STRING("is on the northern hemisphere. The craft is"))
DBG.Tx(13)
DBG.Str(STRING("oriented/moving North and is leveled. Time step is"))
DBG.Tx(13)
DBG.Str(STRING("0.01 sec. Navigation state, such as NED velocity,"))
DBG.Tx(13)
DBG.Str(STRING("the change in geographic coordinates and the"))
DBG.Tx(13) 
DBG.Str(STRING("attitude Euler angles are listed once per second."))
DBG.Tx(13)
DBG.Str(STRING("Notes before the test: We expect the superposition"))
DBG.Tx(13)
DBG.Str(STRING("of the free-fall and a speedy northward travel."))
DBG.Tx(13)
DBG.Str(STRING("But will we see the Coriolis effect? In other"))
DBG.Tx(13)
DBG.Str(STRING("words, as the craft moves on the northern"))
DBG.Tx(13)
DBG.Str(STRING("hemisphere, will it veer to the right slightly?"))
DBG.Tx(13)

WAITCNT(20 * _DBGDEL + CNT) 

FPU.WriteCmdByte(FPU#_FCALL, _BOOT_UP)

la := 45.0
lo := 0.0
al := 0.0
n := 0.0
e := 0.0
d := 0.0
vn := 100.0
ve := 0.0
vd := 0.0
r := 0.0
p := 0.0
y := 0.0
Init_Nav_State(la, lo, al, n, e, d, vn, ve, vd, r, p, y)  

FPU.WriteCmdByte(FPU#_FCALL, _INS_INIT_WGS84_E)
FPU.WriteCmdByte(FPU#_FCALL, _INS_G_WGS84_J2)

dt := 0.01
FPU.WriteCmdByte(FPU#_SELECTA, _Dt)
FPU.WriteCmdFloat(FPU#_FWRITEA, dt)

Disp_Nav_State_Header

'Setup IMU sensor readings     
acc_Ax := 0.0  
acc_Ay := 0.0  
acc_Az := 0.0   
gyro_P := 0.0  
gyro_Q := 0.0   
gyro_R := 0.0

REPEAT 10
  REPEAT 100
    Inject_6DOF_IMU_Data(acc_Ax,acc_Ay,acc_Az,gyro_P,gyro_Q,gyro_R)
    'State update
    FPU.WriteCmdByte(FPU#_FCALL, _INS_UPDATE_WGS84_E)
    FPU.Wait
  
  Disp_Nav_State

WAITCNT(12 * _DBGDEL + CNT)

DBG.Tx(13)
DBG.Str(STRING("Notes after the test: One can see a definite"))
DBG.Tx(13)
DBG.Str(STRING("eastward drift and speed accumulation due to the"))
DBG.Tx(13)
DBG.Str(STRING("Coriolis effect. Since the craft is moving to North,"))
DBG.Tx(13)
DBG.Str(STRING("while it is falling, it drifts to the right. Since"))
DBG.Tx(13)
DBG.Str(STRING("all sensor inputs are zero, these results are"))
DBG.Tx(13)
DBG.Str(STRING("obtained only by the appropriate rotation and"))
DBG.Tx(13)
DBG.Str(STRING("Coriolis compensations done by the INS algorithm."))
DBG.Tx(13)

WAITCNT(16 * _DBGDEL + CNT)

DBG.Str(STRING(16, 1))
DBG.Str(STRING("**************************************************"))
DBG.Tx(13)
DBG.Str(STRING("'Geostationary' test: All sensor inputs are zero"))
DBG.Tx(13)
DBG.Str(STRING("again and the starting NED speed is zero, too."))
DBG.Tx(13)
DBG.Str(STRING("But the craft is now at very high altitude above the"))
DBG.Tx(13)
DBG.Str(STRING("equator. This altitude is about 35.8 thousand km."))
DBG.Tx(13) 
DBG.Str(STRING("At this height gravitation can accelerate the craft"))
DBG.Tx(13)
DBG.Str(STRING("on a circular orbit where it travels above the"))
DBG.Tx(13)
DBG.Str(STRING("equator at the same speed as the Earth rotates."))
DBG.Tx(13)
DBG.Str(STRING("Setting the NED frame velocity as zero at this"))
DBG.Tx(13)
DBG.Str(STRING("altitude means that we prescribe a c.a. 3 km/sec"))
DBG.Tx(13)
DBG.Str(STRING("inertial frame tangential velocity, just the right"))
DBG.Tx(13)
DBG.Str(STRING("size and direction to remain on this circular orbit."))
DBG.Tx(13)
DBG.Str(STRING("Check for the steady NED frame velocity and the "))
DBG.Tx(13)
DBG.Str(STRING("steady geographic coordinates during this type of"))
DBG.Tx(13)
DBG.Str(STRING("'free fall'."))
DBG.Tx(13)

WAITCNT(20 * _DBGDEL + CNT) 

FPU.WriteCmdByte(FPU#_FCALL, _BOOT_UP)

la := 0.0
lo := 0.0
al := 35786550.0
n := 0.0
e := 0.0
d := 0.0
vn := 0.0
ve := 0.0
vd := 0.0
r := 0.0
p := 0.0
y := 0.0
Init_Nav_State(la, lo, al, n, e, d, vn, ve, vd, r, p, y)  

FPU.WriteCmdByte(FPU#_FCALL, _INS_INIT_WGS84_E)
FPU.WriteCmdByte(FPU#_FCALL, _INS_G_WGS84_J2)

Disp_NED_Gravity           'A J4 approximation for the gravity would be
                           'somewhat better here at this distance.
                                       
WAITCNT(4 * _DBGDEL + CNT)

dt := 0.01
FPU.WriteCmdByte(FPU#_SELECTA, _Dt)
FPU.WriteCmdFloat(FPU#_FWRITEA, dt)

Disp_Nav_State_Header

'Setup IMU sensor readings     
acc_Ax := 0.0  
acc_Ay := 0.0  
acc_Az := 0.0   
gyro_P := 0.0  
gyro_Q := 0.0   
gyro_R := 0.0

REPEAT 10
  REPEAT 100
    Inject_6DOF_IMU_Data(acc_Ax,acc_Ay,acc_Az,gyro_P,gyro_Q,gyro_R)
    'State update
    FPU.WriteCmdByte(FPU#_FCALL, _INS_UPDATE_WGS84_E)
    FPU.Wait
    
  Disp_Nav_State

WAITCNT(12 * _DBGDEL + CNT)

DBG.Tx(13)
DBG.Str(STRING("Notes after the test: As one can not see change in" ))
DBG.Tx(13)
DBG.Str(STRING("the geographic coordinates the craft is stationer"))
DBG.Tx(13)
DBG.Str(STRING("relative to the rotating Earth. Since the craft is")) 
DBG.Tx(13)
DBG.Str(STRING("pointing parallel to the Earth's axis, one can see"))
DBG.Tx(13)
DBG.Str(STRING("a change in the roll angle as the craft keeps it's"))
DBG.Tx(13)
DBG.Str(STRING("orientation in inertial space but NED frame rotates."))
DBG.Tx(13)
DBG.Str(STRING("If you have noticed the zero NED gravity vector,"))
DBG.Tx(13)
DBG.Str(STRING("that's correct here, since gravity equals gravitation"))
DBG.Tx(13)
DBG.Str(STRING("minus centripetal acceleration in the non-inertial"))
DBG.Tx(13)
DBG.Str(STRING("NED frame. These two vectors are just equal in this"))
DBG.Tx(13)
DBG.Str(STRING("frame  at the altitude of geostationary orbits."))
DBG.Tx(13) 

WAITCNT(16 * _DBGDEL + CNT)

FPU.WriteCmd2Bytes(FPU#_SEROUT, 0, 0) 'Debug mode enabled
'-------------------------------------------------------------------------


PRI Init_Nav_State(lat,lon,alt,nx,ey,dz,vnx,vey,vdz,roll,pitch,yaw)
'-------------------------------------------------------------------------
'-----------------------------┌────────────────┐--------------------------
'-----------------------------│ Init_Nav_State │--------------------------
'-----------------------------└────────────────┘--------------------------
'-------------------------------------------------------------------------
'     Action: Initializes Navigation State
' Parameters: Latitude [deg], Longitude [deg], Altitude [m]
'             NED position [m], velocity [m/sec]
'             Attitude Roll [deg], Pitch [deg], Yaw [deg]
'    Results: Setup of appropriate FPU registers
'+Reads/Uses: None                      
'    +Writes: None
'      Calls: FPU_SPI_Driver---------->FPU.WriteCmdByte
'                                      FPU.WriteCmdFloat
'                                      FPU.WriteCmd 
'-------------------------------------------------------------------------
'Write geographic coordinates with deg to rad conversion
FPU.WriteCmdByte(FPU#_SELECTA, _LAT)
FPU.WriteCmdFloat(FPU#_FWRITEA, lat)
FPU.WriteCmd(FPU#_RADIANS)
FPU.WriteCmdByte(FPU#_SELECTA, _LON)
FPU.WriteCmdFloat(FPU#_FWRITEA, lon)
FPU.WriteCmd(FPU#_RADIANS)
FPU.WriteCmdByte(FPU#_SELECTA, _ALT)
FPU.WriteCmdFloat(FPU#_FWRITEA, alt)

'Write position expressed in NED Nav frame
FPU.WriteCmdByte(FPU#_SELECTA, _NED_N)
FPU.WriteCmdFloat(FPU#_FWRITEA, nx)
FPU.WriteCmdByte(FPU#_SELECTA, _NED_E)
FPU.WriteCmdFloat(FPU#_FWRITEA, ey)
FPU.WriteCmdByte(FPU#_SELECTA, _NED_D)
FPU.WriteCmdFloat(FPU#_FWRITEA, dz)

'Write velocity expressed in NED Nav frame 
FPU.WriteCmdByte(FPU#_SELECTA, _Vn)
FPU.WriteCmdFloat(FPU#_FWRITEA, vnx)
FPU.WriteCmdByte(FPU#_SELECTA, _Ve)
FPU.WriteCmdFloat(FPU#_FWRITEA, vey)
FPU.WriteCmdByte(FPU#_SELECTA, _Vd)
FPU.WriteCmdFloat(FPU#_FWRITEA, vdz)      

'Write attitude Euler angles referred to Body frame with deg to rad conv.
FPU.WriteCmdByte(FPU#_SELECTA, _ROLL)
FPU.WriteCmdFloat(FPU#_FWRITEA, roll)
FPU.WriteCmd(FPU#_RADIANS)
FPU.WriteCmdByte(FPU#_SELECTA, _PITCH)
FPU.WriteCmdFloat(FPU#_FWRITEA, pitch)
FPU.WriteCmd(FPU#_RADIANS)
FPU.WriteCmdByte(FPU#_SELECTA, _YAW)
FPU.WriteCmdFloat(FPU#_FWRITEA, yaw)
FPU.WriteCmd(FPU#_RADIANS)
'-------------------------------------------------------------------------


PRI Inject_6DOF_IMU_Data(ax, ay, az, pr, qp, ry)
'-------------------------------------------------------------------------
'-------------------------┌──────────────────────┐------------------------
'-------------------------│ Inject_6DOF_IMU_Data │------------------------
'-------------------------└──────────────────────┘------------------------
'-------------------------------------------------------------------------
'     Action: Writes 6DOF IMU data from HUB to FPU
' Parameters: Acceleration: ax, ay, az
'             Rate Gyro data: pr, qp, ry
'    Results: None
'+Reads/Uses: None                      
'    +Writes: None               
'      Calls: FPU_SPI_Driver---------->FPU.WriteCmdByte
'                                      FPU.WriteCmdFloat
'-------------------------------------------------------------------------
FPU.WriteCmdByte(FPU#_SELECTA, _Ax)
FPU.WriteCmdFloat(FPU#_FWRITEA, ax)
FPU.WriteCmdByte(FPU#_SELECTA, _Ay)
FPU.WriteCmdFloat(FPU#_FWRITEA, ay)
FPU.WriteCmdByte(FPU#_SELECTA, _Az)
FPU.WriteCmdFloat(FPU#_FWRITEA, az)
FPU.WriteCmdByte(FPU#_SELECTA, _P)
FPU.WriteCmdFloat(FPU#_FWRITEA, pr)
FPU.WriteCmdByte(FPU#_SELECTA, _Q)
FPU.WriteCmdFloat(FPU#_FWRITEA, qp)
FPU.WriteCmdByte(FPU#_SELECTA, _R)
FPU.WriteCmdFloat(FPU#_FWRITEA, ry)
'-------------------------------------------------------------------------


PRI Disp_NED_Gravity | g_n, g_e, g_d
'-------------------------------------------------------------------------
'----------------------------┌──────────────────┐-------------------------
'----------------------------│ Disp_NED_Gravity │-------------------------
'----------------------------└──────────────────┘-------------------------
'-------------------------------------------------------------------------
'     Action: Displays NED Nav frame gravity vector
' Parameters: None
'    Results: None
'+Reads/Uses: Corresponding FPU Regs                      
'    +Writes: None
'      Calls: FPU_SPI_Driver---------->FPU.WriteCmdByte
'                                      FPU.ReadRaFloatAsStr
'             FullDuplexSerialPlus---->DBG.Str
'                                      DBG.Tx
'-------------------------------------------------------------------------
DBG.Str(STRING(13, "NED gravity vector [m/(sec*sec)]: "))
FPU.WriteCmdByte(FPU#_SELECTA, _G_n)
DBG.Str(FPU.ReadRaFloatAsStr(85))
FPU.WriteCmdByte(FPU#_SELECTA, _G_e)
DBG.Str(FPU.ReadRaFloatAsStr(85))
FPU.WriteCmdByte(FPU#_SELECTA, _G_d)
DBG.Str(FPU.ReadRaFloatAsStr(85))
DBG.Tx(13)
'-------------------------------------------------------------------------


PRI Disp_Nav_State_Header
'-------------------------------------------------------------------------
'-------------------------┌───────────────────────┐-----------------------
'-------------------------│ Disp_Nav_State_Header │-----------------------
'-------------------------└───────────────────────┘-----------------------
'-------------------------------------------------------------------------
'     Action: Displays Navigation State display header
' Parameters: None
'    Results: None
'+Reads/Uses: None                      
'    +Writes: None
'      Calls: FullDuplexSerialPlus---->DBG.Str
'                                      DBG.Tx   
'-------------------------------------------------------------------------
DBG.Str(STRING(13, "   NED speed [m/sec]"))
DBG.Str(STRING("   WGS84 pos.change[deg,deg,m]  Attitude [deg]", 13))
DBG.Str(STRING("  North   East   Down "))
DBG.Str(STRING("     Lat      Lon      Alt"))
DBG.Str(STRING("    Roll Pitch Yaw"))
DBG.Tx(13)
'-------------------------------------------------------------------------


PRI Disp_Nav_State | vn, ve, vd, n, e, d, r, p, y
'-------------------------------------------------------------------------
'-----------------------------┌────────────────┐--------------------------
'-----------------------------│ Disp_Nav_State │--------------------------
'-----------------------------└────────────────┘--------------------------
'-------------------------------------------------------------------------
'     Action: Displays Navigation State variables in a raw
' Parameters: None
'    Results: None
'+Reads/Uses: Corresponding FPU Regs                  
'    +Writes: FPU Reg:127
'      Calls: FPU_SPI_Driver---------->FPU.WriteCmdByte
'                                      FPU.ReadRaFloatAsStr
'             FullDuplexSerialPlus---->DBG.Str
'                                      DBG.Tx
'------------------------------------------------------------------------- 
'Readout NED Nav frame velocity components
FPU.WriteCmdByte(FPU#_SELECTA, _TVn)
DBG.Str(FPU.ReadRaFloatAsStr(72))

FPU.WriteCmdByte(FPU#_SELECTA, _TVe)
DBG.Str(FPU.ReadRaFloatAsStr(72)) 

FPU.WriteCmdByte(FPU#_SELECTA, _TVd)
DBG.Str(FPU.ReadRaFloatAsStr(72)) 

DBG.Str(STRING("  "))        

'Readout accumulated Geographic coordinate increments
FPU.WriteCmdByte(FPU#_SELECTA, 127)
FPU.WriteCmdByte(FPU#_FSET, _DLAT)
FPU.WriteCmd(FPU#_DEGREES)
DBG.Str(FPU.ReadRaFloatAsStr(96)) 

FPU.WriteCmdByte(FPU#_FSET, _DLON)
FPU.WriteCmd(FPU#_DEGREES)
DBG.Str(FPU.ReadRaFloatAsStr(96))

FPU.WriteCmdByte(FPU#_SELECTA, _DALT)
DBG.Str(FPU.ReadRaFloatAsStr(82))

DBG.Str(STRING("  "))

'Transform Quaternion to Euler attitude angles
FPU.WriteCmdByte(FPU#_FCALL, _INS_QUAT_2_EULER)

'Read Euler angles with rad to deg conversion
FPU.WriteCmdByte(FPU#_SELECTA, 127)   
FPU.WriteCmdByte(FPU#_FSET, _ROLL)
FPU.WriteCmd(FPU#_DEGREES)
DBG.Str(FPU.ReadRaFloatAsStr(52))
      
FPU.WriteCmdByte(FPU#_FSET, _PITCH)
FPU.WriteCmd(FPU#_DEGREES)
DBG.Str(FPU.ReadRaFloatAsStr(52))
         
FPU.WriteCmdByte(FPU#_FSET, _YAW)
FPU.WriteCmd(FPU#_DEGREES)
DBG.Str(FPU.ReadRaFloatAsStr(52)) 

DBG.Tx(13)
'-------------------------------------------------------------------------


PRI CT_Check1| lat, lon, alt
'-------------------------------------------------------------------------
'---------------------------------┌───────────┐---------------------------
'---------------------------------│ CT_Check1 │---------------------------
'---------------------------------└───────────┘---------------------------
'-------------------------------------------------------------------------
'     Action: Checks some WGS84 / ECEF transformations
' Parameters: None
'    Results: None
'+Reads/Uses: Corresponding FPU Regs & constnats                  
'    +Writes: None
'      Calls: FPU_SPI_Driver---------->FPU.WriteCmdByte
'                                      FPU.ReadRaFloatAsStr
'             FullDuplexSerialPlus---->DBG.Str
'                                      DBG.Tx
'       Note: Shows the method how to use some CT functions
'------------------------------------------------------------------------- 
DBG.Str(STRING(16, 1))
DBG.Str(STRING("-----------Check WGS84 / ECEF transformations---------"))
DBG.Tx(13)
DBG.Tx(13) 

WAITCNT(CLKFREQ + CNT) 

'Clear FPU's rgisters and prepare WGS84 constants
FPU.WriteCmdByte(FPU#_FCALL, _BOOT_UP)

'Equatorial radius case
lat := 0.0
lon := 0.0
alt := 0.0

'Load TLAT, TLON, TALT
'Write geographic coordinates with deg to rad conversion
FPU.WriteCmdByte(FPU#_SELECTA, _TLAT)
FPU.WriteCmdFloat(FPU#_FWRITEA, lat)
FPU.WriteCmd(FPU#_RADIANS)
FPU.WriteCmdByte(FPU#_SELECTA, _TLON)
FPU.WriteCmdFloat(FPU#_FWRITEA, lon)
FPU.WriteCmd(FPU#_RADIANS)
FPU.WriteCmdByte(FPU#_SELECTA, _TALT)
FPU.WriteCmdFloat(FPU#_FWRITEA, alt)

'Calculate ECEF coordinates
FPU.WriteCmdByte(FPU#_FCALL, _CT_WGS84_2_ECEF)
FPU.Wait

'Read back ECEF data
FPU.WriteCmdByte(FPU#_SELECTA, _ECEF_X)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)      
FPU.WriteCmdByte(FPU#_SELECTA, _ECEF_Y)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
FPU.WriteCmdByte(FPU#_SELECTA, _ECEF_Z)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
DBG.Tx(13)

'Backtransform
FPU.WriteCmdByte(FPU#_FCALL, _CT_ECEF_2_WGS84)
FPU.Wait
      
'Read back ECEF data
FPU.WriteCmdByte(FPU#_SELECTA, _TLAT)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)      
FPU.WriteCmdByte(FPU#_SELECTA, _TLON)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
FPU.WriteCmdByte(FPU#_SELECTA, _TALT)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
DBG.Tx(13)

'Close to the pole case with very high altitude
lat := 90.0
lon := 90.0
alt := 33000.0

'Load TLAT, TLON, TALT
'Write geographic coordinates with deg to rad conversion
FPU.WriteCmdByte(FPU#_SELECTA, _TLAT)
FPU.WriteCmdFloat(FPU#_FWRITEA, lat)
FPU.WriteCmd(FPU#_RADIANS)
FPU.WriteCmdByte(FPU#_SELECTA, _TLON)
FPU.WriteCmdFloat(FPU#_FWRITEA, lon)
FPU.WriteCmd(FPU#_RADIANS)
FPU.WriteCmdByte(FPU#_SELECTA, _TALT)
FPU.WriteCmdFloat(FPU#_FWRITEA, alt)

'Calculate ECEF coordinates
FPU.WriteCmdByte(FPU#_FCALL, _CT_WGS84_2_ECEF)
FPU.Wait

'Read back ECEF data
FPU.WriteCmdByte(FPU#_SELECTA, _ECEF_X)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)      
FPU.WriteCmdByte(FPU#_SELECTA, _ECEF_Y)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
FPU.WriteCmdByte(FPU#_SELECTA, _ECEF_Z)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
DBG.Tx(13)

'Backtransform
FPU.WriteCmdByte(FPU#_FCALL, _CT_ECEF_2_WGS84)
FPU.Wait
      
'Read back ECEF data
FPU.WriteCmdByte(FPU#_SELECTA, _TLAT)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)      
FPU.WriteCmdByte(FPU#_SELECTA, _TLON)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
FPU.WriteCmdByte(FPU#_SELECTA, _TALT)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
DBG.Tx(13)

'Y axis case with high altitude
lat := 0.0
lon := 90.0
alt := 10000.0

'Load TLAT, TLON, TALT
'Write geographic coordinates with deg to rad conversion
FPU.WriteCmdByte(FPU#_SELECTA, _TLAT)
FPU.WriteCmdFloat(FPU#_FWRITEA, lat)
FPU.WriteCmd(FPU#_RADIANS)
FPU.WriteCmdByte(FPU#_SELECTA, _TLON)
FPU.WriteCmdFloat(FPU#_FWRITEA, lon)
FPU.WriteCmd(FPU#_RADIANS)
FPU.WriteCmdByte(FPU#_SELECTA, _TALT)
FPU.WriteCmdFloat(FPU#_FWRITEA, alt)

'Calculate ECEF coordinates
FPU.WriteCmdByte(FPU#_FCALL, _CT_WGS84_2_ECEF)
FPU.Wait

'Read back ECEF data
FPU.WriteCmdByte(FPU#_SELECTA, _ECEF_X)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)      
FPU.WriteCmdByte(FPU#_SELECTA, _ECEF_Y)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
FPU.WriteCmdByte(FPU#_SELECTA, _ECEF_Z)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
DBG.Tx(13)

'Backtransform
FPU.WriteCmdByte(FPU#_FCALL, _CT_ECEF_2_WGS84)
FPU.Wait
      
'Read back ECEF data
FPU.WriteCmdByte(FPU#_SELECTA, _TLAT)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)      
FPU.WriteCmdByte(FPU#_SELECTA, _TLON)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
FPU.WriteCmdByte(FPU#_SELECTA, _TALT)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
DBG.Tx(13)

'Zero altidude somewhere
lat := 45.0
lon := -45.0
alt := 0.0

'Load TLAT, TLON, TALT
'Write geographic coordinates with deg to rad conversion
FPU.WriteCmdByte(FPU#_SELECTA, _TLAT)
FPU.WriteCmdFloat(FPU#_FWRITEA, lat)
FPU.WriteCmd(FPU#_RADIANS)
FPU.WriteCmdByte(FPU#_SELECTA, _TLON)
FPU.WriteCmdFloat(FPU#_FWRITEA, lon)
FPU.WriteCmd(FPU#_RADIANS)
FPU.WriteCmdByte(FPU#_SELECTA, _TALT)
FPU.WriteCmdFloat(FPU#_FWRITEA, alt)

'Calculate ECEF coordinates
FPU.WriteCmdByte(FPU#_FCALL, _CT_WGS84_2_ECEF)
FPU.Wait

'Read back ECEF data
FPU.WriteCmdByte(FPU#_SELECTA, _ECEF_X)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)      
FPU.WriteCmdByte(FPU#_SELECTA, _ECEF_Y)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
FPU.WriteCmdByte(FPU#_SELECTA, _ECEF_Z)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
DBG.Tx(13)

'Backtransform
FPU.WriteCmdByte(FPU#_FCALL, _CT_ECEF_2_WGS84)
FPU.Wait
     
'Read back ECEF data
FPU.WriteCmdByte(FPU#_SELECTA, _TLAT)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)      
FPU.WriteCmdByte(FPU#_SELECTA, _TLON)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
FPU.WriteCmdByte(FPU#_SELECTA, _TALT)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
DBG.Tx(13)

'Deep in the ocean case
lat := -45.0
lon := -90.0
alt := -10000.0

'Load TLAT, TLON, TALT
'Write geographic coordinates with deg to rad conversion
FPU.WriteCmdByte(FPU#_SELECTA, _TLAT)
FPU.WriteCmdFloat(FPU#_FWRITEA, lat)
FPU.WriteCmd(FPU#_RADIANS)
FPU.WriteCmdByte(FPU#_SELECTA, _TLON)
FPU.WriteCmdFloat(FPU#_FWRITEA, lon)
FPU.WriteCmd(FPU#_RADIANS)
FPU.WriteCmdByte(FPU#_SELECTA, _TALT)
FPU.WriteCmdFloat(FPU#_FWRITEA, alt)

'Calculate ECEF coordinates
FPU.WriteCmdByte(FPU#_FCALL, _CT_WGS84_2_ECEF)

'Read back ECEF data
FPU.WriteCmdByte(FPU#_SELECTA, _ECEF_X)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)      
FPU.WriteCmdByte(FPU#_SELECTA, _ECEF_Y)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
FPU.WriteCmdByte(FPU#_SELECTA, _ECEF_Z)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
DBG.Tx(13)

'Backtransform
FPU.WriteCmdByte(FPU#_FCALL, _CT_ECEF_2_WGS84)
FPU.Wait
     
'Read back ECEF data
FPU.WriteCmdByte(FPU#_SELECTA, _TLAT)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)      
FPU.WriteCmdByte(FPU#_SELECTA, _TLON)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
FPU.WriteCmdByte(FPU#_SELECTA, _TALT)
DBG.Str(FPU.ReadRaFloatAsStr(0))
DBG.Tx(13)
DBG.Tx(13)
'-------------------------------------------------------------------------
          

DAT '---------------------------MIT License------------------------------- 


{{
┌────────────────────────────────────────────────────────────────────────┐
│                        TERMS OF USE: MIT License                       │                                                            
├────────────────────────────────────────────────────────────────────────┤
│  Permission is hereby granted, free of charge, to any person obtaining │
│ a copy of this software and associated documentation files (the        │ 
│ "Software"), to deal in the Software without restriction, including    │
│ without limitation the rights to use, copy, modify, merge, publish,    │
│ distribute, sublicense, and/or sell copies of the Software, and to     │
│ permit persons to whom the Software is furnished to do so, subject to  │
│ the following conditions:                                              │
│                                                                        │
│  The above copyright notice and this permission notice shall be        │
│ included in all copies or substantial portions of the Software.        │  
│                                                                        │
│  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND        │
│ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     │
│ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. │
│ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   │
│ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   │
│ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      │
│ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 │
└────────────────────────────────────────────────────────────────────────┘
}}