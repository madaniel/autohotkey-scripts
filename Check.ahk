#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Variables
current_ch=%A_DD%/%A_MM%/%A_YYYY%, %A_Hour%:%A_Min%:%A_Sec%
current_p=%A_Hour%-%A_Min%-%A_Sec%

;Start:
If InternetCheckConnection( "http://www.google.com" )
	{
	FileAppend , %current_ch% - Connection Success `n , connection.log
	Run, C:\share\download.exe
	}
else
	{
	FileAppend , %current_ch% - Connection Failed `n , connection.log
	Gosub, SaveImage
	;RunWait, C:\share\Disconnect.exe
	;sleep 3000
	;RunWait, C:\share\Connect.exe
	;Gosub, Start
	}
 
Return

InternetCheckConnection(Url="",FIFC=1) 
{
 Return DllCall("Wininet.dll\InternetCheckConnectionA", Str,Url, Int,FIFC, Int,0)
}

SaveImage:
WinActivate, e:\zd_console.exe
Send, {PrintScreen}
Run, mspaint
WinWaitActive, untitled - Paint
Send, ^v
Sleep, 1000
Send, {AltDown}f{AltUp}a
Sleep, 1000
Send, %current_p%
Sleep, 1000
Send, {Enter}
Sleep, 1000
Send, {AltDown}f{AltUp}xn
Sleep, 1000
return
