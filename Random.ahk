#Requires AutoHotkey v2.0

CoordMode("Mouse", "Screen")

; Function to introduce a random delay
RandomDelay(min := 200, max := 800) {
    delay := Random(min, max)
    Sleep delay
}

; Function to move the mouse with random variability
RandomMouseMove(x, y, rangeX := 10, rangeY := 4, speed := 10) {

    ; Randomize movement within a given range
    moveX := Random(x - rangeX, x + rangeX)
    moveY := Random(y - rangeY, y + rangeY)
    
    ; Debugging: Log the calculated random movement positions
    ;MsgBox("Moving mouse to X=" moveX " Y=" moveY " with rangeX=" rangeX " and rangeY= " rangeY)

    ; Get current mouse position
    MouseGetPos(&currentX, &currentY)
    ;MsgBox("Before Moving: Current Mouse Position X=" currentX ", Y=" currentY)
    
    ; Move the mouse to the new position with a specific speed
    SendMode("Event")
    MouseMove(moveX, moveY, speed)
    
    ; Wait until the mouse reaches the destination
    While (true) {
        MouseGetPos(&currentX, &currentY)
        
        ; Break the loop if the mouse has reached the destination
        If (currentX = moveX && currentY = moveY)
            Break

        ; Sleep for a short time before checking again
        Sleep(10)  ; Adjust the check interval as needed
    }
    
    ; Debugging: Log the final mouse position after movement
    MouseGetPos(&currentX, &currentY)
    ;MsgBox("After Moving: Final Mouse Position X=" currentX ", Y=" currentY)
}

; Function to perform a random UIA click with coordinates
RandomUIAClick(x, y, minDelay := 300, maxDelay := 500) {
    ; Introduce a random delay before interacting
    RandomDelay(minDelay, maxDelay)
    
    ; Debugging: Log the coordinates received for the click
    ;MsgBox("RandomUIAClick using X=" x ", Y=" y)
    
    ; Perform the click at the exact coordinates without further movement
    Click(x, y)
    
    ; Introduce another random delay after the click
    RandomDelay(minDelay, maxDelay)
}