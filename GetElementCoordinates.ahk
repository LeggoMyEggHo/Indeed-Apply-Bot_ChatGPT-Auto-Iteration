#Requires AutoHotkey v2.0
#SingleInstance Force

; Shared function to retrieve and adjust coordinates for an element or path
GetElementCoordinates(elementOrPath, rootElement := "") {
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
            element := rootElement.WaitElementFromPath(elementOrPath, 2000)
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

        ; Ensure the element is properly scrolled into view
        element.ScrollIntoView()
        RandomDelay(200, 400) ; Allow time for the UI to adjust

        ; Get the clickable point of the element
        point := element.GetClickablePoint()
        x := point.x  ; Extract x coordinate
        y := point.y  ; Extract y coordinate

        ; Log initial coordinates
        ;MsgBox("Initial coordinates: X=" x " Y=" y)

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

        ; No need to adjust coordinates, just return them as-is for the correct monitor
        return {x: x, y: y, monitorNumber: monitorNumber}
    } catch {
        MsgBox("Failed to retrieve clickable point for the element. Exception: " A_LastError)
        return false
    }
}