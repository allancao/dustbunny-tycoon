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

#s::
Run, "C:\Windows\Sysnative\SnippingTool.exe"
KeyWait, LButton, D
KeyWait, LButton

Sleep, 100
InputBox, Name, Enter Cliping Name

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