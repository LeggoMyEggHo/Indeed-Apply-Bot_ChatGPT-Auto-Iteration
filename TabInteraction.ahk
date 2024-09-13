#Requires AutoHotkey v2.0
#Include Random.ahk
#Include ShowToolTipWithTimer.ahk

CloseTabWithCheck(rootElement) {
    ; Close the current tab
    SendInput("{Ctrl down}w{Ctrl up}")
    Sleep(800)
    logFile := "debug_log.txt"
    ShowToolTipWithTimer("Closing the tab.")
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
            leaveButton.ScrollIntoView()
            RandomDelay(100, 300)
            SendInput("{Space}")
            RandomDelay(500, 1000)
        }
    } catch {
        ; If FindFirst throws an error, it means the "Leave" button was not found
        ShowToolTipWithTimer("Finding 'Leave' button failed. Assuming no confirmation needed. Tab closed.")
        FileAppend("Finding 'Leave' button failed. Assuming no confirmation needed. Tab closed.`n", logFile)
    }
}