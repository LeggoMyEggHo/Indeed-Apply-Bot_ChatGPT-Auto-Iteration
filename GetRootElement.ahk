#Requires AutoHotkey v2.0
#Include ..\UIA.ahk
#SingleInstance Force

GetRootElement(hwnd) {
    rootElement := UIA.ElementFromHandle(hwnd)
    if !rootElement {
        ToolTip("Failed to get root element.")
        SetTimer () => ToolTip(""), -1000
        ExitApp
    } else {
        return rootElement
    }
}