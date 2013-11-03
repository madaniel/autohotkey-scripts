#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Global Variables
timeout = 80000

InputBox, cycles , ZeroDriver Auto Test Cycle, How many cycles ? , , , , , , , 10, 1
InputBox, Drive , ZeroDriver Auto Test Cycle, ZeroDriver CD-ROM Drive letter ? , , , , , , , 10, E:

;Clear old sessions
IfWinExist, %drive%\zd_console.exe
	{
    WinKill, %drive%\zd_console.exe
	WinWaitClose, %drive%\zd_console.exe
	}
	
Run, %drive%\zd_console.exe		
WinWait, %drive%\zd_console.exe

loop, %cycles%
{	
	Connect()
	Check()
	Disconnect()
	Eject()
	Connect()
	Check()
	Disconnect()
}

WinClose, %drive%\zd_console.exe
Msgbox, Test Cycle Completed !

exit


;functions


Eject()
{
	;Variables
	global drive
		
	WinActivate, %drive%\zd_console.exe
    Send, q
    sleep, 1000 
	Send, q
    sleep, 1000 
	
	Drive, eject, %drive%
	
	TrayTip , Status, Waiting for Ejection to complete ... , 20, 1
	sleep 20000
	
}


Connect()
{
	global drive	
    
	TrayTip , Status, Waiting for zd_console ... , 3, 1	
	
	WinWaitActive, %drive%\zd_console.exe
	WinSet, AlwaysOnTop, on , %drive%\zd_console.exe
	sleep 2000
    Send, s
    sleep 3000
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
}


Check()
{
	;Variables	
	global drive	
	global timeout	
	tmp=%timeout%
	
	;Waiting for timeout
	TrayTip , Status, Connecting ... , %timeout%, 1	
	while tmp > 0
	{	
		If InternetCheckConnection("http://www.google.com")
			{			
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
				FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Download failed `n , connection.log
				TrayTip , Status, Download failed , 3, 2			
				sleep 2000
				}
				
			return
			}
			
		else
			{						
			tmp:=tmp-1000
			sleep 1000
			}
	}			
	
	;Timeout expired
	TrayTip , Status, Connection failed , 3, 2
	sleep 2000
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Connection Failed `n , connection.log

	;Take Screenshot
	WinActivate, %drive%\zd_console.exe
	Send, {PrintScreen}
	Run, mspaint
	sleep 1000	
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
    
	return
} 


Disconnect()
{
	global drive
	
	WinActivate, %drive%\zd_console.exe
    Send, d
    sleep 2000
    Send, q
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
	
	UrlDownloadToFile, http://www2.jungo.com/~danielm/test20.txt, C:\%file%.txt
	sleep 5000
	IfExist, C:\%file%.txt	
		return 1
	
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Download 2nd retry `n , connection.log
	
	UrlDownloadToFile, http://www.autohotkey.com/download/CurrentVersion.txt, C:\%file%.txt
	sleep 2000
	IfExist, C:\%file%.txt	
		return 1
		
	return 0
}
