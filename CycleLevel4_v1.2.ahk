#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;#############################################################
;
;				Zero Driver	Automation tests				
;
;						Preconditions:
; 			zd_console enabled , Autorun enabled
;
;					Features supported: 
;Connect, Disconnect, Connection verification, Download, Eject
;
;						In Addition:
;		Timers dynamically set, LAN Cable detection
;
;#############################################################

;Global Variables
timeout = 60000

InputBox, cycles , ZeroDriver Auto Test Cycle, How many cycles ? , , , , , , , 10, 1
if ErrorLevel
	exit
InputBox, drive , ZeroDriver Auto Test Cycle, ZeroDriver CD-ROM Drive letter ? , , , , , , , 10, E:
if ErrorLevel
	exit
InputBox, path , ZeroDriver Auto Test Cycle, zd_console.exe path ? , , , , , , , 10, C:\ProgramData\ZeroDriver\V1.7.22
if ErrorLevel
	exit

;Clear old sessions
IfWinExist, %path%\zd_console.exe
	{
    WinKill, %path%\zd_console.exe
	WinWaitClose, %path%\zd_console.exe
	}
	
Run, %path%\zd_console.exe		
WinWait, %path%\zd_console.exe

;-------------------------------Main----------------------------------

;Check if LAN cable is connected
VerifyLAN()

;Enable RSSI
PortTest()

loop, %cycles%
{
	GoSub SkipToHere	
	; Test 1: Connect & disconnect gracefully
	TrayTip , Status, Test 1 , 2, 1
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 1 started `n , connection.log	
	Connect()
	Check()
	
	If InternetCheckConnection("http://www.google.com")
	Disconnect()
	
	; Test 2: Eject gracefully and re-connect & disconnect
	TrayTip , Status, Test 2 , 3, 1
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 2 started `n , connection.log	
	Eject()	
	Connect()
	Check()
	
	If InternetCheckConnection("http://www.google.com")
	Disconnect()
	
	SkipToHere:
	; Test 3: Abort connection
	TrayTip , Status, Test 3 , 2, 1
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 3 started `n , connection.log	
	Connect()
	sleep 1500
	If NOT InternetCheckConnection("http://www.google.com")
		{
		Disconnect()
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Connection aborted `n , connection.log	
		}
		
	; Test 4: Abort download
	TrayTip , Status, Test 4 , 2, 1
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 4 started `n , connection.log
	Connect()	
	;Wait for connection
	If NOT InternetCheckConnection("http://www.google.com")
		{
			sleep 1000
		}	
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Connection aborted `n , connection.log	
	SetTimer, Disconnect, 2000,
	DownloadFile()
	pause
	
	; Test 5: Eject while connecting
	TrayTip , Status, Test 5 , 2, 1
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 5 started `n , connection.log	
	Connect()
	If NOT InternetCheckConnection("http://www.google.com")
		Drive, eject, %drive%
	pause	
	
	; Test 6: Eject after connection established
	TrayTip , Status, Test 6 , 2, 1
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 6 started `n , connection.log	
	Connect()
	Check()
	If InternetCheckConnection("http://www.google.com")
		Drive, eject, %drive%	
	pause	
	
	; Test 7: Eject while downloading
	TrayTip , Status, Test 7 , 2, 1
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 7 started `n , connection.log	
	Connect()
	Check()	
	SetTimer, Eject, 1500,
	DownloadFile()
	Eject:
	SetTimer, Eject, OFF,
	Drive, eject, %drive%
	pause
}

WinSet, AlwaysOnTop, off , %path%\zd_console.exe
Msgbox, Test Cycle Completed !


;------------------------------------------------------------------------

exit


;functions


VerifyLAN()
{	
	While InternetCheckConnection("http://www.google.com")
	{
	TrayTip , Note, Check LAN cable , 3, 2
	sleep 3000
	}	

}

PortTest()
{
	global path
	
	TrayTip , Status, Setting RSSI , 2, 1		
	
	WinWait, %path%\zd_console.exe, ,10
	
	if ErrorLevel
	   Run, %path%\zd_console.exe
	
	WinActivate, %path%\zd_console.exe
	
	WinSet, AlwaysOnTop, on , %path%\zd_console.exe
	Random, rand , 7000, 10000
    sleep, %rand%
	Send, s
	Random, rand , 5000, 7000
    sleep, %rand%
	Send, r
	Random, rand , 500, 1000
    sleep, %rand%
	Send, 3
	Random, rand , 500, 1000
    sleep, %rand%
	Send, {Enter}
	Random, rand , 500, 1000
    sleep, %rand%
	Send, q
	Random, rand , 500, 1000
    sleep, %rand%
	
	return
	
}

Eject()
{
	;Variables
	global drive
	global path
		
	WinWait, %path%\zd_console.exe, ,10
	WinActivate, %path%\zd_console.exe
	
	Send, q
	Random, rand , 3000, 6000
    sleep, %rand%	
	Drive, eject, %drive%
	
	TrayTip , Status, Waiting for Ejection to complete ... , 10, 1
		
	WinWait, %path%\zd_console.exe, ,30
	WinActivate, %path%\zd_console.exe
		
	IfWinNotExist, %path%\zd_console.exe
		{
			FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! zd_console failed loading after eject, re-running console !`n , connection.log	
			Run, %path%\zd_console.exe
			WinWait, %path%\zd_console.exe, ,10
			WinActivate, %path%\zd_console.exe
		}
	
	return
	
}


Connect()
{
	global path	
    
	TrayTip , Status, Waiting for zd_console ... , 2, 1	
		
	WinWait, %path%\zd_console.exe, ,10
	WinActivate, %path%\zd_console.exe
	
	if ErrorLevel
	{
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Failed to find zd_console in connect, retry !`n , connection.log	
    Run, %path%\zd_console.exe
	WinWait, %path%\zd_console.exe, ,10
	WinActivate, %path%\zd_console.exe	
	}
	
	WinSet, AlwaysOnTop, on , %path%\zd_console.exe
	Random, rand , 7000, 10000
    sleep, %rand%
	Send, s
	Random, rand , 5000, 7000
    sleep, %rand%
    Send, c
    Random, rand , 500, 1000
    sleep, %rand%
	send, 2
    Random, rand , 500, 1000
    sleep, %rand%
    Send, {Enter}
	Random, rand , 500, 1000
    sleep, %rand%
	Send, {Enter} 
	Random, rand , 500, 1000
    sleep, %rand%
	Send, {Enter}
    Random, rand , 500, 1000
    sleep, %rand%
    Send, internet
    Random, rand , 5000, 7000
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
	tmp=%timeout%
	start=0
	end=0
	total=0
	
	;Waiting for timeout
	TrayTip , Status, Connecting ... , %timeout%, 1
		
	start:=A_Min*60 + A_Sec
	
	;While for connection procedure
	while tmp > 0
	{	
		If InternetCheckConnection("http://www.google.com")
			{
			end:=A_Min*60 + A_Sec
			total:=end-start
			
			;Abort if connection is successful too fast ...
			If (total=0)
				{
				TrayTip , Error, Aborting - connected too fast , 3, 2
				FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Abort - connection time is not reasonable ! `n , connection.log
				sleep 3000
				exit					
				}			
			;Connection success
			TrayTip , Status, Connection success , 2, 1						
			FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Connection established `n , connection.log
			
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
			FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - timeout = %tmp% `n , connection.log
			Random, rand , 1000, 3000			
			tmp:=tmp-rand
			sleep, %rand%
			}
	}			
	;End of while
	
	;Timeout expired - Connection is failed
	TrayTip , Error, Connection failed , 2, 2
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Connection Failed !`n , connection.log

	;Take Screenshot
	WinWait, %path%\zd_console.exe, ,10
	WinActivate, %path%\zd_console.exe
	
	if ErrorLevel
		{
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Failed to take Screen Shot !`n , connection.log
		return
		}
		
	Send, {PrintScreen}
	Run, mspaint	
	WinWait, untitled - Paint, ,10
	WinActivate, untitled - Paint
	WinSet, AlwaysOnTop, on ,untitled - Paint	
	Send, {Ctrl Down}v{Ctrl Up}
	Sleep, 1000
	Send, {AltDown}f
	Sleep, 1000
	Send, {AltUp}a
	Sleep, 1000
	Send, %A_DD%-%A_MM%-%A_Hour%-%A_Min%-%A_Sec%
	Sleep, 500
	Send, {Tab}
	Sleep, 200
	Send, {Down}
	Sleep, 200
	Send, {Down}
	Sleep, 200
	Send, {Down}
	Sleep, 200
	Send, {Down}
	Sleep, 200
	Send, {Down}
	Sleep, 200
	Send, {Tab}
	Sleep, 200
	Send, {Enter}
	Sleep, 1000
	Send, {AltDown}f{AltUp}xn
	Sleep, 1000	
    
	;Return to Main menu
	WinWait, %path%\zd_console.exe, ,10
	WinActivate, %path%\zd_console.exe
	
	sleep 1000
	Send, q
	sleep 1000
	return
} 

Disconnect:
SetTimer, Disconnect, OFF,
FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Connection abort `n , connection.log	
Disconnect()
{
	global path
	
	WinWait, %path%\zd_console.exe, ,10
	WinActivate, %path%\zd_console.exe
	
	if ErrorLevel
		{
			FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Failed to find zd_console in disconnect !`n , connection.log
			return 0
		}
	
    Send, d ; Disconnect
    Random, rand , 2000, 5000
    sleep, %rand%
    Send, q ; Back to Main menu
    Random, rand , 1000, 3000
    sleep, %rand%	
	TrayTip , Status, ZD Disconnected , 2, 1	
	
	return 1
}


InternetCheckConnection(Url="",FIFC=1) 
{
	Return DllCall("Wininet.dll\InternetCheckConnectionA", Str,Url, Int,FIFC, Int,0)
}

;Download a file and count downloading time in seconds
DownloadFile()
{
	file=%A_DD%-%A_MM%-%A_Hour%-%A_Min%-%A_Sec%		
	
	start:=A_Min*60 + A_Sec
	
	;Try Download 1 Mega file
	UrlDownloadToFile, http://www2.jungo.com/~danielm/test20.txt, %A_MyDocuments%\%file%.txt
	end:=A_Min*60 + A_Sec
	total:=end-start
	;Download successful
	IfExist, %A_MyDocuments%\%file%.txt
		{
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Download completed in %total% sec `n , connection.log
		FileDelete, %A_MyDocuments%\%file%.txt 	
		return 1
		}
		
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Download retry `n , connection.log	
	;Try Download 256 K file
	start:=A_Min*60 + A_Sec	
	UrlDownloadToFile, http://www.autohotkey.com/download/CurrentVersion.txt, %A_MyDocuments%\%file%.txt	
	end:=A_Min*60 + A_Sec
	total:=end-start
	;Download successfull
	IfExist, %A_MyDocuments%\%file%.txt	
		{
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Download completed in %total% sec `n , connection.log	
		return 1
		}
	;Download failed	
	return 0
}
