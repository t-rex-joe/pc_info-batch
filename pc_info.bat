@echo off


rem PC_INFO.bat
rem Used to retrieve machine info upon logon and onstart
rem 
rem 
rem 
rem 
rem -- Create the scheduled tasks 
rem xcopy /y *.* c:\nec\pc_info\
rem schtasks /create /tn "upload_info-start" /tr c:\nec\pc_info\pc_info.bat /sc onstart /ru "System"
rem schtasks /create /tn "upload_info-logon" /tr c:\nec\pc_info\pc_info.bat /sc onlogon /ru "System"
rem 
rem -- Delete The Tasks if needed
rem schtasks /delete /tn "upload_info-start" /f
rem schtasks /delete /tn "upload_info-logon" /f
rem 
rem History
rem 
rem 2015-06-16@0800
rem Born
rem 
rem 2015-06-16@1100
rem Added logic for 32bit and 64bit tftp files
rem 
rem 2015-06-16@1200
rem Changed from "ipconfig /all" to "wmic path win32_NetworkAdapterConfiguration where index='7'" for ip and mac get
rem 
rem 2015-06-16@1300
rem Added User and Boot time
rem 
rem 2015-06-17@0800
rem Added History Pole
rem 
rem 2015-06-17@0830
rem Changed timeout from 1 to 30
rem 
rem 2015-06-17@0904
rem changed variables to %logpath% 
rem Set all variables to unknown
rem removed :end
rem moved all set variables to top of script
rem Changed from logoff to logon
rem enabled scheduled task	
rem created SCCM deployment
rem 
rem 2015-06-17@1440
rem Added "pcname" to set variables
rem Fixed Whitespace on outputing to file
rem Added Debug incase ipconfig/mac was unknown upon printing
rem 
rem 2015-06-17@1500
rem Changed Time to wmic time
rem 
rem 2015-06-17@1520
rem Changed IF statement for unknown in IP AND MAC
rem 
rem 2015-06-23@0815
rem Changed get ip statement
rem Added Version/date/name
rem 
rem 2015-12-10@1300
rem Added UUID
rem 
rem 2015-12-10@1430
rem Fixed Bug in IPv6 IP Addresses being returned from wmic
rem 
rem 2015-12-10@0915 -> v1.2.0
rem Fixed Bug in equ unknown if ip or mac was unknown
rem Added debug output for items being unknown
rem Added Rand sleep before running
rem 
rem 2015-12-10@1020 -> v1.2.1
rem Fixed Random with new logic
rem 
rem 2017-05-21@1800 -> v1.3.0
rem Released to GitHub
rem 


rem Get a number between 30 and 90
set /a rand=%random% * (90 - 30 + 1) / 32768 + 30
rem echo %rand%
rem Random Sleep seconds before running
ping 127.0.0.1 -n %rand% -w 1000 > NUL

set logfilepath=c:\temp\pc_info\

if not exist %logfilepath% (mkdir %logfilepath%)

set IP=unknown
set MAC=unknown
set ARCH=unknown
set USER=unknown
set BOOT=unknown
set pcname=unknown
set UUID=unknown



for /f "tokens=1 delims=." %%a in ('"wmic os get LocalDateTime | find ".""') do set LDT=%%a

for /f "tokens=2,3,4 delims=/ " %%f in ('date /t') do set d=%%h-%%f-%%g

for /f "tokens=1,2,3 delims=: " %%f in ('time /t') do set t=%%f-%%g-00

rem for /f "tokens=* delims=:(" %%a in ('"wmic NICCONFIG WHERE IPEnabled=true GET IPAddress | find /i ".""') do set IP=%%a
rem for /f "tokens=1,2,3 delims=,(" %%a in ('"wmic NICCONFIG WHERE IPEnabled=true GET IPAddress | find /i ".""') do set IP=%%a
for /f "tokens=1-5 delims=:{}," %%a in ('"wmic nicconfig where IPEnabled=True get ipaddress | find /i ".""') do set IP=%%a

for /f "tokens=* delims=:(" %%a in ('"wmic NICCONFIG WHERE IPEnabled=true get MACAddress | find /i ":""') do set MAC=%%a

for /f "tokens=* delims=:(" %%a in ('"wmic path Win32_OperatingSystem get OSArchitecture | find /i "bit""') do set ARCH=%%a

for /f "tokens=* delims=:(" %%a in ('"wmic path Win32_ComputerSystem get Username | find "\""') do set USER=%%a

for /f "tokens=* delims=:(" %%a in ('"wmic path Win32_OperatingSystem get LastBootUpTime | find ".""') do set BOOT=%%a

for /f "tokens=* delims=:(" %%a in ('hostname') do set pcname=%%a

for /f "tokens=* delims=:(" %%a in ('"wmic path win32_computersystemproduct get UUID | find "-""') do set UUID=%%a





rem print out
echo pc_info > "%logfilepath%%pcname%-%LDT%-pc_info.txt"

echo version: 1.3.0 >> "%logfilepath%%pcname%-%LDT%-pc_info.txt"

echo date: 2017-05-21 >> "%logfilepath%%pcname%-%LDT%-pc_info.txt"

echo name: %pcname%  >> "%logfilepath%%pcname%-%LDT%-pc_info.txt"

echo ip: %IP% >> "%logfilepath%%pcname%-%LDT%-pc_info.txt"

echo mac: %MAC% >> "%logfilepath%%pcname%-%LDT%-pc_info.txt"

echo start_time: %LDT% >> "%logfilepath%%pcname%-%LDT%-pc_info.txt"

echo arch: %ARCH% >> %logfilepath%%pcname%-%LDT%-pc_info.txt"

echo boot: %BOOT% >> %logfilepath%%pcname%-%LDT%-pc_info.txt"

echo user: %USER% >> %logfilepath%%pcname%-%LDT%-pc_info.txt"

echo uuid: %UUID% >> %logfilepath%%pcname%-%LDT%-pc_info.txt"



set getdebug=0
if %IP% equ unknown set getdebug=1
if %MAC% equ unknown set getdebug=1
if %pcname% equ unknown set getdebug=1

if %getdebug% equ 1 (
echo 
echo 'debug enabled printing all computer info' >> %logfilepath%%pcname%-%LDT%-pc_info.txt
rem wmic path win32_NetworkAdapterConfiguration get /format:Textvaluelist >> %logfilepath%%pcname%-%LDT%-pc_info.txt
wmic nicconfig where IPEnabled=True get /format:Textvaluelist >> %logfilepath%%pcname%-%LDT%-pc_info.txt
ipconfig /all >> %logfilepath%%pcname%-%LDT%-pc_info.txt
wmic os get /format:Textvaluelist >> %logfilepath%%pcname%-%LDT%-pc_info.txt
wmic csproduct get /format:Textvaluelist >> %logfilepath%%pcname%-%LDT%-pc_info.txt
wmic computersystem get /format:Textvaluelist | find /v "OEMLogoBitmap" >> %logfilepath%%pcname%-%LDT%-pc_info.txt
)





find "32" %logfilepath%%pcname%-%LDT%-pc_info.txt >nul
if %errorlevel% equ 0 goto 32bit

find "64" %logfilepath%%pcname%-%LDT%-pc_info.txt >nul
if %errorlevel% equ 0 goto 64bit

rem tftp to server

:32bit
rem echo FOUND 32BIT echo arch: %ARCH%
"%~dp0tftp32.exe" -i <tftp_server_ip> PUT "%logfilepath%%pcname%-%LDT%-pc_info.txt" /pc_info/"%pcname%-%LDT%-pc_info.txt" >nul
goto done

:64bit
rem echo FOUND 64BIT echo arch: %ARCH%
"%~dp0tftp64.exe" -i <tftp_server_ip> PUT "%logfilepath%%pcname%-%LDT%-pc_info.txt" /pc_info/"%pcname%-%LDT%-pc_info.txt" >nul
goto done


rem DUMP ALL IPCONFIG INFORMATION


:done




