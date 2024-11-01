#Requires AutoHotkey v2.0
#SingleInstance

;#Include ..\ShowToolTipWithTimer.ahk
;#Include ..\CallFunction.ahk
;#Include ..\..\AHK-v2-libraries-main\Lib\Misc.ahk

if FileExist("WaitForCondition_Debug_Log.txt") {
    FileDelete("WaitForCondition_Debug_Log.txt")    
}

; WaitForCondition Module that can be used to wait for conditions to be met
class WaitForConditionModule {
    static logFile := "WaitForCondition_Debug_Log.txt"

    ; Function to check if a condition is met
    static WaitForCondition(conditions := [], timeout := 5000, checkInterval := 50, callbacks := {}, options := {}) {
        startTime := A_TickCount

        successThreshold := ((options.HasProp("successThreshold")) ? options.successThreshold : 1)
        successMode := ((options.HasProp("successMode")) ? (options.successMode) : ("percentage"))
        conditionWeights := ((options.HasProp("conditionWeights")) ? options.conditionWeights : [])
        stateFile := ((options.HasProp("stateFile")) ? options.stateFile : "")
        state := (stateFile ? this.LoadState(stateFile) : {})

        ; Destructure callback dictionary for flexibility
        callbacks.HasProp("onSuccess") ? onSuccess := callbacks.onSuccess : onSuccess := ""
        callbacks.HasProp("onFailure") ? onFailure := callbacks.onFailure : onFailure := ""
        callbacks.HasProp("onTimeout") ? onTimeout := callbacks.onTimeout : onTimeout := ""
        callbacks.HasProp("onIteration") ? onIteration := callbacks.onIteration : onIteration := ""
        ;for condition in conditionWeights {
        ;    messageBox .= condition
        ;} MsgBox("Conditions: " messageBox)
        ;messageBox := ""
        ; Options for dynamic behavior
        options.HasProp("dynamicTimeout") ? dynamicTimeout := options.dynamicTimeout : dynamicTimeout := false
        options.HasProp("parallelEval") ? parallelEval := options.parallelEval : parallelEval := false
        options.HasProp("prioritizeConditions") ? prioritizeConditions := options.prioritizeConditions : prioritizeConditions := []
        options.HasProp("dynamicConditions") ? dynamicConditions := options.dynamicConditions : dynamicConditions := false
        ; Sort conditions by priority if provided
        if (GetArrayLength(prioritizeConditions)) {
            conditions := prioritizeConditions
        } else {
            prioritizeConditions := conditions
        }
        ; Track condition success/fail states
        conditionThresholds := options.HasProp("conditionThresholds") ? options.conditionThresholds : []
        ; Track successful conditions
        successfulConditions := []
        successfulWeight := 0
        totalWeight := 0

        try {
            ;MsgBox("Array Length of prioritizeConditions: " GetArrayLength(prioritizeConditions))

            ; Continuously check conditions
            while (A_TickCount - startTime < timeout) {
                global holdSuccessfulWeight := 0
                allConditionsMet := true
                evaluationCount := 0
                successfulWeight := 0
                totalWeight := 0
                successfulConditions := []

                ; Tooltip handling
                if (options.showTooltip) {
                    ShowToolTipWithTimer("Checking conditions.", timeout, "")
                }
                            
                if dynamicTimeout && IsCallableFunction(callbacks.onTimeoutUpdate) {
                    timeout := callbacks.onTimeoutUpdate(A_TickCount - startTime, timeout)
                }

                ; Evaluate conditions
                for conditionFunc in conditions {
                    if (this.EvaluateCondition(conditionFunc, conditionWeights, conditionThresholds, successfulWeight, totalWeight, successMode, successThreshold, onIteration, successfulConditions, callbacks)) {
                        ; Add the condition to the list of successful conditions
                        successfulConditions.Push(conditionFunc)
                    }
                }

                ; Check if the success threshold is met
                if this.CheckSuccess(successfulWeight, totalWeight, successThreshold, successMode) {
                    FileAppend("Success threshold met for successfulConditions: " Print(successfulConditions) "`n", this.logFile)

                    ; Call the generic onSuccess callback if available
                    if IsCallableFunction(onSuccess) {
                        onSuccess()
                    }

                    ; Call specific success callbacks based on which conditions succeeded
                    for condition in successfulConditions {
                        ;MsgBox("Successful condition: " condition.Name)
                        successCallbackName := "OnSuccess" condition.Name "()"
                        if IsLabel(successCallbackName) {
                            %successCallbackName%  ; Dynamically call the success callback for the specific condition
                        }
                    }
                    return successfulConditions
                }

                if stateFile {
                    this.SaveState(stateFile, state)
                }

                Sleep(checkInterval)
            }
        } catch as e {
            ;MsgBox("Error in WaitForCondition.`n" e.Message "`ne.What: " e.What "`ne.Extra: " e.Extra "`ne.Line: " e.Line "`n" e.Stack, "Error in WaitForCondition")
            FileAppend("Error in WaitForCondition.`n" e.Message "`ne.What: " e.What "`ne.Extra: " e.Extra "`ne.Line: " e.Line "`n" e.Stack "`n", "WaitForCondition_Debug_Log.txt")
        }

        FileAppend("Timeout reached without meeting conditions.", "WaitForCondition_Debug_Log.txt")
        if IsCallableFunction(onTimeout) {
            onTimeout()
        }
        if IsCallableFunction(onFailure) {
            onFailure()
        }
        return false
    }

    static EvaluateCondition(conditionFunc, conditionWeights, conditionThresholds, successfulWeight, totalWeight, successMode, successThreshold, onIteration, successfulConditions, callbacks) {
        global holdSuccessfulWeight
        
        ; Evaluate the condition and update sucess/failure
        ((conditionWeights.HasProp("Name")) ? totalWeight += (conditionWeights.Name) : totalWeight += 1)
        ;MsgBox("Total Weight: " totalWeight)
        try {
            if conditionFunc() {
                ; If the condition succeeded, increment successful weight and add to successful conditions
                successfulConditions.Push(conditionFunc)
                if ((conditionWeights.HasProp("conditionFunc")) && (conditionWeights.conditionFunc.Name)) {
                    successfulWeight += (conditionWeights.conditionFunc.Name)
                    ;MsgBox("Successful Weight: " successfulWeight)
                } else {
                    successfulWeight += 1
                    ;MsgBox("Successful Weight: " successfulWeight)
                }

                holdSuccessfulWeight += successfulWeight
                return true
            } else {
                FileAppend("Condition " conditionFunc.Name " not met.", "WaitForCondition_Debug_Log.txt")
                
                ; Check if conditionThresholds has "conditionFunc" and "Name" before accessing
                if ((conditionThresholds.HasProp("conditionFunc")) && (conditionThresholds.conditionFunc.Name)) {
                    conditionThresholds.conditionFunc.Name++
                    if conditionThresholds.Name && conditionThresholds.conditionFunc.Name >= conditionThresholds["max"] {
                        FileAppend("Threshold reached for " conditionFunc.Name, "WaitForCondition_Debug_Log.txt")
                    }
                }
                
                return false
            }
        } catch as e {
            ; Handle error and log it
            FileAppend("Error in condition " conditionFunc.Name ": " e.Message "`n" e.What "`n" e.Extra "`n" e.Line "`n", "WaitForCondition_Debug_Log.txt")
        }
    
        if IsCallableFunction(onIteration) {
            onIteration()
        }
    }
    

    static CheckSuccess(successfulWeight, totalWeight, successThreshold, successMode) {
        successfulWeight += holdSuccessfulWeight
        ;MsgBox("Entering Check successMode. Success mode is: " successMode "`nSuccessfulWeight is: " successfulWeight "`nTotalWeight is: " totalWeight "`nSuccessThreshold is: " successThreshold, "Check successMode")
        if successMode = "percentage" {
            return (successfulWeight / totalWeight) >= successThreshold
        } else if successMode = "absolute" {
            return successfulWeight >= successThreshold
        }
        return false
    }

    static AddCondition(conditions, func, priority := 0, weight := 1) {
        if !conditions.func.Name {
            conditions.Push(func)
        }
    }

    static RemoveCondition(conditions, func) {
        if conditions.func.Name {
            conditions.RemoveAt(conditions.IndexOf(func))
        }
    }

    static SaveState(stateFile, state) {
        FileAppend(this.StateToString(state), stateFile)
    }
    
    static LoadState(stateFile) {
        if FileExist(stateFile) {
            stateData := FileRead(stateFile)
            return this.StringToState(stateData)
        }
        return {}
    }
    
    static StateToString(state) {
        ; Convert state to a string format (could be JSON or custom)
        result := ""
        for key, value in state {
            result .= key ":" value "`n"
        }
        return result
    }
    
    static StringToState(data) {
        ; Convert string data back to a state object (custom parsing)
        state := {}
        for line in StrSplit(data, "`n") {
            if (line != "") {
                parts := StrSplit(line, ":")
                if (parts.MaxIndex() == 2) {
                    state[parts[1]] := parts[2]
                }
            }
        }
        return state
    }

    static DefaultBreakCondition() {
        return false
    }
}


; Example Usage

; Define condition functions
;ConditionA() {
;    ; Replace with actual condition logic
;    return Random(0, 1) = 1  ; Example: randomly return true or false
;}

;ConditionB() {
;    ; Replace with actual condition logic
;    return Random(0, 1) = 1  ; Example: randomly return true or false
;}

; Define callbacks

;OnSuccessConditionA() {
;    MsgBox("Condition A succeeded!")
;}

;OnSuccessConditionB() {
;    MsgBox("Condition B succeeded!")
;}

;OnSuccess() {
;    MsgBox("All conditions met successfully!")
;}

;OnFailure() {
;    MsgBox("Conditions were not met within the timeout.")
;}

;OnTimeout() {
;    MsgBox("Timeout reached without meeting conditions.")
;}

; Main execution
;conditions := [Func("ConditionA"), Func("ConditionB")]  ; List of condition functions
;callbacks := {
;    "onSuccess": Func("OnSuccess"),
;    "onFailure": Func("OnFailure"),
;    "onTimeout": Func("OnTimeout"),
;    "onLog": Func("Log")  ; Assuming you have a Log function defined
;}

;options := {
;    "timeout": 5000,
;    "checkInterval": 100,
;    "successThreshold": 1,  ; Require at least 1 condition to succeed
;    "successMode": "absolute",
;    "showTooltip": true,
;    "tooltipText": "Checking conditions..."
;}
;
; Call WaitForCondition
;WaitForConditionModule.WaitForCondition(conditions, options.timeout, options.checkInterval, callbacks, options)

;if successfulConditions {
;    MsgBox("Successful conditions: " StrJoin(successfulConditions, ", "))
;}
