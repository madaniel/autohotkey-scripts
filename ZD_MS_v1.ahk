#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

/*
#########################################################################

						Zero Driver	Automation tests				
						***Mass Storage Version***
					
							Preconditions:
					zd_console enabled , Autorun enabled

							Features supported: 
		Connect, Disconnect, Connection verification, Download, Eject

								In Addition:
		Timers dynamically set, LAN Cable detection, zd_core detection

#########################################################################
*/


InputBox, cycles , ZeroDriver Auto Test Cycle, How many cycles ? , , , , , , , 60, 1
if ErrorLevel
	exit
InputBox, drive , ZeroDriver Auto Test Cycle, ZeroDriver CD-ROM Drive letter ? , , , , , , , 60, E
if ErrorLevel
	exit

;Global Variables
timeout = 30000
path = %drive%:\dat
zd_console_window = %drive% ahk_class ConsoleWindowClass
conn_port = 3
diag_port = 2

;Clear old sessions
TrayTip , Note, Please close zd_core.exe gracefully (quit), 3, 2	
Process, WaitClose, zd_core.exe
Run, %path%\zd_console.exe		
WinWait, %zd_console_window%

;-------------------------------Main----------------------------------

;Check if LAN cable is connected
VerifyLAN()

;Enable RSSI
PortTest()

loop, %cycles%
{
	TrayTip , Status, Starting cycle %A_index% , 3, 1	
	
	; Test 1: Connect & disconnect gracefully
	TrayTip , Status, Test 1 , 2, 1
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 1 started loop %A_index% `n , connection.log	
	Connect()
	Check()
	
	If InternetCheckConnection()
		Disconnect()
	
	; Test 2: Eject gracefully and re-connect & disconnect
	TrayTip , Status, Test 2 , 2, 1
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 2 started loop %A_index% `n , connection.log	
	
	Eject(1)	
	Connect()
	Check()
	
	If InternetCheckConnection()
		Disconnect()
	
	; Test 3: Abort connection
	TrayTip , Status, Test 3 , 2, 1
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 3 started loop %A_index% `n , connection.log	
	Connect()
	sleep 1500
	If NOT InternetCheckConnection()
		{
		Disconnect()
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Connection aborted loop %A_index% `n , connection.log	
		}
		
}

WinSet, AlwaysOnTop, off , %zd_console_window%
Msgbox, Test Cycle Completed !
;------------------------------------------------------------------------

exit


;functions

VerifyLAN()
{	
	While InternetCheckConnection()
	{
	TrayTip , Note, Unplug LAN cable ! , 5, 2
	sleep 5000
	}	

}

PortTest()
{
	global path
	global diag_port
	global zd_console_window
	
	TrayTip , Status, Setting RSSI , 2, 1		
	
	WinWait, %zd_console_window%		
	WinActivate, %zd_console_window%
	
	WinSet, AlwaysOnTop, on , %zd_console_window%
	Random, rand , 2000, 3000
    sleep, %rand%
	Send, s
	Random, rand , 3000, 4000
    sleep, %rand%
	Send, r
	Random, rand , 2000, 3000
    sleep, %rand%
	Send, %diag_port%
	Send, {Enter}
	Random, rand , 4000, 5000
    sleep, %rand%
	Send, q
	Random, rand , 1000, 2000
    sleep, %rand%
	
	return
	
}


Eject(graceful)
{
	;Variables
	global drive
	global path
	global zd_console_window
	
	if (graceful)
		{
		WinWait, %zd_console_window%
		WinActivate, %zd_console_window%	
		Send, q
		Random, rand , 1000, 1500 
		sleep, %rand%
		Process, Exist, zd_core.exe ;check if quit procedure completed
		if (errorlevel)
			Send, q
		Process, WaitClose, zd_core.exe
		}
		
	Drive, eject, %drive%:
	
	TrayTip , Status, Waiting for zd_console ... , 2, 1
	WinWait, %zd_console_window%
	WinActivate, %zd_console_window%
		
	;Wait for menu to be ready
	TrayTip , Status, Waiting for menu ... , 2, 1
	Random, rand , 7000, 9000
    sleep, %rand%	
	return	
}


Connect()
{
	global path
	global conn_port
	global zd_console_window

	WinWait, %zd_console_window%
	WinActivate, %zd_console_window%
		
	WinSet, AlwaysOnTop, on , %zd_console_window%
	Send, s
	Random, rand , 3000, 5000
    sleep, %rand%
    Send, c
    Random, rand , 1000, 1500
    sleep, %rand%
	send, %conn_port%
    Send, {Enter}
	Random, rand , 1000, 1500
    sleep, %rand%
	Send, {Enter} 
	Random, rand , 200, 500
    sleep, %rand%
	Send, {Enter}
    Random, rand , 200, 500
    sleep, %rand%
    Send, internet
    Random, rand , 3000, 4000
    sleep, %rand%
    Send, {Enter}
		
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Connection started `n , connection.log	
	
	return
}


Check()
{
	;Variables	
	global path	
	global timeout	
	global zd_console_window
				
	;Waiting for timeout
	TrayTip , Status, Connecting ... , %timeout%, 1
		
	startTime:=A_TickCount	
	current:=A_TickCount
	
	;While for connection procedure
	while (startTime + timeout > current)
	{	
		If InternetCheckConnection()
			{
			elapsedTime:=Round((A_TickCount-startTime)/1000)
			sec:=Mod(elapsedTime,60)
			min:=Round(elapsedTime/60)
			
			;Connection success
			TrayTip , Status, Connection success , 2, 1						
			FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Connection established %min% Minutes and %sec% Seconds `n , connection.log
			
			;Start Downloading
			If DownloadFile()
				{
				FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - File download completed `n , connection.log
				TrayTip , Status, Download completed , 2, 1							
				}
			else
				{
				FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Download failed !`n , connection.log
				TrayTip , Error, Download failed , 2, 2							
				}
				
			return
			}
		;Still in connection procedure	
		else
			{
			current:=A_TickCount
			Random, rand , 1500, 3000			
			sleep, %rand%
			}
	}			
	;End of while
	
	;Timeout expired - Connection is failed
	TrayTip , Error, Connection failed , 2, 2
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Connection Failed !`n , connection.log

	;Take Screenshot
	WinWait, %zd_console_window%
	WinActivate, %zd_console_window%
	
	if ErrorLevel
		{
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Failed to take Screen Shot !`n , connection.log
		return
		}
		
	Send, {PrintScreen}
	Run, mspaint	
	WinWait, ahk_class MSPaintApp,,5
	WinActivate, ahk_class MSPaintApp
	WinSet, AlwaysOnTop, on ,ahk_class MSPaintApp	
	Send, {Ctrl Down}v{Ctrl Up}
	Sleep, 1000
	Send, {AltDown}f
	Sleep, 1000
	Send, {AltUp}a
	Sleep, 1000
	Send, %A_DD%-%A_MM%-%A_Hour%-%A_Min%-%A_Sec%
	Sleep, 1000
	Send, {Tab}
	Sleep, 1000
	Send, {Down}
	Sleep, 1000
	Send, {Down}
	Sleep, 1000
	Send, {Down}
	Sleep, 1000
	Send, {Down}
	Sleep, 1000
	Send, {Down}
	Sleep, 1000
	Send, {Tab}
	Sleep, 1000
	Send, {Enter}
	Sleep, 1000
	Send, {AltDown}f{AltUp}xn
	Sleep, 1000	
    
	;Return to Main menu
	WinWait, %zd_console_window%
	WinActivate, %zd_console_window%
	
	sleep 1000
	Send, q
	sleep 1000
	return
} 


Disconnect()
{
	global path
	global zd_console_window
	
	WinWait, %zd_console_window%
	WinActivate, %zd_console_window%
	
    Send, d ; Disconnect
    Random, rand , 2000, 5000
    sleep, %rand%
    Send, q ; Back to Main menu
    Random, rand , 1000, 3000
    sleep, %rand%	
	TrayTip , Status, ZD Disconnected , 2, 1	
	
	return
}


InternetCheckConnection(flag=0x40) 
{ 
Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", flag,"Int",0) 
}

;Download a file and count downloading time in seconds
DownloadFile()
{
	file=%A_DD%-%A_MM%-%A_Hour%-%A_Min%-%A_Sec%		
	
	startTime:=A_TickCount
	
	;Try Download 1 Mega file
	UrlDownloadToFile, http://www2.jungo.com/~danielm/test20.txt, %A_MyDocuments%\%file%.txt
	time:=Round((A_TickCount-startTime)/1000)
	sec:=Mod(time,60)
	min:=Round(time/60)
	
	;Download successful
	IfExist, %A_MyDocuments%\%file%.txt
		{
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Download completed in %min% Minutes and %sec% Seconds `n , connection.log
		FileDelete, %A_MyDocuments%\%file%.txt 	
		return 1
		}
	
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Download retry `n , connection.log	
	
	;Try Download 256 K file
	startTime:=A_TickCount	
	UrlDownloadToFile, http://www.autohotkey.com/download/CurrentVersion.txt, %A_MyDocuments%\%file%.txt	
	time:=Round((A_TickCount-startTime)/1000)
	sec:=Mod(time,60)
	min:=Round(time/60)
	
	;Download successfull
	IfExist, %A_MyDocuments%\%file%.txt	
		{
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Download completed in %min% Minutes and %sec% Seconds sec `n , connection.log	
		return 1
		}
	
	;Download failed	
	return 0
}
