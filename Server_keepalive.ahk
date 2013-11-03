#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; This script will 

;Variables
popup_window = ahk_class VMPlayerFrame

While true
{
	IfWinNotExist, %popup_window%
		Run C:\Server2012.lnk
	sleep, 300000		
}

