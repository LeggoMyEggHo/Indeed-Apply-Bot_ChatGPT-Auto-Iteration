#Requires AutoHotkey v2.0+

#Include ..\Helper_Functions\ActivateChromeWindow.ahk
#Include ..\Helper_Functions\GetRootElement.ahk

#SingleInstance

; Function to get and return the company names from Indeed using the parent paths and rootElement
GetCompanyNames(rootElement := "") {
    companyNames := []

    if rootElement == "" {
        hwnd := ActivateChromeWindow()
        rootElement := GetRootElement(hwnd)
    }

    try {
        if parentPaths != [] {
            ; Do nothing if parentPaths is not empty
        } else {
            global parentPaths := ["VR87", "VR87q", "VR87r", "VR87s", "VR87t", "VR87v", "VR87w", "VR87x", "VR87y", "VR87z", "VR87rr", "VR87sr", "VR87tr", "VR87ur", "VR87vr"]
        }
    } catch {
        global parentPaths := ["VR87", "VR87q", "VR87r", "VR87s", "VR87t", "VR87v", "VR87w", "VR87x", "VR87y", "VR87z", "VR87rr", "VR87sr", "VR87tr", "VR87ur", "VR87vr"]
    }

    for parentPath in parentPaths {
        parentElement := rootElement.WaitElementFromPath(parentPath, 1000)
        children := parentElement.FindAll()
        i_1 := 1
        i_2 := 4
        try {
            firstChild := children[i_1]
            secondChild := children[i_2]
        } catch {
            continue
        }
        
        ;MsgBox("firstChild.Name: " firstChild.Name)
        ;MsgBox("secondChild.Name: " secondChild.Name)
        if firstChild.Name == "Applied" {
            i_2++
            secondChild := children[i_2]
        }

        if secondChild.Name == "Remote" {
            i_2--
            secondChild := children[i_2]
            companyNames.Push(secondChild.Name)
            ;if InStr(holdCompanyName, ", ") {
            ;    holdCompanyName := RegExReplace(holdCompanyName, ", ", " ")
            ;}
        } else if secondChild.Name == "New" || secondChild.Name == "Hiring multiple candidates" {
            i_2++
            secondChild := children[i_2]
            if secondChild.Name == "Hiring multiple candidates" || secondChild.Name == "New" {
                i_2++
                secondChild := children[i_2]
            }
            companyNames.Push(secondChild.Name)
            ;if InStr(holdCompanyName, ", ") {
            ;    holdCompanyName := RegExReplace(holdCompanyName, ",", " ")
            ;}
        } else {
            secondChild := children[i_2]
            companyNames.Push(secondChild.Name)
            ;if InStr(holdCompanyName, ", ") {
            ;    holdCompanyName := RegExReplace(holdCompanyName, ", ", " ")
            ;}
        }
    }

    for companyName in companyNames {
        companyNamesStr .= companyName "`n"
    }

    ;MsgBox("Company Names: `n" companyNamesStr)

    return companyNames
}