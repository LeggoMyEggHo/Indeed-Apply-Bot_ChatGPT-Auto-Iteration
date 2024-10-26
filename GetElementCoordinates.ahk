#Requires AutoHotkey v2.0
#SingleInstance Force
global secondErrorCaught := false

if FileExist("GetElementCoordinates_Debug_Log.txt") {
    FileDelete("GetElementCoordinates_Debug_Log.txt")
}

; Shared function to retrieve and adjust coordinates for an element or path
GetElementCoordinates(elementOrPath, rootElement := "", alignToElement := false) {
    errorCaught := 0
    try {
        ; Reset variables before each calculation
        x := 0
        y := 0

        ; Check if the parameter is a string, indicating it's a path
        if Type(elementOrPath) = "String" {
            if !IsObject(rootElement) {
                MsgBox("GetElementCoordinates Error: rootElement is required when passing path: " elementOrPath)
                return false
            }
            ; Find the element using the path
            element := rootElement.WaitElementFromPath(elementOrPath, 5000)
            if !element {
                MsgBox("Failed to find element with path: " elementOrPath)
                return false
            }
        } else {
            ; Check if rootElement was mistakenly passed as the element
            if elementOrPath = rootElement {
                MsgBox("GetElementCoordinates Error: rootElement was passed instead of an element or path.")
                return false
            }
            element := elementOrPath  ; Directly use the passed element if it's not a string
        }

        ; Get the total number of monitors
        MonitorCount := MonitorGetCount()

        ; Identify which monitor the coordinates belong to
        monitorNumber := 0
        Loop MonitorCount {
            MonitorGet(A_Index, &L, &T, &R, &B)
            if (x >= L && x <= R && y >= T && y <= B) {
                monitorNumber := A_Index
                ;MsgBox("Coordinates found on Monitor " monitorNumber)
                break
            }
        }

        ; If no monitor is found, return an error
        if (monitorNumber = 0) {
            MsgBox("Failed to find a monitor containing the coordinates.")
            return false
        }
        element.ScrollIntoView()
        ;SendInput("{WheelDown}")
        Sleep(250)
        Scroll:
        {
            ; Get the clickable point of the element
            point := element.Location
            x := point.x  ; Extract x coordinate
            ;MsgBox("x=" x)
            y := point.y  ; Extract y coordinate
            ;MsgBox("y=" y)

            ; Calculate the bottom-right corner of the element by adding width and height
            elementRight := x + element.Location.w  ; Right boundary (x + width)
            ;MsgBox("elementRight=" elementRight)
            elementBottom := y + element.Location.h  ; Bottom boundary (y + height)
            ;MsgBox("elementBottom=" elementBottom)

            if alignToElement {
                ; Get the current mouse position
                MouseGetPos(&currentX, &currentY)

                averageX := (elementRight - x) / 2 + x
                
                MouseMove(averageX, currentY, speed := 10)
            }

            ; Get the monitor dimensions where the element is located
            MonitorGetWorkArea(monitorNumber, &monitorLeft, &monitorTop, &monitorRight, &monitorBottom) ; 1 refers to the primary monitor

            ; Compare element's position with monitor/screen boundaries
            if (x >= monitorLeft && elementRight <= monitorRight && y >= monitorTop && elementBottom <= monitorBottom) {
                ;MsgBox("Element is fully visible in the viewport.")
            } else {
                ;MsgBox("Element is not fully visible in the viewport.")
                Click("WheelDown")
                Sleep(250)
                goto Scroll
            }
        }

        ; Optionally, log the element's boundaries and monitor boundaries
        ;MsgBox("Element boundaries: Left=" x ", Top=" y ", Right=" elementRight ", Bottom=" elementBottom)
        ;MsgBox("Monitor boundaries: Left=" monitorLeft ", Top=" monitorTop ", Right=" monitorRight ", Bottom=" monitorBottom)

        ; No need to adjust coordinates, just return them as-is for the correct monitor
        return {x: x, y: y, elementRight: elementRight, elementBottom: elementBottom, monitorNumber: monitorNumber}
    } catch as e {
        errorCaught++
        errorMessage := "Error in GetElementCoordinates: " e.Message
        errorLine := "Line: " e.Line
        errorExtra := "Extra Info: " e.Extra
        errorFile := "File: " e.File
        errorWhat := "Error Context: " e.What
        
        ; Display detailed error information
        ShowToolTipWithTimer(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat)
        
        ; Log the detailed error information
        FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n", "GetElementCoordinates_Debug_Log.txt")
    }

    switch [errorCaught] {
        case 1:
        Sleep(5000) GetElementCoordinates(elementOrPath, rootElement)
        case 2:
        return false
            
    }
}