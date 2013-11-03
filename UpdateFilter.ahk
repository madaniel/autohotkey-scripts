;This Script will update filters on DTM Controller

; Verify Internet connection
If NOT InternetCheckConnection("http://www.google.com")
	{
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! No Internet connection - aborted !`n , c:\UpdateScript.log	
	exit
	}

;Download Filter CAB file
UrlDownloadToFile, https://winqual.microsoft.com/member/SubmissionWizard/LegalExemptions/updatefilters.cab, c:\updatefilters.cab

;Retry #1
IfNotExist, c:\updatefilters.cab
	{
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Download Retry #1 `n , c:\UpdateScript.log
	sleep 60000
	UrlDownloadToFile, https://winqual.microsoft.com/member/SubmissionWizard/LegalExemptions/updatefilters.cab, c:\updatefilters.cab
	}

;Retry #2
IfNotExist, c:\updatefilters.cab
	{
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Download Retry #2 `n , c:\UpdateScript.log
	sleep 600000
	UrlDownloadToFile, https://winqual.microsoft.com/member/SubmissionWizard/LegalExemptions/updatefilters.cab, c:\updatefilters.cab
	}

;Failed
IfNotExist, c:\updatefilters.cab
	{
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Download failed - aborted ! `n , c:\UpdateScript.log
	exit
	}
	
;Extract CAB file
RunWait, expand C:\updatefilters.cab -F:updatefilters.sql c:\
IfNotExist, c:\updatefilters.sql
	{
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - ! Extraction failed - aborted ! `n , c:\UpdateScript.log
	exit
	}
	
;Move to DTM Controller folder
FileMove, c:\updatefilters.sql , C:\Program Files (x86)\Microsoft Driver Test Manager\Controller , 1
FileDelete, c:\updatefilters.cab
IfNotExist, C:\Program Files (x86)\Microsoft Driver Test Manager\Controller\updatefilters.sql
	{
	FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - File not moved - aborted ! `n , c:\UpdateScript.log
	exit
	}

;Run update command
Run, UpdateFilters.exe , C:\Program Files (x86)\Microsoft Driver Test Manager\Controller
FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Update lunched  `n , c:\UpdateScript.log

;Press any key
WinWait, C:\Program Files (x86)\Microsoft Driver Test Manager\Controller\UpdateFilters.exe, ,10
sleep, 30000
WinActivate, C:\Program Files (x86)\Microsoft Driver Test Manager\Controller\UpdateFilters.exe
Send, {Space}
exit

;Functions
InternetCheckConnection(Url="",FIFC=1) 
{
	Return DllCall("Wininet.dll\InternetCheckConnectionA", Str,Url, Int,FIFC, Int,0)
}