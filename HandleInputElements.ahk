#Requires AutoHotkey v2.0

#Include ..\Helper_Functions\Utility.ahk
#Include ..\ChatGPT_ahk_script\ChatGPT.ahk
#Include ..\Helper_Functions\Random.ahk

#SingleInstance

; Function to handle input elements (e.g., radio buttons, spinners, and edits)
HandleInputElements(rootElement, script := "", specifiedPrompt := "", resume := "") {
    spinnerLabel := "Spinner"
    editLabel := "Edit"
    ;try {
        ; Use Event mode for sending inputs
        SendMode("Event")

        ; Search and handle Spinner elements
        spinners := rootElement.FindAll({ LocalizedType: "spinner" })
        for spinner in spinners {
            Sleep(500)
            ProcessInputElement(spinner, script, specifiedPrompt, resume)
            if spinner.Name != "Address and search bar" {
                spinnerLabel := spinner.Name
                spinnerLabel := RegExReplace(spinnerLabel, "^This is an employer\-written question\. You can report inappropriate questions to Indeed through the `"Report Job`" link at the bottom of the job description\. ?", "")
                spinnerLabel := RegExReplace(spinnerLabel, "\(optional\)", "")
                FileAppend("Spinner Question: " spinnerLabel "`n", "all_questions.txt")
            }
        }

        ; Search and handle Edit elements
        edits := rootElement.FindAll({ LocalizedType: "edit" })
        for edit in edits {
            Sleep(500)
            ProcessInputElement(edit, script, specifiedPrompt, resume)
            if edit.Name != "Address and search bar" {
                editLabel := edit.Name
                editLabel := RegExReplace(editLabel, "^This is an employer\-written question\. You can report inappropriate questions to Indeed through the `"Report Job`" link at the bottom of the job description\. ?", "")
                editLabel := RegExReplace(editLabel, "\(optional\)", "")
                FileAppend("Edit Question: " editLabel "`n", "all_questions.txt")
            }
        }

        return true
    ;} catch as e {
        ;errorMessage := "Error in HandleInputElements: " e.Message
        ;errorLine := "Line: " e.Line
        ;errorExtra := "Extra Info: " e.Extra
        ;errorFile := "File: " e.File
        ;errorWhat := "Error Context: " e.What
        
        ; Display detailed error information
        ;MsgBox(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat)
        
        ; Log the detailed error information
        ;FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n", "debug_log.txt")

        ;return false
    ;}
}

ProcessInputElement(element, script := "", specifiedPrompt := "", resume := "") {
    global answerReview, configFile, inputName
    logFile := "missing_questions_log.txt"
    fileContent := ""

        ; Ignore irrelevant elements based on their label
        if InStr(element.Name, "Address and search bar") {
            return
        }

        if script == "IndeedApplySimple" || script == "IndeedApplySimple.ahk" {
            ; Determine the correct input value using JobApplicationQA
            ;inputValue := JobApplicationQA(element)
            if element.LocalizedType == "spinner" && element.Value == "0.0" {
                specifiedPrompt := "Using this resume, directly and succinctly answer the following question using only an integer. For example: 1"
                inputValue := JobApplicationQA(element, specifiedPrompt)
                if inputValue == "" {
                    MsgBox("No input value found for element even after JobApplicationQA: " element.Name)
                    inputValue := ChatGPT(inputName, specifiedPrompt, resume,,,, getGPTFeedback := "True")
                }
            } else if element.LocalizedType == "edit" && element.Value == "" {
                inputValue := JobApplicationQA(element, specifiedPrompt)
                if inputValue == "" {
                    MsgBox("No input value found for element even after JobApplicationQA: " element.Name)
                    inputValue := ChatGPT(inputName, specifiedPrompt, resume,,,, getGPTFeedback := "True")
                }
            }
        } else if script == "" {
            inputValue := JobApplicationQA(element, specifiedPrompt)
            if inputValue == "" {
                ;MsgBox("No input value found for element: " element.Name)
                inputValue := ChatGPT(inputName, specifiedPrompt, resume,,,, "True")
            }
        }

        
        ;global EditBox
        WinActivate("A")
        ; Check if the element's value is "0.0"
        if (element.Value == "0.0") {
            if answerReview {
                lastWindow := WinActive()
                answerReviewGui := Gui("+Resize -E0x200", "Answer Review")  ; Create a new GUI with the -E0x200 style to remove default styling
                answerReviewGui.BackColor := "Black"     ; Set the GUI background to black
                questionText := answerReviewGui.Add("Text", "w300 h80 x0 Center -E0x200 BackgroundBlack", inputName) ; Add a text control to the GUI
                questionText.SetFont("s10 cWhite") ; Set font size and color to white for visibility
                EditBox := answerReviewGui.Add("Edit", "w300 h35 x0 y+20 Center -VScroll -E0x200 BackgroundBlack", inputValue)
                EditBox.BackColor := "Black" ; Set the background color of the edit box to black
                EditBox.SetFont("s10 cWhite") ; Set font size and color to white for visibility
                submitBtn := answerReviewGui.Add("Button", "x100 w100 +Default -E0x200 BackgroundBlack", "Submit").OnEvent("Click", (*) => InputElement(element))

                ; Handle pressing Enter while in the EditBox
                ;EditBox.Focus() ; Set focus on the Edit control

                InputElement(element) {
                    answerReviewGui.Hide()
                    inputValue := EditBox.Value
                    element.Value := EditBox.Value
                    FileAppend("Answer: " inputValue " for Element Name: " element.Name "`n", "all_questions.txt")
                    answerReviewGui.Destroy()
                }

                ; Wait for the user to press Enter or close the GUI
                answerReviewGui.OnEvent("Close", (*) => ExitApp())
                answerReviewGui.Show()
                WinWaitClose("Answer Review")
            } else {
                element.Value := inputValue
            }
            ; If the Gui fails, you can grab input from the InputBox
            ;inputBoxValue := InputBox("Question:`n`n" element.Name,,, inputValue)
            ;inputValue := inputBoxValue.Value

            ; Add this new question-answer pair to the config file
            IniWrite(inputValue, configFile, "CommonResponses", associatedLabel)
            if FileExist(logFile) {
                fileContent := FileRead(logFile)
            }
            
            if !InStr(fileContent, inputName) {
                FileAppend("Question: " inputName "`n`nChatGPT response: " inputValue "`n`n", logFile)
            }
            FileAppend("Set value (was 0.0): " inputValue " for Element Name: " element.Name "`n", "input_log.txt")
            FileAppend("Spinner Question: " element.Name "`nSet value (was 0.0): " inputValue "`n", "all_questions.txt")
        } 
        ; Check if the element's value is an empty string
        else if (element.Value == "") {
            if answerReview {
                lastWindow := WinActive()
                answerReviewGui := Gui("+Resize -E0x200", "Answer Review")  ; Create a new GUI with the -E0x200 style to remove default styling
                answerReviewGui.BackColor := "Black"     ; Set the GUI background to black
                questionText := answerReviewGui.Add("Text", "w300 h80 x0 Center -E0x200 BackgroundBlack", inputName) ; Add a text control to the GUI
                questionText.SetFont("s10 cWhite") ; Set font size and color to white for visibility
                EditBox := answerReviewGui.Add("Edit", "w300 h35 x0 y+20 Center -VScroll -E0x200 BackgroundBlack", inputValue)
                EditBox.BackColor := "Black" ; Set the background color of the edit box to black
                EditBox.SetFont("s10 cWhite") ; Set font size and color to white for visibility
                submitBtn := answerReviewGui.Add("Button", "x100 w100 +Default -E0x200 BackgroundBlack", "Submit").OnEvent("Click", (*) => InputElement(element))

                ; Handle pressing Enter while in the EditBox
                ;EditBox.Focus() ; Set focus on the Edit control

                ; Wait for the user to press Enter or close the GUI
                answerReviewGui.OnEvent("Close", (*) => ExitApp())
                answerReviewGui.Show()
                WinWaitClose("Answer Review")
            } else {
                element.Value := inputValue
            }
            ; If the Gui fails, you can grab input from the InputBox
            ;inputBoxValue := InputBox("Question:`n`n" element.Name,,, inputValue)
            ;inputValue := inputBoxValue.Value

            ; Add this new question-answer pair to the config file
            if associatedLabel != "todays date" {
                IniWrite(inputValue, configFile, "CommonResponses", associatedLabel)
            }
            if FileExist(logFile) {
                fileContent := FileRead(logFile)
            }
            
            if !InStr(fileContent, inputName) {
                FileAppend("Question: " inputName "`n`nChatGPT response: " inputValue "`n`n", logFile)
            }
            FileAppend("Set value (was empty): " inputValue " for Element Name: " element.Name "`n", "input_log.txt")
            FileAppend("Edit Question: " element.Name "`nSet value to answer (was empty): " inputValue "`n", "all_questions.txt")
        }
        ; Otherwise, log that the value was skipped
        else {
            FileAppend("Skipped element, already has value: " element.Value " for Element Name: " element.Name "`n", "input_log.txt")
        }

        ;RandomDelay(100, 300)
    ;catch as e {
        ;errorMessage := "Error in ProcessInputElement: " e.Message
        ;errorLine := "Line: " e.Line
        ;errorExtra := "Extra Info: " e.Extra
        ;errorFile := "File: " e.File
        ;errorWhat := "Error Context: " e.What
        ;errorObject := "Processing element with name: " element.Name
        
        ; Display detailed error information
        ;MsgBox(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n" errorObject)
        ;SetTimer () => ToolTip(""), -1000
        ;Sleep(1000)
        
        ; Log the detailed error information
        ;FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n" errorObject "`n`n", "debug_log.txt")
    ;}
}