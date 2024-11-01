#Requires AutoHotkey v2.0
#Include ..\Helper_Functions\GetArrayLength\GetArrayLength.ahk

global chatGPTResponses := []  ; Array to store the last three ChatGPT responses
global chatGPTSetResponses := []  ; Array to store the most recent ChatGPT Set responses

; Custom RemoveAt function to remove an element at a specific index
RemoveAt(arr, index) {
    arrayLength := GetArrayLength(arr)  ; Get the array length once
    
    ; Debugging line to print the current array length and the index
    FileAppend("`nCurrent Array Length: " arrayLength "`nRemoving element at index: " index "`n", "ChatGPT_Debug_Log.txt")
    
    if (index < 1 || index > arrayLength) {
        FileAppend("Invalid index: " index "`n", "ChatGPT_Debug_Log.txt")
        return  ; Invalid index, do nothing
    }
    
    ; Shift elements to the left, effectively removing the element at 'index'
    Loop arrayLength - index {
        arr[index + A_Index - 1] := arr[index + A_Index]
        FileAppend("Shifting element " index + A_Index - 1 ": " arr[index + A_Index - 1] "`n", "ChatGPT_Debug_Log.txt")
    }
    
    ; Remove the last element after shifting using RemoveAt() instead of Delete()
    FileAppend("Removing element at position: " arrayLength "`n", "ChatGPT_Debug_Log.txt")
    arr.RemoveAt(arrayLength)  ; Remove the last element that was shifted into place
    
    ; Debugging the final array length
    newArrayLength := GetArrayLength(arr)
    FileAppend("New Array Length after removal: " newArrayLength "`n", "ChatGPT_Debug_Log.txt")
}

; Function to maintain a maximum of 3 responses
AddChatGPTResponse(response) {
    global chatGPTResponses
    
    ; Add the new response to the array
    chatGPTResponses.Push(response)

    ; If there are more than 3 responses, remove the oldest one
    if (chatGPTResponses.Length > 3) {  ; Use the custom Length property
        RemoveAt(chatGPTResponses, 1)  ; Remove the first (oldest) element
        FileAppend("`n`nDEBUG: Removed oldest response: " response "`n`n", "ChatGPT_debug_log.txt")
        Sleep(100)
        if (chatGPTResponses.Length > 3) {
            FileAppend("`n`nDEBUG: chatGPTResponses.Length > 3: " chatGPTResponses.Length " at iteration " iterationCount "`n`nExiting App.`n`n", "ChatGPT_debug_log.txt")
            FileAppend("`n`nDEBUG: chatGPTResponses.Length > 3: " chatGPTResponses.Length " at iteration " iterationCount "`n`nExiting App.`n`n", "verbose_debug_log.txt")
            ExitApp
        }
    }
}

; Define a custom Length property for the array
chatGPTResponses.DefineProp("Length", {
    Get: (*) => GetArrayLength(chatGPTResponses)  ; Custom function to count elements
})

chatGPTSetResponses.DefineProp("Length", {
    Get: (*) => GetArrayLength(chatGPTSetResponses)  ; Custom function to count elements
})

; Function to maintain a maximum of 3 responses
AddChatGPTSetResponse(response, setLength := 2) {
    global chatGPTSetResponses
    
    ; Add the new response to the array
    chatGPTSetResponses.Push(response)

    ; If there are more than setLength responses, remove the oldest one
    if (chatGPTSetResponses.Length > setLength) {  ; Use the custom Length property
        RemoveAt(chatGPTSetResponses, 1)  ; Remove the first (oldest) element
        FileAppend("`n`nDEBUG: Set Length is: " setLength "`nRemoved oldest response: " response "`n`n", "ChatGPT_debug_log.txt")
        if (chatGPTSetResponses.Length > setLength) {
            FileAppend("`n`nDEBUG: chatGPTResponses.Length > setLength: " chatGPTSetResponses.Length " at iteration " currentSet "`n`nExiting App.`n`n", "ChatGPT_debug_log.txt")
            FileAppend("`n`nDEBUG: chatGPTResponses.Length > setLength: " chatGPTSetResponses.Length " at iteration " currentSet "`n`nExiting App.`n`n", "verbose_debug_log.txt")
            ExitApp
        }
    } else {
        FileAppend("`n`nDEBUG: Set Length is: " chatGPTSetResponses.Length "`n`n", "ChatGPT_debug_log.txt")
    }
}