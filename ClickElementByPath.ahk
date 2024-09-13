#Requires AutoHotkey v2.0

#Include Random.ahk
#Include GetElementCoordinates.ahk
#Include ShowToolTipWithTimer.ahk

; Function to click an element by path or directly by element
ClickElementByPath(pathOrElement, rootElement := "", value := "", timeout := 2000) {
    element := pathOrElement

    ; Determine if pathOrElement is already an element or needs to be resolved from a path
    if IsObject(pathOrElement) {
        element := pathOrElement  ; It's already an element
    } else {
        ; If pathOrElement is not an object, assume it's a path and resolve it
        if !IsObject(rootElement) {
            ShowToolTipWithTimer("ClickElementByPath Error: rootElement is required when passing path: " element)
            FileAppend("ClickElementByPath Error: rootElement is required when passing path: " element, "ClickElementByPath_debug_log.txt")
            return false
        }
        element := rootElement.WaitElementFromPath(pathOrElement, timeout)
        if !element {
            ShowToolTipWithTimer("Element with path " pathOrElement " not found within timeout.")
            FileAppend("Element with path " pathOrElement " not found within timeout.", "ClickElementByPath_debug_log.txt")
            return false
        }
    }

    ; Activate the Chrome window before any further action
    WinActivate("ahk_exe chrome.exe")

    element.ScrollIntoView()
    RandomDelay(300, 500)

    ; Retrieve and adjust the element's coordinates
    coords := GetElementCoordinates(element, rootElement)
    if !coords {
        ShowToolTipWithTimer("ClickElementByPath failed to get element coordinates for element: " element.Name)
        FileAppend("ClickElementByPath failed to get element coordinates for element: " element.Name "`n`n", "ClickElementByPath_debug_log.txt")
        return false
    }

    ; Debugging: Log the element coordinates before moving
    ;MsgBox("ClickElementByPath moving to X=" coords.x ", Y=" coords.y)
    
    ; Perform random mouse movement before interacting
    RandomMouseMove(coords.x, coords.y, rangeX := 15, rangeY := 5, speed := 10)
    
    ; Adding a MsgBox to see where the mouse is after moving
    MouseGetPos(&currentX, &currentY)
    ;MsgBox("After ClickElementByPath Mouse Position X=" currentX ", Y=" currentY)

    ; If a value is provided, set it
    if (value != "") {
        element.Value := value
    } else {
        ; Pass the exact coordinates to RandomUIAClick
        RandomUIAClick(coords.x, coords.y)
    }
    return true
}