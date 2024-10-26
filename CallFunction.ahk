#Requires AutoHotkey v2.0

#Include ..\Helper_Functions\ShowToolTipWithTimer.ahk
#SingleInstance

if FileExist("CallFunction_Debug_Log.txt") {
    FileDelete("CallFunction_Debug_Log.txt")
}

IsCallableFunction(FunctionToCall) {
    logFile := "CallFunction_Debug_Log.txt"
    Try {
        if IsObject(FunctionToCall) && FunctionToCall.HasMethod("Call") {
            return true
        }
    } Catch {
        ; If function is not found or callable, log the error and break the loop
        FileAppend("Error: No callable function found for functionToCall: " functionToCall "`n`n", logFile)
        ShowToolTipWithTimer("No callable function found for functionToCall: " functionToCall, , 2000)
        return false
    }
}

CallFunction(functionToCall, rootElement) {
    logFile := "CallFunction_Debug_Log.txt"
    if IsCallableFunction(functionToCall) {
        ; Call the function and return whether it was successful
        success := functionToCall.Call(rootElement)
        if success {
            ;ShowToolTipWithTimer("Successfully called functionToCall.")
            ;FileAppend("Successfully called functionToCall.`n`n", logFile)
            return true
        }
    } else {
        ; If function is not found or callable, log the error and break the loop
        ShowToolTipWithTimer("No callable function found for functionToCall: " functionToCall)
        FileAppend("Error: No callable function for title: " functionToCall "`n`n", logFile)
        return false
    }
}
