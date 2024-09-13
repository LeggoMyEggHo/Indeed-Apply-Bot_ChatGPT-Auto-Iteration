#Requires AutoHotkey v2.0

#Include %A_ScriptDir%\Lib\UIA.ahk
#Include JobApplicationQA.ahk
#Include HandlePostSubmission.ahk
#Include Utility.ahk
#Include ActivateChromeWindow.ahk
#Include GetRootElement.ahk
#Include CompanyReview.ahk
#Include Random.ahk
#Include TabInteraction.ahk
#Include ShowToolTipWithTimer.ahk
#Include ClickElementByPath.ahk
#Include WaitForElementByPath.ahk
#Include WaitForCondition.ahk
#Include CheckWindowTitle.ahk
#Include CallFunction.ahk
#Include HandleCurrentPage.ahk
#Include VerifyHumanCheck.ahk
#Include HandleInputElements.ahk

#SingleInstance Force

global success := false

HandleIgnoredTitles(rootElement, foundTitle) {
    if ClickElementByPath("VRq0", rootElement) {
        ToolTip("Skipping ignored title: " foundTitle)
        SetTimer () => ToolTip(""), -1000
        return true
    }

    return false
}

HandleJobSearch(rootElement) {
    global currentParentElement, parentPaths ; Use global variables

    ; Process the job search page, loop over parents, and handle child loops
    Loop {
        ToolTip("Starting a new page.")
        SetTimer () => ToolTip(""), -1000
        RandomDelay(400, 600)  ; Randomized delay before starting

        ; Iterate over parent elements starting from currentParentElement
        while (currentParentElement < parentPaths.Length) {
            parentPath := parentPaths[currentParentElement]
            ToolTip("Processing parent element: " currentParentElement " with path: " parentPath)
            SetTimer () => ToolTip(""), -1500

            success := false
            
            ; Click the parent element
            parentElement := rootElement.WaitElementFromPath(parentPath, 2000)
            if parentElement {
                ;MsgBox("Clicking parent element before any checks.")
                ClickElementByPath(parentElement, rootElement)
            } else {
                ToolTip("Failed to find parent element.")
                currentParentElement++ ; Increment to move to the next parent
                continue
            }

            ; Ensure the parent and "Easily apply" elements are waited for and found
            if CheckIfValid(rootElement, parentPath) {
                ToolTip("Skipping parent path " parentPath " due to applied or expired status.")
                SetTimer () => ToolTip(""), -1000
                RandomDelay(300, 500)  ; Randomized delay before continuing
                currentParentElement++ ; Increment to move to the next parent
                continue
            } else {
                Sleep(1000)
                ;MsgBox("CheckIfValid completed successfully.")
                ClickElementByPath("VRRu0r", rootElement, , 2000)
            }

            ; If no issues, proceed to the child loop handling
            ToolTip("Proceeding to HandleCurrentIndeedPage for parent: " parentPath)
            SetTimer () => ToolTip(""), -1000
            RandomDelay(300, 500)  ; Randomized delay before continuing
            HandleCurrentIndeedPage(rootElement)

            ToolTip("Finished processing parent element: " currentParentElement " with path: " parentPath)
            SetTimer () => ToolTip(""), -1000
        }

        ; If we've processed all parents, check for the "Next Page" link and click it if found
        if (currentParentElement >= parentPaths.Length) {
        HandleNextPage(rootElement)
        }
    }
}

; Function to handle clicking a "Next Page" link with randomization
HandleNextPage(rootElement) {
    global currentParentElement

    nextPageElement := rootElement.WaitElementFromPath("VRRt87/5", 3000)
    if nextPageElement && InStr(nextPageElement.Name, "Next Page") {
        ToolTip("Navigating to the next page.")
        RandomDelay(200, 500)  ; Randomized delay before action

        nextPageElement.ScrollIntoView()
        RandomDelay(400, 800)  ; Randomized delay after scrolling

        ClickElementByPath(nextPageElement)
        currentParentElement := 1
        RandomDelay(2500, 4000)  ; Randomized delay after clicking
        HandleCurrentIndeedPage(rootElement)
    } else {
        ToolTip("No more pages to process. Script completed.")
        SetTimer () => ToolTip(""), -5000
        Sleep(5000)
    }
}

; Function to handle Indeed titles
HandleIndeedTitles(script := "", titleCheck := "", timeout := 5000, checkInterval := 50, titles := "", keywordSearchTitles := "") {

    global screenerQuestionsTitle := "Answer screener questions from the employer | Indeed.com - Google Chrome",
        reviewJobAppTitle := "Review the contents of this job application | Indeed.com - Google Chrome",
        qualCheckTitle := "Qualification check | Indeed.com - Google Chrome",
        noQualificationsTitle := "It looks like you don’t have some relevant qualifications - Google Chrome",
        humanVerifyTitle := ["Just a moment... - Google Chrome", "Security Check - Indeed.com - Google Chrome"],  ; "Verify You Are Human" check
        pageNotFoundTitle := "Page Not Found - Indeed.com - Google Chrome",
        indeedApplyTitle := "Indeed Apply - Google Chrome",
        applicationSubmittedTitle := "Your application has been submitted | Indeed.com - Google Chrome",
        keywordSearchTitleKeywords := ["Jobs", "in", "| Indeed.com - Google Chrome"],  ; Keywords for job search pages
        resumeUploadTitle := "Upload or build a resume for this application | Indeed.com - Google Chrome",
        relevantXPTitle := "Add relevant work experience information | Indeed.com - Google Chrome",
        reviewQualificationsTitle := "Review these qualifications found in the job post - Google Chrome",
        loadingTitle := "Untitled - Google Chrome",
        ignoredWindowTitleA := "Questions from Indeed to improve your job matches - Google Chrome",
        ignoredWindowTitleB := "It looks like you may not have some common qualifications - Google Chrome"

    global indeedWindowTitleFunctionMap := Map(
        "screenerQuestionsTitle", HandleScreenerQuestionsWrapper,
        "reviewJobAppTitle", HandleReviewJobApp,
        "qualCheckTitle", HandleQualCheck,
        "noQualificationsTitle", HandleNoQualifications,
        "humanVerifyTitle", VerifyHumanCheck,
        "pageNotFoundTitle", HandlePageNotFound,
        "indeedApplyTitle", HandleIndeedApply,
        "applicationSubmittedTitle", HandleApplicationSubmitted,
        "resumeUploadTitle", HandleResumeUpload,
        "jobSearchTitle", HandleJobSearch,
        "relevantXPTitle", HandleRelevantXP,
        "reviewQualificationsTitle", HandleRelevantXP,
        "loadingTitle", HandlePageLoad,
        "ignoredWindowTitleA", HandleIgnoredTitles,
        "ignoredWindowTitleB", HandleIgnoredTitles
    )

    titles := [{ title: screenerQuestionsTitle, label: "screenerQuestionsTitle" }, { title: reviewJobAppTitle, label: "reviewJobAppTitle" }, { title: qualCheckTitle, label: "qualCheckTitle" }, { title: noQualificationsTitle, label: "noQualificationsTitle" }, { title: humanVerifyTitle, label: "humanVerifyTitle" }, { title: pageNotFoundTitle, label: "pageNotFoundTitle" }, { title: indeedApplyTitle, label: "indeedApplyTitle" }, { title: applicationSubmittedTitle, label: "applicationSubmittedTitle" }, { title: resumeUploadTitle, label: "resumeUploadTitle" }, { title: relevantXPTitle, label: "relevantXPTitle" }, { title: reviewQualificationsTitle, label: "reviewQualificationsTitle" }, { title: loadingTitle, label: "loadingTitle" }, { title: ignoredWindowTitleA, label: "ignoredWindowTitleA" }, { title: ignoredWindowTitleB, label: "ignoredWindowTitleB" },]

    ; Add dynamic job search titles
    keywordSearchTitles := [
        keywordSearchTitleKeywords[1],
        keywordSearchTitleKeywords[2],
        keywordSearchTitleKeywords[3]
    ]

    global foundTitle := ""

    ; Get the title of the current window if wasn't passed in
    if titlecheck == "" {
        titlecheck := WinGetTitle("A")
    }

    ; Wait for a matching title
    result := WaitForCondition(() => (
        titlecheck,
        foundTitle := GetMatchingTitle(script, titleCheck, titles, keywordSearchTitles),
        foundTitle != ""), timeout)

    ; If a matching title is found, return it
    if result && foundTitle {
        return foundTitle
    }
    ; If not matching title is found, log and return "unknownTitle"
    FileAppend("Unknown title: " WinGetTitle("A") "`n", "missing_titles_log.txt")
    return "unknownTitle"
}

HandleIndeedKewordSearchTitles(titleCheck, keywordSearchTitles) {
    ; Check for dynamic job search titles
    if InStr(titleCheck, keywordSearchTitles[1]) && InStr(titleCheck, keywordSearchTitles[2]) && InStr(titleCheck, keywordSearchTitles[3]) {
        return "jobSearchTitle"
    }
}

HandleResumeUpload(rootElement) {
    RandomDelay(200, 400)
    if ClickElementByPath("VRq0", rootElement) {
        ToolTip("Clicked 'Continue' on the 'Upload or build a resume' page.")
        SetTimer () => ToolTip(""), -1000
        return true
    }
    return false
}

HandleRelevantXP(rootElement) {
    RandomDelay(200, 400)
    if ClickElementByPath("VRq0", rootElement) {
        ToolTip("Clicked 'Continue' on the 'Add relevant work experience' page.")
        SetTimer () => ToolTip(""), -1000
        return true
    }
    return false
}

HandleReviewJobApp(rootElement) {
    if ClickElementByPath("VRr0/", rootElement) {
        ToolTip("Clicked 'Submit' on the review job application page.")
        SetTimer () => ToolTip(""), -1000
        return true
    }
    return false
}

HandleScreenerQuestionsWrapper(rootElement) {
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

            ToolTip("All attempts failed. Logging and closing the tab.")
            CloseTabWithCheck(rootElement)
            currentParentElement++
            RandomDelay(200, 400)
            return false
        } catch as e {
            ToolTip("Error logging elements: " e.Message)
            FileAppend("Error logging elements: " e.Message "`n", logFile)
            FileAppend("Logging elements with IsRequiredForForm:1:`n", logFile)
        }
    }
    return true
}

HandleQualCheck(rootElement) {
    ToolTip("Handling 'Qualifications Check' window")
    SetTimer () => ToolTip(""), -2000  ; Clears the ToolTip after 2 seconds

    try {
        criteria := { LocalizedType: "text" }
        elements := rootElement.FindAll(criteria)  ; Get all elements in the window
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
        FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n", "debug_log.txt")
    }

    if ClickElementByPath("VRq0", rootElement) {
        ToolTip("Clicked 'continue to application' on the qualification check page.")
        SetTimer () => ToolTip(""), -1000
        return true
    }
    return false
}

HandleNoQualifications(rootElement) {
    ToolTip("Handling 'No Qualifications' window.")
    SetTimer () => ToolTip(""), -2000

    if ClickElementByPath("VRq0", rootElement) {
        ToolTip("Clicked on 'VRq0' for 'No Qualifications' window.")
        SetTimer () => ToolTip(""), -1000
        RandomDelay(300, 500)
        return true
    } else {
        ToolTip("Failed to click 'VRq0' in 'No Qualifications' window.")
        SetTimer () => ToolTip(""), -2000
        RandomDelay(300, 500)
        return false
    }
}

HandlePageNotFound(rootElement) {
    ToolTip("Page not found. Closing the tab.")
    SetTimer () => ToolTip(""), -1000
    CloseTabWithCheck(rootElement)
    RandomDelay(200, 400)
    return true
}

HandlePageLoad(rootElement) {
    Sleep(2000)
    HandleCurrentIndeedPage(rootElement)
}

HandleIndeedApply(rootElement) {
    returnButton := rootElement.FindFirst({ Name: "Return to job search", LocalizedType: "button" })
    if returnButton {
        ToolTip("Return to job search button found. Closing the tab and moving to the next job.")
        CloseTabWithCheck(rootElement)
        RandomDelay(200, 400)
        return true
    } else {
        ToolTip("Return to job search button not found.")
        RandomDelay(400, 800)
        return false
    }
}

HandleApplicationSubmitted(rootElement) {
    global currentParentElement
    RandomDelay(300, 500)
    ; Handle post-submission actions if applicable
    if !HandlePostSubmission(rootElement) {
        ; If HandlePostSubmission does not trigger, close the tab and move on
        ;MsgBox("No post-submission actions needed. Closing the tab.")
        Sleep(5000)
        CloseTabWithCheck(rootElement)
        RandomDelay(200, 500)  ; Randomized delay before moving to the next parent
        return true
    }

    return false
}

CheckIfValid(rootElement, parentPath) {
    success := false
    global excludeList, excludeJobTypes ; Grab the global excludeList and excludeJobTypes variables from #Include JobApplicationQA.ahk

    ; Check for the parent element
    parentElement := rootElement.WaitElementFromPath(parentPath, 2000)  ; 2-second timeout as an example
    if !parentElement {
        MsgBox("Failed to find parent element for path " parentPath)
        return true ; Return true to skip processing if the parent element is not found
    }

    ; Find all children elements within the parent element
    ;MsgBox("Finding all children in parent element.")
    children := parentElement.FindAll()
    childNames := ""
    for child in children {
        childNames .= child.Name "`n"
    }
    ;MsgBox("Found the following children:`n" childNames)
    for child in children {

        ; Iterate through the children to check for button elements containing the target strings
        if (child.LocalizedType = "button" || child.LocalizedType = "text") {
            ; Check if any of the button's name contains a string from either the excludeList or excludeJobTypes
            for checkString in excludeList {
                if InStr(child.Name, checkString) {
                    ; If a match is found, get the first child's name
                    firstChild := children[1].Name

                    ; Remove leading "full details of '" and trailing '"'
                    cleanedName := RegExReplace(firstChild, "^full details of ", "")
                    cleanedName := RegExReplace(cleanedName, "`"$", "")

                    ; Append the result to a log file
                    logFile := "skip_log.txt"
                    FileAppend("Skipped parent path " parentPath " due to keyword match: " checkString " in job title: " cleanedName "`n`n", logFile)
                    
                    ToolTip("Skipped parent path " parentPath " due to keyword match: " checkString " in job title: " cleanedName "`n`n", logFile)
                    RandomDelay(300, 500)  ; Randomized delay before continuing
                    currentParentElement++ ; Increment to move to the next parent
                    return true  ; Indicate that the job should be skipped
                }
            }
        }

        ; Check if "Easily Apply" exists among the children
        if (child.Name == "Easily apply") {
            ;RandomDelay(100, 300)
            ;child.ScrollIntoView()
            ;RandomDelay(100, 300)
            ;MsgBox("Attempting to click 'Easily Apply'")
            ;ClickElementByPath(child)
            ; Instead of returning here, proceed to further checks
            success := true
            RandomDelay(200, 600)
            break ; Exit the loop if "Easily apply" is found, but continue with the rest of the function
        }
    }

    ; If no "Easily apply" was found, return true to skip this job
    if !success {
        ToolTip("No 'Easily apply' found; skipping job.")
        return true  ; Indicate that the job should be skipped
    }

    ; Check for "Applied opens in a new tab" or "This job has expired on Indeed"
    Sleep(1000)
    appliedElement := rootElement.ElementFromPath("VRRu0r")
    if appliedElement && appliedElement.Name == ("Applied opens in a new tab") {
        ToolTip("Job already applied to; skipping this job.")
        return true  ; Skip this parent element
    }

    expiredElement := rootElement.ElementFromPath("VRRuK")
    if expiredElement && expiredElement.Name == ("This job has expired on Indeed") {
        ToolTip("Job expired; skipping this job.")
        return true  ; Skip this parent element
    }

    ; Check for licenses in the "Licenses" group
    licensesGroup := rootElement.WaitElementFromPath({ Name: "Licenses", LocalizedType: "group" }, 2000)
    if licensesGroup {
        licenses := licensesGroup.FindAll()
        for license in licenses {
            if (license.LocalizedType == "text") {
                licenseName := license.Name
                if !(InStr(licenseName, "Driver License") || InStr(licenseName, "Driver's License")) {
                    ; Log any non-Driver License entries
                    logFile := "licenses_log.txt"
                    FileAppend("Found license: " licenseName "`n" "for job: " cleanedName "`n", logFile)
                }
            }
        }
    }

    ; If the job is eligible for application, return false to continue processing this job
    return false
}

HandleDayOptions(rootElement) {
    try {
        ; Find the element that contains "Day options Day"
        dayElement := rootElement.FindFirst({ Name: "Day options Day", LocalizedType: "menu item" })
        ToolTip(dayElement.Name)

        if dayElement {

            dayElement.ScrollIntoView()
            RandomDelay(200, 400)

            ; Directly click the path "VRqB" without further checks
            dayMenuItem := rootElement.ElementFromPath("VRqB")
            if dayMenuItem {
                dayMenuItem.Click("left")
                RandomDelay(200, 400)

                ; After clicking Day, click the Weekday option using path "V87"
                weekdayOption := rootElement.ElementFromPath("V87")
                if weekdayOption {
                    weekdayOption.Click("left")
                    RandomDelay(200, 400)
                }
            }
        }

        ; Return true if both Day and Time options were handled
        return true
    } catch as e {
        if e.Message != "An element matching the condition was not found" {
                errorMessage := "Error in HandleDayOptions: " e.Message
                errorLine := "Line: " e.Line
                errorExtra := "Extra Info: " e.Extra
                errorFile := "File: " e.File
                errorWhat := "Error Context: " e.What
                
                ; Display detailed error information
                MsgBox(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat)
                
                ; Log the detailed error information
                FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n", "debug_log.txt")
        }
        return false
    }
}

HandleIndeedInputElements(rootElement) {
    global resume
    HandleInputElements(rootElement, script := "IndeedApplySimple.ahk", specifiedPrompt := "", resume)
}

HandleScreenerQuestions(rootElement) {
    successful := false  ; Track if we succeeded in any step

    try {
        ; Handle day and time options
        if HandleDayOptions(rootElement) {
            ToolTip("Finished handling day and time options.")
            successful := true
            RandomDelay(100, 300)
        }

        ; Handle radio buttons
        if HandleRadioButtons(rootElement) {
            ToolTip("Finished handling radio buttons.")
            successful := true
            RandomDelay(100, 300)
        }

        ; Handle spinner elements
        if HandleInputElements(rootElement) {
            ToolTip("Finished handling spinner elements.")
            successful := true
            RandomDelay(100, 300)
        }

        ; Handle checkbox elements
        if HandleCheckboxes(rootElement) {
            ToolTip("Finished handling checkboxes.")
            successful := true
            RandomDelay(100, 300)
        }

        ; Try multiple paths for the continue button
        possibleContinuePaths := ["VRq0/", "Rq0", "VR0/"]
        for continuePath in possibleContinuePaths {
            ToolTip("Attempting to click 'Continue' button with path: " continuePath)
            if ClickElementByPath(continuePath, rootElement) {
                ToolTip("Successfully clicked 'Continue' button with path: " continuePath)
                SetTimer () => ToolTip(""), -1000
                successful := true

                ; Initial sleep and check if the form has changed
                Sleep(3500)
                if WinGetTitle("A") == screenerQuestionsTitle {
                    ; Handle spinner elements again
                    if HandleInputElements(rootElement) {
                        ToolTip("Finished handling spinner elements.")
                        successful := true
                        RandomDelay(100, 300)
                    }
                }
                if WinGetTitle("A") == screenerQuestionsTitle {
                    ToolTip("Form has not advanced; checking again...")
                    RandomDelay(1500, 2000)

                    ; Check the title again after the second sleep
                    if WinGetTitle("A") == screenerQuestionsTitle {
                        ToolTip("Form still has not advanced; attempting 'Continue' click again.")
                        RandomDelay(800, 1200)

                        ; Attempt to click "Continue" again
                        if ClickElementByPath(continuePath, rootElement) {
                            ToolTip("Clicked 'Continue' again. Waiting to verify if the form advances...")
                            RandomDelay(2500, 3000)

                            ; Final title check before deciding to close the tab
                            if WinGetTitle("A") == screenerQuestionsTitle {
                                ToolTip("Form did not advance; required spinners, edits, and radio buttons were likely missing.")
                                RandomDelay(800, 1200)
                                FileAppend("Form did not advance after multiple attempts: missing required fields `n", "debug_log.txt")
                                return false  ; Now it's safe to close the tab
                            }
                        }
                    }
                }

                return true  ; If the title changed, return true indicating success
            }
        }

        if successful {
            return true
        } else {
            ToolTip("All attempts to handle screener questions failed.")
            RandomDelay(800, 1200)
            return false
        }
    } catch as e {
        errorMessage := "Error in HandleScreenerQuestions: " e.Message
        errorLine := "Line: " e.Line
        errorExtra := "Extra Info: " e.Extra
        errorFile := "File: " e.File
        errorWhat := "Error Context: " e.What
        
        ; Display detailed error information
        ToolTip(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat)
        
        ; Log the detailed error information
        FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n", "debug_log.txt")
        return false
    }
}

HandleCurrentIndeedPage(rootElement) {
    ; Get the current window title to determine the titleIdentifier
    script := "IndeedApplySimple.ahk"
    titleIdentifier := CheckWindowTitle()
    ; Retrieve the corresponding function from the indeedWindowTitleFunctionMap
    global functionToCall := indeedWindowTitleFunctionMap[titleIdentifier]
    HandleCurrentPage(rootElement, functionToCall, titleIdentifier)
}

^j:: {
    ToolTip("Script started.")
    SetTimer () => ToolTip(""), -1000

     ; Create an InputHook object to capture input
    inputHook := InputHook("L1 M")  ; L1 limits input to one character, M suppresses keypress from being sent to active window
    inputHook.KeyOpt("{r}{a}", "{Enter}{Esc}")  ; Only accept 'r' or 'a' (Enable these keys)
    inputHook.Start()

    ; Wait for input to complete
    inputHook.Wait()

    ; Get input result
    input := inputHook.Input

    ; Handle input
    if (input == "r") {
        CheckCompanies()  ; Call CheckCompanies without passing any parameters
    } else if (input != "a") {
        MsgBox("Invalid input! Press 'r' for Review & Apply or 'a' for Apply.")
        return  ; Stop the script if invalid input
    }

    hwnd := ActivateChromeWindow()
    rootElement := GetRootElement(hwnd)
    global currentParentElement := 1  ; Initialize the currentParentElement to the starting index, usually 0
    global parentPaths := ["VR87", "VR87q", "VR87r", "VR87s", "VR87t", "VR87v", "VR87w", "VR87x", "VR87y", "VR87z", "VR87rr", "VR87sr", "VR87tr", "VR87ur", "VR87vr"]
    totalParents := parentPaths.Length

    Loop {
        ToolTip("Starting a new page.")
        SetTimer () => ToolTip(""), -1000
        RandomDelay(300, 500)

        HandleCurrentIndeedPage(rootElement)

        ; Process HandleJobSearch until all parent elements are processed
        if (currentParentElement < totalParents) {
            HandleJobSearch(rootElement)
        }

        ; Check for the "Next Page" link after all parent elements are processed
        HandleNextPage(rootElement)
    }
}

ESC:: ExitApp

^p::Pause -1 ; Press Ctrl+P to pause/resume the script