#Requires AutoHotkey v2.0
#Include ..\Helper_Functions\Random.ahk
#Include ..\Helper_Functions\ShowToolTipWithTimer.ahk

if FileExist("TabInteraction_debug_log.txt") {
    FileDelete("TabInteraction_debug_log.txt")
}

CloseTabWithCheck(rootElement) {
    ; Close the current tab
    SendInput("{Ctrl down}w{Ctrl up}")
    logFile := "TabInteraction_debug_log.txt"
    ShowToolTipWithTimer("Closing the tab.", 1000, 1000)
    FileAppend("Closing the tab.`n", logFile)

    ; Try to locate the "Leave" button
    try {
        leaveButton := rootElement.FindFirst({
            Type: "Button",
            LocalizedType: "button",
            Name: "Leave"
        })

        if leaveButton {
            ; If the "Leave" button is found, press Space to confirm closing the tab
            ShowToolTipWithTimer("Leave button detected. Pressing Space to confirm.")
            FileAppend("Leave button detected. Pressing Space to confirm.`n", logFile)
            SendInput("{Space}")
        }
    } catch {
        ; If FindFirst throws an error, it means the "Leave" button was not found
        ShowToolTipWithTimer("Finding 'Leave' button failed. Assuming no confirmation needed. Tab closed.")
        FileAppend("Finding 'Leave' button failed. Assuming no confirmation needed. Tab closed.`n", logFile)
    }
}