#Requires AutoHotkey v2.0

#Include %A_ScriptDir%\Lib\UIA.ahk
#Include Utility.ahk
#Include ChatGPT.ahk
#SingleInstance Force
#Include HandleClipboard.ahk

global resume := "Work experience`nSales Development Representative`nServiceTitan - Remote`nFebruary 2024 to June 2024`nConvert QLs into SQLs by enriching leads, building rapport, providing value, and qualifying until estimated Customer LifeTime Value is 95+% before booking 1-hour SQLs`nThe only one to hit quota by Month 1 out of a starting class of 30`n3x June quota booked and confirmed before the month started`nSales Development Representative`nOperatix - Remote`nFebruary 2023 to August 2023`nCollaborated with Regional Sales Managers to design and execute strategic sales campaigns, resulting in a 40% increase in public sector engagement.`nLeveraged SalesLoft, ZoomInfo, and 6Sense to enhance lead generation strategies, directly contributing to a 35% increase in business revenue.`nReceived further Salesforce training to adeptly convert both cold and warm MQLs to SALs, resulting in a Customer Lifetime Value exceeding $2 million through the identification and fulfillment of client needs via targeted CoreView solutions.`nSales Development Representative`nVaVende - Remote`nAugust 2020 to February 2023`nImplemented innovative marketing and sales training techniques, reducing training costs by approximately 50%`nSustained high productivity, averaging 30 calls, emails, and texts per hour`nScheduled up to 18 appointments daily, achieving an appointment-to-sales conversion rate of up to 40%`nPro Services Sales Specialist`nLowe's - Stillwater, OK`nFebruary 2020 to August 2020`nConsulted on B2B, retail, and special order services, nurturing client relationships and increasing monthly revenue by 25%`nIdentified client needs and promoted additional products and services, driving business growth`nIndependent Contractor`nSelf Employed Contractor - Stillwater, OK`nFebruary 2018 to February 2020`nConducted compliance audits for franchises with 1-25 employees, identifying regulatory weaknesses and implementing strategic improvements`nAchieved a monthly sales quota of $80k, demonstrating strong sales and business development skills`nEducation`nAssociate in Science (AS) in Business Administration`nNorthern Oklahoma College - Stillwater, OK`nJanuary 2021 to June 2023`nSkills`nCRM Software - 5 years`nPenetration testing - 1 year`nSaaS sales - 1 year`nNetwork administration - 2 years`nC# - 1 year`nCold Calling - 4 years`nMicrosoft Excel - 5 years`nJavaScript - 2 years`nComputer Networking - 2 years`nB2B Sales - 4 years`nSales - 5 years"
; Define global variables for config values
global configFile := A_ScriptDir "\config.ini"
global commonResponses := Map()  ; Initialize commonResponses as a map
global editFields := []  ; Array to store dynamically created Edit controls
; Define the list of strings to check for in HandleJobSearch elements
global excludeList := ["Applied", "Expired", "Already Applied", "Application Closed", "Insurance", "Real Estate", "Solar", "Licensed"]
; Define the list of job types to exclude in HandleJobSearch
global excludeJobTypes := ["financial", "health", "insurance", "medical", "va", "autocad", "electronic components", "estimating", "writing", "federal", "transformer", "travel", "foodservice", "logistics", "capital equipment", "glass", "leadership", "supply"]

; Load existing configuration or create a new one
if !FileExist(configFile) {
    SetupConfig()  ; If config file doesn't exist, open GUI for setup
} else {
    LoadConfig()   ; Otherwise, load the existing configuration
}

; Hotkey to open the GUI for editing settings (Ctrl + E)
^e::SetupConfig()

; Function to load config values from the .ini file
LoadConfig() {
    ; Define global variables for config values
    global excludeList, excludeJobTypes, phone, email, linkedIn, currentEmployer, cityState, timezone, salaryRange, travelPreference, willingToRelocate, citizenshipStatus, industryExperience, sponsorshipStatus, zeroYearsOfExperience, oneYearOfExperience
    global backgroundCheck, needTimeOff, payExpectations, willingToTravel, visaSponsorship, outreachMethods, comfortableWorking, highestAchieved, salesTargets, whyAreYouInterestedKeywords
    global commonResponses, configFile

    excludeList := IniRead(configFile, "Settings", "Exclude Job Details", excludeList)
    excludeJobTypes := IniRead(configFile, "Settings", "Exclude Job Types", excludeJobTypes)
    phone := IniRead(configFile, "Settings", "Phone", "(xxx) xxx-xxxx")
    email := IniRead(configFile, "Settings", "Email", "your_email@your_domain.com")
    linkedIn := IniRead(configFile, "Settings", "LinkedIn", "www.linkedin.com/in/FIRSTNAME-LASTNAME-li")
    currentEmployer := IniRead(configFile, "Settings", "Current Employer", "Current Employer or N/A if none")
    cityState := IniRead(configFile, "Settings", "City, State", "Ardmore, Oklahoma")
    timezone := IniRead(configFile, "Settings", "Timezone", "Central Time (CT)")

    ; Load HandleKeywords strings for the script
    salaryRange := IniRead(configFile, "Settings", "Salary Range", "$50,000 - $70,000")
    travelPreference := IniRead(configFile, "Settings", "Travel Preference", "0-25% travel is best")
    willingToRelocate := IniRead(configFile, "Settings", "Willing to Relocate", "No")
    citizenshipStatus := IniRead(configFile, "Settings", "Citizenship Status", "2")
    industryExperience := IniRead(configFile, "Settings", "Industry Experience", "Retail, Wholesale, Construction, Manufacturing, Marketing, Insurance, Automotive, Accounting, and SaaS")
    sponsorshipStatus := IniRead(configFile, "Settings", "Sponsorship Status", "No")

    ; Load HandleYearQuestions strings for the script
    zeroYearsOfExperience := IniRead(configFile, "Settings", "Years of Experience", excludeJobTypes)
    oneYearOfExperience := IniRead(configFile, "Settings", "Years of Experience", "events")
    ; Load additional keyword responses
    backgroundCheck := IniRead(configFile, "Settings", "Background Check Response", "Yes")
    needTimeOff := IniRead(configFile, "Settings", "Need Time Off Response", "No")
    payExpectations := IniRead(configFile, "Settings", "Pay Expectations Response", "$50,000 - $70,000")
    willingToTravel := IniRead(configFile, "Settings", "Willing to Travel Response", "0-25% travel")
    visaSponsorship := IniRead(configFile, "Settings", "Visa Sponsorship Response", "No")
    outreachMethods := IniRead(configFile, "Settings", "Outreach Methods", "Phone, Email, and Messages")
    comfortableWorking := IniRead(configFile, "Settings", "Comfortable Working Response", "Yes")
    highestAchieved := IniRead(configFile, "Settings", "Highest Achieved Quota", "~100-150k")
    salesTargets := IniRead(configFile, "Settings", "Sales Targets Response", "5+ years")
    whyAreYouInterestedKeywords := IniRead(configFile, "Settings", "Why Are You Interested Keywords", "I’m drawn to your company’s innovative approach and commitment to excellence, which align with my values and professional aspirations.")
}

; Load common responses from the .ini file using Loop, Read
LoadCommonResponses() {
    global configFile, commonResponses, commonResponses
    section := "[CommonResponses]"
    isInSection := false

    ; Load the common responses from the INI file
    Loop Read, configFile
    {
        line := Trim(A_LoopReadLine)  ; Trim leading/trailing spaces
        
        ; Check if we're in the desired section
        if (line = section) {
            isInSection := true
            continue
        }

        ; If another section is found, exit the CommonResponses section
        if (isInSection && line ~= "^\[.*\]$") {
            break
        }

        ; Process key-value pairs within the CommonResponses section
        if (isInSection && InStr(line, "=")) {
            keyValue := StrSplit(line, "=")
            questionKey := Trim(keyValue[1])
            response := Trim(keyValue[2])
            commonResponses[questionKey] := response  ; Add key-value pair to map
        }
    }
}

; GUI for setting or editing configuration
SetupConfig() {
    global excludeList, excludeJobTypes phone, email, linkedIn, currentEmployer, cityState, timezone, salaryRange, travelPreference, willingToRelocate, citizenshipStatus, industryExperience, sponsorshipStatus, zeroYearsOfExperience, oneYearOfExperience
    global backgroundCheck, needTimeOff, payExpectations, willingToTravel, visaSponsorship, outreachMethods, comfortableWorking, highestAchieved, salesTargets, whyAreYouInterestedKeywords
    global configFile, commonResponses, editFields

    ; Create a new GUI object
    gui := Gui()
    gui.SetFont("s10")  ; Set font size for better readability
    gui.Opt("+LastFound")
    gui.WinSetTransColor "#02CCFE"  ; Set the background color to a bright sky blue

    ; Prepare the commonResponsesText for GUI display
    commonResponsesText := ""
    ; Dynamically create input fields for each question and response
    editFields := []  ; Array to store dynamically created Edit controls

    for key, value in commonResponses {
        gui.Add("Text",, "Question:")
        questionEdit := gui.Add("Edit", "w300 cRed", key)  ; Editable field for the question
        gui.Add("Text",, "Response:")
        responseEdit := gui.Add("Edit", "w300 cRed", value)  ; Editable field for the response
        editFields.Push([questionEdit, responseEdit])  ; Store the Edit controls
    }

    ; Add input fields for each setting
    gui.Add("Text",, "Excluded Job Offer Details, Job Titles, & Companies")
    excludeListEdit := gui.Add("Edit", "w300 cRed", excludeList)

    gui.Add("Text",, "Excluded Job Types (Comma Separated):")
    excludeJobTypesEdit := gui.Add("Edit", "w300 cRed", excludeJobTypes)

    gui.Add("Text",, "Phone Number ((format: (xxx) xxx-xxxx )):")
    phoneEdit := gui.Add("Edit", "w300 cRed", phone)

    gui.Add("Text",, "Email (your_email@your_domain.com):")
    emailEdit := gui.Add("Edit", "w300 cRed", email)

    gui.Add("Text",, "LinkedIn (www.linkedin.com/in/FIRSTNAME-LASTNAME):")
    linkedInEdit := gui.Add("Edit", "w300 cRed", linkedIn)

    gui.Add("Text",, "Current Employer (N/A if none):")
    currentEmployerEdit := gui.Add("Edit", "w300 cRed", currentEmployer)

    gui.Add("Text",, "City, State (i.e. Seattle, WA):")
    cityStateEdit := gui.Add("Edit", "w300 cRed", cityState)

    gui.Add("Text",, "Timezone (i.e. Central Time (CST)):")
    timezoneEdit := gui.Add("Edit", "w300 cRed", timezone)

    ; Add additional fields for the return strings
    gui.Add("Text",, "Salary Range (i.e.$50,000 - $70,000):")
    salaryRangeEdit := gui.Add("Edit", "w300 cRed", salaryRange)

    gui.Add("Text",, "Travel Preference (0-100%):")
    travelPreferenceEdit := gui.Add("Edit", "w300 cRed", travelPreference)

    gui.Add("Text",, "Willing to Relocate (Yes/No):")
    willingToRelocateEdit := gui.Add("Edit", "w300 cRed", willingToRelocate)

    gui.Add("Text",, "Citizenship Status (2 for yes, 1 for no):")
    citizenshipStatusEdit := gui.Add("Edit", "w300 cRed", citizenshipStatus)

    gui.Add("Text",, "Industry Experience (Comma Separated):")
    industryExperienceEdit := gui.Add("Edit", "w300 cRed", industryExperience)

    gui.Add("Text",, "Visa Sponsorship Needed (Yes/No):")
    sponsorshipStatusEdit := gui.Add("Edit", "w300 cRed", sponsorshipStatus)

    gui.Add("Text",, "Industries with 0 to 0.5 years of experience:")
    zeroYearsofExperienceEdit := gui.Add("Edit", "w300 cRed", zeroYearsOfExperience)

    gui.Add("Text",, "Industries with 0.5 to 1.5 years of experience:")
    oneYearofExperienceEdit := gui.Add("Edit", "w300 cRed", oneYearOfExperience)

    ; Add additional configurable responses
    gui.Add("Text",, "Background Check Response:")
    backgroundCheckEdit := gui.Add("Edit", "w300 cRed", backgroundCheck)

    gui.Add("Text",, "Need Time Off Response:")
    needTimeOffEdit := gui.Add("Edit", "w300 cRed", needTimeOff)

    gui.Add("Text",, "Pay Expectations Response:")
    payExpectationsEdit := gui.Add("Edit", "w300 cRed", payExpectations)

    gui.Add("Text",, "Willing to Travel Response:")
    willingToTravelEdit := gui.Add("Edit", "w300 cRed", willingToTravel)

    gui.Add("Text",, "Visa Sponsorship Response:")
    visaSponsorshipEdit := gui.Add("Edit", "w300 cRed", visaSponsorship)

    gui.Add("Text",, "Outreach Methods:")
    outreachMethodsEdit := gui.Add("Edit", "w300 cRed", outreachMethods)

    gui.Add("Text",, "Comfortable Working Response:")
    comfortableWorkingEdit := gui.Add("Edit", "w300 cRed", comfortableWorking)

    gui.Add("Text",, "Highest Achieved Salary:")
    highestAchievedEdit := gui.Add("Edit", "w300 cRed", highestAchieved)

    gui.Add("Text",, "Sales Targets Response:")
    salesTargetsEdit := gui.Add("Edit", "w300 cRed", salesTargets)

    gui.Add("Text",, "Why Are You Interested?(Universal Answer, leave blank to get ChatGPT Answer):")
    whyAreYouInterestedKeywordsEdit := gui.Add("Edit", "w300 cRed", whyAreYouInterestedKeywords)
    
    ; Add save button and link it to SaveConfig function
    gui.Add("Button",, "Save").OnEvent("Click", () => SaveConfig(
        gui,
        excludeListEdit.Text,
        excludeJobTypesEdit.Text,
        phoneEdit.Text,
        emailEdit.Text,
        linkedInEdit.Text,
        currentEmployerEdit.Text,
        cityStateEdit.Text,
        timezoneEdit.Text,
        salaryRangeEdit.Text,
        travelPreferenceEdit.Text,
        willingToRelocateEdit.Text,
        citizenshipStatusEdit.Text,
        industryExperienceEdit.Text,
        sponsorshipStatusEdit.Text,
        zeroYearsOfExperienceEdit.Text,
        oneYearOfExperienceEdit.Text,
        backgroundCheckEdit.Text,
        needTimeOffEdit.Text,
        payExpectationsEdit.Text,
        willingToTravelEdit.Text,
        visaSponsorshipEdit.Text,
        outreachMethodsEdit.Text,
        comfortableWorkingEdit.Text,
        highestAchievedEdit.Text,
        salesTargetsEdit.Text,
        editFields,
        whyAreYouInterestedKeywordsEdit.Text
    ))

    ; Show the GUI
    gui.Show("AutoSize, Center")
}

; Function to save the configuration
SaveConfig(gui, excludeListText, excludeJobTypesText, phoneText, emailText, linkedInText, currentEmployerText, cityStateText, timezoneText, salaryRangeText, travelPreferenceText, willingToRelocateText, citizenshipStatusText, industryExperienceText, sponsorshipStatusText, zeroYearsOfExperienceText, oneYearOfExperienceText, backgroundCheckText, needTimeOffText, payExpectationsText, willingToTravelText, visaSponsorshipText, outreachMethodsText, comfortableWorkingText, highestAchievedText, salesTargetsText, editFields, whyAreYouInterestedKeywordsText) {
    global configFile, commonResponses

    ; First, clear the existing CommonResponses section in the .ini file
    IniDelete(configFile, "CommonResponses")

    ; Iterate through the dynamic fields and save the new question and response pairs
    for fieldPair in EditFields {
        question := Trim(fieldPair[1].Text)  ; Get the edited question
        response := Trim(fieldPair[2].Text)  ; Get the edited response

        ; Ensure both the question and response are present before saving
        if (question != "" && response != "") {
            ; Write each key-value pair to the [CommonResponses] section in config.ini
            IniWrite(response, configFile, "CommonResponses", question)
        }
    }

    ; Write all values to config.ini
    IniWrite(excludeListText, configFile, "Settings", "Exclude Job Details")
    IniWrite(excludeJobTypesText, configFile, "Settings", "Exclude Job Types")
    IniWrite(phoneText, configFile, "Settings", "Phone")
    IniWrite(emailText, configFile, "Settings", "Email")
    IniWrite(linkedInText, configFile, "Settings", "LinkedIn")
    IniWrite(currentEmployerText, configFile, "Settings", "Current Employer")
    IniWrite(cityStateText, configFile, "Settings", "City State")
    IniWrite(timezoneText, configFile, "Settings", "Timezone")
    IniWrite(salaryRangeText, configFile, "Settings", "Salary Range")
    IniWrite(travelPreferenceText, configFile, "Settings", "Travel Preference")
    IniWrite(willingToRelocateText, configFile, "Settings", "Willing to Relocate")
    IniWrite(citizenshipStatusText, configFile, "Settings", "Citizenship Status")
    IniWrite(industryExperienceText, configFile, "Settings", "Industry Experience")
    IniWrite(sponsorshipStatusText, configFile, "Settings", "Sponsorship Status")
    IniWrite(zeroYearsOfExperienceText, configFile, "Settings", "Years of Experience 0")
    IniWrite(oneYearOfExperienceText, configFile, "Settings", "Years of Experience 1")
    IniWrite(backgroundCheckText, configFile, "Settings", "Background Check Response")
    IniWrite(needTimeOffText, configFile, "Settings", "Need Time Off Response")
    IniWrite(payExpectationsText, configFile, "Settings", "Pay Expectations Response")
    IniWrite(willingToTravelText, configFile, "Settings", "Willing to Travel Response")
    IniWrite(visaSponsorshipText, configFile, "Settings", "Visa Sponsorship Response")
    IniWrite(outreachMethodsText, configFile, "Settings", "Outreach Methods")
    IniWrite(comfortableWorkingText, configFile, "Settings", "Comfortable Working Response")
    IniWrite(highestAchievedText, configFile, "Settings", "Highest Achieved Quota")
    IniWrite(salesTargetsText, configFile, "Settings", "Sales Targets Response")
    IniWrite(whyAreYouInterestedKeywordsText, configFile, "Settings", "Why Are You Interested Keywords")
    MsgBox("Configuration saved!")

    gui.Destroy()
}

; Function to log missing questions and get answer dynamically
HandleMissingQuestion(missingQuestion, rootElement) {
    global resume, configFile
    
    logFile := "missing_questions_log.txt"
    fileContent := ""

    ; Remove the standard leading sentence
    missingQuestion := RegExReplace(missingQuestion, "^This is an employer-written question\. You can report inappropriate questions to Indeed through the `"Report Job`" link at the bottom of the job description\. ?", "")

    ; Remove the trailing (optional)
    missingQuestion := RegExReplace(missingQuestion, "\(optional\)", "")

    ; Trim any extra spaces or quotes that may be left
    cleanedQuestion := Trim(missingQuestion)
    ;MsgBox("Cleaned Question: " cleanedQuestion)

    ; Create a simplified key for the config by removing punctuation and converting to lowercase
    questionKey := Utility.StrLower(Utility.RemovePunctuation(cleanedQuestion))

    ; Check if the question is already in commonResponses
    response := IniRead(configFile, "CommonResponses", questionKey, "")
    if (response != "") {
        return response  ; If it's already in the config, return the existing response
    }

    ; If not found, generate a new response using ChatGPT
    ChatGPTResponse := ChatGPT(cleanedQuestion, , resume)

    if ChatGPTResponse != "" {
        ; Add this new question-answer pair to the config file
    IniWrite(ChatGPTResponse, configFile, "CommonResponses", questionKey)
    }

    if FileExist(logFile) {
        fileContent := FileRead(logFile)
    }
    
    if !InStr(fileContent, cleanedQuestion) {
        FileAppend("Question: " cleanedQuestion "`n`nChatGPT response: " ChatGPTResponse "`n`n", logFile)
    }
    
    global missingAnswer := ChatGPTResponse
    FileAppend("Answer: " missingAnswer "`n", logFile)
    Sleep(1000)
    return missingAnswer
}

; Function to handle specific keywords
HandleKeywords(associatedLabel) {
    global email, phone, linkedIn, currentEmployer, salaryRange, travelPreference, willingToRelocate, citizenshipStatus, industryExperience, sponsorshipStatus, outreachMethods, comfortableWorking, highestAchieved, salesTargets, willingToTravel

    FileAppend("Checking label: " associatedLabel "`n", "JobApplicationQA_debug_log.txt")  ; Log the label being checked

    if InStr(associatedLabel, "solutions") && InStr(associatedLabel, "have you sold") {
        FileAppend("Matched keyword: solutions + have you sold`n", "JobApplicationQA_debug_log.txt")
        return industryExperience
    } else if InStr(associatedLabel, "please answer 2 if you are a us citizen") {
        FileAppend("Matched keyword: US citizen (2)`n", "JobApplicationQA_debug_log.txt")
        return citizenshipStatus
    } else if InStr(associatedLabel, "salary") || InStr(associatedLabel, "compensation") {
        FileAppend("Matched keyword: Salary`n", "JobApplicationQA_debug_log.txt")
        return salaryRange
    } else if InStr(associatedLabel, "timezone") || InStr(associatedLabel, "time zone") {
        FileAppend("Matched keyword: Timezone`n", "JobApplicationQA_debug_log.txt")
        return timezone
    } else if InStr(associatedLabel, "live") || InStr(associatedLabel, "located") || InStr(associatedLabel, "location") || InStr(associatedLabel, "residence") || InStr(associatedLabel, "city") {
        FileAppend("Matched keyword: Location`n", "JobApplicationQA_debug_log.txt")
        return cityState
    } else if InStr(associatedLabel, "not accepting applicants without") {
        FileAppend("Matched keyword: Not accepting applicants`n", "JobApplicationQA_debug_log.txt")
        return "I understand."
    } else if InStr(associatedLabel, "why are you interested") {
        FileAppend("Matched keyword: Why are you interested`n", "JobApplicationQA_debug_log.txt")
        return whyAreYouInterestedKeywords
    } else if InStr(associatedLabel, "background check") {
        FileAppend("Matched keyword: Background check`n", "JobApplicationQA_debug_log.txt")
        return backgroundCheck
    } else if InStr(associatedLabel, "need") && InStr(associatedLabel, "time off") {
        FileAppend("Matched keyword: Time off`n", "JobApplicationQA_debug_log.txt")
        return needTimeOff
    } else if InStr(associatedLabel, "pay expectations") || InStr(associatedLabel, "desired salary") || InStr(associatedLabel, "salary expectations") || InStr(associatedLabel, "salary range") || InStr(associatedLabel, "hourly compensation") || InStr(associatedLabel, "salary compensation") {
        FileAppend("Matched keyword: Pay expectations`n", "JobApplicationQA_debug_log.txt")
        return salaryRange
    } else if InStr(associatedLabel, "are you willing to travel") && InStr(associatedLabel, "between") {
        FileAppend("Matched keyword: Willing to travel`n", "JobApplicationQA_debug_log.txt")
        return travelPreference
    } else if InStr(associatedLabel, "willing to relocate") {
        FileAppend("Matched keyword: Willing to relocate`n", "JobApplicationQA_debug_log.txt")
        return willingToRelocate
    } else if InStr(associatedLabel, "subject to") && InStr(associatedLabel, "non-compete") {
        FileAppend("Matched keyword: Non-compete`n", "JobApplicationQA_debug_log.txt")
        return "Not to my knowledge"
    } else if InStr(associatedLabel, "which industries have you worked in") {
        FileAppend("Matched keyword: Industries worked in`n", "JobApplicationQA_debug_log.txt")
        return industryExperience
    } else if (InStr(associatedLabel, "which") || InStr(associatedLabel, "what")) && InStr(associatedLabel, "have you sold") {
        FileAppend("Matched keyword: Have you sold (specific)`n", "JobApplicationQA_debug_log.txt")
        return industryExperience
    } else if InStr(associatedLabel, "require sponsorship") || InStr(associatedLabel, "sponsorship") || InStr(associatedLabel, "visa") {
        FileAppend("Matched keyword: Sponsorship`n", "JobApplicationQA_debug_log.txt")
        return sponsorshipStatus
    } else if InStr(associatedLabel, "primary") && InStr(associatedLabel, "outreach") {
        FileAppend("Matched keyword: Primary outreach`n", "JobApplicationQA_debug_log.txt")
        return outreachMethods
    } else if (InStr(associatedLabel, "are you") && InStr(associatedLabel, "comfortable")) || InStr(associatedLabel, "are you okay with") {
        FileAppend("Matched keyword: Comfortable working`n", "JobApplicationQA_debug_log.txt")
        return comfortableWorking
    } else if InStr(associatedLabel, "highest") && InStr(associatedLabel, "achieved") {
        FileAppend("Matched keyword: Highest achieved`n", "JobApplicationQA_debug_log.txt")
        return highestAchieved
    } else if InStr(associatedLabel, "email") && InStr(associatedLabel, "phone") {
        FileAppend("Matched keyword: Email and phone`n", "JobApplicationQA_debug_log.txt")
        return email . " " . phone
    } else if InStr(associatedLabel, " phone ") {
        FileAppend("Matched keyword: Phone`n", "JobApplicationQA_debug_log.txt")
        return phone
    } else if InStr(associatedLabel, " email ") {
        FileAppend("Matched keyword: Email`n", "JobApplicationQA_debug_log.txt")
        return email
    } else if InStr(associatedLabel, "linkedin") {
        FileAppend("Matched keyword: LinkedIn`n", "JobApplicationQA_debug_log.txt")
        return linkedIn
    } else if InStr(associatedLabel, "current employer") {
        FileAppend("Matched keyword: Current employer`n", "JobApplicationQA_debug_log.txt")
        return currentEmployer
    }

    ; Add more patterns and responses as needed
    FileAppend("No HandleKeywords() match found for associatedLabel: " associatedLabel "`n", "JobApplicationQA_debug_log.txt")
    return ""
}


; Handle year-related questions
HandleYearQuestions(associatedLabel) {
    global zeroYearsOfExperience, oneYearOfExperience

    ; Determine the threshold based on the associated label and respond with "Yes" or "No"
    if RegExMatch(associatedLabel, "have more than") || RegExMatch(associatedLabel, "have over") || RegExMatch(associatedLabel, "how many years") {
        ; Capture the number in the label
        if RegExMatch(associatedLabel, "\b\d+\b", &numberMatch) {
            number := numberMatch[0]  ; Extract the matched number as a string
            number := number + 0      ; Convert it to a number for comparison

            ; Determine the threshold based on specific keywords
            threshold := 5  ; Default threshold

            for keyword in zeroYearsOfExperience {
                if InStr(associatedLabel, keyword) {
                    threshold := 0
                    break
                }
            }

            for keyword in oneYearOfExperience {
                if InStr(associatedLabel, keyword) {
                    threshold := 1
                    break
                }
            }

            ; Perform the comparison
            return number <= threshold ? "Yes" : "No"
        }
        return "Yes"
    }
    
    ; Assign fallback value for numerical answers
    fallbackValue := "5"  ; Default value

    ; Check if fallback value can be reassigned to a known keyword value
    for keyword in zeroYearsOfExperience {
        if InStr(associatedLabel, keyword) {
            fallbackValue := "0"
            break  ; Exit the loop once a match is found
        }
    }

    ; Check if fallback value can be reassigned to a known keyword value
    for keyword in oneYearOfExperience {
        if InStr(associatedLabel, keyword) {
            fallbackValue := "1"
            break  ; Exit the loop once a match is found
        }
    }
    ; If we've reached this point, no match was found. Log the error and return the fallback value
    FileAppend("No HandleYearQuestions() match found for associatedLabel: " associatedLabel "`n", "JobApplicationQA_debug_log.txt")
    return fallbackValue
}

; Handle general "do you" questions
HandleDoYouQuestions(associatedLabel) {
    global cityState, timezone
    ; Split the string at the comma
    cityAndState := StrSplit(cityState, ",")
    ; The first element is the city
    global city := Trim(cityAndState[1])
    ; The second element is the state (if needed)
    stateAbbreviation := Trim(cityAndState[2])

    timezoneKeywords := StrSplit(timezone, "(")

    timezoneKeywordA := Trim(timezoneKeywords[1])
    timezoneKeywordA := StrSplit(timezoneKeywordA, " ")
    timezoneKeywordA := Trim(timezone[1])

    timezoneKeywordB := Trim(timezoneKeywords[2])
    timezoneKeywordB := StrSplit(timezoneKeywordB, " ")
    timezoneKeywordB := Trim(timezone[2])

    ; Determine the threshold based on the associated label and respond with "Yes" or "No"
    if (InStr(associatedLabel, "west coast") || InStr(associatedLabel, "east coast")) && (!InStr(associatedLabel, stateAbbreviation) || !InStr(associatedLabel, timezoneKeywordA) || InStr(associatedLabel, timezoneKeywordB) || InStr(associatedLabel, "remote") || InStr(associatedLabel, "remote work")) || InStr(associatedLabel, "book of business") || InStr(associatedLabel, "sponsorship") || InStr(associatedLabel, "visa") || InStr(associatedLabel, "issue for you") {
        return "No"
    } else if InStr(associatedLabel, "relationships") {
        return "None"
    } else if InStr(associatedLabel, "have an understanding") {
        return "Yes"
    } else {
        FileAppend("No HandleDoYouQuestions() match found for associatedLabel: " associatedLabel "`n", "JobApplicationQA_debug_log.txt")
        return "Yes"
    }
}

; Main function to handle custom job application questions
JobApplicationQA(input) {
    global commonResponses 
    global associatedLabel := Utility.StrLower(Utility.RemovePunctuation(input.Name))  ; Convert to lowercase after removing punctuation
    response := ""

    ; Handle specific keywords first
    response := HandleKeywords(associatedLabel)
    if response {
        input.Value := response
        return response
    }

    ; Handle year-related questions
    if InStr(associatedLabel, "year") || InStr(associatedLabel, "years") {
        response := HandleYearQuestions(associatedLabel)
        input.Value := response
        return response
    }

    ; Handle general "do you" questions
    if InStr(associatedLabel, "do you") {
        response := HandleDoYouQuestions(associatedLabel)
        input.Value := response
        return response
    }

    if IniRead(configFile, "CommonResponses") != "" {
        FileAppend("configFile not found: " configFile "`n", "JobApplicationQA_debug_log.txt")
        ; Common questions with predefined responses
        commonResponses.Set("tell me about yourself", "I’m a dedicated professional with a passion for continuous improvement and a track record of success in delivering results through strategic thinking and collaboration.")
        commonResponses.Set("why do you want to work for our company", "I’m drawn to your company’s innovative approach and commitment to excellence, which align with my values and professional aspirations.")
        commonResponses.Set("why are you the best candidate for the job", "My unique combination of skills, experience, and dedication to continuous learning ensures I can bring immediate value and grow with your organization.")
        commonResponses.Set("what are your greatest strengths", "My strengths lie in my analytical thinking, adaptability, and ability to lead teams toward shared goals with clarity and motivation.")
        commonResponses.Set("what are your greatest weaknesses", "I tend to focus heavily on details, but I’ve learned to balance this by prioritizing tasks and delegating when necessary.")
        commonResponses.Set("what are your most impressive achievements", "My most significant achievements include leading successful initiatives that resulted in measurable improvements and being recognized for my contributions to the team’s success.")
        commonResponses.Set("what have you learned from your previous work experience", "I’ve learned the importance of adaptability, clear communication, and continuous improvement, which have been crucial in achieving successful outcomes.")
        commonResponses.Set("provide an example of a time when you demonstrated leadership abilities", "I led a cross-functional team through a complex project, ensuring clear communication and aligning everyone's efforts toward a successful outcome, surpassing our goals.")
        commonResponses.Set("give an example of a time you resolved a team conflict", "I facilitated a discussion where conflicting team members could express their concerns, leading to a mutual understanding and a collaborative solution.")
        commonResponses.Set("how does this position fit in with your longterm career goals", "This role aligns perfectly with my desire to contribute to innovative projects while continuing to develop my expertise and leadership abilities.")
        commonResponses.Set("what is your first goal if you get this role", "My initial goal would be to fully understand the team’s dynamics and ongoing projects to identify where I can contribute most effectively from the start.")
        commonResponses.Set("describe your last position and what you accomplished", "In my last role, I focused on streamlining processes and enhancing team collaboration, resulting in significant efficiency improvements and project success.")
        commonResponses.Set("describe your education in university, trade school or college", "My education was rigorous and diverse, equipping me with both theoretical knowledge and practical skills applicable to a wide range of scenarios.")
        commonResponses.Set("what did you major in while in college", "My major focused on a field that combines analytical thinking with creativity, preparing me for the multifaceted challenges of today’s work environment.")
        commonResponses.Set("do you have an undergraduate degree", "Yes, I completed an undergraduate program that deepened my understanding of key concepts and prepared me for professional challenges.")
        commonResponses.Set("what was your favorite class in college", "A class that combined theory with real-world applications, allowing me to explore complex problems and develop practical solutions.")
        commonResponses.Set("did you complete any minors or certificates while in school", "Yes, I pursued additional certifications that complemented my major, broadening my expertise and enhancing my versatility.")
        commonResponses.Set("do you have any advanced degrees", "I have pursued advanced studies that have deepened my knowledge and provided specialized skills relevant to my professional path.")
        commonResponses.Set("what are your advanced degrees focused on", "My advanced studies focused on areas that require critical thinking and strategic planning, equipping me with tools to tackle complex challenges.")
        commonResponses.Set("when did you graduate from high school or earn your ged", "I graduated in a timeframe that provided me with the necessary academic foundation to pursue further education and professional development.")
        commonResponses.Set("when did you graduate from college", "I graduated during a period that allowed me to immediately apply my education to the professional world, gaining valuable experience.")
        commonResponses.Set("have you ever been published", "Yes, I’ve had the opportunity to contribute to publications where I shared insights and findings relevant to my field of expertise.")
        commonResponses.Set("what was your first position", "My first position provided a strong foundation in the basics of professional conduct, offering invaluable lessons that I carry with me today.")
        commonResponses.Set("what did you learn from your first job", "My first job taught me the importance of responsibility, attention to detail, and the value of teamwork in achieving common goals.")
        commonResponses.Set("how did you earn money as a kid", "I started by taking on small entrepreneurial tasks, which taught me the value of hard work and financial independence from an early age.")
        commonResponses.Set("have you completed any volunteer work", "Yes, I’ve volunteered in initiatives that align with my values, contributing my skills to causes that positively impact the community.")
        commonResponses.Set("how have you stayed current with trends in your career", "I stay current by engaging with industry news, participating in professional networks, and attending relevant seminars and conferences.")
        commonResponses.Set("how did you learn about this job opportunity", "I learned about this opportunity through a combination of professional networks and my ongoing research into companies that align with my career aspirations.")
        commonResponses.Set("how do you continue your education", "I am committed to lifelong learning, regularly engaging in courses, workshops, and self-study to stay current in my field.")
        commonResponses.Set("are you willing to obtain another degree or certificate if the role requires it", "Absolutely, I am open to furthering my education to better align with the demands of the role and contribute more effectively.")
        commonResponses.Set("what industry developments are you excited about", "I’m excited about developments that integrate technology and human-centered design, offering innovative solutions to contemporary challenges.")
        commonResponses.Set("which industry developments are you wary about", "I approach certain rapid technological changes with caution, considering their long-term implications and the balance between innovation and ethics.")
        commonResponses.Set("why did you or do you want to leave your present position", "I’m seeking new challenges that align more closely with my long-term goals and offer opportunities for growth and contribution.")
        commonResponses.Set("why did you change your mind last", "I reassessed my priorities based on new information, leading me to make a decision that better aligned with my long-term goals.")
        commonResponses.Set("what are your it and programming language capabilities", "I possess a solid foundation in various programming languages and IT systems, adept at quickly learning and applying new technologies to meet project needs.")
        commonResponses.Set("describe the technology and tools you used in your previous position", "I utilized a range of tools that supported data analysis, project management, and communication, ensuring efficient and effective task completion.")
        commonResponses.Set("are there any technologies you'd like to learn how to use", "I’m always eager to learn new technologies that can enhance productivity and innovation, particularly those that are emerging in the market.")
        commonResponses.Set("do you have experience mentoring others", "I’ve had the opportunity to mentor colleagues, focusing on their growth by sharing insights and providing constructive feedback to help them reach their potential.")
        commonResponses.Set("describe a time you displayed good oral communication skills", "I have effectively communicated complex ideas to diverse audiences by breaking down technical jargon into understandable concepts, ensuring clarity and engagement.")
        commonResponses.Set("how have you solved conflict in your workplace", "I address conflicts by listening to all perspectives, fostering open communication, and working towards a resolution that benefits the team.")
        commonResponses.Set("what is your leadership style", "My leadership style is collaborative and supportive, ensuring that team members feel valued and motivated to contribute their best work.")
        commonResponses.Set("have you held managerial positions in the past", "Yes, I’ve managed teams where I focused on empowering individuals, fostering collaboration, and driving toward our collective goals.")
        commonResponses.Set("please list 23 dates and time ranges that you could do an interview", "I am available on weekdays, preferably taking meetings in the afternoons, but I can be flexible to accommodate your schedule.")
        commonResponses.Set("describe your writing skills", "I possess strong writing skills, capable of crafting clear, concise, and compelling content that communicates ideas effectively across various formats.")
        commonResponses.Set("describe your management skills", "I have a proven track record of managing teams and projects efficiently, ensuring goals are met while fostering a positive and productive work environment.")
        commonResponses.Set("describe your experience with customer service", "I have a solid background in customer service, consistently delivering solutions that exceed client expectations and foster long-term relationships.")
        commonResponses.Set("describe your experience with networking", "I’ve successfully built and maintained professional networks that have provided valuable opportunities for collaboration and career growth.")
        commonResponses.Set("do you consider yourself a team player", "Absolutely, I thrive in collaborative environments where diverse ideas contribute to innovative solutions and shared success.")
        commonResponses.Set("why or why not", "Absolutely, I thrive in collaborative environments where diverse ideas contribute to innovative solutions and shared success.")
        commonResponses.Set("what motivates you", "I’m motivated by the opportunity to solve complex problems, make meaningful contributions, and continuously learn and grow professionally.")
        commonResponses.Set("what are three words that best describe you, and why", "Curious, resilient, and proactive—these qualities drive me to continuously learn, adapt to challenges, and take initiative.")
        commonResponses.Set("what is something interesting about you", "I have a passion for problem-solving, which often leads me to find creative solutions in both professional and personal endeavors.")
        commonResponses.Set("tell us about your hobbies", "My hobbies include activities that challenge my mind and body, such as strategic games, fitness, and exploring new technologies.")
        commonResponses.Set("how do you spend your free time", "I enjoy a mix of activities that keep me mentally stimulated and physically active, balancing relaxation with personal development.")
        commonResponses.Set("what do you do outside of work", "Outside of work, I engage in activities that broaden my perspective, such as reading, staying active, and participating in community initiatives.")
        commonResponses.Set("what is the last book you read", "The last book I read was focused on leadership and strategy, offering valuable insights that I apply in my work.")
        commonResponses.Set("what is the last article you read", "I recently read an article on emerging trends in technology, which sparked ideas for how these innovations could be applied in various industries.")
        commonResponses.Set("what would you like to achieve while working here", "I aim to contribute to significant projects that drive the company forward, while also developing my skills and growing within the organization.")
        commonResponses.Set("explain three steps you might take to improve this business", "I’d start by analyzing current processes, identifying areas for efficiency gains, and implementing technology-driven solutions to enhance productivity.")
        commonResponses.Set("is there a quote that you live by", "“The only way to do great work is to love what you do.” This motivates me to pursue excellence and find passion in every task.")
        commonResponses.Set("what is it", "“The only way to do great work is to love what you do.” This motivates me to pursue excellence and find passion in every task.")
        commonResponses.Set("why should we hire you over other qualified candidates", "My proactive approach, coupled with a deep understanding of the required skills, ensures I can make a meaningful impact from day one.")
        commonResponses.Set("when can you start", "Immediately")
        commonResponses.Set("do you speak english", "Yes")
        commonResponses.Set("do you speak spanish", "No")
    }

    ; Match the associatedLabel to a common response
    ;for key, value in commonResponses {
    ;    if InStr(associatedLabel, key) {
    ;        input.Value := value
    ;        return value
    ;    }
    ;}

    ; Check if the question exists in commonResponses
    response := IniRead(configFile, "CommonResponses", associatedLabel, "")
    if (response != "") {
        input.Value := response
        return response
    }

    ; Get rootElement if no match is found
    hwnd := ActivateChromeWindow()
    rootElement := GetRootElement(hwnd)

    ; Log the missing question if no match is found and return a default response
    defaultResponse := "Yes"
    missingAnswer := HandleMissingQuestion(input.Name, rootElement)

    if missingAnswer {
        input.Value := missingAnswer
        return missingAnswer
    } else {
        input.Value := defaultResponse  ; Input the default response
        failureMessage := "No matches found and unable to get answer dynamically, inputting defaultResponse for associatedLabel: "
        FileAppend(failureMessage associatedLabel "`n", "JobApplicationQA_debug_log.txt")
        ToolTip(failureMessage associatedLabel)
        SetTimer () => ToolTip("") -1000
        Sleep(1000)
        return defaultResponse
    }
    
}

; Function to handle input elements (e.g., radio buttons, spinners, and edits)
HandleRadioButtons(rootElement) {
    try {
        ; Find all radio groups
        radioGroups := rootElement.FindAll({ LocalizedType: "radio group" })
        for radioGroup in radioGroups {
            ; Retrieve and display specific properties of the radio group element
            radioGroupName := Utility.StrLower(Utility.RemovePunctuation(radioGroup.Name))
            FileAppend("Question: " radioGroupName "`n", "all_questions.txt")

            ; Find radio buttons within this radio group
            radioButtons := radioGroup.FindAll({ LocalizedType: "radio button" })

            ; Check if any radio button in this group is already selected
            radioButtonAlreadySelected := false
            for radioButton in radioButtons {
                if radioButton.IsSelected && !InStr(radioGroupName, "remote") {
                    ;MsgBox("A radio button is already selected in this group.")  ; Debugging output
                    radioButtonAlreadySelected := true
                    break
                }
            }

            ; If any radio button is selected, skip this group
            if radioButtonAlreadySelected {
                continue
            }

            ; Iterate through radio buttons and handle each one individually
            for radioButton in radioButtons {
                radioButtonName := Utility.StrLower(Utility.RemovePunctuation(radioButton.Name))

                ; Handle specific cases first
                if InStr(radioGroupName, "highest level of education you have completed") {
                    ToolTip("Processing Education Question")  ; Debugging output
                    if InStr(radioButtonName, "associate") {
                        ToolTip("Found 'Associate', about to click.")  ; Debugging output
                        RandomDelay(100, 300)
                        ClickElementByPath(radioButton)
                        RandomDelay(200, 400)
                        break  ; Stop after clicking the correct button
                    }
                }

                ; Special conditions for selecting "Yes" or "No" irrespective of current selection
                if InStr(radioGroupName, "authorized to work in the united states") {
                    if InStr(radioButtonName, "yes") {
                        ToolTip("Clicking 'Yes' for authorized to work in the United States.")
                        WinActivate("ahk_exe chrome.exe")
                        RandomDelay(100, 300)
                        ClickElementByPath(radioButton)
                        RandomDelay(200, 400)
                        break
                    }
                } else if InStr(radioGroupName, "remote") || InStr(radioGroupName, "driver license") {
                    if InStr(radioButtonName, "yes") {
                        ToolTip("Clicking 'Yes' for remote location or driver's license.")
                        WinActivate("ahk_exe chrome.exe")
                        RandomDelay(100, 300)
                        ClickElementByPath(radioButton)
                        RandomDelay(200, 400)
                        break
                    }
                } else if InStr(radioGroupName, "visa") || InStr(radioGroupName, "sponsor") || InStr(radioGroupName, "sponsorship") {
                    if InStr(radioButtonName, "no") {
                        ToolTip("Clicking 'No' for visa/sponsorship question.")
                        WinActivate("ahk_exe chrome.exe")
                        RandomDelay(100, 300)
                        ClickElementByPath(radioButton)
                        RandomDelay(200, 400)
                        break
                    }
                } else if InStr(radioGroupName, "license") && !(InStr(radioGroupName, "driver license") || InStr(radioGroupName, "driver's license")) {
                    if InStr(radioButtonName, "no") {
                        ToolTip("Clicking 'No' for non-driver license related question.")
                        logFile := "radio_button_log.txt"
                        FileAppend("Clicked 'No' for RadioGroup: " radioGroupName "`n", logFile)
                        WinActivate("ahk_exe chrome.exe")
                        RandomDelay(100, 300)
                        ClickElementByPath(radioButton)
                        RandomDelay(200, 400)
                        break
                    }
                } else if InStr(radioGroupName, "what percentage of the time are you willing to travel for work") {
                    if InStr(radioButtonName, "25%") {
                        ToolTip("Clicking '25%' for travel percentage question.")
                        WinActivate("ahk_exe chrome.exe")
                        RandomDelay(100, 300)
                        ClickElementByPath(radioButton)
                        RandomDelay(200, 400)
                        break
                    }
                } else if InStr(radioGroupName, "do you speak english") {
                    if InStr(radioButtonName, "yes") {
                        ToolTip("Clicking 'Yes' for English question.")
                        WinActivate("ahk_exe chrome.exe")
                        RandomDelay(100, 300)
                        ClickElementByPath(radioButton)
                        RandomDelay(200, 400)
                        break
                    }
                } else if InStr(radioGroupName, "do you speak spanish") {
                    if InStr(radioButtonName, "no") {
                        ToolTip("Clicking 'No' for Spanish question.")
                        WinActivate("ahk_exe chrome.exe")
                        RandomDelay(100, 300)
                        ClickElementByPath(radioButton)
                        RandomDelay(200, 400)
                        break
                    }
                }
            }
        }
        return true
    } catch as e {
        ; Enhanced error reporting
        errorMessage := "Error in HandleRadioButtons: " e.Message
        errorLine := "Line: " e.Line
        errorExtra := "Extra Info: " e.Extra
        errorFile := "File: " e.File
        errorWhat := "Error Context: " e.What
        
        ; Display detailed error information
        MsgBox(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat)
        
        ; Log the detailed error information
        FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n", "debug_log.txt")
        
        return false
    }
}

HandleCheckboxes(rootElement) {
    try {
        ; Define the list of text patterns to match against checkboxes
        patterns := ["Example1.1", "Example 1.2", "Example 1.3", "Example 2.1", "Example 2.2", "Example 2.3"]

        ; Find all checkbox elements
        checkboxes := rootElement.FindAll({ LocalizedType: "check box" })

        for checkbox in checkboxes {
            ; Scroll the checkbox into view
            checkbox.ScrollIntoView()
            RandomDelay(100, 300)

            ; Get the TogglePattern to check the state
            togglePattern := checkbox.GetPattern("TogglePattern")
            if !togglePattern {
                MsgBox("No TogglePattern available for checkbox: " checkbox.Name)
                continue
            }
            toggleState := togglePattern.ToggleState

            if toggleState = 1 {
                ToolTip("Checkbox for " checkbox.Name " is already selected. Skipping.")
                continue
            }

            ; Find associated text element (assuming the text is the previous sibling or close to the checkbox)
            associatedText := checkbox.Parent

            if associatedText && associatedText.LocalizedType = "group" {
                checkboxText := associatedText.Name
                ; Check if the associated text matches any pattern
                for pattern in patterns {
                    if InStr(checkboxText, pattern) {
                        ToolTip("Clicking checkbox for " checkboxText)
                        togglePattern.Toggle()
                        RandomDelay(200, 400)
                        break
                    }
                }
            } else {
                ; If no associated text found, click the checkbox by default
                ToolTip("No associated text found; clicking checkbox by default")
                togglePattern.Toggle()
                RandomDelay(300, 500)
            }
        }

        return true
    } catch as e {
        errorMessage := "Error in HandleCheckboxes: " e.Message
        errorLine := "Line: " e.Line
        errorExtra := "Extra Info: " e.Extra
        errorFile := "File: " e.File
        errorWhat := "Error Context: " e.What
        
        ; Display detailed error information
        MsgBox(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat)
        
        ; Log the detailed error information
        FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n", "debug_log.txt")
        return false
    }
}