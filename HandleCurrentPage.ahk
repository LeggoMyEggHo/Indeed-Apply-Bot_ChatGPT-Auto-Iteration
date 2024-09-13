#Requires AutoHotkey v2.0

#Include CheckWindowTitle.ahk
#Include ShowToolTipWithTimer.ahk
#Include CallFunction.ahk
#Include Random.ahk

#SingleInstance Force

HandleCurrentPage(rootElement, functionToCall, titleIdentifier := "") {

    ; Initialize the success flag to false
    success := false

    ; Continue handling pages until no more valid actions are detected
    Loop {
        if titleIdentifier == "" {
            ; If no titleIdentifier is provided, check the current window title
            titleIdentifier := CheckWindowTitle()
        }

        ; Log or display the identified title
        ;MsgBox("Handling page based on title: " titleIdentifier)

        ; Call the corresponding function based on the titleIdentifier
        success := CallFunction(functionToCall, rootElement)

        ; Check for the success of the previous function call
        if success {
            ShowToolTipWithTimer("Successfully called function for title: " titleIdentifier)

            ; Introduce a delay to allow any page transition to occur
            RandomDelay(1100, 1400)
            
            ; Recheck the window title to determine the next action dynamically
            ; If the window title is still the same, break to avoid an infinite loop
            newTitleIdentifier := CheckWindowTitle()
            loop 10 {
                if (newTitleIdentifier == titleIdentifier) {
                    Sleep(500)
                    newTitleIdentifier := CheckWindowTitle()
                    continue
                } else if (newTitleIdentifier != titleIdentifier) {
                    ShowToolTipWithTimer("Title changed after handling.")
                    break
                } else {
                    ; If no success or nothing more to handle, exit the loop
                    ShowToolTipWithTimer("No more actions to perform. Continuing the next iteration of the loop.", , 2000)
                    break ; Exit the loop
                }
            }
        } else {
            ; If function is not found or callable, log the error and break the loop
            ShowToolTipWithTimer("No callable function found for title: " titleIdentifier)
            FileAppend("Error: No callable function for title: " titleIdentifier "`n", "page_debug_log.txt")
            break
        }
        ; The loop will continue to re-evaluate the current window title and handle accordingly
    }
}