#Requires AutoHotkey v2.0

#Include ..\Helper_Functions\ShowToolTipWithTimer.ahk
#Include ..\Helper_Functions\TabInteraction.ahk

#SingleInstance

HandleCurrentIndeedPage(rootElement) {
    ; Get the current window title to determine the titleIdentifier
    script := "IndeedApplySimple.ahk"
    titleIdentifier := CheckWindowTitle(script)
    ; Retrieve the corresponding function from the indeedWindowTitleFunctionMap
    global functionToCall
    functionToCall := indeedWindowTitleFunctionMap[titleIdentifier]
    Sleep(100)
    HandleCurrentPage(rootElement, functionToCall, titleIdentifier)
}

HandlePageNotFound(rootElement) {
    ShowToolTipWithTimer("Page not found. Closing the tab.")
    CloseTabWithCheck(rootElement)
    return true
}

HandlePageLoad(rootElement) {
    Sleep(2000)
    HandleCurrentIndeedPage(rootElement)
}

HandleDocumentUpload(rootElement) {

    try {
        reviewApplicationBtn := rootElement.FindFirst({ Name: "Review your application", LocalizedType: "button" })
    } catch {
        reviewApplicationBtn := ""
    }

    try {
        continueBtn := rootElement.FindFirst({ Name: "Continue", LocalizedType: "button" })
    } catch {
        continueBtn := ""
    }

    if reviewApplicationBtn != "" {
        ClickElementByPath(reviewApplicationBtn, rootElement)
        return true
    } else if continueBtn {
        ClickElementByPath(continueBtn, rootElement)
        return true
    } else {
        ShowToolTipWithTimer("Review your application button not found.")
        FileAppend("Review your application button not found: " "PageHandling_Debug_Log.txt", "PageHandling_Debug_Log.txt")
    }

    ; If no known buttons are found, log unknown buttons, close the tab, and skip to the next parent element
    try {
        global allButtonsStr := ""
        allButtons := rootElement.FindAll({ LocalizedType: "button" })
        for button in allButtons {
            allButtonsStr .= button.Name "`n"
        }
    } catch {
        allButtons := ""
    }
    FileAppend("HandleDocumentUpload failed. No known buttons found. Unknown buttons found: " allButtonsStr "`n", "PageHandling_Debug_Log.txt")
    CloseTabWithCheck(rootElement)
    try {
        currentParentElement++
    }
    return false
}

HandleQualCheck(rootElement) {
    try {
        criteria := { LocalizedType: "text" }
        elements := rootElement.FindAll(criteria)  ; Get all text elements in the window
        for element in elements {
            if element.LocalizedType = "text" && InStr(element.Name, "(Required)") {
                FileAppend("Required qualification: " element.Name ".`n", "required_qualifications.txt")
                FileAppend("End of required qualifications for this job.`n", "required_qualifications.txt")
            }
        }

        
    } catch as e {
        errorMessage := "Error in HandleQualCheck: " e.Message
        errorLine := "Line: " e.Line
        errorExtra := "Extra Info: " e.Extra
        errorFile := "File: " e.File
        errorWhat := "Error Context: " e.What
        
        ; Display detailed error information
        MsgBox(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat)
        
        ; Log the detailed error information
        FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n", "PageHandling_Debug_Log.txt")
    }

    try {
        applyAnywayButton := rootElement.FindFirst({ Name: "Apply anyway", LocalizedType: "button" })
        if applyAnywayButton {
            ClickElementByPath("VRq0/", rootElement)
        }
    } catch {
        applyAnywayButton := ""
    }

    Sleep(1500)

    try {
        continueApplyingButton := rootElement.FindFirst({ Name: "Continue applying", LocalizedType: "button" })
        if continueApplyingButton {
            if ClickElementByPath("VRq0/", rootElement) {
                return true
            }
        }
    } catch {
        continueApplyingButton := ""
    }

   if ClickElementByPath("VRq0", rootElement) {
        ShowToolTipWithTimer("Clicked 'continue to application' on the qualification check page.")
        return true
    }
    return false
}

HandleNoQualifications(rootElement) {
    ShowToolTipWithTimer("Handling 'No Qualifications' window.")

    if ClickElementByPath("VRq0", rootElement) {
        ShowToolTipWithTimer("Clicked on 'VRq0' for 'No Qualifications' window.")
        return true
    } else {
        ShowToolTipWithTimer("Failed to click 'VRq0' in 'No Qualifications' window.")
        return false
    }
}

HandleReviewJobApp(rootElement) {
    RandomDelay(1000, 2000)
    try {
        imNotARobotElement := rootElement.FindFirst({ Name: "I'm not a robot", LocalizedType: "check box" })
    } catch {
        imNotARobotElement := ""
    }

    if imNotARobotElement != "" {
        ClickElementByPath(imNotARobotElement, rootElement)
    }

    if ClickElementByPath("VRr0/", rootElement,, 5000) {
        ShowToolTipWithTimer("Clicked 'Submit' on the review job application page.")
        return true
    } else {
        MsgBox("Failed to click 'Submit' on the review job application page.")
        return HandleCurrentIndeedPage(rootElement)
    }
    return false
}

HandleApplicationSubmitted(rootElement) {
    global currentParentElement, totalAppliedJobs, sessionID
    Sleep(4000)
    totalAppliedJobs++
    FileAppend("`nSession ID: " sessionID " Total applied jobs: " totalAppliedJobs, "TotalAppliedJobs.txt")
    
    ; Handle post-submission actions if applicable
    if !HandlePostSubmission(rootElement) {
        ; If HandlePostSubmission does not trigger, close the tab and move on
        CloseTabWithCheck(rootElement)
        return false
    }

    return true
}

HandleIndeedApply(rootElement) {
    try {
        returnButton := rootElement.FindFirst({ Name: "Return to job search", LocalizedType: "button" })
    } catch {
        returnButton := ""
    }
    if returnButton != "" {
        ShowToolTipWithTimer("Return to job search button found. Closing the tab and moving to the next job.")
        CloseTabWithCheck(rootElement)
        return true
    } else {
        ShowToolTipWithTimer("Return to job search button not found.")
        CloseTabWithCheck(rootElement)
        return false
    }
}

