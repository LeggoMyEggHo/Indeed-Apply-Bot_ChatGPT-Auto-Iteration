#Requires AutoHotkey v2.0
#Include ..\Helper_Functions\ShowToolTipWithTimer.ahk
#Include ..\Helper_Functions\GetArrayLength\GetArrayLength.ahk

#SingleInstance

global failedContinue := false

HandleJobSearch(rootElement) {
    global currentParentElement, parentPaths ; Use global variables

    ; Process the job search page, loop over parents, and handle child loops
    Loop {
        
        global failedContinue := false
        ShowToolTipWithTimer("Starting a new page.")

        parentLength := GetArrayLength(parentPaths)

        ; Iterate over parent elements starting from currentParentElement
        while (currentParentElement < parentLength) {

            global failedContinue
            parentPath := parentPaths[currentParentElement]
            ShowToolTipWithTimer("Processing parent element: " currentParentElement " with path: " parentPath,,500)

            success := false
            
            parentElement := rootElement.WaitElementFromPath(parentPath, 2000)

            ; Ensure elements are waited for and found
            if !CheckIfValid(rootElement, parentPath) {
                ;MsgBox("incrementing currentParentElement from " currentParentElement " to " (currentParentElement + 1))
                currentParentElement++ ; Increment to move to the next parent
                continue
            } else {
                if totalAppliedJobs != 0 {
                    if Mod(totalAppliedJobs, 1) == 0 {
                        ShowToolTipWithTimer("Sleeping for 30 seconds to avoid rate limits.", 30000, 30000)
                    }
                }

                ;MsgBox("CheckIfValid completed successfully.")
                applyNowElement := rootElement.FindFirst({ LocalizedType: "button", Name: "Apply now opens in a new tab" })
                ClickElementByPath(applyNowElement, rootElement, , 2000)
            }

            ; If no issues, proceed to the child loop handling
            ShowToolTipWithTimer("Proceeding to HandleCurrentIndeedPage for parent: " parentPath)
             HandleCurrentIndeedPage(rootElement)

            ShowToolTipWithTimer("Finished processing parent element with path: " parentPath)
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
        ShowToolTipWithTimer("Navigating to the next page.")
        RandomDelay(200, 500)  ; Randomized delay before action

        nextPageElement.ScrollIntoView()
        RandomDelay(400, 800)  ; Randomized delay after scrolling

        ClickElementByPath(nextPageElement)
        currentParentElement := 1
        RandomDelay(2500, 4000)  ; Randomized delay after clicking
        HandleCurrentIndeedPage(rootElement)
    } else {
        ShowToolTipWithTimer("No more pages to process. Script completed.", 5000, 5000)
    }
}

CheckIfValid(rootElement, parentPath) {
    success := false
    global excludeList, excludeJobTypes, jobSearchKeywords ; Grab the global jobSearchKeywords, excludeList, and excludeJobTypes variables from #Include JobApplicationQA.ahk
    global cleanedJobName
    ; Check for the parent element
    parentElement := rootElement.WaitElementFromPath(parentPath, 500)  ; 2-second timeout as an example
    if !parentElement {
        CloseTabWithCheck(rootElement)
        Send("^t")
        Sleep(600)
        SendText("https://www.indeed.com/jobs?q=" jobSearchKeywords "&sc=0kf%3Aattr%28DSQF7%29%3B&rbl=Remote&fromage=14&jlid=aaa2b906602aa8f5 `n")
        currentParentElement := 0
        return false
    }

    try {
        child := parentElement.Children[1]
        if child.LocalizedType == "group" {
            ;HandleDismissThis(parentPath, rootElement)
            return false
        }
    } catch {
        ; The parent element has no children, so skip it
        ;MsgBox("No .Children[1] element found within CheckIfValid() for path " parentPath)
        FileAppend("No .Children[1] element found within CheckIfValid() for path " parentPath "`n", "skip_log.txt")
        return false
    }
    
    ; Find all children elements within the parent element
    children := parentElement.FindAll()
    childNames := ""
    for child in children {
        childNames .= child.Name "`n"
    }
    ;MsgBox("Found the following children:`n" childNames)

    firstChild := children[1].Name

    ; Remove leading "full details of '" and trailing '"'
    cleanedJobName := RegExReplace(firstChild, "^full details of ", "")
    cleanedJobName := RegExReplace(cleanedJobName, "`"$", "")

    for child in children {
        ; Iterate through the children to check for button elements containing the target strings
        if (child.LocalizedType = "button" || child.LocalizedType = "text") { 

            ; Check if any of the button's name contains a string from either the excludeList or excludeJobTypes
            for checkString in excludeList {
                if InStr(child.Name, checkString) {
                    global cleanedJobName

                    ; Append the result to a log file
                    logFile := "skip_log.txt"
                    FileAppend("Skipped parent path " parentPath " due to keyword match: " checkString " in job title: " cleanedJobName "`n`n", logFile)
                    
                    ShowToolTipWithTimer("Skipped parent path " parentPath " due to keyword match: " checkString " in job title: " cleanedJobName "`n`n")

                    return false  ; Indicate that the job should be skipped
                }
            }

            for checkString in excludeJobTypes {
                if InStr(child.Name, checkString) {
                    global cleanedJobName

                    ; Append the result to a log file
                    logFile := "skip_log.txt"
                    FileAppend("Skipped parent path " parentPath " due to job type match: " checkString " in job title: " cleanedJobName "`n`n", logFile)
                    ShowToolTipWithTimer("Skipped parent path " parentPath " due to job type match: " checkString " in job title: " cleanedJobName)
                    return false  ; Indicate that the job should be skipped
                }
            }
        }

        if (child.Name == "Job hidden") {
            return false  ; Indicate that the job should be skipped
        }

        ; Check if "Easily Apply" exists among the children
        if (child.Name == "Easily apply") {
            success := true
            break ; Exit the loop if "Easily apply" is found, but continue with the rest of the function
        }
    }

    ; If no "Easily apply" was found, return true to skip this job
    if !success {
        ShowToolTipWithTimer("No 'Easily apply' found; skipping job.")
        ; Only mark job as Not Interested if you don't want to manually apply later
        ;HandleNotInterested(parentPath, rootElement)
        return false  ; Indicate that the job should be skipped
    }

    ClickElementByPath(parentElement, rootElement,,, true)

    result := CheckIfJobValid(rootElement, parentPath)

    return result
}

CheckIfJobValid(rootElement, parentPath) {
    global cleanedJobName
    ; Check for "Applied opens in a new tab" or "This job has expired on Indeed"
    
    parentElement := rootElement.WaitElementFromPath(parentPath, 2000)
    ; Check for licenses in the "Licenses" group
    licensesGroup := parentElement.WaitElementFromPath({ Name: "Licenses", LocalizedType: "group" }, 2000)
    if licensesGroup {
        licenses := licensesGroup.FindAll()
        for license in licenses {
            if (license.LocalizedType == "text") {
                licenseName := license.Name
                if !(InStr(licenseName, "Driver License") || InStr(licenseName, "Driver's License")) {
                    ; Log any non-Driver License entries
                    logFile := "licenses_log.txt"
                    FileAppend("Found license: " licenseName "`n" "for job: " cleanedJobName "`n", logFile)
                }
            }
        }
    }

    logFile := "skip_log.txt"

    try {
        parentElement := rootElement.FindFirst({ LocalizedType: "group", Name: "Job Post Details" })
    } catch {
        parentElement := ""
        return false
    }

    ; Check for "This job has expired on Indeed"
    try {
        expiredElement := rootElement.FindFirst({ LocalizedType: "text", Name: "This job has expired on Indeed" })
        
        FileAppend("Job has expired: " cleanedJobName "`n", logFile)      
        return false
    } catch {
        expiredElement := ""
    }

    ; Check for "Applied opens in a new tab"
    try {
        appliedElement := parentElement.FindFirst({ LocalizedType: "button", Name: "Applied opens in a new tab" })
        ;MsgBox("Applied opens in a new tab for job: " cleanedJobName)
        FileAppend("Applied opens in a new tab for job: " cleanedJobName "`n", logFile)
        return false
    } catch {
        appliedElement := ""
    }

    ; Check for "Apply now (opens in a new tab)"
    try {
        applyNowElement := parentElement.FindFirst({ LocalizedType: "button", Name: "Apply now (opens in a new tab)" })
        ;MsgBox("Apply now (opens in a new tab) for job: " cleanedJobName)
        FileAppend("Apply now (opens in a new tab) for job: " cleanedJobName "`n", logFile)
        return false
    } catch {
        appliedElement := ""
    }
    ;MsgBox("returning false for job: " cleanedJobName)
    ; If the job is eligible for application, return false to continue processing this job
    return true
}