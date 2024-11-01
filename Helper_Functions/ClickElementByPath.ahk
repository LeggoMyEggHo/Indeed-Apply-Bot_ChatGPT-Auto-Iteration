#Requires AutoHotkey v2.0

;#Include ..\UIA.ahk
;#Include Random.ahk
;#Include GetElementCoordinates.ahk
;#Include ShowToolTipWithTimer.ahk

if FileExist("ClickElementByPath_debug_log.txt") {
    FileDelete("ClickElementByPath_debug_log.txt")
}

; Function to click an element by path or directly by element
ClickElementByPath(pathOrElement, rootElement := "", value := "", timeout := 2000, alignToElement := false) {

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
    
    ; Retrieve and adjust the element's coordinates (adjust with ScrollIntoView and Send("{WheelDown}"))
    coords := GetElementCoordinates(element, rootElement , alignToElement)
    if !coords {
        ShowToolTipWithTimer("ClickElementByPath failed to get element coordinates for element: " element.Name)
        FileAppend("ClickElementByPath failed to get element coordinates for element: " element.Name "`n`n", "ClickElementByPath_debug_log.txt")
        return false
    }
   
    ; Perform random mouse movement before interacting
    RandomMouseMove(coords.x, coords.y, coords.elementRight, coords.elementBottom,,, speed := 10)
    
    ; Adding a MsgBox to see where the mouse is after moving
    MouseGetPos(&currentX, &currentY)

    ; If a value is provided, set it
    if (value != "") {
        element.Value := value
    } else {
        ; Pass the exact coordinates to RandomUIAClick
        RandomUIAClick(currentX, currentY)
    }
    return true
}