#Requires AutoHotkey v2.0

#Include ..\IndeedApply\WaitForCondition.ahk
#Include ..\Helper_Functions\ShowToolTipWithTimer.ahk

; Function to wait for an element by path
WaitForElementByPath(rootElement, path, timeout := 4000) {
    ShowToolTipWithTimer("Waiting for element with path: " path, timeout,, true)
    element := ""
    found := WaitForCondition(() => (
    element := rootElement.WaitElementFromPath(path, 1000)),,timeout)

    if found {
        return element
    } else {
        ToolTip("Failed to find element with path: " path)
        SetTimer () => ToolTip(""), -2000
        return false
    }
}