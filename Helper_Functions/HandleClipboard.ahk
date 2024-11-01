#Requires AutoHotkey v2.0

#Include ..\UIA.ahk
#Include ..\Helper_Functions\ShowToolTipWithTimer.ahk

global clipboardBackupExists := false

if FileExist("HandleClipboard_Debug_Log.txt") {
    FileDelete("HandleClipboard_Debug_Log.txt")
}

HandleClipboard(rootElement := {}, clipboardAssignment := "", variableAssignment := "", copy := false, paste := false, restoreClipboard := true, clearClipboard := true) {
    logFile := "HandleClipboard_Debug_Log.txt"
    verboseLogFile := "verbose_debug_log.txt"
    eMessage := "Error in HandleClipboard: "
    global clipboardBackupExists, clipboardBackup

    if FileExist(logFile) {
        FileDelete(logFile)
    }

    ; Backup the current clipboard if restoring it is required
    if restoreClipboard && !clipboardBackupExists {
        clipboardBackup := ClipboardAll()
        clipboardBackupExists := true
        Sleep(100)  ; Small delay to allow clipboard update
    }

    ; Clear the clipboard if requested
    if clearClipboard && !paste {
        if copy || clipboardAssignment != "" {
            A_Clipboard := ""
            Sleep(100)  ; Small delay to allow clipboard update
        }
    }

    ; Assign the clipboardAssignment value to the clipboard if clipboardAssignment is provided
    if clipboardAssignment != "" {
        A_Clipboard := clipboardAssignment ; Assign the clipboardAssignment value to the clipboard
        restoreClipboard := false
        FileAppend("clipboardAssignment received: " clipboardAssignment "`n", logFile)
        FileAppend("Clipboard after assignment: " A_Clipboard "`n", logFile)
        FileAppend("clipboardAssignment received: " clipboardAssignment "`n", verboseLogFile)
        FileAppend("Clipboard after assignment: " A_Clipboard "`n", verboseLogFile)
        Sleep(100)  ; Small delay to allow clipboard update
    }

    ; Perform copy if the copy parameter is true
    if copy {
        Send("^c")  ; Simulate Ctrl+C to copy selected text
        FileAppend("Clipboard after copy: " A_Clipboard "`n", logFile)
        FileAppend("Clipboard after copy: " A_Clipboard "`n", verboseLogFile)
        Sleep(100)  ; Wait for clipboard to update
        restoreClipboard := false
    }

    ; Assign the clipboard value to variableAssignment if variableAssignment is provided
    if variableAssignment != "" {
        variableAssignment := A_Clipboard ; Assign the clipboard value to the variable
        FileAppend("variableAssignment received: " variableAssignment "`n", logFile)
        FileAppend("Clipboard being assigned to variable: " A_Clipboard "`n", logFile)
        FileAppend("variableAssignment after assignment: " variableAssignment "`n", logFile)
        FileAppend("Clipboard being assigned to variable: " A_Clipboard "`n", verboseLogFile)
        FileAppend("variableAssignment after assignment: " variableAssignment "`n", verboseLogFile)
        Sleep(100)  ; Small delay to allow clipboard update
    }

    ; Perform paste if the paste parameter is true
    if paste {
        Send("^v")  ; Simulate Ctrl+V to paste clipboard contents
        Sleep(200)
        A_Clipboard := ""
        Sleep(100)  ; Wait for clipboard to update
        restoreClipboard := true
    }

    ; Retrieve the current clipboard content
    clipboardText := A_Clipboard

    Sleep(100)  ; Small delay to allow clipboard update
    ; Restore the clipboard if required
    if restoreClipboard {
        A_Clipboard := clipboardBackup
        Sleep(100)  ; Small delay to allow clipboard update
    } else {
        restoreClipboard := true
    }

    ; Return the clipboard content (either after copy, assignment, or the current state)
    return clipboardText
}