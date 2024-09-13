#Requires AutoHotkey v2.0
#SingleInstance Force

; Function to show ToolTip and automatically hide it after a given duration
ShowToolTipWithTimer(message, duration := 2000, sleepDuration := "") {
    ToolTip(message)
    SetTimer(() => ToolTip(""), -duration)  ; Hide ToolTip after the duration (in ms)

    if sleepDuration != "" {
        Sleep(sleepDuration)
    }
}