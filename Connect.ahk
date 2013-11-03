#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Variables
current=%A_DD%/%A_MM%/%A_YYYY%, %A_Hour%:%A_Min%:%A_Sec%

Run, e:\zd_console.exe

sleep 3000

IfWinExist, e:\zd_console.exe
{
    WinActivate, e:\zd_console.exe
    Send, s
    sleep 2000
    Send, c
    sleep, 1000
    send, 2
    sleep, 1000
    Send, {Enter}
	sleep, 1000
	Send, {Enter} 
	sleep, 1000
	Send, {Enter}
    sleep, 1000
    Send, internet 
    sleep, 5000
    Send, {Enter}    
    sleep, 20000
    return 
}

FileAppend , %current% - Connected `n , connection.log



