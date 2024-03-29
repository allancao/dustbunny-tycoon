;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         A.N.Other <myemail@nowhere.com>
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

^+v::
StringReplace, Clipboard, Clipboard, `n, %A_Space%, All
StringReplace, Clipboard, Clipboard, `r, %A_Space%, All
Send, ^v
Return

^+c::
clipboard =  ; Start off empty to allow ClipWait to detect when the text has arrived.
Send ^c
ClipWait, 2
if ErrorLevel
{
    MsgBox, The attempt to copy text onto the clipboard failed.
    return
}
StringReplace, Clipboard, Clipboard, `n, %A_Space%, All
StringReplace, Clipboard, Clipboard, `r, %A_Space%, All
IfWinExist, Microsoft Excel
{
	WinActivate 
	Send {F2}
	Sleep 100
	Send -%clipboard%|
}
else
{
	MsgBox No Excel
}
return

#s::
Run, "C:\Windows\Sysnative\SnippingTool.exe"
KeyWait, LButton, D
KeyWait, LButton

Sleep, 150
InputBox, Name, Enter Cliping Name
if ErrorLevel
{
	return
}
StringReplace, Name, Name, %A_SPACE%,, All

IfWinExist Snipping Tool
{
	WinActivate
	Send ^s

	;Does Not work:
	;WinWait,"Save As",,1
	Sleep, 1200

	Send %A_ScriptDir%\%Name%
	Send {Enter}
	Sleep, 500
	WinClose
	WinWaitClose

}
else
{
	return
}

sleep, 300

IfWinActive Microsoft Excel
{
	WinActivate
	Send img:%Name%
	sleep,100
	send ^s
	send {Enter}
}
else
{
	MsgBox No Excel
}

return