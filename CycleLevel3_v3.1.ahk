#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Global Variables
timeout = 60000

InputBox, cycles , ZeroDriver Auto Test Cycle, How many cycles ? , , , , , , , 10, 1
if ErrorLevel
	exit
InputBox, drive , ZeroDriver Auto Test Cycle, ZeroDriver CD-ROM Drive letter ? , , , , , , , 10, E:
if ErrorLevel
	exit
InputBox, path , ZeroDriver Auto Test Cycle, zd_console.exe path ? , , , , , , , 10, C:\ProgramData\ZeroDriver\V1.7.18
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
	Connect()
	Check()
	
	If InternetCheckConnection("http://www.google.com")
	Disconnect()
	
	Eject()	
	Connect()
	Check()
	
	If InternetCheckConnection("http://www.google.com")
	Disconnect()
}

WinSet, AlwaysOnTop, off , %path%\zd_console.exe
Msgbox, Test Cycle Completed !


;------------------------------------------------------------------------

exit


;functions

VerifyLAN()
{	
	If InternetCheckConnection("http://www.google.com")
	{
	TrayTip , Pause, Check LAN cable , 3, 2
	pause
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
	sleep 7000
    Send, s
	sleep 5000
	Send, r
	sleep 500
	Send, 3
	sleep 500
	Send, {Enter}
	sleep 500
	Send, q
	sleep 500
	
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
    sleep, 3000 
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
	sleep 2000
	
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
	sleep 7000
    Send, s
    sleep 5000
    Send, c
    sleep, 500
    send, 2
    sleep, 500
    Send, {Enter}
	sleep, 500
	Send, {Enter} 
	sleep, 500
	Send, {Enter}
    sleep, 500
    Send, internet
    sleep, 5000
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
	sleep 2000
	
	start:=A_Min*60 + A_Sec
	
	while tmp > 0
	{	
		If InternetCheckConnection("http://www.google.com")
			{
			end:=A_Min*60 + A_Sec
			total:=end-start
			
			;Abort if connection is successful too fast ...
			If (total=0)
				{
				TrayTip , Status, Aborting - connected too fast , 3, 2
				FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Abort - connection time is not reasonable ! `n , connection.log
				sleep 3000
				exit					
				}			
			
			TrayTip , Status, Connection success , 3, 1			
			sleep 2000
			FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Connection established `n , connection.log
			
			If DownloadFile()
				{
				FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - File download completed `n , connection.log
				TrayTip , Status, Download completed , 3, 1			
				sleep 2000
				}
			else
				{
				FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Download failed !`n , connection.log
				TrayTip , Status, Download failed , 3, 2			
				sleep 2000
				}
				
			return
			}
			
		else
			{
			FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - timeout = %tmp% `n , connection.log
			tmp:=tmp-3000
			sleep 3000
			}
	}			
	;End of while
	
	;Timeout expired
	TrayTip , Status, Connection failed , 2, 2
	sleep 2000
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


Disconnect()
{
	global path
	
	WinWait, %path%\zd_console.exe, ,10
	WinActivate, %path%\zd_console.exe
	
	if ErrorLevel
		{
			FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Failed to find zd_console in disconnect !`n , connection.log
			return
		}
	
    Send, d ; Disconnect connection
    sleep 2000
    Send, q ; Back to Main menu
    sleep, 1000	
	TrayTip , Status, ZD Disconnected , 3, 1
	sleep 2000
	
	return
}

	
InternetCheckConnection(Url="",FIFC=1) 
{
	Return DllCall("Wininet.dll\InternetCheckConnectionA", Str,Url, Int,FIFC, Int,0)
}


DownloadFile()
{
	file=%A_DD%-%A_MM%-%A_Hour%-%A_Min%-%A_Sec%		
	
	start:=A_Min*60 + A_Sec	
	UrlDownloadToFile, http://www2.jungo.com/~danielm/test20.txt, C:\%file%.txt
	end:=A_Min*60 + A_Sec
	total:=end-start
	IfExist, C:\%file%.txt
		{
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Download completed in %total% sec `n , connection.log	
		return 1
		}
		
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Download retry `n , connection.log	
	
	start:=A_Min*60 + A_Sec	
	UrlDownloadToFile, http://www.autohotkey.com/download/CurrentVersion.txt, C:\%file%.txt	
	end:=A_Min*60 + A_Sec
	total:=end-start
	
	IfExist, C:\%file%.txt	
		{
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Download completed in %total% sec `n , connection.log	
		return 1
		}
		
	return 0
}
