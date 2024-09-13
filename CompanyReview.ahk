#Requires AutoHotkey v2.0
#Include %A_ScriptDir%\Lib\UIA.ahk
#Include ShowToolTipWithTimer.ahk
#SingleInstance Force

; Hotkey to activate the script manually (Ctrl+Shift+Q)
^q:: {
    CheckCompanies()  ; Call the main function
}

CheckCompanies(companies := "") {
    global keywordList := ["fun", "great pay"]  ; Keywords to search for
    global excludeList := ["micromanage", "long hours"]  ; Keywords to exclude
    logFile := "company_review_log.txt"  ; File to log results
    global logFileAppended := false ; Flag to check if FileAppend occurred during the script

    ; If no companies are passed, show the ToolTip and prompt user for input
    if companies = ""
    {
        ShowToolTipWithTimer("No companies passed. Press 'A' to review all companies or 'H' to review the highlighted company.", 7500)
        choice := WaitForUserInput()  ; Wait for user input ('a' or 'h')

        if choice = "a" || choice = "A"  ; Option 1: Review all companies
        {
            companies := GetParentPathCompanyList()  ; Generate the company list using the parentPath
        }
        else if choice = "h" || choice = "H"  ; Option 2: Review the highlighted company
        {
            companies := [GetHighlightedCompany()]
        }
        else
        {
            MsgBox("Invalid choice. Exiting script.")
            ExitApp
        }
    }

    ; Process each company and review its related pages
    for company in companies
    {
        company := CleanCompanyName(company)  ; Format company name for the URL
        ProcessCompany(company, logFile)
    }

    ; If script is run manually, open the log file automatically for review
    if A_ThisHotkey == "^q"
    {
        ; Open the log file if FileAppend ocurred during the script
        if logFileAppended {
            Run(logFile)
        }
    }
}

; Function to process each company's Indeed pages
ProcessCompany(company, logFile) {
    baseUrl := "https://www.indeed.com/cmp/" company "/"
    relatedUrls := ["", "about", "reviews", "faq", "salaries"]  ; Related subpages to search

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
        if results != ""
        {
            FileAppend("Company: " company "`nURL: " fullUrl "`n" results "`n`n", logFile)
            global logFileAppended := true  ; Set the flag to true if FiledAppend occurs
        }
    }
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
    }
    
    return foundText
}

; Function to clean up the company name for URL use
CleanCompanyName(company) {
    ; Replace spaces with hyphens
    return StrReplace(company, " ", "-")
}

; Function to retrieve the highlighted company name
GetHighlightedCompany() {
    clipboardBackup := ClipboardAll()  ; Backup current clipboard
    A_Clipboard := ""  ; Clear the clipboard
    Send("^c")  ; Copy the highlighted text
    Sleep(100)  ; Wait for clipboard to update
    highlightedText := A_Clipboard
    A_Clipboard := clipboardBackup  ; Restore the clipboard

    ; Remove any trailing spaces or newlines
    highlightedText := Trim(highlightedText)
    return highlightedText
}

; Function to retrieve the list of companies from the parentPath list
GetParentPathCompanyList() {
    ; Simulate the list of companies by appending "Kr" to the parentPath
    parentPaths := ["VR87", "VR87q", "VR87r", "VR87s", "VR87t", "VR87v", "VR87w", "VR87x", "VR87y", "VR87z"]
    companyList := []

    for path in parentPaths
    {
        companyList.Push(path "Kr")
    }

    return companyList
}

; Function to wait for user input ('a' for review all, 'h' for review highlighted)
WaitForUserInput() {
    Loop {
        ; Wait for the next key press within 7.5 seconds
        ih := InputHook("L1 T7.5 V")
        ih.Start()
        ih.Wait()

        SubKey := ih.Input
        if (SubKey = "") {
            ToolTip("")  ; Turn off the tooltip if input time expires
            break
        }

        ; Validate the key press
        if InStr("ah", SubKey) {
            return SubKey  ; Return the valid key press
        }
    }
    return ""
}

ESC:: ExitApp ; Press ESC to exit the script

^p:: Pause -1  ; Press Ctrl+P to pause/resume the script
