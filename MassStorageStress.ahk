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

ms_folder:=MakeDir(ms_drive)
hd_folder:=MakeDir(hd_drive)

;Get capacity of the Mass Storage
DriveSpaceFree, ms_capacity, %ms_drive%:\

;Get capacity of the Hard Disk
DriveSpaceFree, hd_capacity, %hd_drive%:\

;Abort if not enough space on Hard Disk
If (hd_capacity < ms_capacity)	
	{
	TrayTip , Error , Not enough free space on HDD , 3, 3		
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Not enough space on HDD, you need at least %ms_capacity% MegaBytes free on your HardDisk `n , MassStorageStress.log		
	sleep 3000
	exit
	}

;-----------------------Start loop-----------------------

GenerateLargeFile()

loop, %cycles%
{	
	TransfersLargeFiles()	
}

CleanAll()

;-----------------------End loop-----------------------

exit

;Functions

GenerateLargeFile()
{
	global ms_capacity
	global hd_drive
	global ms_drive
	global ms_folder
	global hd_folder
	
	fileSize:= ms_capacity * 1048576
	RunWait, fsutil file createnew %hd_drive%:\%hd_folder%\large.tmp %fileSize% , , min

	;Abort if file generation was failed
	IfNOTExist, %hd_drive%:\%hd_folder%\large.tmp
		{
			FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Test file generation failed, abort ! `n , MassStorageStress.log		
			exit
		}
	else
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test file generated on %hd_drive%:\%hd_folder% in %ms_capacity% MegaBytes size `n , MassStorageStress.log		

}

TransfersLargeFiles()
{
	global ms_capacity
	global hd_drive
	global ms_drive
	global ms_folder
	global hd_folder
	
	;Start file transfer HDD --> MS
	TrayTip , Status , Start HDD --> MS large transfer ... , 2, 1		
	
	FileMove, %hd_drive%:\%hd_folder%\*.tmp , %ms_drive%:\%ms_folder%\
	
	;Abort if transfer failed
	IfNOTExist, %ms_drive%:\%ms_folder%\large.tmp
		{
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test file transfer to %ms_drive%:\%ms_folder% failed, abort `n , MassStorageStress.log		
		exit
		}
		
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test file transfered to %ms_drive%:\%ms_folder% `n , MassStorageStress.log		

	;Start file transfer HDD <-- MS
	TrayTip , Status , Start HDD <-- MS large transfer ... , 2, 1		

	FileMove, %ms_drive%:\%ms_folder%\*.tmp , %hd_drive%:\%hd_folder%\

	;Abort if transfer failed
	IfNOTExist, %hd_drive%:\%hd_folder%\large.tmp
		{
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test file transfer to %hd_drive%:\%hd_folder% failed, abort `n , MassStorageStress.log		
		exit
		}
		
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test file transfered to %hd_drive%:\%hd_folder% `n , MassStorageStress.log		
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
	while Exist(drive,folder)
	{
		sleep 1000
		folder=%A_Min%%A_Sec%		
	}
	
	;Create a folder
	FileCreateDir, %drive%:\%folder%
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Folder %folder% created on %drive%: `n , MassStorageStress.log	
	
	If errorlevel
		{
		FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Error - failed to create %drive%\%folder%, abort `n , MassStorageStress.log	
		exit
		}
	
	return %folder%
}

Exist(drive,folder)
{	
	IfExist, %drive%:\%folder%
		return 1
	else
		return 0
}
