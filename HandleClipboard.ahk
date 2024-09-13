#Requires AutoHotkey v2.0

HandleClipboard(rootElement := "", clipboardAssignment := "", variableAssignment := "", copy := false, paste := false, restoreClipboard := true, clearClipboard := true) {
    global clipboardBackup

    ; Backup the current clipboard if restoring it is required
    if restoreClipboard {
        clipboardBackup := ClipboardAll()
    }

    ; Clear the clipboard if requested
    if clearClipboard {
        A_Clipboard := ""
    }

    if rootElement != "" {
        rootElement.ScrollIntoView()
    }

    ; Assign the clipboardAssignment value to the clipboard if clipboardAssignment is provided
    if clipboardAssignment != "" {
        A_Clipboard := clipboardAssignment ; Assign the clipboardAssignment value to the clipboard
    }

    ; Assign the clipboard value to variableAssignment if variableAssignment is provided
    if variableAssignment != "" {
        variableAssignment := A_Clipboard ; Assign the clipboard value to the variable
        Sleep(100)  ; Small delay to allow clipboard update
    }

    ; Perform copy if the copy parameter is true
    if copy {
        Send("^c")  ; Simulate Ctrl+C to copy selected text
        Sleep(100)  ; Wait for clipboard to update
    }

    ; Perform paste if the paste parameter is true
    if paste {
        Send("^v")  ; Simulate Ctrl+V to paste clipboard contents
        Sleep(100)  ; Wait for clipboard to update

    }

    ; Retrieve the current clipboard content
    clipboardText := A_Clipboard

    ; Restore the clipboard if required
    if restoreClipboard {
        A_Clipboard := clipboardBackup
    }

    ; Return the clipboard content (either after copy, assignment, or the current state)
    return clipboardText
}