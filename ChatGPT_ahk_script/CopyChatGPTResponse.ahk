#Requires AutoHotkey v2.0

#Include ..\Helper_Functions\ActivateChromeWindow.ahk
#Include ..\Helper_Functions\GetRootElement.ahk
#Include ..\Helper_Functions\TabInteraction.ahk
#Include ..\Helper_Functions\ClickElementByPath.ahk

; Function to copy the latest response from ChatGPT
CopyChatGPTResponse() {
    global ChatGPTResponse
    ; Call the wait function and return whether it was successful
    ChatGPTResponse := WaitForNewCopyButtonAndCopy()
    
    if ChatGPTResponse == "" {
        ChatGPTResponse := WaitForNewCopyButtonAndCopy()
        MsgBox("Failed to copy the response within the allowed time.")
        FileAppend("Failed to copy the response within the allowed time.`n", "ChatGPT_Debug_Log.txt")
    }

    return ChatGPTResponse
}

; Function to wait for the new "Copy" button and copy ChatGPT's latest response
WaitForNewCopyButtonAndCopy() {
    global copyButtonResponseFlag, clipboardBackup, paidGPTFlag, paidGPTFlagLocked
    ; Step 6: Look for the "Copy" button, but ensure it is the latest response
    hwnd := ActivateChromeWindow()
    rootElement := GetRootElement(hwnd)

    ; Initialize a timeout counter and maximum wait time
    maxWaitTime := 65000  ; 30 seconds max wait
    interval := 500       ; Check every 500ms
    elapsedTime := 0

    while elapsedTime < maxWaitTime {
        CopyAnswerHook:
        {
            try {
                stayLoggedOutLink := rootElement.FindFirst({ Name: "Stay logged out", LocalizedType: "link" })
                stayLoggedOutLink.Click()
            } catch {
                stayLoggedOutLink := ""
            }
            ; Try to find the latest "Copy" button in the chat
            try {
                preferredResponse := rootElement.FindFirst({ Name: "I prefer this response", LocalizedType: "button" })
                preferredResponse.Click()

            } catch {
                preferredResponse := ""
            }

            try {
                continueGenerating := rootElement.FindFirst({ Name: "Continue generating", LocalizedType: "button" })
                continueGenerating.Click() ? elapsedTime := 0 : elapsedTime
            } catch {
                continueGenerating := ""
            }
            try {
                copyButton := rootElement.FindFirst({ Name: "Copy", LocalizedType: "button" })
            } catch {
                copyButton := ""
            }

            try {
                errorPopup := rootElement.FindFirst({ Name: "The message you submitted was too long, please reload the conversation and submit something shorter.", LocalizedType: "text" })
            } catch {
                errorPopup := ""
            }

            try {
                regenerateButton := rootElement.FindFirst({ Name: "Regenerate", LocalizedType: "button" })
                regenerateButton.Click() ? elapsedTime := 0 : elapsedTime
            } catch {
                regenerateButton := ""
            }

            if errorPopup {
                ShowToolTipWithTimer("Failed to copy the latest response from ChatGPT.",, 2000)
                FileAppend("Failed to copy the latest response from ChatGPT: " errorPopup.Name "`n", "ChatGPT_Debug_Log.txt")
                paidGPTFlag := true
                paidGPTFlagLocked := true
                return false
            }
        }

        ; Check if the copy button exists
        if copyButton && IsObject(copyButton) {
            try {
                if clipboardBackup == "" {
                    clipboardBackup := ClipboardAll()
                }
                A_Clipboard := "" ; Clear the clipboard before interacting with the copy button
                ; Scroll to the copy button and click it
                copyButton.ScrollIntoView()
                Sleep(600)
                if copyButton.Click() {
                    success := true
                }
                Sleep(500)  ; Wait for the button to be clicked
                ; Check if clicking the copy button worked
                if A_Clipboard == "" && copyButtonResponseFlag {
                    FileAppend("Failed to copy the latest response from ChatGPT.", "ChatGPT_Debug_Log.txt")
                    return false
                } else if A_Clipboard == "" {
                    copyButtonResponseFlag := true
                    goto CopyAnswerHook
                } else if A_Clipboard != "" {
                    copyButtonResponseFlag := false
                }

                ShowToolTipWithTimer("Copying the latest response from ChatGPT...")

                ; Return the response from the clipboard
                ChatGPTResponse := A_Clipboard
            } catch {
                ; Handle any errors while interacting with the copy button
                ShowToolTipWithTimer("Error interacting with the Copy button.")
                FileAppend("Error interacting with the Copy button.`n", "ChatGPT_Debug_Log.txt")
            }

            CloseTabWithCheck(rootElement)
            Sleep(200)
            try {
                return ChatGPTResponse
            } catch {
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