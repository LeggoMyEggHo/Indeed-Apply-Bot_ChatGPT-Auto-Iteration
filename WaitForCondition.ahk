#Requires AutoHotkey v2.0

WaitForCondition(conditionFunc, timeout := 5000, checkInterval := 50) {
    startTime := A_TickCount

    ; Continuously check the condition until the timeout or condition is met
    while (A_TickCount - startTime < timeout) {
        if conditionFunc() {
            return true  ; Condition met
        }
        Sleep(checkInterval)  ; Wait a little before checking again
    }

    return false  ; Timeout reached without meeting condition
}