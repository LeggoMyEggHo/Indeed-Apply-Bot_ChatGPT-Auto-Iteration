#Requires AutoHotkey v2.0

#Include ShowToolTipWithTimer.ahk
#SingleInstance Force

IsCallableFunction(FunctionToCall) {
    Try {
        return IsObject(FunctionToCall) && FunctionToCall.HasMethod("Call")
    } Catch {
        ; If function is not found or callable, log the error and break the loop
        FileAppend("Error: No callable function found for functionToCall: " functionToCall "`n`n", "function_debug_log.txt")
        ShowToolTipWithTimer("No callable function found for functionToCall: " functionToCall, , 2000)
        return false
    }
}

CallFunction(functionToCall, rootElement) {
    if IsCallableFunction(functionToCall) {
        ; Call the function and return whether it was successful
        success := functionToCall.Call(rootElement)
        if success {
            ShowToolTipWithTimer("Successfully called function: " functionToCall)
        FileAppend("Successfully called functionToCall: " functionToCall "`n`n", "debug_Log.txt")
        return true
        }
    } else {
        ; If function is not found or callable, log the error and break the loop
        ToolTip("No callable function found for functionToCall: " functionToCall)
        SetTimer () => ToolTip(""), -1000
        FileAppend("Error: No callable function for title: " functionToCall "`n`n", "function_debug_log.txt")
        return false
    }
}
