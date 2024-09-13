#Requires AutoHotkey v2.0

; Function to check for and copy highlighted text from all non-CabinetWClass(File Explorer) windows
CheckForHighlightedText(excludeClasses := ("CabinetWClass", "SysListView32"), excludeTitles := "Visual Studio Code") {
    ; Backup the current clipboard content
    clipboardBackup := ClipboardAll()

    ; Get a list of all open windows
    windows := WinGetList()

    ; Loop through the open windows
    for window in windows {
        ; Get the class of the window
        winClass := WinGetClass(window)

        ; Assume the window is not excluded
        skipWindow := false

        ; Check if the window's class is in excludeClasses
        for excludeClass in excludeClasses {
            if InStr(winClass, excludeClass) {
                skipWindow := true
                break  ; Break the inner loop if the class matches
            }
        }

        ; Skip the window if it's in the exclude list
        if skipWindow {
            continue  ; Continue to the next window in the outer loop
        }

        ; Activate the window to capture the highlighted text
        WinActivate(window)
        WinWaitActive(window)
        Sleep(300)  ; Small delay to ensure the window is fully active

        ; Get the title of the active window
        winTitle := WinGetTitle("A")  ; "A" refers to the active window

        ; Check if the window title contains "Visual Studio Code"
        if InStr(winTitle, "Visual Studio Code") {
            continue
        }

        A_Clipboard := ""  ; Clear the clipboard
        Send("^c") ; Send Ctrl+C to copy the highlighted text
        Sleep(200)  ; Wait for the clipboard to update

        ; Retrieve the clipboard content
        highlightedText := A_Clipboard
        ; If valid highlighted text is found, return it
        if highlightedText != "" {
            ; Restore the clipboard content after copying
            A_Clipboard := clipboardBackup
            return highlightedText
        }
    }

    ; Restore the clipboard if no highlighted text was found
    A_Clipboard := clipboardBackup
    return ""  ; Return empty string if no highlighted text is found
}