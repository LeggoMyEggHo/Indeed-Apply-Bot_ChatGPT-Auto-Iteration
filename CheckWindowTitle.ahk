#Requires AutoHotkey v2.0

;#Include ..\IndeedApply\WaitForCondition.ahk
;#Include ..\Helper_Functions\ShowToolTipWithTimer.ahk

#SingleInstance Force

; Function to get window title(titleCheck) if all options are left blank or set script name to perform other actions
CheckWindowTitle(script := "", titleCheck := "", timeout := "", checkInterval := "", titles := [], keywordSearchTitles := []) {
    if script == "" {
        currentTitle := WinGetTitle("A")
        return currentTitle
    } else if InStr(script, "IndeedApplySimple" || "IndeedApplySimple.ahk") {
        currentTitle := HandleIndeedTitles(script, titleCheck, timeout, checkInterval, titles, keywordSearchTitles)
        return currentTitle
    } else if InStr(script, "CompanyReview" || "CompanyReview.ahk") {
        currentTitle := WinGetTitle("A")
        return currentTitle
    }
}

GetMatchingTitle(script := "", titleCheck := "", titles := [], keywordSearchTitles := []) {
    if script == "IndeedApplySimple" || script == "IndeedApplySimple.ahk" || script == "CompanyReview" || script == "CompanyReview.ahk" {
        result := HandleIndeedKeywordSearchTitles(titleCheck, keywordSearchTitles)
        if result != "" {
            return result
        }
    }

    for each, titleObj in titles {
        ; Handle case where titleObj.title is an array (for multiple possible titles)
        if IsObject(titleObj.title) && titleObj.title.HasMethod("Push") {
            for each, possibleTitle in titleObj.title {
                if InStr(titleCheck, possibleTitle) {
                    return titleObj.label
                }
            }
        } else {
            if InStr(titleCheck, titleObj.title) {
                return titleObj.label
            }
        }
    }

    MsgBox("No matching title found for: " titleCheck)
    return ""
}