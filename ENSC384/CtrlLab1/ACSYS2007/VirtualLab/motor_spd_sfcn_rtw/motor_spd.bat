set MSVCDir=c:\program files\microsoft visual studio\vc98
set MSDevDir=c:\program files\microsoft visual studio\common\msdev98
C:\MATLAB6P1\rtw\bin\win32\envcheck INCLUDE "c:\program files\microsoft visual studio\vc98\include"
if errorlevel 1 goto vcvars32
C:\MATLAB6P1\rtw\bin\win32\envcheck PATH "c:\program files\microsoft visual studio\vc98\bin"
if errorlevel 1 goto vcvars32
C:\MATLAB6P1\rtw\bin\win32\envcheck PATH "c:\program files\microsoft visual studio\common\msdev98\bin"
if errorlevel 1 goto vcvars32
goto make
:vcvars32
set VSCommonDir=c:\program files\microsoft visual studio\common
call "C:\MATLAB6P1\toolbox\rtw\rtw\private\vcvars32_600.bat"
:make
nmake -f motor_spd.mk  VISUAL_VER=6.0
