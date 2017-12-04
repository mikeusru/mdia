Multiclamp 700B Telegraph Client or Multiclamp Messenger Version 2
***************************************************************************************************************
Emiliano Rial Verde, Ph.D.
emiliano@rialverde.com
November-December 2005

Based on: MultiClamp TeleCLient example included with the MultiClamp 700B. This gets installed with the
MultiClamp Commander in C:\Program Files\MultiClamp 700B Commander\3rd Party Support\Telegraph_SDK\MCTeleClient


***************************************************************************************************************
Function:

The Multiclamp Telegraph Client updates a .txt file every time changes are made in the Multiclamp Commander.
The .txt files are, one for each channel of each amplifier, named with the serial number of the amplifier
followed by and underscore and the channel number.
These files are stored in C:\Program Files\acq\amps\


***************************************************************************************************************
Installation:

1) Copy the required .dll files into C:\Windows\system32\ (mfc42d.dll, msvcrtd.dll, msvcirt, and msvcirtd.dll).

2) Create the folders C:\Program Files\acq\ and C:\Program Files\acq\amps\

3) Copy MCTeleClient.exe and MCTeleClient_ERV_readme.txt in C:\Program Files\acq\

4) Copy 00000000_1.txt and 00000000_2.txt in C:\Program Files\acq\amps\ (These files will be used in Demo mode)


***************************************************************************************************************
Use:

Open as many instances of the Multiclamp Messenger Version 2 as amplifiers connected to the computer.
One instance of the program per amplifier!

The first amplifier is selected by default.

If more than one amplifier is connected, disconnect from the first amplifier in one of the instances of the
Multiclamp Messenger Version 2, and select the appropriate serial number of the other amplifier from the 
popup menu.

The program can be minimized and it will update the .txt files every time the user changes a telegraphed setting
in the popup menu.

The .txt files can be read from Matlab or other application to monitor the status of the telegraphed settings.


***************************************************************************************************************
Information Telegraphed:

Serial_Number
Channel_ID (1 or 2)
Mode (V-Clamp or I-Clamp)
Primary_Scale_Factor
Primary_Scale_Factor_Units
Primary_Gain
Secondary_Scale_Factor
Secondary_Scale_Factor_Units
Secondary_Gain
External_Cmd_Sens


Scale factor units number meaning:
VOLTS_PER_VOLT      = 0;
VOLTS_PER_MILLIVOLT = 1;
VOLTS_PER_MICROVOLT = 2;
UNITS_VOLTS_PER_AMP = 3;
VOLTS_PER_MILLIAMP  = 4;
VOLTS_PER_MICROAMP  = 5;
VOLTS_PER_NANOAMP   = 6;
VOLTS_PER_PICOAMP   = 7;
NONE                = 8;


***************************************************************************************************************
More information:

Look in these folders:
C:\Program Files\MultiClamp 700B Commander\3rd Party Support\Telegraph_SDK\MultiClampBroadcastMsg.hpp
C:\Program Files\MultiClamp 700B Commander\3rd Party Support\Telegraph_SDK\MCTeleClient

Locate and review the following files:
MultiClampBroadcastMsg.hpp
MCTG_Spec.pdf

E-mail me:
emiliano@rialverde.com