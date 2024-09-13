#Requires AutoHotkey v2.0

#Include WaitForCondition.ahk

; Function to wait for an element by path
WaitForElementByPath(rootElement, path, timeout := 2000) {
    ToolTip("Waiting for element with path: " path)
    element := ""
    found := WaitForCondition(() => (
        element := rootElement.WaitElementFromPath(path, 1000)), timeout)

    SetTimer () => ToolTip(""), -2000

    if found {
        return element
    } else {
        ToolTip("Failed to find element with path: " path)
        SetTimer () => ToolTip(""), -2000
        return false
    }
}