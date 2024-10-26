#Requires AutoHotkey v2.0

#Include ..\AHK-v2-libraries-main\Lib\Acc.ahk
#Include ..\AHK-v2-libraries-main\Lib\Misc.ahk
#Include ..\Helper_Functions\ShowToolTipWithTimer.ahk
#Include ..\Helper_Functions\ActivateChromeWindow.ahk
#Include ..\Helper_Functions\GetRootElement.ahk

HandleOpenChatGPT(iterationCount, maxIterations) {
    global paidGPTFlag, paidGPTFlagLocked, resume

    if !IsSet(resume) || resume = ""
        {
            resume := ""  ; Assign the default value if uninitialized or blank
        }

    ; Retrieve all windows that match "chrome.exe"
    chromeWindows := WinGetList("ahk_exe chrome.exe")
    ; Loop through each Chrome window
    for window in chromeWindows {
        ; Get the title of the window
        winTitle := WinGetTitle(window)

        ; Check if the title contains "Visual Studio Code"
        if InStr(winTitle, "Visual Studio Code") {
            continue  ; Skip this window if it contains "Visual Studio Code"
        }

        ; If not, activate the window
        WinActivate(window)
        break  ; Stop after activating the first matching window
    }

    if iterationCount == maxIterations {
        paidGPTFlag := true
    }

    ; Step 2: Open a new browser tab
    if paidGPTFlag || iterationCount == maxIterations {
        Sleep(300)
        Send("^t")
        Sleep(600)
        if !paidGPTFlagLocked {
            paidGPTFlag := false
        }
    } else {
        Sleep(300)
        Send("^+n")  ; Ctrl+Shift+N to open new tab
        Sleep(600)  ; Wait for the tab to open
    }

    ; Step 3: Navigate to ChatGPT
    SendText("https://chatgpt.com/ `n")  ; Enter URL and hit Enter
    WinWaitActive("ChatGPT - Google Chrome") ; Wait for ChatGPT to open
    Sleep(1000)  ; Wait for the page to load elements

    ; Step 4: Wait for window to be ready and handle random events if needed
    rootElement := HandleOpenChatGPTEvents()
    return rootElement
}

HandleOpenChatGPTEvents() {
    hwnd := ActivateChromeWindow()
    rootElement := GetRootElement(hwnd)
    Sleep(100)  ; Wait for the page to load elements

    stayLoggedOutLink := {}
    messageChatGPTBtn := {}
    ; Define a variable to hold the found elements
    foundElements := {}

    ; Define the conditions as functions
    ConditionStayLoggedOut() {
        stayLoggedOutLink := rootElement.FindFirst({ LocalizedType: "link", Name: "Stay logged out" })
        if (stayLoggedOutLink) {
            foundElements.stayLoggedOutLink := stayLoggedOutLink  ; Store the found element
            return true
        }
        return false
    }

    ConditionMessageChatGPT() {
        messageChatGPTBtn := rootElement.FindFirst({ LocalizedType: "text", Name: "Message ChatGPT" })
        if (messageChatGPTBtn) {
            FileAppend("`nMessage ChatGPT found!`n", "ChatGPT_Debug_Log.txt")
            foundElements.messageChatGPTBtn := messageChatGPTBtn  ; Store the found element
            return true
        }
        return false
    }

    ; Define callbacks for success, failure, and logging
    OnSuccess() {
        FileAppend("`nCondition met: Successfully found one of the elements!", "ChatGPT_Debug_Log.txt")
        
        try {
            if foundElements.stayLoggedOutLink {
                FileAppend("`nStay logged out found and trying to click!`n", "ChatGPT_Debug_Log.txt")
                Sleep(500)
                foundElements.stayLoggedOutLink.Click()
                Sleep(500)
                Send("^+c")
            }
        } catch as e {
            FileAppend("`nError in OnSuccess.`n" e.Message "`ne.What: " e.What "`ne.Extra: " e.Extra "`ne.Line: " e.Line "`n" e.Stack, "ChatGPT_Debug_Log.txt")
        }

        Sleep(500)

        try {
            ; Example: Click the found elements if they exist
            if foundElements.messageChatGPTBtn {
                FileAppend("`nMessage ChatGPT found and trying to click!`n", "ChatGPT_Debug_Log.txt")
                Sleep(500)
                foundElements.messageChatGPTBtn.Click()
                FileAppend("`nMessage ChatGPT clicked!`n", "ChatGPT_Debug_Log.txt")
                return rootElement
            }
        } catch as e {
            FileAppend("`nError in OnSuccess.`n" e.Message "`ne.What: " e.What "`ne.Extra: " e.Extra "`ne.Line: " e.Line "`n" e.Stack, "ChatGPT_Debug_Log.txt")
        }
    }

    OnFailure() {
        FileAppend("`nConditions were not met within the timeout.", "ChatGPT_Debug_Log.txt")
    }

    OnTimeout() {
        FileAppend("`nTimeout reached without meeting any condition.", "ChatGPT_Debug_Log.txt")
    }

    ; Prepare conditions and options
    conditions := [ConditionMessageChatGPT, ConditionStayLoggedOut]  ; No need for Func()
    callbacks := {
        onSuccess: OnSuccess,
        onFailure: OnFailure,
        onTimeout: OnTimeout,
    }

    options := {
        timeout: 30000,  ; 30 seconds
        checkInterval: 100,  ; 100 milliseconds
        successThreshold: 1,  ; Require at least 1 condition to succeed
        successMode: "absolute",
        showTooltip: true,
        tooltipText: "Checking conditions...",
        conditionWeights: [2],
        prioritizeConditions: [ConditionMessageChatGPT, ConditionStayLoggedOut]
    }

    ; Call WaitForCondition
    if result := WaitForConditionModule.WaitForCondition(conditions, options.timeout, options.checkInterval, callbacks, options) {

        FileAppend("`nSuccessful conditions: " Print(result), "ChatGPT_Debug_Log.txt")
        
        return rootElement
    ; Handle the case where neither element is found within the timeout
    } else if hwnd := WinExist("ahk_exe ChatGPT - Google Chrome") {
        WinActivate
        WinWaitActive("ahk_exe ChatGPT - Google Chrome")
        ShowToolTipWithTimer("ChatGPT window found.")
        FileAppend("`nChatGPT window found.`n", "ChatGPT_Debug_Log.txt")
        return rootElement
    } else {
        ShowToolTipWithTimer("ChatGPT window not found.")
        FileAppend("`nChatGPT window not found.`n", "ChatGPT_Debug_Log.txt")
        ExitApp
    }
}