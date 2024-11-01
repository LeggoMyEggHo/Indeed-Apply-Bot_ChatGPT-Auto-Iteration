#Requires AutoHotkey v2.0

#Include ..\Helper_Functions\CheckWindowTitle.ahk
#Include ..\Helper_Functions\ShowToolTipWithTimer.ahk
#Include ..\Helper_Functions\CallFunction.ahk
#Include ..\Helper_Functions\Random.ahk

#SingleInstance Force

HandleCurrentPage(rootElement, functionToCall, titleIdentifier := "") {

    ; Continue handling pages until no more valid actions are detected
    Loop {
        success := false
        loopCount := 1
        ; If no titleIdentifier is provided, check the current window title
        titleIdentifier := CheckWindowTitle(script := "IndeedApplySimple.ahk")

        ; Log or display the identified title
        ;MsgBox("Handling page based on title: " titleIdentifier)

        ; Call the corresponding function based on the titleIdentifier
        functionToCall := indeedWindowTitleFunctionMap[titleIdentifier]
        success := CallFunction(functionToCall, rootElement)

        ; Check for the success of the previous function call
        if success {
            ShowToolTipWithTimer("Successfully called function for title: " titleIdentifier)

            ; Introduce a delay to allow any page transition to occur
            RandomDelay(1300, 1400)
            
            ; Recheck the window title to determine the next action dynamically

            loop 10 {
                newTitleIdentifier := CheckWindowTitle(script := "IndeedApplySimple.ahk")
                if (newTitleIdentifier == titleIdentifier) {
                    Sleep(500)
                    continue
                } else if (newTitleIdentifier != titleIdentifier) {
                    ShowToolTipWithTimer("Title changed after handling. TitleIdentifier: " newTitleIdentifier " Title: " titleIdentifier)
                    break
                }
            }
        } else {
            ; If function is not found or callable, log the error and break the loop
            ShowToolTipWithTimer("No callable function found for title: " titleIdentifier)
            FileAppend("Error: No callable function found for title: " titleIdentifier "`n", "page_debug_log.txt")
            break
        }
        ; The loop will continue to re-evaluate the current window title and handle accordingly
        loopCount++
    }
}