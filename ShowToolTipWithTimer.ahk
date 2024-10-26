#Requires AutoHotkey v2.0
#SingleInstance Force

; Function to show ToolTip with a visual timer
ShowToolTipWithTimer(message := "", duration := 2000, sleepDuration := "", visualTimer := false) {
    ToolTip(message)  ; Show the initial ToolTip

    if visualTimer {
        endTime := A_TickCount + duration
        SetTimer(UpdateToolTipTimer, 1000)  ; Set a timer to update the tooltip every second

        UpdateToolTipTimer() {  ; Define the timer function to update the tooltip
            remainingTime := endTime - A_TickCount
            seconds := remainingTime // 1000  ; Convert ms to seconds
            if (remainingTime <= 0) {
                ToolTip("")  ; Clear the tooltip when time is up
                SetTimer(UpdateToolTipTimer, "0")  ; Turn off the timer
            } else {
                ToolTip(message . "`nTime remaining: " . seconds . " seconds")  ; Update ToolTip with remaining time
            }
        }
    }

    ; Manage the duration of the tooltip separately
    SetTimer(() => ToolTip(""), -duration)

    ; Handle sleepDuration asynchronously
    if sleepDuration != "" {
        SetTimer(() => SleepFunction(sleepDuration), 0)  ; Run sleep function in a new timer
    }
}

SleepFunction(duration) {
    Sleep(duration)
}

; Example usage
;ShowToolTipWithTimer("This is a tooltip with a timer.", 10000, "", true)  ; 10 seconds with visual timer
