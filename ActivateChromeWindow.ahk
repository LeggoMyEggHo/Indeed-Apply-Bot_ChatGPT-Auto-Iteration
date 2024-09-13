#Requires AutoHotkey v2.0
#Include %A_ScriptDir%\Lib\UIA.ahk
#SingleInstance Force

; Function to activate the Chrome window
ActivateChromeWindow() {
    if hwnd := WinExist("ahk_exe chrome.exe") {
        WinActivate
        WinWaitActive("ahk_exe chrome.exe")
        return hwnd
    } else {
        ToolTip("Chrome window not found.")
        SetTimer () => ToolTip(""), -1000
        ExitApp
    }
}