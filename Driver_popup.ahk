#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; This script will close new driver installation pop up

;Variables
popup_window = Windows Security ahk_class #32770

While true
{
	WinWait, %popup_window%
	WinActivate, %popup_window%
	Send, {Down}
	sleep, 500
	Send, {Enter}
	WinWaitClose, %popup_window%
}

