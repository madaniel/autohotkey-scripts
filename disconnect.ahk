#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Variables
current_d=%A_DD%/%A_MM%/%A_YYYY%, %A_Hour%:%A_Min%:%A_Sec%

IfWinExist, e:\zd_console.exe
{
    WinActivate, e:\zd_console.exe
    Send, d
    sleep 2000
    Send, q
    sleep, 1000
    send, q
    sleep, 1000   
    return 
}

FileAppend , %current_d% - Disconnected `n , connection.log