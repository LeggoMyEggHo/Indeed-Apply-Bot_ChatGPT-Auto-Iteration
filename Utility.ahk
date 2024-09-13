#Requires AutoHotkey v2.0
#SingleInstance Force

; Function to check if a class is defined
IsClassDefined(className) {
    try {
        ; Attempt to call a static method or create an instance to check if the class exists
        if IsObject(%className%) || %className%.__ClassName
            return true
    } catch {
        return false
    }
    return false
}

; Utility.ahk
if !IsClassDefined("Utility") {
    class Utility {
        static RemovePunctuation(str) {
            return RegExReplace(str, "[\p{P}\p{S}]", "")
        }

        static StrLower(str) {
            return StrLower(str)
        }
    }

    global Utility_ClassDefined := true  ; Mark as defined if you need this flag
}
