#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; This script will keep the Mass Storage interface busy in Read / Write for testing purpose.
; The Script will generate dummy files in different sizes and transffer them back and forth from the device and the Host.

;Global Variables

InputBox, cycles , Mass Storage Stress Test, How many cycles ? , , , , , , , 10, 1
if ErrorLevel
	exit
	
InputBox, ms_drive , Mass Storage Stress Test, Mass Storage Drive Letter ? , , , , , , , 10, F
if ErrorLevel
	exit

InputBox, hd_drive , Mass Storage Stress Test, Hard Disk Drive Letter ? , , , , , , , 10, C
if ErrorLevel
	exit

FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test started `n , MassStorageStress.log	
	
ms_folder:=MakeDir(ms_drive)
hd_folder:=MakeDir(hd_drive)

;Get capacity of the Mass Storage
DriveSpaceFree, ms_capacity, %ms_drive%:\

;Get capacity of the Hard Disk
DriveSpaceFree, hd_capacity, %hd_drive%:\

;Abort if not enough space on Hard Disk
If (hd_capacity < ms_capacity*3)
	{
	TrayTip , Error , Not enough free space on HDD , 3, 3		
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Not enough space on HDD, you need at least %ms_capacity% MegaBytes free on your HardDisk `n , MassStorageStress.log		
	sleep 3000
	exit
	}
	
If (ms_capacity < 1)
	{
	TrayTip , Error , Not enough free space on Mass Storage , 3, 3		
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Not enough space on Mass Storage, you need at least 1 Mega free `n , MassStorageStress.log		
	}

;-----------------------Start loop-----------------------

GenerateFiles()

loop, %cycles%
{

TransferFull()

TransferLargeFiles()

TransferSmallFiles()

}

CleanAll()

;-----------------------End loop-----------------------

FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test accomplished `n , MassStorageStress.log	
exit

;Functions

GenerateFiles()
{
	global ms_capacity
	global hd_drive
	global ms_drive
	global ms_folder
	global hd_folder
	
	TrayTip , Status , Generating files to transfer ... , 2, 1		
	
	;Full size file
	FileSize:= ms_capacity * 1048576	
	RunWait, fsutil file createnew %hd_drive%:\%hd_folder%\full.tmp %FileSize% , , Hide
	
	;Large (10%) files
	i=1
	FileSize:= ms_capacity * 104857
 	loop, 10
	{
		RunWait, fsutil file createnew %hd_drive%:\%hd_folder%\large%i%.tmp %FileSize% , , Hide
		i++
	}
	
	;Small (0.1%) files
	i=1
	FileSize:= ms_capacity * 1037
	loop, 1000
	{	
		RunWait, fsutil file createnew %hd_drive%:\%hd_folder%\small%i%.tmp %FileSize% , , Hide
		i++
	}
	
	;Abort if file generation was failed
	If NOT ( Exist(hd_drive,hd_folder,"full.tmp") and Exist(hd_drive,hd_folder,"large10.tmp") and Exist(hd_drive,hd_folder,"small1000.tmp") )
		{
			FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Test file generation failed - abort ! `n , MassStorageStress.log		
			exit
		}
	else
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test files generated on %hd_drive%:\%hd_folder% `n , MassStorageStress.log		

}

TransferSmallFiles()
{
	global ms_capacity
	global hd_drive
	global ms_drive
	global ms_folder
	global hd_folder
	
	;Move Small files HDD --> MS
	TrayTip , Status , Start HDD --> MS small files transfer ... , 2, 1		
	i=1	
	startTime:=A_TickCount	
	loop, 1000
	{
		FileMove, %hd_drive%:\%hd_folder%\small%i%.tmp , %ms_drive%:\%ms_folder%				
		i++
	}
	time:=Round((A_TickCount-startTime)/1000)
	sec:=Mod(time,60)
	min:=Round(time/60)
	
	;Verify transfer completion
	If NOT Exist(ms_drive,ms_folder,"small1000.tmp")
	{
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Small files transfer to %ms_drive%:\%ms_folder% failed - abort `n , MassStorageStress.log		
		exit
	}		
		
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Small files transfered to %ms_drive%:\%ms_folder% in %min% minutes and %sec% seconds `n , MassStorageStress.log				
	
	Random, rand , 0, 5000
	sleep, %rand%	
	
	;Move small files HDD <-- MS
	TrayTip , Status , Start HDD <-- MS small files transfer ... , 2, 1		
	i=1	
	startTime:=A_TickCount
	loop, 1000
	{
		FileMove, %ms_drive%:\%ms_folder%\small%i%.tmp , %hd_drive%:\%hd_folder%		
		i++
	}
	time:=Round((A_TickCount-startTime)/1000)
	sec:=Mod(time,60)
	min:=Round(time/60)
	
	;Verify transfer completion
		If NOT Exist(hd_drive,hd_folder,"small1000.tmp")
			{
			FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - small files transfer to %hd_drive%:\%hd_folder% failed - abort `n , MassStorageStress.log		
			exit
			}		
			
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Small files transfered to %hd_drive%:\%hd_folder% in %min% minutes and %sec% seconds `n , MassStorageStress.log				
	
	Random, rand , 0, 5000
	sleep, %rand%		
}

TransferLargeFiles()
{
	global ms_capacity
	global hd_drive
	global ms_drive
	global ms_folder
	global hd_folder
	
	;Move Large files HDD --> MS
	TrayTip , Status , Start HDD --> MS large files transfer ... , 2, 1		
	i=1	
	startTime:=A_TickCount
	loop, 10
	{
		FileMove, %hd_drive%:\%hd_folder%\large%i%.tmp , %ms_drive%:\%ms_folder%		
		i++
	}
	
	time:=Round((A_TickCount-startTime)/1000)
	sec:=Mod(time,60)
	min:=Round(time/60)
	
	;Verify transfer completion
	If NOT Exist(ms_drive,ms_folder,"large10.tmp")
	{
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Large files transfer to %ms_drive%:\%ms_folder% failed - abort `n , MassStorageStress.log		
		exit
	}		
		
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Large files transfered to %ms_drive%:\%ms_folder% in %min% minutes and %sec% seconds `n , MassStorageStress.log				
	
	Random, rand , 0, 5000
	sleep, %rand%	
	
	;Move Large files HDD <-- MS
	TrayTip , Status , Start HDD <-- MS large files transfer ... , 2, 1		
	i=1	
	startTime:=A_TickCount

	loop, 10
	{
		FileMove, %ms_drive%:\%ms_folder%\large%i%.tmp , %hd_drive%:\%hd_folder%		
		i++
	}
	time:=Round((A_TickCount-startTime)/1000)
	sec:=Mod(time,60)
	min:=Round(time/60)
	
	;Verify transfer completion
		If NOT Exist(hd_drive,hd_folder,"large10.tmp")
			{
			FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - large files transfer to %hd_drive%:\%hd_folder% failed - abort `n , MassStorageStress.log		
			exit
			}		
			
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Large files transfered to %hd_drive%:\%hd_folder% in %min% minutes and %sec% seconds `n , MassStorageStress.log				
	
	Random, rand , 0, 5000
	sleep, %rand%	
}


TransferFull()
{
	global ms_capacity
	global hd_drive
	global ms_drive
	global ms_folder
	global hd_folder
	
	;Move Full file HDD --> MS
	TrayTip , Status , Start HDD --> MS Full transfer ... , 2, 1		
	startTime:=A_TickCount
	FileMove, %hd_drive%:\%hd_folder%\full.tmp , %ms_drive%:\%ms_folder%\
	time:=Round((A_TickCount-startTime)/1000)
	sec:=Mod(time,60)
	min:=Round(time/60)

	;Abort if transfer failed
	If NOT Exist(ms_drive,ms_folder,"full.tmp")
		{
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Full file transfer to %ms_drive%:\%ms_folder% failed - abort `n , MassStorageStress.log		
		exit
		}
		
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Full file transfered to %ms_drive%:\%ms_folder% in %min% minutes and %sec% seconds `n , MassStorageStress.log		
	
	Random, rand , 0, 5000
	sleep, %rand%	
	
	;Move Full file HDD <-- MS
	TrayTip , Status , Start HDD <-- MS Full transfer ... , 2, 1		
	startTime:=A_TickCount
	FileMove, %ms_drive%:\%ms_folder%\full.tmp , %hd_drive%:\%hd_folder%\
	time:=Round((A_TickCount-startTime)/1000)
	sec:=Mod(time,60)
	min:=Round(time/60)

	;Abort if transfer failed
	If NOT Exist(hd_drive,hd_folder,"full.tmp")
		{
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Full file transfer to %hd_drive%:\%hd_folder% failed - abort `n , MassStorageStress.log		
		exit
		}
		
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Full file transfered to %hd_drive%:\%hd_folder% in %min% minutes and %sec% seconds `n , MassStorageStress.log		
	
	Random, rand , 0, 5000
	sleep, %rand%	
}

CleanAll()
{
	global ms_capacity
	global hd_drive
	global ms_drive
	global ms_folder
	global hd_folder
	
	FileDelete, %hd_drive%:\%hd_folder%\*.tmp
	FileRemoveDir, %hd_drive%:\%hd_folder%
	FileDelete, %ms_drive%:\%ms_folder%\*.tmp
	FileRemoveDir, %ms_drive%:\%ms_folder%
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test files deleted `n , MassStorageStress.log		
}

MakeDir(drive)
{	
	folder=%A_Min%%A_Sec%
	
	;Choose non exist folder
	while Exist(drive,folder,"")
	{
		sleep 1000
		folder=%A_Min%%A_Sec%		
	}
	
	;Create a folder
	FileCreateDir, %drive%:\%folder%
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Folder %folder% created on %drive%: `n , MassStorageStress.log	
	
	If errorlevel
		{
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Error - failed to create %drive%\%folder% - abort `n , MassStorageStress.log	
		exit
		}
	
	return %folder%
}

Exist(drive,folder,file)
{	
	IfExist, %drive%:\%folder%\%file%
		return 1
	else
		return 0
}


