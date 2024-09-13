#Requires AutoHotkey v2.0

#Include %A_ScriptDir%\Lib\UIA.ahk
#Include Random.ahk
#Include ShowToolTipWithTimer.ahk
#Include ClickElementByPath.ahk

#SingleInstance Force

VerifyHumanCheck(rootElement) {

    ; Use FindFirst to locate the "Verify you are human" checkbox
    checkbox := rootElement.FindFirst({
        Type: "CheckBox",
        LocalizedType: "check box",
        Name: "Verify you are human",
        FrameworkId: "Chrome"
    })

    if checkbox {
        ClickElementByPath(checkbox)
        RandomDelay(1000, 1500)  ; Wait for the verification to complete
        return true
    } else {
        ShowToolTipWithTimer("Failed to find 'Verify you are human' checkbox.")
    }
}