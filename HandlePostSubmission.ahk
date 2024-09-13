#Requires AutoHotkey v2.0
#Include %A_ScriptDir%\Lib\UIA.ahk
#Include Utility.ahk
#SingleInstance Force

; Function to handle the post-application submission actions
HandlePostSubmission(rootElement) {
    finishTestExists := true
    finishExists := true
    reviewAndShareExists := true
    success := true
    global currentParentElement ; Use the global currentParentElement
    currentElement := "" ; Initialize a variable to keep track of the current element

    ; Handle the post-application submission actions
    try {
        ; Click on the "Finish test" button if it exists
        finishTestBtn := rootElement.FindFirst({Name: "Finish test", LocalizedType: "button"})
        currentElement := finishTestBtn ; Track the current element
        if finishTestBtn {
            finishTestBtn.ScrollIntoView()
            finishTestBtn.Click("left")
            Sleep(1100)
        } else {
            finishTestExists := false
        }
    } catch {
        ;MsgBox("currentElement: " currentElement)
        finishTestExists := false
    }

    try {
        ; Click on the "Finish" button if it exists
        finishBtn := rootElement.FindFirst({Name: "Finish", LocalizedType: "button"})
        currentElement := finishBtn ; Track the current element
        if finishBtn {
            finishBtn.ScrollIntoView()
            finishBtn.Click("left")
            Sleep(1100)
        } else {
            finishExists := false
        }
    } catch {
        ;MsgBox("currentElement: " currentElement)
        finishExists := false
    }

    try {
        ; Click on the "Review and share" button if it exists
        reviewAndShareBtn := rootElement.FindFirst({Name: "Review and share", LocalizedType: "button"})
        currentElement := reviewAndShareBtn ; Track the current element
        if reviewAndShareBtn {
            reviewAndShareBtn.ScrollIntoView()
            reviewAndShareBtn.Click("left")
            Sleep(1100)
        } else {
            ;MsgBox("currentElement: " currentElement)
            reviewAndShareExists := false
        }
    } catch {
        ;MsgBox("currentElement: " currentElement)
        reviewAndShareExists := false
    }

    ; If none of the buttons were found, mark success as false and return early
    if !finishTestExists && !finishExists && !reviewAndShareExists {
        success := false
    }

    ; Check if the script should stop early due to failure
    if !success {
        currentParentElement += 1
        return success
    }

    ; Continue with further steps only if elements were found
    try {
        Sleep(5000)
        ; Handle the assessments sharing page
        ; Find and select all "Share previous result" radio buttons
        hwnd := ActivateChromeWindow()
        rootElement := GetRootElement(hwnd)
        radioButtonsText := rootElement.FindAll({LocalizedType: "text"})

        for radioButtonText in radioButtonsText {
            currentParentElement := radioButtonText  ; Track the current element
            
            if InStr(radioButtonText.Name, "Share previous result") {
                FileAppend("Found 'Share previous result' text element: " radioButtonText.Name "`n", "HandlePostSubmission_debug_log.txt")
                
                ; Highlight the element for visual debugging
                radioButtonText.Highlight()
                
                ; Log that we're attempting to click the element
                FileAppend("Attempting to click 'Share previous result' element.`n", "HandlePostSubmission_debug_log.txt")
                
                ; Perform the click
                try {
                    radioButtonText.Click()
                    FileAppend("Successfully clicked 'Share previous result' element.`n", "HandlePostSubmission_debug_log.txt")
                } catch as e {
                    FileAppend("Error clicking 'Share previous result' element: " e.Message "`n", "HandlePostSubmission_debug_log.txt")
                }
                
                Sleep(300)  ; Small delay after the click
            }
        }

    } catch as e {
        ; Enhanced error reporting
        errorMessage := "Error handling Review and Share: " e.Message
        errorLine := "Line: " e.Line
        errorExtra := "Extra Info: " e.Extra
        errorFile := "File: " e.File
        errorWhat := "Error Context: " e.What
        
        ; Display detailed error information
        MsgBox(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat)
        
        ; Log the detailed error information
        FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n", "HandlePostSubmission_debug_log.txt")
    }

    try {
        Sleep(500)
        ; Now try to click the "Continue" button
        continueBtn := rootElement.FindFirst({Name: "Continue", LocalizedType: "button"})
        
        if !continueBtn {  ; If no button is found, log and return
            FileAppend("Continue button not found.`n", "JobApplicationQA_debug_log.txt")
            return false
        }
    
        currentElement := continueBtn  ; Track the current element
        FileAppend("Found 'Continue' button: " continueBtn.Name "`n", "JobApplicationQA_debug_log.txt")
        
        if continueBtn {
            if continueBtn.IsEnabled {
                continueBtn.Click("left")
                Sleep(5000)
                doneButton := rootElement.FindFirst({Name: "done", LocalizedType: "button"})
                if doneButton {
                    success := true
                    FileAppend("Done button found. Closing the tab.`n", "JobApplicationQA_debug_log.txt")
                    CloseTabWithCheck(rootElement)
                } else {
                    success := false
                    FileAppend("Done button not found. Closing the tab.`n", "JobApplicationQA_debug_log.txt")
                    CloseTabWithCheck(rootElement)
                }
            } else {
                FileAppend("Continue button is disabled. Closing the tab.`n", "JobApplicationQA_debug_log.txt")
                Sleep(2000)  ; Give time to read
                SendInput("{Ctrl down}w{Ctrl up}")  ; Close the current tab
                Sleep(100)
                ; Try to locate the "Leave" button
                try {
                    leaveButton := rootElement.FindFirst({
                        Type: "Button",
                        LocalizedType: "button",
                        Name: "Leave"
                    })

                    if leaveButton {
                        leaveButton.ScrollIntoView()
                        RandomDelay(100, 300)
                        SendInput("{Space}")
                        RandomDelay(500, 1000)
                        SetTimer(() => ToolTip(""), -1000)
                    } else {
                        ToolTip("No confirmation needed. Tab closed.")
                        SetTimer(() => ToolTip(""), -1000)
                    }
                } catch {
                    ToolTip("No confirmation needed. Tab closed.")
                    SetTimer(() => ToolTip(""), -1000)
                }
                success := false
            }
        } else {
            FileAppend("Continue button not found. Closing the tab.`n", "JobApplicationQA_debug_log.txt")
            Sleep(2000)
            SendInput("{Ctrl down}w{Ctrl up}")
            Sleep(100)
            SendInput("{Space}")
            success := false
        }

    } catch as e {
        ; Enhanced error reporting
        errorMessage := "Error handling the Continue button: " e.Message
        errorLine := "Line: " e.Line
        errorExtra := "Extra Info: " e.Extra
        errorFile := "File: " e.File
        errorWhat := "Error Context: " e.What
        
        ; Display detailed error information
        MsgBox(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat)
        
        ; Log the detailed error information
        FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n", "HandlePostSubmission_debug_log.txt")
    }

    ; If success is false, increment currentParentElement to ensure only one increment
    if !success {
        currentParentElement += 1
    }

    return success
}