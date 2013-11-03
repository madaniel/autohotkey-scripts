#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;#############################################################
;
;	This script will write into SIM cards dummy contacts
;
;			for testing purpose, using zd_cosole
;
;#############################################################

;Global Variables
phoneNumber1 = {+}972521234567
phoneNumber2 = 00972521234567
phoneNumber3 = 0521234567
phoneNumber4 = *0123

MsgBox , 1, Warning , Your existing SIM contacts will be overwrite !, 

IfMsgBox Cancel
	exit

InputBox, path , Generating new contacts to SIM, zd_console.exe path ? , , , , , , , 10, C:\ProgramData\ZeroDriver\V1.7.22
if ErrorLevel
	exit
	
;Run zd_console
IfWinNotExist, %path%\zd_console.exe
	{
    Run, %path%\zd_console.exe		
	WinWait, %path%\zd_console.exe
	}


;----------------------------------Main----------------------------------

;Get ready for AT Commands
OpenTerminal()

index=3

;Writing contacts
loop, 62
{
	Send,AT{+}CPBW=%index%,”%phoneNumber1%”,145,”%index% Country”
	sleep 500
	Send, {Enter}
	index++
	Send,AT{+}CPBW=%index%,”%phoneNumber2%”,145,”%index% Country”	
	sleep 500
	Send, {Enter}
	index++
	Send,AT{+}CPBW=%index%,”%phoneNumber3%”,129,”%index% Regular”	
	sleep 500
	Send, {Enter}
	index++
	Send,AT{+}CPBW=%index%,”%phoneNumber4%”,129,”%index% Short”
	sleep 500
	Send, {Enter}
	index++
}

CloseTerminal()

WinSet, AlwaysOnTop, off , %path%\zd_console.exe
Msgbox, Generating contacs Completed !


;------------------------------------------------------------------------

exit


;functions

OpenTerminal()
{
	global path
	
	TrayTip , Status, Opening Terminal , 2, 1		
	
	WinWait, %path%\zd_console.exe, ,10
	
	if ErrorLevel
	   Run, %path%\zd_console.exe
	
	WinActivate, %path%\zd_console.exe
	
	WinSet, AlwaysOnTop, on , %path%\zd_console.exe
	sleep, 7000
	Send, s	
    sleep, 5000
	Send, t	
    sleep, 500
	Send, 3
	sleep, 500
	Send, {Enter}	
    sleep, 500	
	
	return
}

CloseTerminal()
{
	global path
	
	TrayTip , Status, Closing Terminal , 2, 1		
	
	WinWait, %path%\zd_console.exe, ,10
	
	if ErrorLevel
	   return
	
	WinActivate, %path%\zd_console.exe
	
	WinSet, AlwaysOnTop, on , %path%\zd_console.exe
	sleep, 3000
	Send, ^z	
    sleep, 500
	Send, {Enter}		
    sleep, 1000
	Send, q
	sleep, 500
	Send, q
    sleep, 500	
	
	return
}