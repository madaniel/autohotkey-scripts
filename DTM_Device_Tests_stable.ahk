#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force ; Replace old instance of the script
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

/* 
This app will test USB device.
The tests based on Microsoft WLK 1.6 DTM USB tests.
*/

/* TODO
1. Take test times
3. Hide all the non-relevant exe file
*/

; Variables
hubPop=0
directPop=0
testID=0
start=0

VerifyOS() 
AllFilesExist()
CleanAll()

valid=0

while not (valid)
{	
	InputBox, vid , Device Details, Enter device VID (e.g. 1F32),,200,120
    if ErrorLevel
        ExitApp

	if vid is xdigit
		if StrLen(vid) > 3
			valid=1
	
	if not (valid)
		MsgBox, VID must be 4 HEX number	
}

valid=0

while not (valid)
{	
	InputBox, pid , Device Details, Enter device PID (e.g. 0FB4),,200,120
    if ErrorLevel
        ExitApp

	if pid is xdigit
		if StrLen(pid) > 3
			valid=1
	
	if not (valid)
		MsgBox, PID must be 4 HEX number	
}


Gui 1:Default
;-----------------------------Start of GUI
Gui, Font, S7 ,Verdana
Gui, Add, Text, x16 yp+10 w260 h20 +Center cgray, Tested Device - [VID:%vid%/PID:%pid%]
Gui, Font, ,
Gui, Font, S11 Underline, Ariel
Gui, Add, Text, x16 yp+20 w260 h20 , Select Test Case To Execute:
Gui, Font, ,
Gui, Font, S10 Bold, 
Gui, Add, CheckBox, gAll vAll x16 yp+20 w90 h20 , &All Tests
Gui, Font, ,
Gui, Font, S10 Check3,
Gui, Add, CheckBox, gAllUnchecked vTest1 x20 y100 h20 ,1. USB Isochronous Alternate Interface Presence
Gui, Add, CheckBox, gAllUnchecked vTest2 x20 yp+20 h20 ,2. USB Specification Compliance
Gui, Add, CheckBox, gAllUnchecked vTest3 x20 yp+20 h20 ,3. USB Enable Disable
Gui, Add, CheckBox, gAllUnchecked vTest4 x20 yp+20 h20 ,4. USB Descriptor
Gui, Add, CheckBox, gAllUnchecked vTest5 x20 yp+20 h20 ,5. USB HCT Control Request
Gui, Add, CheckBox, gAllUnchecked vTest6 x20 yp+20 h20 ,6. USB HCT Enumeration Stress
Gui, Add, CheckBox, gAllUnchecked vTest7 x20 yp+20 h20 ,7. USB Address Description
Gui, Add, GroupBox, x86 yp+20 w0 h0 , GroupBox
Gui, Add, CheckBox, gAllUnchecked vTest8 x20 yp+40 h20 ,8. USB Suspend Resume
Gui, Add, CheckBox, gAllUnchecked vTest9 x20 yp+20 h20 ,9. USB Device Framework (CV)
Gui, Add, CheckBox, gAllUnchecked vTest10 x20 yp+20 h20 ,10. USB Driver Level Re-Enumeration
Gui, Add, CheckBox, gAllUnchecked vTest11 x20 yp+20 h20 ,11. USB HCT Selective Suspend
Gui, Add, GroupBox, x86 yp+20 w0 h0 , GroupBox
Gui, Add, CheckBox, gAllUnchecked vTest12 x20 yp+40 h20 ,12. USB Serial Number
Gui, Font, S10 CDefault Bold, Ariel
Gui, Font, S11 CDefault, Ariel
Gui, Add, GroupBox, x10 y77 w330 h170 , Direct USB Connection
Gui, Add, GroupBox, x10 y257 w330 h110 , High-Speed USB Hub Connection
Gui, Add, GroupBox, x10 y377 w330 h50 , Pair of Devices
Gui, Font, S11 Bold, Verdana
Gui, Add, Button, x125 y440 w100 h32 , &Start
Gosub, StartGui2
Gui, 1:Show, h490 w350, Device WHQL Qualification Tests
Return

StartGui2:
Gui, 2:Destroy
Gui, 2:Font, S10 bold ,Verdana
Gui, 2:add, text , x15 y0, 
loop, 12
{
	Gui, 2:add, text, x15 yp+20 ,Test %A_index%:    
}
Gui, 2:Add, Button, vRetest x60 yp+25 w80 h25 , &Retest
GuiControl, 2:hide, Retest
return

GuiClose:
CleanAll()
ExitApp

2GuiClose:
ExitApp

2ButtonRetest:
GuiControl, 2:hide, Retest
Gui, 2:Show, y130 h280 w200, Test Results
Gui, 1:Show, y440 h490 w350, Device WHQL Qualification Tests

return

All:
GuiControlGet, checked ,,All	
if (checked)
	loop, 12 ;Check all test checkboxes
		GuiControl,,Test%A_Index%,1			
else
	loop, 12 ;Uncheck all test checkboxes
		GuiControl,,Test%A_Index%,0	
return

AllUnchecked:
GuiControl,,All,0			
return

ButtonStart:
;Verify if any of the Checkboxes marked
count=0
loop, 12
{
    GuiControlGet, checked ,,Test%A_index%
    count+=checked   
}

if (count=0)
{
    Msgbox, 49,Device WHQL Qualification Tests, You didn't check any Test Case !
    return    
}
Gui,Submit

gosub, StartGui2 ;Clear old records from Gui2

loop,12
    if not (Test%A_Index%) ;Remove results for scheduled tests
            ShowResult(A_index)

loop, 12	
{
	If (Test%A_Index%)
		gosub, Test%A_Index%			
}	
goto, End

;USB Isochronous Alternate Interface Presence
Test1:
if not USBDirectRequired()
    goto End
FileMove, Test1.txt, Test1.old, 1
Run, usbiaipt.exe -a -l Test1.txt, ,min
TimeBar(2,"usbiaipt.exe",1)
if (ShowResult(1)) 
{
    passed1=1
    GuiControl,,Test1,0
}
else
    passed1=0
    
return

;USB Specification Compliance
Test2:
if not USBDirectRequired()
    goto End
FileMove, Test2.txt, Test2.old, 1
Run, usb1_1ct.exe -x -l Test2.txt, ,min
TimeBar(2,"usb1_1ct.exe",2)
if (ShowResult(2)) 
{
    passed2=1
    GuiControl,,Test2,0
}
else
    passed2=0

return

;USB Enable Disable
Test3:
if not USBDirectRequired()
    goto End
FileMove, Test3.txt, Test3.old, 1
RegistryFix(1)
Time(start)
Run, NewTests.exe -c -d %vid%/%pid% -l Test3 -i USB\VID_%vid%, ,min
TimeBar(224,"newtests.exe",3)
FileAppend , Test %ID% ended after Time(stop) [expected=224] `n , DTM_Device_Tests.log   
if (ShowResult(3)) 
{
    passed3=1
    GuiControl,,Test3,0
}
else
    passed3=0

RegistryFix(0)
return

;USB Descriptor
Test4:
if not USBDirectRequired()
    goto End
FileMove, Test4.txt, Test4.old, 1
RegistryFix(1)
Run, usbhct.exe -g -d %vid%/%pid% -l Test4, ,min
TimeBar(200,"usbhct.exe",4)
if (ShowResult(4)) 
{
    passed4=1
    GuiControl,,Test4,0
}
else
    passed4=0

RegistryFix(0)
return

;USB HCT Control Request
Test5:
if not USBDirectRequired()
    goto End
FileMove, Test5.txt, Test4.old, 1
RegistryFix(1)
Run, usbhct.exe -c -d %vid%/%pid% -l Test5, ,min
TimeBar(190,"usbhct.exe",5)
if (ShowResult(5)) 
{
    passed5=1
    GuiControl,,Test5,0
}
else
    passed5=0

RegistryFix(0)
return

;USB HCT Enumeration Stress
Test6:
if not USBDirectRequired()
    goto End
FileMove, Test6.txt, Test6.old, 1
RegistryFix(1)
Run, usbhct.exe -e -d %vid%/%pid% -l Test6, ,min
TimeBar(312,"usbhct.exe",6)
if (ShowResult(6)) 
{
    passed6=1
    GuiControl,,Test6,0
}
else
    passed6=0
RegistryFix(0)
return

;USB Address Description
Test7:
if not USBDirectRequired()
    goto End
FileMove, Test7.txt, Test7.old, 1
RegistryFix(1)
Run, usbhct.exe -a -d %vid%/%pid% -l Test7, ,min
TimeBar(1356,"usbhct.exe",7)
if (ShowResult(7)) 
{
    passed7=1
    GuiControl,,Test7,0
}
else
    passed7=0

RegistryFix(0)
return

;USB Suspend Resume
Test8:
Msgbox, 49, Power Management modes test cycle, Host will enter into Sleep / Hibernate auto cycles in 20 seconds ! `n`n No user intervention needed !, 20

IfMsgBox, Cancel
        return 
        
if not USBHubRequired()
    goto End
FileMove, Test8.txt, Test8.old, 1
RunWait, powercfg /hibernate on, ,min
RunWait, powercfg -SETACVALUEINDEX scheme_current SUB_NONE CONSOLELOCK 0, ,min ;no password after sleep resume
RunWait, powercfg.exe -setacvalueindex SCHEME_CURRENT SUB_SLEEP bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 1, ,min ;Enable AC RTC wake
RunWait, powercfg.exe -setdcvalueindex SCHEME_CURRENT SUB_SLEEP bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 1, ,min ;Enable DC RTC wake
RunWait, powercfg.exe -setactive scheme_current, ,min ;apply settings
RegistryFix(1)
Run, newTests.exe -s -d %vid%/%pid% -l Test8 -i \"USB\VID_%vid%", ,min
TimeBar(2430,"newtests.exe",8)
if (ShowResult(8)) 
{
    passed8=1
    GuiControl,,Test8,0
}
else
    passed8=0

RegistryFix(0)
return

;USB Device Framework (CV)
Test9:
if not USBHubRequired()
    goto End
FileMove, Test9.txt, Test9.old, 1
RegistryFix(1)
Run, usbCheckApp -chap9 0 %vid% %pid% Test9, ,min
TimeBar(1435,"usbcheckapp.exe",9)
if (ShowResult(9)) 
{
    passed9=1
    GuiControl,,Test9,0
}
else
    passed9=0

RegistryFix(0)
return

;USB Driver Level Re-Enumeration
Test10:
if not USBHubRequired()
    goto End
FileMove, Test10.txt, Test10.old, 1
RunWait, devedinstaller.msi /quiet, ,min
Run, Driver_popup.exe
RunWait, devcon install USBVirtTest.inf root\USBVirtTest, ,min
RegistryFix(1)
Run, UsbVirtTest.exe %vid% %pid%, ,min
TimeBar(17,"usbvirttest.exe",10)
RunWait, devcon remove USBVirtTest.inf root\USBVirtTest, ,min
RunWait, msiexec /x devedinstaller.msi /q, ,min
process, close , Driver_popup.exe
FileMove, $console, Test10.txt,1
if (ShowResult(10)) 
{
    passed10=1
    GuiControl,,Test10,0
}
else
    passed10=0

RegistryFix(0)
return

;USB HCT Selective Suspend
Test11:
if not USBHubRequired()
    goto End
FileMove, Test11.txt, Test11.old, 1
RegistryFix(1)
Run, usbhct.exe -s -d %vid%/%pid% -l Test11, ,min
TimeBar(444,"usbhct.exe",11)
if (ShowResult(11)) 
{
    passed11=1
    GuiControl,,Test11,0
}
else
    passed11=0

RegistryFix(0)
return

;USB Serial Number
Test12:
FileMove, Test12.txt, Test12.old, 1
Msgbox,49,Device WHQL Qualification Tests - Serial Test, Please attach * ANOTHER * device with the * SAME PID / VID * with DIFFERENT Serial number.`n Please verify the Driver and the Devices are loaded and identified correctly after connection.`n`n Click OK when you're done.
IfMsgBox, Cancel
        goto End
Run, usbnum.exe /d %vid%%pid%, ,min
TimeBar(3,"usbnum.exe",12)
FileMove, usbnum.log.xml, Test12.xml, 1
FileMove, usbnum.log.txt , Test12.txt, 1
if (ShowResult(12)) 
{
    passed12=1
    GuiControl,,Test12,0
}
else
    passed12=0
return

End:
passed=0
loop,12
    passed+=passed%A_index%

if (passed < 12)
{
    Gui, 2:Show, y120 h305 w200, Test Results
    GuiControl, 2:show, Retest	
}
else
    MsgBox, ,Device WHQL Qualification Test Cycle, Cycle completed, All tests have passed !

; ---------------------------------------------------Functions----------------------------------------------------

;Present the results in GUI2
ShowResult(ID)
{    
    line:=ID*20
    result:=GetResult(ID)
    
    if (result=-1) ;Test didn't run yet
        return
        
    if (result)
    {        
        Gui, 2:add, text , cgreen x80 y%line% ,Passed
        Gui, 2:Show, y130 h280 w200, Test Results
        return 1
    }
    else
    {
        Gui, 2:add, text, cred x80 y%line% ,Failed
        Gui, 2:Show, y130 h280 w200, Test Results
        return 0
    }
}   

;Change registry as required for test
RegistryFix(on)
{
    if (on)
    {
        Run, usb_error.exe
        RunWait, reg.exe add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers /v DisableAutoplay /t REG_DWORD /d 1 /f, ,min
        RunWait, reg.exe add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\usb /v ForcePortsHighSpeed /t REG_DWORD /d 00000001 /f, ,min
    }
    else
    {
        process, close , usb_error.exe
        RunWait, reg.exe delete HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers /v DisableAutoplay /f, ,min
        RunWait, reg.exe delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\usb /v ForcePortsHighSpeed /f, ,min
    }
    
    RunWait, usbrefresh.exe, ,min    
    TimeBar(3,"","preparation")
}

;kill all process and logs
CleanAll()
{
    process, close, usbnum.exe
    process, close, devcon.exe
    process, close, usbvirttest.exe
    process, close, usbcheckapp.exe
    process, close, usb1_1ct.exe 
    process, close, usbrefresh.exe
    process, close, usbhct.exe
    process, close, newtests.exe
    process, close, usbiaipt.exe    
    loop, 12
        FileDelete, Test%A_index%.txt
}

;Lunch progress bar until time expried and task completed
TimeBar(time,process,ID)
{	
Progress, M R0-%time%,,Test %ID% in Progress , Please wait...
loop, %time%
	{
    process, Exist, %process%  
    if not errorlevel ;process closed before estimation
        {
        more:=time-A_index
        ;FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Decrease %more% seconds from Test %ID% `n , DTM_Device_Tests.log      
        progress, OFF
        return 0
        }
	Progress, %A_index%	
    sleep, 1000
	}
;Time("start")
process, waitclose, %process% ;process closed after estiamtion
;less:=Time("stop")
;FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Add %less% seconds to Test %ID% `n , DTM_Device_Tests.log      
progress, OFF
}

;Return 1 for passed test
GetResult(ID)
{   
    IfNotExist, Test%ID%.txt
        return -1  

    if (ID=7 OR ID=4 OR ID=3 OR ID=5 OR ID=6 OR ID=8 OR ID=11 OR ID=12)
    {                
        if (Pass(ID,"Total=1, Passed=1, Failed=0"))
        {
            FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test %ID% has passed `n , DTM_Device_Tests.log
            GuiControl,,Test%ID%,0	
            GuiControl,,All,0			
            return 1
        }    
    }
    
    if (ID=9)
    {    
        if (Pass(ID,"Failed=0"))
        {
            FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test %ID% has passed `n , DTM_Device_Tests.log           
            GuiControl,,Test%ID%,0	
            GuiControl,,All,0			
            return 1            
        }
    }
    
    if (ID=10)
    {
        if (Pass(ID,"Failed=""0"""))
            if (Pass(ID,"Passed=""1""")) 
                if (Pass(ID,"Total=""1""")) 
        {
            FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test %ID% has passed `n , DTM_Device_Tests.log
            GuiControl,,Test%ID%,0	
            GuiControl,,All,0			
            return 1            
        }
    }    

    if (ID=1 OR ID=2)
    {
        if (Pass(ID,"Tests Passed          1 100%"))
        {
            FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test %ID% has passed `n , DTM_Device_Tests.log
            GuiControl,,Test%ID%,0	
            GuiControl,,All,0		            
            return 1
        }    
    }    
    
    FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test %ID% has failed `n , DTM_Device_Tests.log    
    return 0    	
}

;Parse the log file and search for "Pass"
Pass(ID,string)
{
    Loop, read, Test%ID%.txt
    {
        IfInString, A_LoopReadLine,%string%, Return , 1	
    }
    return 0
}

;Verify all files in place
AllFilesExist()
{
Check("usb_error.exe")
Check("usbnum.exe")
Check("devcon.exe")
Check("devedinstaller.msi")
Check("usbvirttest.cat")
Check("usbvirttest.exe")
Check("usbvirttest.inf")
Check("usbvirttest.sys")
Check("USBVirtTest.wtl")
Check("devioctl.dll")
Check("testservices.dll")
Check("tsmfcguihelperdll.dll")
Check("usb.if")
Check("usbcheckapp.exe")
Check("usbcommandverifier.dll")
Check("usbif-deviceclasscodes.cod")
Check("usb1_1ct.exe")
Check("cmdutil.dll")
Check("ntlog.dll")
Check("ntlogger.ini")
Check("usbiaipt.exe")
Check("usblib.dll")
Check("newtests.exe")
Check("etwcap.dll")
Check("hctrans.dll")
Check("usbhct.exe")
Check("usbrefresh.exe")
Check("usbtree.dll")
Check("wttlog.dll")
Check("Driver_popup.exe")
}

Check(file)
{
	if(FileExist(file))
		return 
	else MsgBox,16,Device WHQL Qualification Tests - File is missing,%file% is missing
	ExitApp
}

;Request connection of a USB Hub
USBHubRequired()
{
	global hubPop
    global directPop
	
	if (hubPop)
        return 1
    
	Msgbox,49,Device WHQL Qualification Tests - HUB Required, This test requires the device to be connected * THROUGH A USB HUB * to the Host (self powered preferable).`n Please verify the Driver and the Device are loaded and identified correctly after connection.`n`n Click OK when you're done.
	
	IfMsgBox, Cancel
        return 0
    
    hubPop=1
    directPop=0
    
    return 1
}

;Request direct connection to the Host
USBDirectRequired()
{
	global hubPop
    global directPop
	
	if (directPop)
        return 1
    
    Msgbox,49,Device WHQL Qualification Tests - No USB Hub, This test requires the device to be connected * DIRECTLY * (no USB Hub) to the Host`n Please verify the Driver and the Device are loaded and identified correctly after connection.`n`nClick OK when you're done.
	
    IfMsgBox, Cancel
        return 0
    
    directPop=1
    hubPop=0
    
    return 1
}

;Verify the OS is Win7 32 bit
VerifyOS()
{
	if !(A_OSVersion = "WIN_7") or (DllCall("IsWow64Process", "uint", DllCall("GetCurrentProcess"), "int*", isWow64process) && isWow64process)
		MsgBox,16,Device WHQL Qualification Tests, The script will work only on Windows 7 32 bit !	
	else
		return
	
	Exitapp
}


;Take time
Time(action)
{	
    global start
    
    if (action="start")
    {
        start:=A_TickCount
        return
    }
    
    if (action="stop")
        end:=Round((A_TickCount-start)/1000,1)
	
    return , end
}
