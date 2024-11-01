#Requires AutoHotkey v2.0+

#Include ..\Helper_Functions\CheckAndSetHotkey\CheckAndSetHotkey.ahk
#Include ..\UIA.ahk
#Include ..\Helper_Functions\ActivateChromeWindow.ahk
#Include ..\Helper_Functions\GetRootElement.ahk
#Include ..\Helper_Functions\CheckForHighlightedText.ahk
#Include ..\Helper_Functions\TabInteraction.ahk
#Include ..\Helper_Functions\HandleClipboard.ahk
#Include ..\Helper_Functions\ShowToolTipWithTimer.ahk
#Include ..\Helper_Functions\ClickElementByPath.ahk
#Include ..\Helper_Functions\WaitForCondition\WaitForCondition.ahk
#Include ..\AHK-v2-libraries-main\Lib\Misc.ahk
#Include ..\AHK-v2-libraries-main\Lib\Acc.ahk
#Include ..\ChatGPT_ahk_script\GetInput.ahk
#Include ..\ChatGPT_ahk_script\BuildCombinedPrompt.ahk
#Include ..\ChatGPT_ahk_script\HandleOpenChatGPT.ahk
#Include ..\ChatGPT_ahk_script\CopyChatGPTResponse.ahk
#Include ..\ChatGPT_ahk_script\AddChatGPTResponse.ahk
#Include ..\Helper_Functions\GetArrayLength\GetArrayLength.ahk

#SingleInstance

; ChatGPT Interaction Script for AHK v2
; This script handles copying input, submitting it to ChatGPT, grabbing the response, and returning the value.

global optimalPrompt := "Which one of these is the best response? Your only options for response are 1 for the first one or 2 for the second one.`n"

; Global variables for the specified prompt and resume assigned in GetInput.ahk and used in BuildCombinedPrompt.ahk
global resumeSpecifiedPrompt := "Act like you are applying to jobs using this resume and answer the following application question with a single sentence and no period unless necessary, keeping the response as brief and direct as possible, without adding extra details, using first-person if a perspective is needed. If the answer can't be implied by using the given resume, respond with something similar to no or 0 or N/A but make sure the response is natural, brief, and as direct as possible. Date format: MM/DD/YYYY`n"
global defaultSpecifiedPrompt := "If you see a GPT response attached to this prompt, then your response will be appended and fed to a GPT model in the next iteration, so do not provide any non-essential output, such as a summary, breakdown, key enhancements, example usage, or describing your changes. Do not provide anything that doesn't change the solution or isn't explicitly needed for the next user to use or build upon your script. Refine, improve, and evolve without losing the core intent or sacrificing simplicity. Each iteration should build meaningfully on the previous one by introducing significant improvements, exploring new directions, and solving deeper problems rather than just incremental tweaks. Strive to balance innovation, broader use cases, and practical usability. Explicitly address the following universal needs in every iteration: Broader Use Cases: How can this solution be adapted or expanded to address a wider range of scenarios or use cases? Focus on increasing applicability without adding unnecessary complexity. Innovation and Creativity: Is there a more innovative or creative way to approach this? Look for opportunities to challenge existing assumptions and explore new approaches that could lead to transformative changes or breakthroughs, not just small refinements. Avoiding Incremental Refinements: Have the changes made in this iteration moved the solution meaningfully toward global optimization, or are they just minor tweaks? Avoid small, incremental changes unless they significantly enhance overall quality, usability, or functionality. Instead, aim for deeper improvements that advance the solution. Simplicity vs. Complexity: Are there areas where the solution could be simplified without losing functionality or impact? Prioritize simplicity and clarity while retaining the solution’s core purpose. Preventing Feature Overload: Does this iteration introduce new features or functionality that add real value, or is it contributing to feature overload? Focus on adding only meaningful improvements, and avoid overwhelming the core with unnecessary options, settings, or components. Avoiding Repetition: Am I avoiding repetition by introducing new concepts, ideas, or angles, rather than reworking the same solutions in slightly different ways? Ensure that each iteration offers fresh insights or advancements, not simply rephrasing or marginal adjustments. Modularity and Scalability: Can the solution be modularized or broken into distinct parts to improve flexibility and scalability? Consider breaking the solution into smaller, reusable components to handle growth and complexity while maintaining simplicity. New Perspectives and Frameworks: Have I considered alternative perspectives, approaches, or frameworks that could lead to a more efficient or innovative solution? Don’t get locked into a single way of thinking; explore new methodologies that could improve the overall approach. Alignment with the Core Problem: Is the current iteration aligned with the core problem while extending the solution’s broader applicability? Ensure the solution is still solving the primary issue but adaptable to new contexts. Finalization and Completion: Is it time to finalize the solution? Determine if the iteration process has reached a point where the solution is comprehensive and effective, allowing you to stop iterating and finalize the outcome without unnecessary further refinements."
global verboseLogFile := "verbose_debug_log.txt"
global resetCombinedPrompt := false
global paidGPTFlag := false, paidGPTFlagLocked := false

if FileExist("ChatGPT_Debug_Log.txt") {
    FileDelete("ChatGPT_Debug_Log.txt")
}

if FileExist("ChatGPT_log.txt") {
    FileDelete("ChatGPT_log.txt")
}

; Main function that handles the ChatGPT interaction
ChatGPT_Interaction(inputText := "", specifiedPrompt := "", resume := "", combinedPrompt := "", chatGPTResponse := "", maxIterations := "", iterationCount := "", getGPTFeedback := "") {
    global noResponsesFlag
    
    ; Ensure iterationCount is correctly set and incremented across calls
    if iterationCount == "" {
        MsgBox("iterationCount is empty. Setting iterationCount to 1.")
        iterationCount := 1
    }

    ; Step 0: Prepare Clipboard and Input
    combinedPrompt := BuildCombinedPrompt(inputText, specifiedPrompt, resume, combinedPrompt, chatGPTResponse, maxIterations, iterationCount, noResponsesFlag, getGPTFeedback)

    ; Step 1: Copy the combinedPrompt to the clipboard
    HandleClipboard(, combinedPrompt)

    ;MsgBox("Combined Prompt before opening ChatGPT: " combinedPrompt)
    ;FileAppend("Combined Prompt before opening ChatGPT: " combinedPrompt "`n", "ChatGPT_Debug_Log.txt")

    hwnd := HandleOpenChatGPT(iterationCount, maxIterations)
    Sleep(500)

    MsgBox("Clipboard Input: " A_Clipboard)

    ; Step 4: Paste the input into ChatGPT's text box
    pasteResult := HandleClipboard(,,,, true)
    Sleep(600)
    ;FileAppend("Returned HandleClipboard pasteResult: " pasteResult "`nClipboard Input: " A_Clipboard "`n", "verbose_debug_log.txt")
    Send("{Enter}")  ; Submit the request

    ; Step 5: Copy the ChatGPT response to the clipboard and rotate previous responses if needed
    chatGPTResponse := CopyChatGPTResponse()

    Sleep(100)
    if getGPTFeedback != "set" && chatGPTResponse != "" {
        ; Add the new response to the list and ensure only 3 are kept
        AddChatGPTResponse(chatGPTResponse)
    }

    Sleep(100)

    FileAppend("Combined Prompt: " combinedPrompt "`n`n", "ChatGPT_log.txt")
    Sleep(100)
    if A_ThisHotkey != "^i" && resume != "" {
        ; Return the ChatGPT response
        return chatGPTResponse
    } else if (getGPTFeedback == "True" || getGPTFeedback == "true") {
        return chatGPTResponse
    } else if resume != "" {
        return chatGPTResponse
    } else return {inputText: inputText, specifiedPrompt: specifiedPrompt, combinedPrompt: combinedPrompt, chatGPTResponse: chatGPTResponse, maxIterations: maxIterations}
}



; Separate function to handle feedback interactions
ChatGPT_FeedbackInteraction(combinedPrompt, iterationCount, inputText, specifiedPrompt, chatGPTResponse) {

    ; Perform the feedback interaction without affecting the main logic
    feedbackPrompt := "What is great and what is bad about the most recent ChatGPT response? Does the response accurately meet the prompt's needs and goals? If you make any corrections, please provide the corrections."
    
    ; Call ChatGPT interaction for feedback
    feedbackResponse := ChatGPT_Interaction(inputText,specifiedPrompt "`n`n" feedbackPrompt "`n`n",, combinedPrompt, chatGPTResponse,,iterationCount, getGPTFeedback := "True")

    ; Return feedback response to be added to the combinedPrompt
    return feedbackResponse
}

; ChatGPT interaction loop function
ChatGPT_Loop(inputText := "", specifiedPrompt := "", combinedPrompt := "", chatGPTResponse := "", maxIterations := 5, iterationCount := 2) {

    ; Loop until the maximum number of iterations
    while iterationCount < maxIterations + 1 {
        ; Append the response to the combined prompt for the next iteration
        ;combinedPrompt .= "`n ChatGPTResponse " iterationCount - 1 ": " chatGPTResponse "`n"

        ; Call ChatGPT_Interaction and get the response for the next iteration
        holdInteractionResponse := ChatGPT_Interaction(inputText,specifiedPrompt,,combinedPrompt,,maxIterations,iterationCount)
        chatGPTResponse := holdInteractionResponse.chatGPTResponse
        if Mod(iterationCount, 5) = 0 && iterationCount != maxIterations {
            FileAppend("`n------------------------------------`nChatGPT response: `n" chatGPTResponse "`n`n`n", "ChatGPT_Debug_Log.txt")
            FileAppend("`n------------------------------------`nChatGPT response: `n" chatGPTResponse "`n`n`n", "verbose_debug_log.txt")
            FileAppend("`n------------------------------------`nChatGPT response: `n" chatGPTResponse "`n`n`n", "ChatGPT_Debug_Log_Response.txt")
        }

        ; Provide feedback every second iteration without resetting iterationCount
        if Mod(iterationCount, 2) = 0 && iterationCount != maxIterations {
            chatGPTFeedback := ChatGPT_FeedbackInteraction(combinedPrompt, iterationCount, inputText, specifiedPrompt, chatGPTResponse)
        }

        ; Increment the iteration count after each loop
        iterationCount++
    }

    return {inputText: inputText,specifiedPrompt: specifiedPrompt,combinedPrompt: combinedPrompt,chatGPTResponse: chatGPTResponse,maxIterations: maxIterations}
}

ChatGPT(inputText := "", specifiedPrompt := "", resume := "", chatGPTResponse := "", maxIterations := 5, maxSets := 1, getGPTFeedback := "", noResponseFlag := false, functionSpecificPrompt := "") {
    global holdInputText := inputText
    global getInputText := false
    
    if functionSpecificPrompt == "" {
        functionSpecificPrompt := "
        (
        I need you to break down my complex question into a series of function-specific sub-prompts. Each sub-prompt should perform a unique action while covering the entire scope of that action. Focus on the broadest possible interpretation for each action so that the response is comprehensive. Please separate each sub-prompt with '; ' for easy processing.

        Here's the list of actions to address:

        Fact-Checking: Create a prompt to verify all factual information relevant to the question, ensuring accuracy.
        Summarization: Formulate a prompt to summarize the key points, including any relevant nuances or details.
        Contextual Analysis: Generate a prompt to explore the background, history, or broader context relevant to the question.
        Logical Reasoning: Write a prompt that encourages the exploration of logical connections or causal relationships within the question's scope.
        Comparative Evaluation: Create a prompt to compare and contrast the different aspects or perspectives related to the question.
        Risk or Trade-Off Analysis: Develop a prompt that examines potential risks, trade-offs, or downsides.
        Forecasting or Hypothetical Scenarios: Suggest a prompt to explore possible future outcomes or hypothetical situations based on the question.
        Recommendation: Formulate a prompt to generate actionable insights or recommendations based on the analysis.

        Please respond with only the list of sub-prompts, separated by '; ', ensuring each one comprehensively addresses its respective action.
        Here is the question:
        )"
    }
    if getGPTFeedback == "true" || getGPTFeedback == "True" || getGPTFeedback == "set" || getGPTFeedback == "Set" || resume != "" {
        finalResponse := HandleChatGPT(inputText, specifiedPrompt, resume, chatGPTResponse, maxIterations, maxSets, getGPTFeedback, noResponseFlag)
        FileAppend("`n------------------------------------`nChatGPT response: `n" finalResponse "`n`n`n", "ChatGPT_Final_Function_Specific_Response.txt")
     
        return finalResponse
    } else {
        chatGPTResponse := functionSpecificPrompt
        functionSpecificPrompts := HandleChatGPT(inputText, specifiedPrompt, resume, chatGPTResponse, 1, 1, getGPTFeedback, noResponseFlag)

        functionSpecificPrompts := StrSplit(functionSpecificPrompts, "; ")

        responses := []

        for each, subPrompt in functionSpecificPrompts {
            if inputText == "" {
                holdInputText := subPrompt
                getInputText := true
            } else {
                inputText := subPrompt . inputText
            }
            response := HandleChatGPT(inputText, specifiedPrompt, resume, subPrompt, maxIterations, maxSets, getGPTFeedback, noResponseFlag)
            responses.Push(response)
        }

        combinedResponses := ""
        for each, resp in responses {
            combinedResponses .= resp "`n"  ; Append each response with a newline for clarity
        }

        synthesisPrompt := ""
        synthesisPrompt .= "Based on the detailed responses to each specific aspect of my question, please synthesize a single, cohesive response. "
        synthesisPrompt .= "Here are the function-specific responses:`n`n"
        synthesisPrompt .= combinedResponses
        synthesisPrompt .= "`nNow, using this information, write a comprehensive answer to the main question: '" holdInputText "'. "
        synthesisPrompt .= "Ensure that you maintain a logical flow, highlight key insights, and provide a holistic perspective."

        finalResponse := HandleChatGPT( " ", synthesisPrompt, resume, combinedResponses, maxIterations, maxSets, getGPTFeedback, noResponseFlag)
        FileAppend("`n------------------------------------`nChatGPT response: `n" finalResponse "`n`n`n", "ChatGPT_Final_Function_Specific_Response.txt")

        return finalResponse
    }
    
}

; Function to handle the ChatGPT lookup interaction
HandleChatGPT(inputText := "", specifiedPrompt := "", resume := "", chatGPTResponse := "", maxIterations := 5, maxSets := 1, getGPTFeedback := "", noResponseFlag := false) {
    global noResponsesFlag := noResponseFlag
    global paidGPTFlag := false
    global paidGPTFlagLocked := false
    global finalResponse := {}, holdLoopResponse := {}, holdInteractionResponse := {}, holdInputText := ""
    global chatGPTResponses := []
    combinedPrompt := ""
    logFile := "ChatGPT_Debug_Log.txt"
    global holdInputText, getInputText

    if getGPTFeedback == "true" || getGPTFeedback == "True" {
        maxIterations := 1
    }

    if chatGPTResponse != "" {
        AddChatGPTResponse(chatGPTResponse)
        chatGPTResponse := ""
    }

    if (resume != "" && specifiedPrompt == "") {
        specifiedPrompt := resumeSpecifiedPrompt
        ShowToolTipWithTimer("Using the specifiedPrompt.")
        FileAppend("Using the following specifiedPrompt: " specifiedPrompt "`n", logFile)
        FileAppend("Using the following specifiedPrompt: " specifiedPrompt "`n", verboseLogFile)
    } else if (resume == "" && specifiedPrompt == "") {
        specifiedPrompt := defaultSpecifiedPrompt
        ShowToolTipWithTimer("Using the default specifiedPrompt.")
        FileAppend("Using the following default specifiedPrompt.`n", logFile)
        FileAppend("Using the following default specifiedPrompt.`n", verboseLogFile)
    }

    if inputText == "" {
        updatedParams := GetGPTInput(inputText, specifiedPrompt, resume, chatGPTResponse, maxIterations, maxSets)
        if !updatedParams {
            FileAppend("Failed to get valid input.", logFile)
            FileAppend("Failed to get valid input.", verboseLogFile)
            return false 
        }
        inputText := updatedParams.inputText
        specifiedPrompt := updatedParams.specifiedPrompt
        maxIterations := updatedParams.maxIterations
        maxSets := updatedParams.maxSets
    }
    if getInputText {
        inputText := holdInputText
        getInputText := false
    } else {
        holdInputText := inputText
    }

    ; Call the main function and retrieve ChatGPT's finalResponse
    finalStrResponse := HandleSets(inputText, specifiedPrompt, resume, combinedPrompt, ChatGPTResponse, maxIterations, maxSets, getGPTFeedback)
    
    FileAppend("`n------------------------------------`nChatGPT response: `n" finalStrResponse "`n`n`n", "ChatGPT_Final_Set_Response.txt")
    return finalStrResponse
}

HandleSets(inputText, specifiedPrompt, resume, combinedPrompt, ChatGPTResponse, maxIterations, maxSets, getGPTFeedback) {
    logFile := "ChatGPT_Debug_Log.txt"
    global iterationCount := 1
    global currentSet := 1
    global holdInputText := ""
    global chatGPTSetResponses, chatGPTResponses
    finalResponse := ""
    while currentSet < maxSets + 1 {
        ; Call the main function and retrieve ChatGPT's finalResponse
        holdInteractionResponse := ChatGPT_Interaction(inputText, specifiedPrompt, resume, combinedPrompt, chatGPTResponse, maxIterations, iterationCount, getGPTFeedback)
        if !IsObject(holdInteractionResponse) {
            return holdInteractionResponse
        }

        inputText := holdInteractionResponse.inputText
        specifiedPrompt := holdInteractionResponse.specifiedPrompt
        
        combinedPrompt := holdInteractionResponse.combinedPrompt
        holdInputText := holdInteractionResponse.inputText

        if (A_ThisHotkey != "^i" && resume != "") || getGPTFeedback == "True" || getGPTFeedback == "true" {
            FileAppend("`n`nSingle-iteration completed. Returning finalResponse: " chatGPTResponse "`n`n", logFile)
            FileAppend("`n`nSingle-iteration completed. Returning finalResponse: " chatGPTResponse "`n`n", verboseLogFile)
            return holdInteractionResponse
        }
        ;combinedPrompt := combinedPrompt "`n" specifiedPrompt "`n" inputText "`n ChatGPT Response " iterationCount ": " chatGPTResponse "`n"
        iterationCount++

        ; Call the loop function and retrieve ChatGPT's finalResponse
        holdLoopResponse := ChatGPT_Loop(inputText, specifiedPrompt, combinedPrompt, chatGPTResponse, maxIterations)
        inputText := holdLoopResponse.inputText
        specifiedPrompt := holdLoopResponse.specifiedPrompt
        try {
            chatGPTResponse := holdLoopResponse.chatGPTResponse
            AddChatGPTSetResponse(chatGPTResponse)
        } catch {
            chatGPTResponse := ""
        }
        maxIterations := holdLoopResponse.maxIterations

        FileAppend("`n------------------------------------`nChatGPT Set response: `n" chatGPTResponse "`n`n`n", "ChatGPT_Debug_Log.txt")
        FileAppend("`n------------------------------------`nChatGPT Set response: `n" chatGPTResponse "`n`n`n", "verbose_debug_log.txt")
        FileAppend("`n------------------------------------`nChatGPT Set response: `n" chatGPTResponse "`n`n`n", "ChatGPT_Debug_Log_Response.txt")

        optimalResponseObj := ChatGPT_GetOptimalInteraction(inputText, specifiedPrompt, maxSets)
        optimalResponseStr := optimalResponseObj.chatGPTResponse
        optimalIndex := RegExMatchAll(optimalResponseStr, "1|2")
        optimalSet := optimalIndex[1][0]

        finalResponse := chatGPTResponses[optimalSet]

        if currentSet == 1 {
            AddChatGPTSetResponse(chatGPTResponses[optimalSet])
            AddChatGPTResponse(chatGPTResponses[optimalSet])
            FileAppend("`n------------------------------------`nChatGPT Optimal Set Response: `n" ChatGPTResponses[optimalSet] "`n`n`n", "ChatGPT_Debug_Log_Final_Response.txt")
        } else {
            AddChatGPTSetResponse(chatGPTSetResponses[optimalSet])
            AddChatGPTResponse(chatGPTSetResponses[optimalSet])
            FileAppend("`n------------------------------------`nChatGPT Optimal Set Response: `n" ChatGPTSetResponses[optimalSet] "`n`n`n", "ChatGPT_Debug_Log_Final_Response.txt")
        }          

        currentSet++
    }

    return finalResponse
}

; Function to get the optimal Set response
ChatGPT_GetOptimalInteraction(inputText, specifiedPrompt, maxSets) {
    global optimalPrompt

    optimalResponse := ChatGPT_Interaction(inputText, optimalPrompt "`n" specifiedPrompt,,,, 1, 1, "set")
    
    return optimalResponse
}

; Initial hotkey
^i:: {
    if !ChatGPT() {
        ShowToolTipWithTimer("Script Failed. Press Ctrl+i to try again." , 10000)
    }
    ShowToolTipWithTimer("Script Completed. Press Ctrl+Shift+I to iterate 5 more times" , 10000)
}

; Hotkey for Ctrl + Alt + I to iterate 5 more times based on the last ChatGPT response
^!I:: {
    if chatGPTResponses != [] {
        ; Iterate 5 more times on the last response
        finalResponse := ChatGPT(holdInputText,,,)
        FileAppend("Final Iterated Response: " finalResponse, "ChatGPT_Debug_Log.txt")
        return finalResponse
    } else {
        ShowToolTipWithTimer("No previous response to iterate.",,2000)
        return finalResponse
    }
}