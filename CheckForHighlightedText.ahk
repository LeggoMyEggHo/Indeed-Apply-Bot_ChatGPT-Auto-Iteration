#Requires AutoHotkey v2.0

#Include ..\UIA.ahk

if FileExist("CheckForHighlightedText_debug_log.txt") {
    FileDelete("CheckForHighlightedText_debug_log.txt")
}

; Function to check for and copy highlighted text from all non-CabinetWClass(File Explorer) windows
CheckForHighlightedText(excludeClasses := ["CabinetWClass", "SysListView32", "SysTreeView32"], excludeTitles := ["Visual Studio Code"]) {
    ; Backup the current clipboard content
    global clipboardBackup := ClipboardAll()
    logFile := "CheckForHighlightedText_debug_log.txt"
    verboseLogFile := "verbose_debug_log.txt"

    WinActivate("A")

    if (copiedText := GetHighlightedText(excludeClasses, excludeTitles)) == "" {
        FileAppend("Didn't find any highlighted text. Clipboard contents: `"" copiedText "`"`n", verboseLogFile)
        return ""  ; Return empty string if no highlighted text is found
    } else {
        FileAppend("Found highlighted text: `"" copiedText "`"`n", verboseLogFile)
        return copiedText
    }
}

; Function to retrieve the highlighted text of the active window
GetHighlightedText(excludeClasses := [], excludeTitles := []) {
    global clipboardBackup
    Static currentClass := WinGetClass("A")
    for excludeClass in excludeClasses {
        if InStr(currentClass, excludeClass) {
            CheckAllWindowsForHighlightedText(excludeClasses, excludeTitles)
        }
    }
    Static currentTitle := WinGetTitle("A")
    for excludeTitle in excludeTitles {
        if InStr(currentTitle, excludeTitle) {
            CheckAllWindowsForHighlightedText(excludeClasses, excludeTitles)
        }
    }

    clipboardBackup := ClipboardAll()  ; Backup current clipboard
    A_Clipboard := ""  ; Clear the clipboard
    Send("^c")  ; Copy the highlighted text
    Sleep(100)  ; Wait for clipboard to update
    highlightedText := A_Clipboard
    A_Clipboard := clipboardBackup  ; Restore the clipboard
    ; Remove any trailing spaces or newlines
    highlightedText := Trim(highlightedText)
    return highlightedText
}

CheckAllWindowsForHighlightedText(excludeClasses := [], excludeTitles := []) {
    global clipboardBackup
    winTitles := ""
    logFile := "CheckForHighlightedText_debug_log.txt"
    verboseLogFile := "verbose_debug_log.txt"

    ; Get a list of all open windows
    windows := []
    allWindows := WinGetList()

    ; Filter the windows based on specific class names
    for win in allWindows {
        winClass := WinGetClass(win)
        if (winClass = "Chrome_WidgetWin_1" || winClass = "MozillaWindowClass" || winClass = "Notepad" || winClass = "Edge") {
            windows.Push(win)
        }
    }
    
    ; Loop through the open windows
    for window in windows {
        ; Get the class of the window
        winClass := WinGetClass(window)
        winTitle := WinGetTitle(window)
        winText := WinGetText(window)
        pid := WinGetPID(window)
        winTitles := winTitles . winTitle
        FileAppend("Checking window: " window " with class: " winClass " with title: " winTitle "with text: " winText " and pid: " pid "`n", verboseLogFile)

        ; Reset the skipWindow flag
        skipWindow := false

        for excludeTitle in excludeTitles {
            if InStr(winTitle, excludeTitle) {
                skipWindow := true
                FileAppend("Skipping window: " window " due to title: " winTitle "`n", verboseLogFile)
                break  ; Break the inner loop if the title matches
            }
        }

        ; Check if the window's class is in excludeClasses
        for excludeClass in excludeClasses {
            if InStr(winClass, excludeClass) {
                skipWindow := true
                FileAppend("Skipping window: " window " due to class: " winClass "`n", verboseLogFile)
                break  ; Break the inner loop if the class matches
            }
        }

        ; Skip the window if it's in the exclude list
        if skipWindow {
            FileAppend("Skipped window: " window " with class: " winClass " and title: " winTitle "`n", verboseLogFile)
            continue  ; Continue to the next window in the outer loop
        }

        ; Activate the window to capture the highlighted text
        WinActivate(window)
        WinWaitActive(window)
        Sleep(200)  ; Small delay to ensure the window is fully active

        ; Get the title of the active window
        winTitle := WinGetTitle("A")

        A_Clipboard := ""  ; Clear the clipboard
        Send("^c") ; Send Ctrl+C to copy the highlighted text
        Sleep(200)  ; Wait for the clipboard to update

        ; Retrieve the clipboard content
        highlightedText := A_Clipboard
        ; If valid highlighted text is found, return it
        if highlightedText != "" {
            ; Restore the clipboard content after copying
            A_Clipboard := clipboardBackup
            FileAppend("Found highlighted text: " highlightedText " in window: " winTitle "`n Returning highlighted text.`n`n", logFile)
            FileAppend("Found highlighted text: " highlightedText " in window: " winTitle "`n Returning highlighted text.`n`n", verboseLogFile)
            return highlightedText
        }
    }

    ; Restore the clipboard if no highlighted text was found
    A_Clipboard := clipboardBackup
    FileAppend("No highlighted text found for the following windows: " winTitles "`n`n", logFile)
    FileAppend("No highlighted text found for the following windows: " winTitles "`n`n", verboseLogFile)
    return ""  ; Return empty string if no highlighted text is found
}