#Requires AutoHotkey v2.0+

#Include ..\Helper_Functions\CheckAndSetHotkey\CheckAndSetHotkey.ahk
#Include ..\UIA.ahk
#Include ..\UIA_Browser.ahk
#Include JobApplicationQA.ahk
#Include HandlePostSubmission.ahk
#Include ..\Helper_Functions\Utility.ahk
#Include ..\Helper_Functions\ActivateChromeWindow.ahk
#Include ..\Helper_Functions\GetRootElement.ahk
#Include ..\IndeedApply\CompanyReview.ahk
#Include ..\Helper_Functions\Random.ahk
#Include ..\Helper_Functions\TabInteraction.ahk
#Include ..\Helper_Functions\ShowToolTipWithTimer.ahk
#Include ..\Helper_Functions\ClickElementByPath.ahk
#Include ..\Helper_Functions\WaitForElementByPath.ahk
#Include ..\IndeedApply\WaitForCondition.ahk
#Include ..\Helper_Functions\CheckWindowTitle.ahk
#Include ..\Helper_Functions\CallFunction.ahk
#Include ..\IndeedApply\HandleCurrentPage.ahk
#Include ..\Helper_Functions\VerifyHumanCheck.ahk
#Include ..\IndeedApply\HandleInputElements.ahk
#Include ..\AHK-v2-libraries-main\Lib\Misc.ahk
#Include ..\AHK-v2-libraries-main\Lib\Acc.ahk
#Include ..\IndeedApply\HandleJobSearch.ahk
#Include ..\IndeedApply\HandleTitles.ahk
#Include ..\IndeedApply\PageHandling.ahk
#Include ..\IndeedApply\UIAutomationFunctions.ahk
#Include ..\IndeedApply\GetCompanyNames.ahk
#Include ..\Helper_Functions\GetElementCoordinates.ahk

#SingleInstance Force

global success := false
global totalAppliedJobs := 0
generateSessionID := Random(10000, 99999)
global sessionID := generateSessionID

^j:: {

    global answerReview := false
    hwnd := ActivateChromeWindow()
    rootElement := GetRootElement(hwnd)
    global parentPaths := ["VR87", "VR87q", "VR87r", "VR87s", "VR87t", "VR87v", "VR87w", "VR87x", "VR87y", "VR87z", "VR87rr", "VR87sr", "VR87tr", "VR87ur", "VR87vr"]

    Rehook1:
    {
        ttMessage := "Press 'r' to add Company/GPT Oversight Review, 'o' to add GPT Oversight Review only, 'a' to only Apply."
        input := ""
        ; Create an InputHook object to capture input
        iHook := InputHook("L1", ,"r,a,o")  ; L1 limits input to one character, M suppresses keypress from being sent to active window
        iHook.KeyOpt("{All}", "-E")  ; Ignore all keys by default ('-E' disables all keys as EndKeys)
        iHook.Start()

        ShowToolTipWithTimer("Script started. " ttMessage, 30000,)
        ; Wait for input to complete
        iHook.Wait()

        SetTimer () => ToolTip("")

        if iHook.EndReason == "Match" {
            input := iHook.Match
        } else {
            MsgBox("Invalid input! " ttMessage)
            goto('Rehook1')
        }

        ; Handle input
        if (input == "r") {
            answerReview := true
            companies := CheckCompanies()  ; Call CheckCompanies to get the list of companies that passed review criteria
            global companiesStr := "`n"
            for company in companies {
                companiesStr .= company "`n"
            }
            MsgBox("Companies reviewed: " companiesStr)
        } else if (input == "o") {
            answerReview := true
        } else if (input != "a") {
            MsgBox("Invalid input! " ttMessage)
            goto('Rehook1')  ; Rehook the script
        }
    }

    global currentParentElement := 1  ; Initialize the currentParentElement to the starting index, usually 0
    totalParents := parentPaths.Length

    Loop {
        ShowToolTipWithTimer("Starting a new page.")
        RandomDelay(300, 500)
        HandleCurrentIndeedPage(rootElement)
        HandleIndeedTitles(script := "", titleCheck := "", timeout := 5000, checkInterval := 50, titles := "", keywordSearchTitles := "")
            
        ; Process HandleJobSearch until all parent elements are processed
        if (currentParentElement < totalParents) {
            HandleJobSearch(rootElement)
        }

        ; Check for the "Next Page" link after all parent elements are processed
        HandleNextPage(rootElement)
    }
}