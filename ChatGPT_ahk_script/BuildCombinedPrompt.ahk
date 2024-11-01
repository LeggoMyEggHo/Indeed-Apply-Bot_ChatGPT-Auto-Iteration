#Requires AutoHotkey v2.0

; Build the combined prompt
BuildCombinedPrompt(inputText, specifiedPrompt, resume := "", combinedPrompt := "", ChatGPTResponse := "", maxIterations := "", iterationCount := "", noResponsesFlag := false, getGPTFeedback := "") {
    global chatGPTResponses, chatGPTSetResponses
    combinedPrompt := "maxIterations: " maxIterations "`niterationCount: " iterationCount "`n" specifiedPrompt "`n`nQuestion: " inputText "`n`n" resume "`n"
    global paidGPTFlag, paidGPTFlagLocked, currentSet

    if (!noResponsesFlag) {
        
        ; Get the current length of combinedPrompt
        currentLength := StrLen(combinedPrompt)
        FileAppend("`nDEBUG: Current combinedPrompt length: " currentLength "`n", "ChatGPT_debug_log.txt")
    
        if getGPTFeedback == "set" {
            paidGPTFlag := true
            for index, response in chatGPTSetResponses {
                combinedPrompt .= "`nChatGPT Set Response: " response "`n"
                FileAppend("response " index "`nfor response: " response "`n", "ChatGPT_debug_log.txt")
                FileAppend("response " index "`nfor response: " response "`n", "verbose_debug_log.txt")
            }

            return combinedPrompt
        }
        ; Only append responses if chatGPTResponses contains any
        if (GetArrayLength(chatGPTResponses) > 0) {
            ; Set a character limit for combinedPrompt
            charLimit := 22000  ; Set this to your desired maximum length
            paidCharLimit := 120000

            ; Calculate remaining characters we can add
            remainingLength := charLimit + paidCharLimit - currentLength
    
            ; If the current prompt is below the limit, append responses
            if (remainingLength > 0) {


                loopCount := GetArrayLength(chatGPTResponses)
                totalResponsesStrLen := 0  ; Variable to store the total length of responses
                totalCombinedPromptStrLen := StrLen(combinedPrompt)
                
                ; Calculate the total length of the responses
                for index, response in chatGPTResponses {
                    responseStrLen := StrLen(response)
                    totalResponsesStrLen += responseStrLen
                    ;MsgBox("response " index "`nresponseStrLen: " responseStrLen "`nTotal Response Length: " totalResponsesStrLen "`n")
                    FileAppend("response " index "`nresponseStrLen: " responseStrLen "`nTotal Response Length: " totalResponsesStrLen "`n", "ChatGPT_debug_log.txt")
                }

                ; Adjust the number of responses to append based on the total length
                (responsesToAppend := (totalCombinedPromptStrLen + totalResponsesStrLen) <= charLimit ? 3 : 2)
                
                if !paidGPTFlagLocked && !paidGPTFlag && responsesToAppend == 3 {
                    paidGPTFlag := false
                } else if !paidGPTFlagLocked {
                    paidGPTFlag := true
                }
                ; Check if the length exceeds the limit and adjust accordingly
                (!paidGPTFlagLocked && paidGPTFlag) ? (responsesToAppend := (totalCombinedPromptStrLen + totalResponsesStrLen) <= paidCharLimit ? 3 : 2) : (responsesToAppend := 3)
                    
                ; Append the last responses to the combined prompt based on the length condition
                loopCount := Min(responsesToAppend, loopCount)
                ;MsgBox("Character Count if all 3 responses are appended: " totalCombinedPromptStrLen + totalResponsesStrLen "`npaidGPTFlag: " paidGPTFlag "`nloopCount: " loopCount "`n")
                FileAppend("Character Count if all 3 responses are appended: " totalCombinedPromptStrLen + totalResponsesStrLen "`npaidGPTFlag: " paidGPTFlag "`nloopCount: " loopCount "`n", "ChatGPT_debug_log.txt")
                for index, response in chatGPTResponses {
                    if (index > loopCount) {
                        FileAppend("`nDEBUG: Breaking after finishing final loopCount " loopCount "`n", "ChatGPT_debug_log.txt")
                        break
                    }
                    
                    ; Append the response if it exists and is not empty
                    FileAppend("`nDEBUG: Iterating through iterationCount " iterationCount "`n", "ChatGPT_debug_log.txt")
                    
                    if (response == "") {
                        FileAppend("`nDEBUG: Response is unassigned or empty at iteration.`n", "ChatGPT_debug_log.txt")
                    }
                    
                    combinedPrompt .= "`nChatGPT Response: " response "`n"
                }
            }
        }
    }
    
    ;FileAppend("Combined Prompt: " combinedPrompt "`n", "ChatGPT_debug_log.txt")
    ;FileAppend("Combined Prompt: " combinedPrompt "`n", "verbose_debug_log.txt")

    return combinedPrompt
}