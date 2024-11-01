#Requires AutoHotkey v2.0

GetUIAProps(element) {
    elementPtr := element.ptr  ; Get the pointer to the element

    ; Convert the pointer to a COM object
    comElement := ComObject(elementPtr, 13) 

    return comElement
}