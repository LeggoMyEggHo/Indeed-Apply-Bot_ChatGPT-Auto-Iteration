#Requires AutoHotkey v2.0
#SingleInstance

WaitForCondition(conditionFuncA, conditionFuncB := {}, timeout := 2000, checkInterval := 50) {
    startTime := A_TickCount
    logFile := "WaitForCondition_Debug_Log.txt"
    try {
        ; Continuously check the condition until the timeout or condition is met
        while (A_TickCount - startTime < timeout) {
            try {
                ; Check first condition
                if conditionFuncA() {
                    FileAppend("Condition A met.`n", logFile)
                    return true  ; Condition A met
                }
            } catch as e {
                FileAppend("Error in Condition A: " e.Message "`n", logFile)
            }
            
            try {
                ; Check second condition
                if conditionFuncB() {
                    FileAppend("Condition B met.`n", logFile)
                    return true  ; Condition B met
                }
            } catch as e {
                FileAppend("Error in Condition B: " e.Message "`n", logFile)
            } 
            
            try {
                ; Show a tooltip that also counts down the remaining timeout
                ShowToolTipWithTimer("Checking conditions. Time remaining: " ((timeout - (A_TickCount - startTime)) // 1000) " Seconds")
            } catch as e {
                FileAppend("Error in ShowToolTipWithTimer: " e.Message "`n", logFile)
            }

            Sleep(checkInterval)  ; Wait a little before checking again
        }
    } catch as e {
        FileAppend("Error in WaitForCondition: " e.Message "`n", logFile)
    }

    FileAppend("Timeout reached without meeting any condition.`n", logFile)
    return false  ; Timeout reached without meeting condition
}