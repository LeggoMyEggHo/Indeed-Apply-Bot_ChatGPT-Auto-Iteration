#Requires AutoHotkey v2.0

#Include Utility.ahk
#Include ChatGPT.ahk
#Include Random.ahk

#SingleInstance Force

; Function to handle input elements (e.g., radio buttons, spinners, and edits)
HandleInputElements(rootElement, script := "", specifiedPrompt := "", resume := "") {
    try {
        ; Use Event mode for sending inputs
        SendMode("Event")

        ; Search and handle Spinner elements
        spinners := rootElement.FindAll({ LocalizedType: "spinner" })
        for spinner in spinners {
            RandomDelay(300, 500)
            ProcessInputElement(spinner, script, specifiedPrompt, resume)
            RandomDelay(300, 500)
            if spinner.Name != "Address and search bar" {
                FileAppend("Question: " spinner.Name "`n", "all_questions.txt")
            }
        }

        ; Search and handle Edit elements
        edits := rootElement.FindAll({ LocalizedType: "edit" })
        for edit in edits {
            RandomDelay(300, 500)
            ProcessInputElement(edit, script, specifiedPrompt, resume)
            RandomDelay(300, 500)
            if edit.Name != "Address and search bar" {
                FileAppend("Question: " edit.Name "`n", "all_questions.txt")
            }
        }

        return true
    } catch as e {
        errorMessage := "Error in HandleInputElements: " e.Message
        errorLine := "Line: " e.Line
        errorExtra := "Extra Info: " e.Extra
        errorFile := "File: " e.File
        errorWhat := "Error Context: " e.What
        
        ; Display detailed error information
        MsgBox(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat)
        
        ; Log the detailed error information
        FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n", "debug_log.txt")

        return false
    }
}

ProcessInputElement(element, script := "", specifiedPrompt := "", resume := "") {
    try {

        global associatedLabel := Utility.StrLower(Utility.RemovePunctuation(element.Name))
        ToolTip("Current input is: " associatedLabel ".")

        ; Ignore irrelevant elements based on their label
        if InStr(associatedLabel, "address and search bar") {
            return
        }

        if script == ("IndeedApplySimple" || "IndeedApplySimple.ahk") {
            ; Determine the correct input value using JobApplicationQA
            inputValue := JobApplicationQA(element)
        } else if script == "" {
            inputValue := ChatGPT(associatedLabel, specifiedPrompt, resume)
        }
        
        ; Check if the element's value is "0.0"
        if (element.Value == "0.0") {
            RandomDelay(100, 300)
            element.Value := inputValue
            RandomDelay(100, 300)
            FileAppend("Set value (was 0.0): " inputValue " for Element Name: " element.Name "for Label: " associatedLabel "`n", "input_log.txt")
        } 
        ; Check if the element's value is an empty string
        else if (element.Value == "") {
            RandomDelay(100, 300)
            element.Value := inputValue
            RandomDelay(100, 300)
            FileAppend("Set value (was empty): " inputValue " for Element Name: " element.Name "for Label: " associatedLabel "`n", "input_log.txt")
        } 
        ; Otherwise, log that the value was skipped
        else {
            FileAppend("Skipped element, already has value: " element.Value " for Element Name: " element.Name "for Label: " associatedLabel "`n", "input_log.txt")
        }

        RandomDelay(100, 300)
    } catch as e {
        errorMessage := "Error in ProcessInputElement: " e.Message
        errorLine := "Line: " e.Line
        errorExtra := "Extra Info: " e.Extra
        errorFile := "File: " e.File
        errorWhat := "Error Context: " e.What
        errorObject := "Processing element with name: " element.Name "for Label: " associatedLabel
        
        ; Display detailed error information
        MsgBox(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n" errorObject)
        SetTimer () => ToolTip(""), -1000
        Sleep(1000)
        
        ; Log the detailed error information
        FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n" errorObject "`n`n", "debug_log.txt")
    }
}