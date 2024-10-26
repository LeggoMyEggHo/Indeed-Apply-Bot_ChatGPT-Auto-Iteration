#Requires AutoHotkey v2.0

CoordMode("Mouse", "Screen")

; Function to introduce a random delay
RandomDelay(min := 200, max := 800) {
    delay := Random(min, max)
    Sleep delay
}

; Function to move the mouse with random variability
RandomMouseMove(x, y, elementRight, elementBottom, rangeX := elementRight - x / 2 - 10, rangeY := elementBottom - y / 2 - 10, speed := 10) {
    if elementRight < x || elementBottom < y {
        elementRight := elementRight + x
        elementBottom := elementBottom + y
        rangeX := elementRight / 2
        rangeY := elementBottom / 2
    }
    averageX := (elementRight - x) / 2 + x
    averageY := (elementBottom - y) / 2 + y
    
    ; Ensure the random movement stays within the element's boundaries
    ; Calculate minimum and maximum X/Y values based on range and element boundaries
    minX := Max(averageX - rangeX, x)  ; Ensure minimum X stays within the element's left boundary
    maxX := Min(averageX + rangeX, elementRight)  ; Ensure maximum X stays within the element's right boundary
    minY := Max(averageY - rangeY, y)  ; Ensure minimum Y stays within the element's top boundary
    maxY := Min(averageY + rangeY, elementBottom)  ; Ensure maximum Y stays within the element's bottom boundary
    ;MsgBox("Moving mouse non-randomly to X=" minX " Y=" minY " with rangeX=" rangeX " and rangeY= " rangeY)
    
    ; Randomize movement within the calculated boundary range
    moveX := Round(Random(minX, maxX))
    moveY := Round(Random(minY, maxY))
    
    ; Debugging: Log the calculated random movement positions
    ;MsgBox("Moving mouse randomly to X=" moveX " Y=" moveY " with rangeX=" rangeX " and rangeY= " rangeY)

    ; Get current mouse position
    MouseGetPos(&currentX, &currentY)
    
    ; Move the mouse to the new position with a specific speed
    SendMode("Event")
    MouseMove(moveX, moveY, speed)
    ; Debugging: Log the final mouse position after movement
    ;MouseGetPos(&currentX, &currentY)
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