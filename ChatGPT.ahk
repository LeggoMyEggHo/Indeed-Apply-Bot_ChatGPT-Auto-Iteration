#Requires AutoHotkey v2.0

#Include C:\Users\bachi\Downloads\UIA-v2-main\UIA-v2-main\Lib\UIA.ahk
#Include ActivateChromeWindow.ahk
#Include GetRootElement.ahk
#Include CheckForHighlightedText.ahk
#Include TabInteraction.ahk
#Include HandleClipboard.ahk

#SingleInstance Force 

; ChatGPT Interaction Script for AHK v2
; This script handles copying input, submitting it to ChatGPT, grabbing the response, and returning the value.

global lastChatGPTResponse := ""  ; Global variable to store the last response for iterations

; Main function that handles the ChatGPT interaction
ChatGPT_Interaction(inputText := "", specifiedPrompt := "", resume := "", combinedPrompt := "", chatGPTResponse := "") {
    global iterationCount

    ; display the inputText in a message box
    ;MsgBox("Input: " inputText.Name)
    ; Step 0: Prepare Clipboard and Input
    if specifiedPrompt != "" {
        if resume != "" {
            combinedPrompt := CombineSpecifiedPrompt(inputText, specifiedPrompt, resume)
        } else if !IsObject(inputText) {
            ;MsgBox("Input is not an object")
            combinedPrompt := CombineSpecifiedPrompt(inputText, specifiedPrompt, "")

            A_Clipboard := ""
            Sleep(100)
            A_Clipboard := combinedPrompt
        } else if IsObject(inputText) {
            ;MsgBox("Input is an object")
            combinedPrompt := CombineSpecifiedPrompt(inputText, specifiedPrompt, "")
        } else {
            MsgBox("Invalid input. First input parameter must be a string.")
        }
    }
    
    ;MsgBox("Combined Prompt: " combinedPrompt)
    ;MsgBox("Input: " inputText)

    ; Step 1: Copy the input to the clipboard
    if iterationCount = 1 {
        HandleClipboard(combinedPrompt)
    }

    HandleOpenChatGPT()

    ;MsgBox("Clipboard Input: " A_Clipboard)

    ; Step 4: Paste the input into ChatGPT's text box
    Send("^v")  ; Paste the clipboard content
    Sleep(300)
    Send("{Enter}")  ; Submit the request

    ; Step 5: Copy the ChatGPT response
    chatGPTResponse := CopyChatGPTResponse()
    lastChatGPTResponse := chatGPTResponse

    FileAppend("Question 1: " combinedPrompt "`n`nChatGPT response: " chatGPTResponse "`n`n", "ChatGPT_log.txt")
    Sleep(100)
    if A_ThisHotkey != "^i" && resume != "" {
        ; Return the ChatGPT response
        return lastChatGPTResponse
    }

    finalResponse := ChatGPT_Loop( , "", combinedPrompt, chatGPTResponse, 5)  ; Loop 5 times
    return finalResponse
}

; ChatGPT interaction loop function
ChatGPT_Loop(inputText := "", specifiedPrompt := "", combinedPrompt := "", chatGPTResponse := "", maxIterations := 5) {
    if specifiedPrompt != "" {
        combinedPrompt := specifiedPrompt . inputText  ; Start with the initial combined prompt
    } else if combinedPrompt != "" {
        combinedPrompt := combinedPrompt . chatGPTResponse  ; Start with the initial combined prompt
    }
    
    iterationCount := 2

    ; Loop until the maximum number of iterations
    while iterationCount <= maxIterations {
        ; Call ChatGPT_Interaction and get the response
        chatGPTResponse := ChatGPT_Interaction(,,,combinedPrompt)

        ; Show the combined prompt for debugging (optional)
        MsgBox("Iteration " iterationCount ": " combinedPrompt)

        FileAppend("Question" iterationCount ": " combinedPrompt "`n`nChatGPT response: " chatGPTResponse "`n`n", "ChatGPT_log.txt")

        ; Append the response to the combined prompt for the next iteration
        combinedPrompt .= "`n" chatGPTResponse  ; Append response with a newline

        ; Increment the loop count
        iterationCount++
    }

    return chatGPTResponse
}

CombineSpecifiedPrompt(inputText := "", specifiedPrompt := "", resume := "", combinedPrompt := "", chatGPTResponse := "") {
    if resume != "" {
        ; Combine prompt with additional information if provided
        combinedPrompt := specifiedPrompt . resume . inputText

        HandleClipboard(, combinedPrompt) ; Copy the combined prompt to the clipboard
    } else if !IsObject(inputText) {
        ;MsgBox("Input is not an object")
        combinedPrompt := specifiedPrompt . inputText

        HandleClipboard(, combinedPrompt) ; Copy the combined prompt to the clipboard
    } else if IsObject(inputText) {
        ;MsgBox("Input is an object")
        combinedPrompt := specifiedPrompt . inputText.Value

        HandleClipboard(, combinedPrompt) ; Copy the combined prompt to the clipboard
    } else {
        MsgBox("Invalid input. All input parameters must be a string or an object with a Value property.")
    }

    return combinedPrompt
}

; Function to wait for the new "Copy" button and copy ChatGPT's latest response
WaitForNewCopyButtonAndCopy() {
    ; Step 6: Look for the "Copy" button, but ensure it is the latest response
    hwnd := ActivateChromeWindow()
    rootElement := GetRootElement(hwnd)

    ; Initialize a timeout counter and maximum wait time
    maxWaitTime := 30000  ; 30 seconds max wait
    interval := 500       ; Check every 500ms
    elapsedTime := 0

    while elapsedTime < maxWaitTime {
        ; Try to find the latest "Copy" button in the chat
        try {
            copyButton := rootElement.FindFirst({ Name: "Copy", LocalizedType: "button" })
        } catch {
            copyButton := ""
        }

        ; Check if the copy button exists
        if copyButton && IsObject(copyButton) {
            try {
                ; Scroll to the copy button and click it
                copyButton.ScrollIntoView()
                copyButton.Click()
                Sleep(400)  ; Small delay to ensure the copying occurs

                ToolTip("Copying the latest response from ChatGPT...")
                SetTimer(() => ToolTip(""), -1000)  ; Clear the tooltip after 1 second

                ; Return the response from the clipboard
                ChatGPTResponse := A_Clipboard
                Sleep(100)
                CloseTabWithCheck(rootElement)
                return ChatGPTResponse
            } catch {
                ; Handle any errors while interacting with the copy button
                MsgBox("Error interacting with the Copy button.")
                return false
            }
        }

        ; Wait for the interval before checking again
        Sleep(interval)
        elapsedTime += interval
    }

    ; If the loop ends without finding the button, log the error
    FileAppend("Failed to find the new Copy button within the timeout.`n", "ChatGPT_Debug_Log.txt")
    return false
}


; Function to copy the latest response from ChatGPT
CopyChatGPTResponse() {
    global ChatGPTResponse
    ; Call the wait function and return whether it was successful
    ChatGPTResponse := WaitForNewCopyButtonAndCopy()
    
    if !ChatGPTResponse {
        MsgBox("Failed to copy the response within the allowed time.")
    }

    return ChatGPTResponse
}


HandleOpenChatGPT() {
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
 
     ; Step 2: Open a new browser tab
     Send("^t")  ; Ctrl+T to open new tab
     Sleep(500)  ; Wait for the tab to open
 
     ; Step 3: Navigate to ChatGPT
     SendText("https://chatgpt.com/?model=gpt-4o-mini `n")  ; Enter URL and hit Enter
     WinWaitActive("ChatGPT - Google Chrome") ; Wait for ChatGPT to open

     if hwnd := WinExist("ahk_exe ChatGPT - Google Chrome") {
         WinActivate
         WinWaitActive("ahk_exe ChatGPT - Google Chrome")
         return hwnd
     } else {
         ToolTip("ChatGPT window not found.")
         SetTimer () => ToolTip(""), -1000
         ExitApp
     }
}

; Function to handle the ChatGPT lookup interaction
ChatGPT(inputText := "", specifiedPrompt := "", resume := "") {
    ; Initialize flags as false by default
    isHotkeyTriggered := false
    isTextHighlighted := false
    inputText := ""
    combinedPrompt := ""

    ; Check if the function was triggered by a hotkey, specifically this script's name
    if A_ThisHotkey == "^i" {
        isHotkeyTriggered := true
    }

    MsgBox("isHotkeyTriggered: " isHotkeyTriggered)

    ; If the script was triggered by a hotkey and no input was passed, check for highlighted text
    if isHotkeyTriggered == true && inputText == "" {
        ; Try to grab highlighted text from any non-File Explorer windows
        inputText := CheckForHighlightedText()

        if inputText != "" {
            isTextHighlighted := true
        } else {
            ToolTip("No highlighted text found in non-File Explorer windows.")
            SetTimer(() => ToolTip(""), -1000)
            Sleep(1000)
        }
    }

    MsgBox("isTextHighlighted: " isTextHighlighted)

    ; If no input text is found (from highlighted text or passed directly), prompt the user
    if isHotkeyTriggered == true && isTextHighlighted == false && inputText == "" {
        ;inputText := ""
        inputText := InputBox("No highlighted text, enter your input text manually:", "ChatGPT Interaction Script")
        ; Check if InputBox was cancelled (Result will be "Cancel")
        if inputText.Result == "OK" {
            inputText := inputText.Value  ; Get the input text from the Value property
        } else {
            MsgBox("Input was cancelled.")
            return  ; Exit if the input was cancelled
        }
    }

    ; Final debugging: Check what inputText contains at this stage
    ;MsgBox("Final input: '" inputText "'")

    ; Define your input text, prompt, and optional resume here
    if resume != "" {
        specifiedPrompt := "Using this resume, directly and succinctly answer the following question in first-person using only one or two sentences. Resume: "
    } else specifiedPrompt := "Refine, improve, and execute while preserving the original meaning and intent: "
    

    ; Call the main function and retrieve ChatGPT's response
    iteratedResponse := ChatGPT_Interaction(inputText, specifiedPrompt, resume)

    ; Show response in a message box or return to another script
    ;MsgBox(chatGPTResponse)
    return iteratedResponse
}

; Initial hotkey
^i:: {
    global iterationCount := 1  ; Initialize the iteration count to 1

    ; Define your input text here (leave empty if you want to prompt the user)
    inputText := ""

    ; Call the ChatGPT function
    ChatGPT(inputText)
}

; Hotkey for Ctrl + Alt + I to iterate 5 more times based on the last ChatGPT response
^!i:: {
    if (lastChatGPTResponse != "") {
        ; Iterate 5 more times on the last response
        finalResponse := ChatGPT_Loop(, "", lastChatGPTResponse, lastChatGPTResponse, 5)
        MsgBox("Final Iterated Response: " finalResponse)
    } else {
        MsgBox("No previous response to iterate.")
    }
}

ESC::ExitApp ; Exit the script

^p::Pause -1  ; Press Ctrl+P to pause/resume the script