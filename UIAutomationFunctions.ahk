#Requires AutoHotkey v2.0

#Include ..\UIA.ahk
#Include ..\Helper_Functions\GetElementCoordinates.ahk

#SingleInstance

CheckForPageChange(rootElement, initialWinTitle) {

    if !(WinWaitNotActive(initialWinTitle,, 2.5)) {
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
    HandleInputElements(rootElement)
    HandleRadioButtons(rootElement)
    HandleComboBoxes(rootElement)

    initialWinTitle := WinGetTitle("A")
    if ClickElementByPath("VRq0", rootElement) {
        if CheckForPageChange(rootElement, initialWinTitle) {
            return true
        }

        HandleInputElements(rootElement)
        HandleRadioButtons(rootElement)
        HandleComboBoxes(rootElement)
        
        ClickElementByPath("VRq0", rootElement)

        if CheckForPageChange(rootElement, initialWinTitle) {
            return true
        }

        HandleInputElements(rootElement)
        HandleRadioButtons(rootElement)
        HandleComboBoxes(rootElement)
        
        ClickElementByPath("VRq0", rootElement)

        if CheckForPageChange(rootElement, initialWinTitle) {
            return true
        }

        ClickElementByPath("VRq0", rootElement)

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

HandleIgnoredTitles(rootElement) {
    initialWinTitle := WinGetTitle("A")
    if ClickElementByPath("VRq0", rootElement) {
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

HandleComboBoxes(rootElement) {
    comboBoxes := rootElement.FindAll({ LocalizedType: "combo box" })
    arrLengthA := GetArrayLength(comboBoxes)
    if arrLengthA != 0 {
        for comboBox in comboBoxes {
            ; Retrieve and adjust the element's coordinates (adjust with ScrollIntoView and Send("{WheelDown}"))
            coords := GetElementCoordinates(comboBox, rootElement)
            ;RandomMouseMove(coords.x, coords.y, coords.elementRight, coords.elementBottom)
            ;MouseMove(comboBox.Location.x, comboBox.Location.y, speed := 10)
            ;MouseGetPos(&currentX, &currentY)
            ;MsgBox("currentX: " currentX " currentY: " currentY "`ncombo box coords: " comboBox.Location.x " " comboBox.Location.y " " comboBox.Location.w " " comboBox.Location.h)
            if ClickElementByPath(comboBox, rootElement) {
                Sleep(500)
                children := comboBox.FindAll()
                for child in children {
                    childNames .= child.Name "`n"
                }
                ;MsgBox("Found the following combo box children:`n" childNames)

                for child in children {
                    if InStr(child.Name, "United States") || InStr(child.Name, "Oklahoma") || InStr(child.Name, " OK ") || InStr(child.Name, "I decline to identify") {
                        Sleep(300)
                        child.Invoke()
                        Sleep(1000)
                        break
                    }
                }

                try {
                    ;grandchildren := comboBox.Children[1].Children
                    ;for grandchild in grandchildren {
                    ;    if InStr(grandchild.Name, "I decline to identify") {
                    ;        grandchild.Invoke()
                    ;        break
                    ;    }
                    ;}
                } catch as e {
                    errorMessage := "Unable to find combo box grandchildren: " e.Message
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
                
            }
        }
        Sleep(300)
        ; Check if the number of combo boxes has changed once a combo box has been clicked
        comboBoxes := rootElement.FindAll({ LocalizedType: "combo box" })
        arrLengthB := GetArrayLength(comboBoxes)
        if arrLengthA != arrLengthB {
            for combox in comboBoxes {
                if ClickElementByPath(combox, rootElement) {
                    Sleep(200)
                    children := combox.FindAll()
                    for child in children {
                        childNames .= child.Name "`n"
                    }
                    ;MsgBox("Found the following combo box children:`n" childNames)

                    for each, child in children {
                        if each == 1 {
                            continue
                        }
                        if InStr(child.Name, "Oklahoma") {
                            child.Invoke()
                            break
                        }
                    }
                }
            }
        }

        return true
    }
    

    return false
}

HandleScreenerQuestions(rootElement) {
    successful := false  ; Track if we succeeded in any step
    global answerReview
    global failedContinue

    while !successful {  ; Loop until successful or we decide to exit
        if failedContinue {
            
        }
        ; Handle day and time options
        if HandleDayOptions(rootElement) {
            ShowToolTipWithTimer("Finished handling day and time options.")
            successful := true
            RandomDelay(100, 300)
        }

        ; Handle radio buttons
        if HandleRadioButtons(rootElement, answerReview) {
            ShowToolTipWithTimer("Finished handling radio buttons.")
            successful := true
            RandomDelay(100, 200)
        }

        ; Handle spinner & edit elements
        if HandleIndeedInputElements(rootElement) {
            ShowToolTipWithTimer("Finished handling spinner elements.")
            successful := true
            RandomDelay(100, 200)
        }

        ; Handle checkbox elements in JobApplicationQA.ahk
        if HandleCheckboxes(rootElement) {
            ShowToolTipWithTimer("Finished handling checkboxes.")
            successful := true
            RandomDelay(100, 200)
        }

        ; Handle combo boxes
        if HandleComboBoxes(rootElement) {
            ShowToolTipWithTimer("Finished handling combo boxes.")
            successful := true
            RandomDelay(100, 200)
        }

        ; Try multiple paths for the continue button
        try {
            continueElement := rootElement.FindFirst({ LocalizedType: "button", Name: "Continue" })
        } catch {
            continueElement := ""
        }
        
        global failedContinue
        ShowToolTipWithTimer("Attempting to click 'Continue' button.")

        if continueElement {
            initialWinTitle := WinGetTitle("A")
            ClickElementByPath(continueElement, rootElement)
            if CheckForPageChange(rootElement, initialWinTitle) {
                ShowToolTipWithTimer("Successfully clicked 'Continue' button with path.")
                return true  ; Exit function on success
            } else {
                if failedContinue {
                    FileAppend("Failed twice to click 'Continue' button.", "apply_debug_log.txt")
                    return false  ; Exit function after repeated failure
                }
                Sleep(3000)
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