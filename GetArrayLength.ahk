#Requires AutoHotkey v2.0

; Function to count elements in the array
GetArrayLength(arr) {
    count := 0
    for _, _ in arr {
        count++
    }
    return count
}