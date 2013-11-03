#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force ; Replace old instance of the script
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

/* 
This app will test USB device.
The tests based on Microsoft WLK 1.6 DTM USB tests.
*/

; Variables
hubPop=0
directPop=0
testID=0
failed=0
start=0

CleanAll()
VerifyOS() 
AllFilesExist()

InputBox, vid , Device Details, Enter device VID (e.g. 1F32),,200,120
    if ErrorLevel
        ExitApp

InputBox, pid , Device Details, Enter device PID (e.g. 0FB4),,200,120
    if ErrorLevel
        ExitApp

Msgbox,49,Device WHQL Qualification Tests - Check Device, Please verify the driver is LOADED and the Device is ENABLED !
IfMsgBox, Cancel
	ExitApp

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
Gui, Show, h490 w350, Device WHQL Qualification Tests
Return

GuiClose:
CleanAll()
ExitApp

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
Gui, destroy ;First GUI closed

loop, 12	
{
	If (Test%A_Index%)
		gosub, Test%A_Index%			
}	
gosub, End

;USB Isochronous Alternate Interface Presence
Test1:
USBDirectRequired()
FileMove, Test1.txt, Test1.old, 1
FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 1 started `n , DTM_Device_Tests.log
Run, usbiaipt.exe -a -l Test1.txt, ,min
TimeBar(10,"usbiaipt.exe",1)
if not (GetResult(1))
	failed++
return

;USB Specification Compliance
Test2:
USBDirectRequired()
FileMove, Test2.txt, Test2.old, 1
FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 2 started `n , DTM_Device_Tests.log
Run, usb1_1ct.exe -x -l Test2.txt, ,min
TimeBar(14,"usb1_1ct.exe",2)
if not (GetResult(2))
	failed++
return

;USB Enable Disable
Test3:
USBDirectRequired()
FileMove, Test3.txt, Test3.old, 1
FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 3 started `n , DTM_Device_Tests.log
Run, NewTests.exe -c -d %vid%/%pid% -l Test3 -i USB\VID_%vid%, ,min
TimeBar(70,"newtests.exe",3)
if not (GetResult(3))
	failed++
return

;USB Descriptor
Test4:
USBDirectRequired()
FileMove, Test4.txt, Test4.old, 1
FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 4 started `n , DTM_Device_Tests.log
Run, usbhct.exe -g -d %vid%/%pid% -l Test4, ,min
TimeBar(201,"usbhct.exe",4)
if not (GetResult(4))
	failed++
return

;USB HCT Control Request
Test5:
USBDirectRequired()
FileMove, Test5.txt, Test4.old, 1
FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 5 started `n , DTM_Device_Tests.log
Run, usbhct.exe -c -d %vid%/%pid% -l Test5, ,min
TimeBar(208,"usbhct.exe",5)
if not (GetResult(5))
	failed++
return

;USB HCT Enumeration Stress
Test6:
USBDirectRequired()
FileMove, Test6.txt, Test6.old, 1
FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 6 started `n , DTM_Device_Tests.log
Run, usbhct.exe -e -d %vid%/%pid% -l Test6, ,min
TimeBar(312,"usbhct.exe",6)
if not (GetResult(6))
	failed++
return

;USB Address Description
Test7:
USBDirectRequired()
FileMove, Test7.txt, Test7.old, 1
FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 7 started `n , DTM_Device_Tests.log
Run, usbhct.exe -a -d %vid%/%pid% -l Test7, ,min
TimeBar(1716,"usbhct.exe",7)
if not (GetResult(7))
	failed++	
return

;USB Suspend Resume
Test8:
USBHubRequired()
FileMove, Test8.txt, Test8.old, 1
RunWait, powercfg /hibernate on, ,min
RunWait, powercfg -SETACVALUEINDEX scheme_current SUB_NONE CONSOLELOCK 0, ,min
Run, newTests.exe -s -d %vid%/%pid% -l Test8 -i \"USB\VID_%vid%", ,min
FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 8 started `n , DTM_Device_Tests.log
TimeBar(3388,"newtests.exe",8)
if not (GetResult(8))
	failed++
return

;USB Device Framework (CV)
Test9:
USBHubRequired()
FileMove, Test9.txt, Test9.old, 1
Run, usbCheckApp -chap9 0 %vid% %pid% Test9, ,min
FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 9 started `n , DTM_Device_Tests.log
TimeBar(1453,"usbcheckapp.exe",9)
if not (GetResult(9))
	failed++
return

;USB Driver Level Re-Enumeration
Test10:
USBHubRequired()
FileMove, Test10.txt, Test10.old, 1
RunWait, devedinstaller.msi /quiet, ,min
Run, Driver_popup.exe
RunWait, devcon install USBVirtTest.inf root\USBVirtTest, ,min
Run, UsbVirtTest.exe %vid% %pid%, ,min
FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 10 started `n , DTM_Device_Tests.log
TimeBar(17,"usbvirttest.exe",10)
RunWait, devcon remove USBVirtTest.inf root\USBVirtTest, ,min
RunWait, msiexec /x devedinstaller.msi /q, ,min
process, close , Driver_popup.exe
FileMove, $console, Test10.txt,1
if not (GetResult(10))
	failed++
return

;USB HCT Selective Suspend
Test11:
USBHubRequired()
FileMove, Test11.txt, Test11.old, 1
RunWait, regedit.exe /s add.reg, ,min
Run, usbhct.exe -s -d %vid%/%pid% -l Test11, ,min
FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 11 started `n , DTM_Device_Tests.log
TimeBar(412,"usbhct.exe",11)
RunWait, regedit.exe /s del.reg, ,min
if not (GetResult(11))
	failed++
return

;USB Serial Number
Test12:
FileMove, Test12.txt, Test12.old, 1
Msgbox,49,Device WHQL Qualification Tests - Serial Test, Please attach *** ANOTHER *** device with the *** SAME PID / VID *** with DIFFERENT Serial number.

IfMsgBox, Cancel
        ExitApp
        
Run, usbnum.exe /d %vid%%pid%, ,min
FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test 12 started `n , DTM_Device_Tests.log
TimeBar(3,"usbnum.exe",12)
FileMove, usbnum.log.xml, Test12.xml, 1
FileMove, usbnum.log.txt , Test12.txt, 1
if not (GetResult(12))
	failed++
return

End:
if (failed)
	Msgbox,48, Device WHQL Qualification Test Cycle, Cycle completed, but %failed% Tests were failed !
else
	MsgBox, ,Device WHQL Qualification Test Cycle, Cycle completed, All tests have passed !



; ---------------------------------------------------Functions----------------------------------------------------

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
    FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Process cleanup `n , DTM_Device_Tests.log    
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
        FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - %process% process %more% seconds early `n , DTM_Device_Tests.log      
        progress, OFF
        return 0
        }
	Progress, %A_index%	
    sleep, 1000
	}
process, waitclose, %process% ;process closed after estiamtion
progress, OFF
}

/*
;Take time for each test
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
*/

;Display "Passed" or "Failed" on Gui
GetResult(ID)
{
	Gui, Font, S10 bold ,Verdana
	Gui, add, text , x15 y0, 
	
	loop, 12
	{
		Gui, add, text, x15 yp+20 ,Test %A_index%:    
	}
	Gui, Show, y130 h280 w200, Test Results
    
    if (ID=0)
        return

    if (ID=7 OR ID=4 OR ID=3 OR ID=5 OR ID=6 OR ID=8 OR ID=11 OR ID=12)
    {                
        if (Pass(ID,"Total=1, Passed=1, Failed=0"))
        {
            FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test %ID% has passed `n , DTM_Device_Tests.log
            line:=ID*20
            Gui, add, text, cgreen x80 y%line% ,Pass
            Gui, Show, y130 h280 w200, Test Results
            return 1
        }    
    }
    
    if (ID=9)
    {    
        if (Pass(ID,"Total=15, Passed=15, Failed=0"))
        {
            FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test %ID% has passed `n , DTM_Device_Tests.log
            line:=ID*20
            Gui, add, text, cgreen x80 y%line% ,Pass
            Gui, Show, y130 h280 w200, Test Results
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
            line:=ID*20
            Gui, add, text, cgreen x80 y%line% ,Pass
            Gui, Show, y130 h280 w200, Test Results
            return 1            
        }
    }    

    if (ID=1 OR ID=2)
    {
        if (Pass(ID,"Tests Passed          1 100%"))
        {
            FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test %ID% has passed `n , DTM_Device_Tests.log
            line:=ID*20
            Gui, add, text, cgreen x80 y%line% ,Pass
            Gui, Show, y130 h280 w200, Test Results
            return 1
        }    
    }    
    
    FileAppend , %A_DD%/%A_MM%/%A_YYYY% %A_Hour%:%A_Min%:%A_Sec% - Test %ID% has failed `n , DTM_Device_Tests.log
    line:=ID*20
    Gui, add, text, cred x80 y%line% ,Failed
    Gui, Show, y130 h280 w200, Test Results
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
Check("usbnum.exe")
Check("add.reg")
Check("del.reg")
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
	
	if (hubPop)
        return
    
	Msgbox,49,Device WHQL Qualification Tests - HUB Required, This test requires the device to be connected *** THROUGH A USB HUB *** to the Host (self powered preferable).`n`nClick OK when you're done.
	
	IfMsgBox, Cancel
        ExitApp
	
	hubPop=1
}

;Request direct connection to the Host
USBDirectRequired()
{
	global directPop
	
	if (directPop)
        return
    
    Msgbox,49,Device WHQL Qualification Tests - No USB Hub, This test requires the device to be connected *** DIRECTLY *** (no USB Hub) to the Host`n`nClick OK when you're done.
	
    IfMsgBox, Cancel
        ExitApp
    
    directPop=1
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
