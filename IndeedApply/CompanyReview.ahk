#Requires AutoHotkey v2.0

#Include ..\Helper_Functions\CheckAndSetHotkey\CheckAndSetHotkey.ahk
#Include ..\UIA.ahk
#Include ..\Helper_Functions\ShowToolTipWithTimer.ahk
#Include ..\AHK-v2-libraries-main\Lib\Array.ahk
#Include ..\IndeedApply\GetCompanyNames.ahk

#SingleInstance

; Hotkey to activate the script manually (Ctrl+Shift+Q)
^q:: {
    CheckCompanies()  ; Call the main function
}

; Main function to search for keywords in the UI elements of each company's profile
CheckCompanies(companies := [], keywordList := [], excludeList := []) {
    global defaultKeywordList := ["fun", "great pay"]  ; Keywords to search for
    global defaultExcludeList := ["micromanage", "long hours"]  ; Keywords to exclude
    logFile := "company_review_log.txt"  ; File to log results

    if keywordList != [] {
        for each, item in defaultKeywordList {
            keywordList.Push(item)
        }
    } else {
        keywordList := defaultKeywordList
    } 

    if excludeList != [] {
        for each, item in defaultExcludeList {
            excludeList.Push(item)
        }
    } else {
        excludeList := defaultExcludeList
    }
    ;global companiesStr := ""
    ;for company in companies {
    ;    companiesStr .= company
    ;}
    ;MsgBox("Companies: " companiesStr)

    ; If no companies are passed, show the ToolTip and prompt user for input
    if GetArrayLength(companies) = 0 {
        if A_ThisHotkey == "^j" {
            ;MsgBox("No highlighted text found. Grabbing all companies on the job search page.")
            companies := GetCompanyNames()
        } else if companies := [GetHighlightedText()] != "" {
            ;MsgBox("Found highlighted text. Using highlighted text as the company list.")
            ShowToolTipWithTimer("Found highlighted text. Using highlighted text as the company list.", 1000, 1000)
        } else {
            ;MsgBox("No hotkeys or highlighted text found. Grabbing all companies on the job search page.")
            companies := GetCompanyNames()
        } 
    } else {
        MsgBox("Using provided company list.")
    }

    ; Process each company and review its related pages
    for company in companies
    {
        company := CleanCompanyName(company)  ; Format company name for the URL
        companies := ProcessCompany(company, logFile, keywordList, excludeList)
    }

    ; If script is run manually, open the log file automatically for review
    if A_ThisHotkey == "^q" {
        ; Open the log file if FileAppend ocurred during the script
        if FileExist(logFile) {
            Run(logFile)
        }
    } else if A_ThisHotkey == "^j" {
        return companies
    }
}

; Function to process each company's Indeed pages
ProcessCompany(company, logFile, keywordList, excludeList) {
    baseUrl := "https://www.indeed.com/cmp/" company "/"
    relatedUrls := ["", "about", "reviews", "faq", "salaries"]  ; Related subpages to search
    companies := []

    for subpage in relatedUrls
    {
        fullUrl := baseUrl subpage

        ; Open the URL in Chrome
        Run("chrome.exe " fullUrl)

        ; Wait for the page to load
        Sleep(3000)

        ; Perform the keyword search among the elements
        results := SearchKeywordsInElements(keywordList, excludeList)

        ; Log the results if any keywords are found
        if results != "" {
            FileAppend("Company: " company "`nURL: " fullUrl "`nResults: " results "`n`n", logFile)
            companies.Push(company)
        }

        Send("{Ctrl+W}")  ; Close the tab
    }

    return companies
}

; Function to search for keywords in the UI elements on the current window
SearchKeywordsInElements(keywordList, excludeList) {
    foundText := ""

    ; Get the root element of the active window
    hwnd := WinExist("ahk_exe chrome.exe")
    rootElement := UIA.ElementFromHandle(hwnd)

    if !rootElement {
        MsgBox("Unable to get the root element of the window.")
        return
    }

    ; Find all elements in the active window
    allElements := rootElement.FindAll()

    ; Search through each element's .Name property
    for element in allElements
    {
        elementName := element.Name

        for keyword in keywordList
        {
            if InStr(elementName, keyword)
            {
                excludeFlag := false
                for exclude in excludeList
                {
                    if InStr(elementName, exclude)
                    {
                        excludeFlag := true
                        break
                    }
                }

                if !excludeFlag
                {
                    foundText .= "Matched: " elementName "`n"
                    break  ; Break out of the keyword loop if a match is found
                }
            }
        }

        excludeFlag := false
        notExcluded := true
        for exclude in excludeList
        {
            if InStr(elementName, exclude)
            {
                excludeFlag := true
                break
            }
        }

        if excludeFlag
        {
            notExcluded := false
        }
    }

    if notExcluded {
        return foundText
    } else {
        return ""
    }
}

; Function to clean up the company name for URL use
CleanCompanyName(company) {
    ; Replace spaces with hyphens
    return StrReplace(company, " ", "-")
}

; Function to wait for user input ('a' for review all, 'h' for review highlighted)
WaitForUserInput() {
    
    Rehook1:
    {
        ttMessage := "Press 'a' to review all companies or 'h' to review the highlighted company."
        ; Wait for the next key press within 7.5 seconds
        ih := InputHook("L1 T7.5 V", , "a,h")
        ih.Start()
        ShowToolTipWithTimer(ttMessage, 7500)

        ih.Wait()

        if ih.EndReason == "Match" {
            return ih.Match
        } else {
            MsgBox("Invalid input! " ttMessage)
            goto('Rehook1')
        }
    }
    
}
