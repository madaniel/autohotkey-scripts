;Take Screenshot	
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