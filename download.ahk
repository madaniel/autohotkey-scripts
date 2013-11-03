#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Variables
file=%A_Hour%-%A_Min%-%A_Sec%

UrlDownloadToFile, http://www.autohotkey.com/download/CurrentVersion.txt, C:\%file%.txt
