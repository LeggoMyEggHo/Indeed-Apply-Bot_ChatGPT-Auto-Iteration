#Requires AutoHotkey v2.0

#Include ..\UIA.ahk
#Include ..\Helper_Functions\GetElementCoordinates.ahk

#SingleInstance

GetContinueElement(rootElement) {
    ; Try multiple paths for the continue button
    try {
        continueElement := rootElement.FindFirst({ LocalizedType: "button", Name: "Continue" })
    } catch {
        continueElement := ""
    }

    if continueElement == "" {
        try {
            continueElement := rootElement.FindFirst({ LocalizedType: "button", Name: "Review your application" })
        } catch {
            continueElement := ""
        }
    }

    if continueElement == "" {
        try {
            continueElement := rootElement.FindFirst({ LocalizedType: "button", Name: "Next" })
        } catch {
            continueElement := ""
        }
    }

    return continueElement
}

CheckForPageChange(rootElement, initialWinTitle) {

    if !(WinWaitNotActive(initialWinTitle,, 2)) {
        try {
            requiredAnswers := rootElement.FindAll({LocalizedType: "alert" })
            if requiredAnswers {
                for i, alert in requiredAnswers {
                    FileAppend("Failed to click Continue due to Alert #" i ": " alert.Children[1].Name "`n", "apply_debug_log.txt")
                }
                ;MsgBox("Failed to click Continue due to Alerts. Returning false in CheckForPageChange()")
                return false
            }
        } catch as e {
            errorMessage := "Error in CheckForPageChange() when finding requiredAnswers: " e.Message
            errorLine := "Line: " e.Line
            errorExtra := "Extra Info: " e.Extra
            errorFile := "File: " e.File
            errorWhat := "Error Context: " e.What
            
            ; Display detailed error information
            ;MsgBox(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat)
            
            ; Log the detailed error information
            FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n", "apply_debug_log.txt")
        } 

        try {
            rootElement.FindFirst({ Name: "Go back", LocalizedType: "button" }).Click()
            Sleep(500)
            rootElement.FindFirst({ Name: "Go back", LocalizedType: "button" }).Click()
            WinWaitNotActive( "A",, 3)
            rootElement.FindFirst({ Name: "Continue", LocalizedType: "button" }).Click()
            if WinWaitNotActive( "A",, 3) {
                ;MsgBox("Successfully clicked Continue after going back a page. Returning true in CheckForPageChange()")
                return true
            }
            
        } catch as e {
            errorMessage := "Error in CheckForPageChange() when finding or clicking 'Go back' button: " e.Message
            errorLine := "Line: " e.Line
            errorExtra := "Extra Info: " e.Extra
            errorFile := "File: " e.File
            errorWhat := "Error Context: " e.What
            
            ; Display detailed error information
            ;MsgBox(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat)
            
            ; Log the detailed error information
            FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n", "apply_debug_log.txt")
            
            return false
        }
    } else {
        return true
    }
}

HandleInvoluntaryWindowTitleA(rootElement) {
    ShowToolTipWithTimer("Skipping involuntary window.")

    HandleScreenerQuestionsWrapper(rootElement)

    return true
}

HandleIgnoredTitles(rootElement) {
    initialWinTitle := WinGetTitle("A")
    try {
        continueBtn := rootElement.FindFirst({ Name: "Continue", LocalizedType: "button" })
    } catch {
        continueBtn := "VRq0"
    }

    if ClickElementByPath(continueBtn, rootElement) {
        ShowToolTipWithTimer("Skipping pointless window.")
        if !CheckForPageChange(rootElement, initialWinTitle) {
            global strSkipElementsNames := ""
            skipElements := rootElement.FindAll()
            for i, element in skipElements {
                if element.Name != "Go back" && element.Name != "Continue" {
                    strSkipElementsNames .= element.Name "---"
                }
            }

            FileAppend("Skipping elements: " strSkipElementsNames "`n", "skip_log.txt")

            return false
        }
        return true
    }

    return false
}

HandleResumeUpload(rootElement) {
    if ClickElementByPath("VRq0", rootElement) {
        ShowToolTipWithTimer("Clicked 'Continue' on the 'Upload or build a resume' page.")
        return true
    }
    return false
}

HandleRelevantXP(rootElement) {
    initialWinTitle := WinGetTitle("A")
    if ClickElementByPath("VRq0", rootElement) {
        ShowToolTipWithTimer("Clicked 'Continue' on the 'Add relevant work experience' page.")
        CheckForPageChange(rootElement, initialWinTitle)
        return true
    }
    return false
}

HandleDayOptions(rootElement) {
    try {
        ; Find the element that contains "Day options Day"
        dayElement := rootElement.FindFirst({ Name: "Day options Day", LocalizedType: "menu item" })
        ;ShowToolTipWithTimer("dayElement.Name: " dayElement.Name,, 2000)
    } catch {
        return false
    }

    try {
        if dayElement {
            ; Force a viable viewport before clicking
            GetElementCoordinates(dayElement, rootElement, true)
            Sleep(200)

            ; Directly click the path "VRqB" without further checks
            dayMenuItem := rootElement.ElementFromPath("VRqB")
            if dayMenuItem {
                dayMenuItem.Click("left")
                RandomDelay(200, 400)
                ; After clicking Day, click the Weekday option using path "V87"
                weekdayOption := rootElement.ElementFromPath("V87")
                if weekdayOption {
                    weekdayOption.Click("left")
                }
            }
        }

        ; Return true if both Day and Time options were handled
        return true
    } catch as e {
        if e.Message != "An element matching the criteria in HandleDayOptions(rootElement) was not found" {
                errorMessage := "Error in HandleDayOptions: " e.Message
                errorLine := "Line: " e.Line
                errorExtra := "Extra Info: " e.Extra
                errorFile := "File: " e.File
                errorWhat := "Error Context: " e.What
                
                ; Display detailed error information
                ;MsgBox(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat)
                
                ; Log the detailed error information
                FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n", "apply_debug_log.txt")
        }
        return false
    }
}

HandleScreenerQuestions(rootElement) {
    successful := false  ; Track if we succeeded in any step
    global answerReview
    global failedContinue

    ; needs an else {} added after each handle function so 

    while !successful {  ; Loop until successful or we decide to exit
        ; Handle day and time options
        if HandleDayOptions(rootElement) {
            ShowToolTipWithTimer("Finished handling day and time options.")
        }

        ; Handle spinner & edit elements
        if HandleIndeedInputElements(rootElement) {
            ShowToolTipWithTimer("Finished handling spinner elements.")
        }

        ; Handle checkbox elements in JobApplicationQA.ahk
        if HandleCheckboxes(rootElement) {
            ShowToolTipWithTimer("Finished handling checkboxes.")
        }

        ; Handle combo boxes
        if HandleComboBoxes(rootElement, answerReview) {
            ShowToolTipWithTimer("Finished handling combo boxes.")
        }

        ; Handle radio buttons
        if HandleRadioButtons(rootElement, answerReview) {
            ShowToolTipWithTimer("Finished handling radio buttons.")
        }

        continueElement := GetContinueElement(rootElement)
        
        ShowToolTipWithTimer("Attempting to click 'Continue' button.")

        if continueElement != "" {
            initialWinTitle := WinGetTitle("A")
            ClickElementByPath(continueElement, rootElement)
            if CheckForPageChange(rootElement, initialWinTitle) {
                successful := true
                failedContinue := false
                ShowToolTipWithTimer("Successfully clicked 'Continue' button with path.")
                return true  ; Exit function on success
            } else {
                if failedContinue {
                    successful := true ; Exit the while !successful loop even if we failed
                    failedContinue := false
                    initialWinTitle := WinGetTitle("A")
                    continueElement := GetContinueElement(rootElement)
                    ClickElementByPath(continueElement, rootElement)
                    if CheckForPageChange(rootElement, initialWinTitle) {
                        successful := true
                        ShowToolTipWithTimer("Successfully clicked 'Continue' button with path.")
                        return true  ; Exit function on success
                    } else {
                        FileAppend("Failed three times to click 'Continue' button.`n", "apply_debug_log.txt")
                        return false  ; Exit function after repeated failure
                    }
                }
                ShowToolTipWithTimer("Setting FailedContinue to true.")
                failedContinue := true
                ; Continue to next iteration of loop
            }

        } else {
            ; Final title check before deciding to close the tab
            if WinGetTitle("A") == screenerQuestionsTitle {
                ShowToolTipWithTimer("Unable to find 'Continue' button.")
                RandomDelay(800, 1200)
                FileAppend("Form did not advance after multiple attempts. Missing required fields.`n", "apply_debug_log.txt")
            } else {
                return true  ; If title changed, exit function successfully
            }
        }

        ; Check if any handling succeeded
        if successful {
            return true
        } else {
            ShowToolTipWithTimer("All attempts to handle screener questions failed.")
            return false
        }
    }
}


HandleScreenerQuestionsWrapper(rootElement) {
    global currentParentElement
    if !HandleScreenerQuestions(rootElement) {
        try {
            elements := rootElement.FindAll()  ; Find all elements on the screen
            logFile := "skip_log.txt"
            
            for element in elements {
                if element.IsRequiredForForm {
                    elementDetails := "Name: " element.Name "`nType: " element.LocalizedType "`nAutomationId: " element.AutomationId "`nIsRequiredForForm: " element.IsRequiredForForm "`n`n"
                    FileAppend(elementDetails, logFile)
                }
            }

            ShowToolTipWithTimer("All attempts failed. Logging and closing the tab.")
            ;MsgBox("All attempts failed.")
            Sleep(1000)
            CloseTabWithCheck(rootElement)
            RandomDelay(200, 400)
        } catch as e {
            ShowToolTipWithTimer("Error logging elements: " e.Message)
            FileAppend("Error logging elements: " e.Message "`n", logFile)
            FileAppend("Logging elements with IsRequiredForForm:1:`n", logFile)
        }

        currentParentElement++
        RandomDelay(200, 400)
    }
    return true
}

HandleIndeedInputElements(rootElement) {
    global resume
    script := "IndeedApplySimple.ahk"
    HandleInputElements(rootElement, script, specifiedPrompt := "", resume)
}

HandleNotInterested(parentPath, rootElement) {
    parentElement := rootElement.WaitElementFromPath(parentPath, 2000)

    jobNamePath := parentPath . "K0"
    ;MsgBox(jobNamePath)

    childrenCheck := parentElement.FindAll()
    ;MsgBox(GetArrayLength(childrenCheck))

    if GetArrayLength(childrenCheck) > 0 {
        jobNameElement := rootElement.WaitElementFromPath(jobNamePath, 2000)
        jobName := jobNameElement.Name
        jobName := RegExReplace(jobName, "full details of ", "")
        
        jobActionsName := "Job actions for " jobName " is collapsed"
        ShowToolTipWithTimer("jobActionsName: " jobActionsName,, 2000)
        parentElement.FindFirst({ LocalizedType: "menu item", Name: jobActionsName }).Highlight()
        parentElement.FindFirst({ LocalizedType: "menu item", Name: jobActionsName }).Click()
        Sleep(300)
        ; Find the newly substantiated menu that contains "Not interested"
        jobActionsName := "Job actions for " jobName
        jobActionsMenu := rootElement.FindFirst({ LocalizedType: "menu", Name: jobActionsName }).Highlight()
        jobActionsMenu := rootElement.FindFirst({ LocalizedType: "menu", Name: jobActionsName })
        ShowToolTipWithTimer("found " jobActionsMenu.Name,, 2000)

        jobActionsMenu.FindFirst({ LocalizedType: "menu item", Name: "Not interested" }).Highlight()
        jobActionsMenu.FindFirst({ LocalizedType: "menu item", Name: "Not interested" }).Click()
        return true
    }

    return false
}

HandleDismissThis(parentPath, rootElement) {
    parentElement := rootElement.WaitElementFromPath(parentPath, 2000)

    jobNamePath := parentPath . "K0"
    ;MsgBox(jobNamePath)

    childrenCheck := parentElement.FindAll()
    ;MsgBox(GetArrayLength(childrenCheck))

    if GetArrayLength(childrenCheck) > 0 {
        childElementName := "Non job content: Strengthen your profile menu actions"
        parentElement.FindFirst({ LocalizedType: "menu item", Name: childElementName }).Highlight()
        parentElement.FindFirst({ LocalizedType: "menu item", Name: childElementName }).Click()
        Sleep(500)

        ;  find the newly instantiated menu that contains "Dismiss this"
        jobActionsMenuName := "Non job content: Strengthen your profile menu actions"
        rootElement.FindFirst({ LocalizedType: "menu", Name: jobActionsMenuName }).Highlight()
        jobActionsMenu := rootElement.FindFirst({ LocalizedType: "menu", Name: jobActionsMenuName })
        
        jobActionsMenu.FindFirst({ LocalizedType: "menu item", Name: "Dismiss this" }).Highlight()
        jobActionsMenu.FindFirst({ LocalizedType: "menu item", Name: "Dismiss this" }).Click()
        Sleep(100)

        return true
    }

    return false
}