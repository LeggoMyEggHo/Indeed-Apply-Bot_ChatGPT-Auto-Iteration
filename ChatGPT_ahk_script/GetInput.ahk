#Requires AutoHotkey v2.0

#Include ..\Helper_Functions\CheckForHighlightedText.ahk
#Include ..\Helper_Functions\ShowToolTipWithTimer.ahk

GetGPTInput(inputText := "", specifiedPrompt := "", resume := "", ChatGPTResponse := "", maxIterations := "", maxSets := "", getGPTFeedback := false) {
    global inputTextEdit, promptTextEdit, chatGPTResponseEdit, maxIterationsEdit, maxSetsEdit, optimalPromptEdit
    global defaultSpecifiedPrompt, resumeSpecifiedPrompt
    global inputGui, isUserInputProvided, isHotkeyTriggered, isTextHighlighted
    isUserInputProvided := false
    isHotkeyTriggered := false
    isTextHighlighted := false
    logFile := "ChatGPT_Debug_Log.txt"
    global collectedInput

    ; Check if the function was triggered by a hotkey, specifically this script's name
    if A_ThisHotkey == "^i" {
        isHotkeyTriggered := true
    }

    ; If the script was triggered by a hotkey and no input was passed, check for highlighted text
    if isHotkeyTriggered == true && inputText == "" {
        ; Try to grab highlighted text from any non-File Explorer windows
        inputText := CheckForHighlightedText()

        if inputText != "" {
            isTextHighlighted := true
        } else {
            ShowToolTipWithTimer("No highlighted text found in non-File Explorer windows.", 1000)
        }
    }

    ;MsgBox("isTextHighlighted: " isTextHighlighted)

    ; If no input text is found (from highlighted text or passed directly), prompt the user
    if isHotkeyTriggered && inputText == "" {
        isUserInputProvided := true

        if FileExist("ChatGPT_Debug_Log_FileUpload.txt") {
            FileDelete("ChatGPT_Debug_Log_FileUpload.txt")
        }

        ; Create the GUI with multi-line input box and file upload button
        inputGui := Gui("+Resize", "ChatGPT Iteration Script")
        inputGui.SetFont("s10 q5")
        ;inputGui.Opt("+LastFound")  ; Always bring the GUI to the front
        ;inputGui.Opt("0x02CCFE")  ; Set the background color to a bright sky blue

        inputGui.Add("Text", , "Enter your ChatGPT Prompt or leave blank for default prompt:")
        promptTextEdit := inputGui.Add("Edit", "w400 h100", specifiedPrompt)  ; Multi-line edit box (400px wide, 100px tall)

        ; Add multi-line edit box for text input
        inputGui.Add("Text", , "Enter your input text manually (Required):")
        inputTextEdit := inputGui.Add("Edit", "w400 h200", inputText)  ; Multi-line edit box (400px wide, 200px tall)

        ; Add file upload button
        uploadInputTextBtn := inputGui.Add("Button", , "Upload Input Text File")

        ; Add multi-line edit box for chatGPT response
        inputGui.Add("Text",, "ChatGPT Response:")
        chatGPTResponseEdit := inputGui.Add("Edit", "w400 h100", ChatGPTResponse)  ; Multi-line edit box (400px wide, 100px tall)

        uploadChatGPTResponseBtn := inputGui.Add("Button", , "Upload ChatGPT Response File")
        
        inputGui.Add("Text", , "Max iterations:")
        maxIterationsEdit := inputGui.Add("Edit")
        inputGui.Add("UpDown", "vmaxIterationsUpDown Range1-1000 ", maxIterations)
        inputGui.Add("Text",, "Max sets:")
        maxSetsEdit := inputGui.Add("Edit")
        inputGui.Add("UpDown", "vmaxSetsUpDown Range1-1000 ", maxSets)

        inputGui.Add("Text", , "Optimal Prompt:")
        optimalPromptEdit := inputGui.Add("Edit", "w400 h100", optimalPrompt)
        
        ; Add OK and Cancel buttons
        uploadOptimalPromptBtn := inputGui.Add("Button",, "Upload Optimal Prompt File")
        submitBtn := inputGui.Add("Button", "x+90", "Submit")
        cancelBtn := inputGui.Add("Button","x+10", "Cancel")

        ; Define the button actions
        inputGui.OnEvent("Close", (*) => inputGui.Destroy())  ; Allow the GUI to close
        inputGui.OnEvent("Escape", (*) => inputGui.Destroy())  ; Handle escape key to close the GUI

        ; Define the actions for the Upload and OK buttons
        uploadInputTextBtn.OnEvent("Click", (*) => UploadFile("uploadInputTextBtn"))
        uploadChatGPTResponseBtn.OnEvent("Click", (*) => UploadFile("uploadChatGPTResponseBtn"))
        uploadOptimalPromptBtn.OnEvent("Click", (*) => UploadFile("uploadOptimalPromptBtn"))
        
        submitBtn.OnEvent("Click", (*) => CaptureAndProcessInput())
        
        ; Allow the Cancel button to close the GUI
        if cancelBtn.OnEvent("Click", (*) => inputGui.Destroy()) {
            submittedInputText := ""
        }

        ; Show the GUI
        inputGui.Show()

        ; Wait for the GUI to be closed
        WinWaitClose("ChatGPT Iteration Script")
    }
    
    inputText := collectedInput.inputText
    specifiedPrompt := collectedInput.specifiedPrompt
    maxIterations := collectedInput.maxIterations
    maxSets := collectedInput.maxSets

    if inputText == "" {
        ShowToolTipWithTimer("No inputText received.",, 5000)
        FileAppend("No inputText received.`n", logFile)
        return false
    }

    ; Final debugging: Check what inputText contains at this stage
    ;MsgBox("Final input: '" inputText "'")

    return {inputText: inputText,specifiedPrompt: specifiedPrompt, maxIterations: maxIterations, maxSets: maxSets}
}

; Function to handle file upload
UploadFile(ctrl) {
    global inputTextEdit, chatGPTResponseEdit  ; Declare the global variables for both edit boxes
    file := FileSelect("File")
    
    if file {
        ; Read the content of the file
        fileContent := FileRead(file)
        
        ; Check which button triggered the upload and set the corresponding edit box
        if (ctrl = "uploadInputTextBtn") {
            inputTextEdit.Value := fileContent  ; Set the content for the input text edit box
            FileAppend("Uploaded Input Text file: " file "`n", "ChatGPT_Debug_Log.txt")
            FileAppend("Uploaded Input Text file with content: " fileContent "`n`n", "ChatGPT_Debug_Log_FileUpload.txt")
        } else if (ctrl = "uploadChatGPTResponseBtn") {
            chatGPTResponseEdit.Value := fileContent  ; Set the content for the ChatGPT response edit box
            FileAppend("Uploaded ChatGPT Response file: " file "`n", "ChatGPT_Debug_Log.txt")
            FileAppend("Uploaded ChatGPT Response file with content: " fileContent "`n`n", "ChatGPT_Debug_Log_FileUpload.txt")
        } else if (ctrl = "uploadOptimalPromptBtn") {
            optimalPromptEdit.Value := fileContent  ; Set the content for the optimal prompt edit box
            FileAppend("Uploaded Optimal Prompt file: " file "`n", "ChatGPT_Debug_Log.txt")
            FileAppend("Uploaded Optimal Prompt file with content: " fileContent "`n`n", "ChatGPT_Debug_Log_FileUpload.txt")
        }
    }
}

CaptureAndProcessInput(*) {
    global collectedInput
    collectedInput := SubmitInput()  ; Call SubmitInput and capture its return value
    inputGui.Destroy()  ; Destroy the GUI
    return collectedInput
}


; Function to handle submission of text
SubmitInput(*) {
    global inputTextEdit, promptTextEdit, chatGPTResponseEdit, maxIterationsEdit, maxSetsEdit, chatGPTResponseEdit, optimalPromptEdit
    global inputGui
    inputText := inputTextEdit.Value  ; Get the input text from the edit box
    specifiedPrompt := promptTextEdit.Value  ; Get the specified prompt from the edit box
   
    maxIterations := maxIterationsEdit.Value  ; Get the maxIterations from the edit box
    maxSets := maxSetsEdit.Value  ; Get the maxSets from the edit box
    if chatGPTResponseEdit.Value != "" {
        AddChatGPTResponse(chatGPTResponseEdit.Value)
    }

    ; Now that we've got the values, destroy the GUI
    inputGui.Destroy()

    ; Ensure that all values are returned or passed for further processing
    FileAppend("`nCollected inputText: " inputText "`n`nCollected specifiedPrompt: " specifiedPrompt "`n`nCollected maxIterations: " maxIterations "`n`nCollected maxSets: " maxSets "`n`n", "ChatGPT_Debug_Log.txt")
    return {inputText: inputText, specifiedPrompt: specifiedPrompt, maxIterations: maxIterations, maxSets: maxSets}
}