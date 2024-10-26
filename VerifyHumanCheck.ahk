#Requires AutoHotkey v2.0

#Include ..\UIA.ahk
#Include ..\Helper_Functions\ShowToolTipWithTimer.ahk
#Include ..\Helper_Functions\ClickElementByPath.ahk
#Include ..\ahk-v2-libraries-main\Lib\Misc.ahk

#SingleInstance Force

VerifyHumanCheck(rootElement) {
    Sleep(5000)
    try {
        ; Use FindFirst to locate the "Verify you are human" checkbox
        checkbox := rootElement.FindFirst({
            Type: "CheckBox",
            LocalizedType: "check box",
            Name: "Verify you are human",
            FrameworkId: "Chrome"
        })
    } catch {
        ShowToolTipWithTimer("Failed to find 'Verify you are human' checkbox.")
        checkbox := ""
        return false
    }

    if checkbox != "" {
        ClickElementByPath(checkbox)
        RandomDelay(1000, 1500)  ; Wait for the verification to complete
        return true
    }
}