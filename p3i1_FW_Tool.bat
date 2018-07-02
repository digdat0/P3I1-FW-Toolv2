REM *second* version of a batch file to simplify the P3/I1 FW process
REM Created June 29, 2018 by digdat0
REM I'm not a programmer guys
REM Credits to mefistotelis for the awesome p3 tools
REM Credit to binary, i borrowed some stuff from your apk batch files
REM Credit to java dudes, I'll add a GPL or needed license to use download.jar
REM Thanks to DJI for pushing content on GitHub
REM
ECHO OFF
CLS
SETLOCAL DisableDelayedExpansion
if not exist tools mkdir tools
java -version >nul 2>&1 && ( GOTO:MAIN
 ) || ( call )
javac -version >nul 2>&1 && ( GOTO:MAIN
 ) || ( echo.-: Java not installed...
  pause
 exit )
:MAIN
SET APPVER=2.0
SET ORIGDATE=June 29, 2018
SET SAVEDATE=%DATE%
@ECHO OFF
CLS
ECHO.
ECHO ------------------------------------------------------------------------
ECHO  Phantom 3 and Inspire 1 Firmware Mod Tool %APPVER% by digdat0
ECHO ------------------------------------------------------------------------
ECHO  The tool will assist in the P3/I1 modding process. It reads the current 
ECHO  folder looking for .BIN files. If it finds any, it will display a list. 
ECHO  You can then pick the firmware from this list. 
ECHO.
ECHO  After selecting, it will extract the firmware and start the process.
ECHO ------------------------------------------------------------------------
ECHO.
SET index=1
SETLOCAL ENABLEDELAYEDEXPANSION
FOR %%f IN (*.BIN) DO (
   SET file!index!=%%f
   ECHO   !index! - %%f
   SET /A index=!index!+1
)
SETLOCAL DISABLEDELAYEDEXPANSION
ECHO.
SET /P selection="Select the firmware file: "
SET file%selection% >nul 2>&1
IF ERRORLEVEL 1 (
   ECHO.
   ECHO Invalid number selected
   TIMEOUT 2   
   GOTO MAIN
)
CALL :RESOLVE %%file%selection%%%
ECHO Selected file name: %filename%
copy %filename% tools
GOTO MAIN2
:RESOLVE
SET filename=%1
GOTO :EOF
:MAIN2
for /f "tokens=1-3* delims=_" %%A in ('dir /b /a-d "%filename%"') do (
  set filenamespec=%%~A_%%~B_%%~C
  set actype=%%~A
  set fwtype=%%~B
  set acversion=%%~C
)
REM CALL :FILECHECK
CLS
ECHO.
ECHO ------------------------------------------------------------------------
ECHO  Phantom 3 and Inspire 1 Firmware Mod Tool %APPVER% by digdat0
ECHO ------------------------------------------------------------------------
ECHO. 
ECHO  You have selected the following firmware, please confirm.
ECHO.
ECHO ------------------------------------------------------------------------
ECHO.
ECHO   Firmware Filename    : %filename%
ECHO   Aircraft Type        : %actype%
ECHO   Firmware Version     : %acversion%
ECHO.
SET /P M=Is this information right? Y/N: 
IF %M%==Y GOTO MAIN3
IF %M%==y GOTO MAIN3
IF %M%==N GOTO MAIN
IF %M%==n GOTO MAIN
IF %M%==Q GOTO EOF
IF %M%==q GOTO EOF
:MAIN3
@ECHO OFF
python --version 2>NUL
if errorlevel 1 goto NOPY
GOTO DLXV4
:NOPY
CLS
echo.
echo You don't have Python installed. Goto python.org
TIMEOUT 2 >nul
GOTO MAIN
:DLXV4
IF EXIST "tools\dji_xv4_fwcon.py" (
GOTO PARAMED
) ELSE (
ECHO.
ECHO Downloading Python firmware tool, please wait .. 
ECHO.
java -jar download.jar https://github.com/o-gs/dji-firmware-tools/raw/master/dji_xv4_fwcon.py dji_xv4_fwcon.py
)
GOTO PARAMED
:PARAMED
IF EXIST "tools\dji_flyc_param_ed.py" (
GOTO EXTRACTFC
) ELSE (
ECHO.
ECHO Downloading Python firmware tool, please wait .. 
ECHO.
java -jar download.jar https://github.com/o-gs/dji-firmware-tools/raw/master/dji_flyc_param_ed.py dji_flyc_param_ed.py
)
GOTO EXTRACTFC
:EXTRACTFC
cd tools
md fwextract
md final_firmware_files
copy *.py fwextract
copy %filename% fwextract
cd fwextract
CLS
ECHO.
ECHO ------------------------------------------------------------------------
ECHO  Phantom 3 and Inspire 1 Firmware Mod Tool %APPVER% by digdat0
ECHO ------------------------------------------------------------------------
ECHO. 
ECHO  Lets extract the firmware file
ECHO.  
ECHO ------------------------------------------------------------------------
ECHO.
python dji_xv4_fwcon.py -vv -x -p %filename%
CLS
ECHO.
ECHO ------------------------------------------------------------------------
ECHO  Phantom 3 and Inspire 1 Firmware Mod Tool %APPVER% by digdat0
ECHO ------------------------------------------------------------------------
ECHO. 
ECHO  Lets confirm the flight controller module
ECHO.  
ECHO ------------------------------------------------------------------------
ECHO.
REM how to get 306 module filename
SET index=1
SETLOCAL ENABLEDELAYEDEXPANSION
FOR %%f IN (*m0306.bin) DO (
   SET file!index!=%%f
   ECHO   !index! : %%f
   SET /A index=!index!+1
)
SETLOCAL DISABLEDELAYEDEXPANSION
ECHO.
SET /P selection="Select the flight controller module: "
SET file%selection% >nul 2>&1
IF ERRORLEVEL 1 (
   ECHO.
   ECHO Invalid number selected
   TIMEOUT 2   
   GOTO MAIN
)
CALL :RESOLVE2 %%file%selection%%%
cd ..
GOTO MAIN4
:RESOLVE2
SET filename2=%1
GOTO :EOF
:MAIN4
cd fwextract
CLS
ECHO.
ECHO ------------------------------------------------------------------------
ECHO  Phantom 3 and Inspire 1 Firmware Mod Tool %APPVER% by digdat0
ECHO.
ECHO   Firmware Filename    : %filename%
ECHO   Aircraft Type        : %actype%
ECHO   Firmware Version     : %acversion%
ECHO ------------------------------------------------------------------------
ECHO. 
ECHO  Lets extract the flight controller module
ECHO.  
ECHO ------------------------------------------------------------------------
ECHO.
python dji_flyc_param_ed.py -vv -x -m %FILENAME2%
CLS
ECHO.
ECHO ------------------------------------------------------------------------
ECHO  Phantom 3 and Inspire 1 Firmware Mod Tool %APPVER% by 
ECHO.
ECHO   Firmware Filename    : %filename%
ECHO   Aircraft Type        : %actype%
ECHO   Firmware Version     : %acversion%
ECHO ------------------------------------------------------------------------
ECHO.
ECHO  Lets backup a copy of the parameters
ECHO.
ECHO ------------------------------------------------------------------------
ECHO.
copy flyc_param_infos ..\flyc_param_infos_STOCK_%acversion%.txt
cd ..
copy flyc_param_infos_STOCK_%acversion%.txt final_firmware_files
del flyc_param_infos_STOCK_%acversion%.txt
cd fwextract
CLS
ECHO.
ECHO ------------------------------------------------------------------------
ECHO  Phantom 3 and Inspire 1 Firmware Mod Tool %APPVER% by digdat0
ECHO.
ECHO   Firmware Filename    : %filename%
ECHO   Aircraft Type        : %actype%
ECHO   Firmware Version     : %acversion%
ECHO ------------------------------------------------------------------------
ECHO. 
ECHO  Lets edit the flight controller module parameters. After you save
ECHO  it will come back to this tool and finish things.
ECHO ------------------------------------------------------------------------
ECHO.
notepad.exe flyc_param_infos
CLS
ECHO.
ECHO ------------------------------------------------------------------------
ECHO  Phantom 3 and Inspire 1 Firmware Mod Tool %APPVER% by 
ECHO.
ECHO   Firmware Filename    : %filename%
ECHO   Aircraft Type        : %actype%
ECHO   Firmware Version     : %acversion%
ECHO ------------------------------------------------------------------------
ECHO. 
ECHO  Lets re-compile the flight controller module
ECHO.  
ECHO ------------------------------------------------------------------------
ECHO.
python dji_flyc_param_ed.py -vv -u -m %FILENAME2%
copy flyc_param_infos ..\flyc_param_infos_MODDED_%acversion%.txt
copy %FILENAME2% ..
cd ..
REN %FILENAME2% %FILENAME2%_MODDED
copy %FILENAME2%_MODDED final_firmware_files
copy flyc_param_infos_MODDED_%acversion%.txt final_firmware_files
del flyc_param_infos_MODDED_%acversion%.txt
del %FILENAME2%_MODDED
cd fwextract
CLS
ECHO.
ECHO ------------------------------------------------------------------------
ECHO  Phantom 3 and Inspire 1 Firmware Mod Tool %APPVER% by digdat0
ECHO.
ECHO   Firmware Filename    : %filename%
ECHO   Aircraft Type        : %actype%
ECHO   Firmware Version     : %acversion%
ECHO ------------------------------------------------------------------------
ECHO. 
ECHO  Lets clean-up the files
ECHO.  
ECHO ------------------------------------------------------------------------
ECHO.
cd ..
GOTO MAIN5
:MAIN5
CLS
ECHO.
ECHO ------------------------------------------------------------------------
ECHO  Phantom 3 and Inspire 1 Firmware Mod Tool %APPVER% by digdat0
ECHO.
ECHO   Firmware Filename    : %filename%
ECHO   Aircraft Type        : %actype%
ECHO   Firmware Version     : %acversion%
ECHO ------------------------------------------------------------------------
ECHO. 
ECHO  You are done. The modded flight controller file was copied to the final
ECHO  firmware folder. Make sure to rename it before installing.
ECHO.
ECHO  Do you want to re-compile the WHOLE firmware file? (Not required)
ECHO ------------------------------------------------------------------------
ECHO.
SET /P M=   Yes or No? Y/N: 
IF %M%==Y GOTO T1
IF %M%==y GOTO T1
IF %M%==N GOTO DONE
IF %M%==n GOTO DONE
IF %M%==Q GOTO EOF
IF %M%==q GOTO EOF
GOTO MAIN5
REM MAYBE USE LATER FOR MORE TOOL OPTIONS :MAIN6
CLS
ECHO.
ECHO ------------------------------------------------------------------------
ECHO  Phantom 3 and Inspire 1 Firmware Mod Tool %APPVER% by digdat0
ECHO.
ECHO   Firmware Filename    : %filename%
ECHO   Aircraft Type        : %actype%
ECHO   Firmware Version     : %acversion%
ECHO ------------------------------------------------------------------------
ECHO. 
ECHO You have edited the parameters, saved and re-compiled it. The file is in
ECHO the "final_firmware_files" folder.
ECHO. 
ECHO   1: Re-compile the entire firwmare file 
ECHO   2: Rename the flight controller module to service file name
ECHO   3: Make a debug file
ECHO   4: TBD
ECHO   Q: Quit
ECHO   M: Main Menu
ECHO.   
SET /P M=Please make a choice : 
IF %M%==1 GOTO T1
IF %M%==2 GOTO T2
IF %M%==3 GOTO T3
IF %M%==4 GOTO T4
IF %M%==Q GOTO EOF
IF %M%==q GOTO EOF
IF %M%==M GOTO MAIN
IF %M%==m GOTO MAIN
:T1
CLS
ECHO.
ECHO ------------------------------------------------------------------------
ECHO  Phantom 3 and Inspire 1 Firmware Mod Tool %APPVER% by digdat0
ECHO ------------------------------------------------------------------------
ECHO. 
ECHO  Lets re-compile the whole the firmware file
ECHO.  
ECHO ------------------------------------------------------------------------
ECHO.
ren %filename% %filename%_orig
cd fwextract
python dji_xv4_fwcon.py -vv -a -p %filename%
REN %filename% %filename%_MODDED
copy %filename%_MODDED ..
cd ..
copy %filename%_MODDED final_firmware_files
del %filename%_MODDED
ren %filename%_orig %filename%
GOTO DONE
:DONE
CLS
ECHO.
ECHO ------------------------------------------------------------------------
ECHO  Phantom 3 and Inspire 1 Firmware Mod Tool %APPVER% by digdat0
ECHO.
ECHO   Firmware Filename    : %filename%
ECHO   Aircraft Type        : %actype%
ECHO   Firmware Version     : %acversion%
ECHO ------------------------------------------------------------------------
ECHO. 
ECHO   You are all done with the process. Checkout http://dji.retroroms.info
ECHO   for more information or assistance in the process.
ECHO.
ECHO   We have copied all the files in the final_firmware_files folder
ECHO.
ECHO.  Donations can be sent to flyflydrones@gmail.com
ECHO.
ECHO  #credits
ECHO  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ECHO  credit to mefistotelis for the Phantom 3 Python tools
ECHO  credit to binary for download.jar and batch functions
ECHO  credit to cs2000 for file link hosting
ECHO  thanks to the community and the OG's
ECHO  thanks to DJI for using github properly
ECHO.
TIMEOUT 10 >nul
GOTO EOF
:EOF
cd tools
cd fwextract
del *.bin
del *.ini
del *.py
del flyc_param_infos
cd ..
rd fwextract
EXIT