;This Script will update filters on DTM Controller

;Variables
Download_Link = https://winqual.microsoft.com/member/SubmissionWizard/LegalExemptions/updatefilters.cab
DTM_Folder = C:\Program Files\Microsoft Driver Test Manager\Controller
/*
2003 folder = C:\Program Files\Microsoft Driver Test Manager\Controller
2008 folder = C:\Program Files (x86)\Microsoft Driver Test Manager\Controller\UpdateFilters.exe
*/

; Verify Internet connection
If NOT InternetCheckConnection()
	{
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! No Internet connection - aborted !`n , c:\UpdateScript.log	
	exit
	}

;Download Filter CAB file
UrlDownloadToFile, %Download_Link%, c:\updatefilters.cab

;Retry #1
IfNotExist, c:\updatefilters.cab
	{
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Download Retry #1 `n , c:\UpdateScript.log
	sleep 60000
	UrlDownloadToFile, %Download_Link%, c:\updatefilters.cab
	}

;Retry #2
IfNotExist, c:\updatefilters.cab
	{
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Download Retry #2 `n , c:\UpdateScript.log
	sleep 600000
	UrlDownloadToFile, %Download_Link%, c:\updatefilters.cab
	}

IfExist, c:\updatefilters.cab
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Download Completed `n , c:\UpdateScript.log
else
	{
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Download failed - aborted ! `n , c:\UpdateScript.log
	exit
	}

;Extract CAB file
RunWait, expand C:\updatefilters.cab -F:updatefilters.sql c:\

IfExist, c:\updatefilters.sql
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - File extracted `n , c:\UpdateScript.log
else
	{
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Extraction failed - aborted ! `n , c:\UpdateScript.log
	exit
	}
	
;Move to DTM Controller folder
FileMove, c:\updatefilters.sql , %DTM_Folder%  , 1
FileDelete, c:\updatefilters.cab

IfExist, %DTM_Folder%\updatefilters.sql
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - File Moved `n , c:\UpdateScript.log
else
	{
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - File not moved - aborted ! `n , c:\UpdateScript.log
	exit
	}

;Run update command
Run, UpdateFilters.exe , %DTM_Folder%
FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Update completed  `n , c:\UpdateScript.log

;Press any key
WinWait, %DTM_Folder%\UpdateFilters.exe, ,10
sleep, 60000
WinActivate, %DTM_Folder%\UpdateFilters.exe
Send, {Space}
WinWaitClose, %DTM_Folder%\UpdateFilters.exe,,10

IfWinExist, %DTM_Folder%\UpdateFilters.exe
	WinKill, %DTM_Folder%\UpdateFilters.exe
	

;Functions
InternetCheckConnection(flag=0x40) 
{ 
Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", flag,"Int",0) 
}