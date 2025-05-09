#Requires AutoHotkey v2.0

#Include ..\Helper_Functions\CheckAndSetHotkey\CheckAndSetHotkey.ahk
#Include ..\UIA.ahk
#Include ..\Helper_Functions\Utility.ahk
#Include ..\ChatGPT_ahk_script\ChatGPT.ahk
#Include ..\Helper_Functions\HandleClipboard.ahk
#Include ..\Helper_Functions\GetArrayLength\GetArrayLength.ahk

#SingleInstance

global logFile := "JobApplicationQA_debug_log.txt"
if FileExist(logFile) {
    FileDelete(logFile)
}

; Define global variables for config values
global configFile := A_ScriptDir "\config.ini"
global commonResponses := Map()  ; Initialize commonResponses as a map
global editFields := []  ; Array to store dynamically created Edit controls

global jobSearchKeywords := ""
global resumeSpecifiedPrompt

; Define the list of strings to check for in HandleJobSearch elements
global jobExcludeList := ["Applied", "Expired", "Already Applied", "Application Closed", "Manager", "Insurance", "Real Estate", "Solar", "Licensed", "Commission", "Commission-based"]
global strJobExcludeList := ""
; Define the list of job types to exclude in HandleJobSearch
global excludeJobTypes := ["financial", "health", "insurance", "medical", "va", "autocad", "electronic components", "estimating", "writing", "federal", "transformer", "travel", "foodservice", "logistics", "capital equipment", "glass", "leadership", "supply"]
global strExcludeJobTypes := ""

global resume := ""
global phone := ""
global email := ""
global linkedIn := "www.linkedin.com/in/FIRSTNAME-LASTNAME-li"
global currentEmployer := "N/A"
global cityState := ""
global timezone := "Central Time (CST)"
global salaryRange := ""
global travelPreference := "25%"
global willingToRelocate := "No"
global citizenshipStatus := ""
global industryExperience := "Retail, Wholesale, Construction, Manufacturing, Marketing, Insurance, Automotive, Accounting, SaaS"
global sponsorshipStatus := "No"
global zeroYearsOfExperience := "financial, health, insurance, medical, va, autocad, electronic components, estimating, writing, federal, transformer, travel, foodservice, logistics, capital equipment, glass, leadership, supply"
global oneYearOfExperience := "Events"
global backgroundCheck := "Yes"
global needTimeOff := "No"
global highestAchieved := "~600k - 5x Quota"
global speakSpanish := "No"
global checkboxPatterns := Map("ignoreNA", "N/A", "ignoreNone", "None", "updates", "Share these answers with Indeed")
global strCheckboxPatterns := ""

global parentCheckboxExcludeList := Map("Add Preferred Name(optional)", "update", "message", "allowed")


for checkboxType, checkboxPattern in checkboxPatterns {
    strCheckBoxPatterns .= checkboxPattern ", "
}
strCheckboxPatterns := RTrim(strCheckboxPatterns, ', ')

for itemType, excludeItem in jobExcludeList {
    strJobExcludeList .= excludeItem ", "
}
strJobExcludeList := RTrim(strJobExcludeList, ', ')

for excludeType, excludeJobType in excludeJobTypes {
    strExcludeJobTypes .= excludeJobType ", "
}
strExcludeJobTypes := RTrim(strExcludeJobTypes, ', ')

; Load existing configuration or create a new one
if !FileExist(configFile) {
    ; Common questions with predefined responses
    commonResponses.Set("tell me about yourself", "I'm a dedicated professional with a passion for continuous improvement and a track record of success in delivering results through strategic thinking and collaboration.")
    commonResponses.Set("why do you want to work for our company", "I'm drawn to your company's innovative approach and commitment to excellence, which align with my values and professional aspirations.")
    commonResponses.Set("why are you the best candidate for the job", "My unique combination of skills, experience, and dedication to continuous learning ensures I can bring immediate value and grow with your organization.")
    commonResponses.Set("what are your greatest strengths", "My strengths lie in my analytical thinking, adaptability, and ability to lead teams toward shared goals with clarity and motivation.")
    commonResponses.Set("what are your greatest weaknesses", "I tend to focus heavily on details, but I've learned to balance this by prioritizing tasks and delegating when necessary.")
    commonResponses.Set("what are your most impressive achievements", "My most significant achievements include leading successful initiatives that resulted in measurable improvements and being recognized for my contributions to the team's success.")
    commonResponses.Set("what have you learned from your previous work experience", "I've learned the importance of adaptability, clear communication, and continuous improvement, which have been crucial in achieving successful outcomes.")
    commonResponses.Set("provide an example of a time when you demonstrated leadership abilities", "I led a cross-functional team through a complex project, ensuring clear communication and aligning everyone's efforts toward a successful outcome, surpassing our goals.")
    commonResponses.Set("give an example of a time you resolved a team conflict", "I facilitated a discussion where conflicting team members could express their concerns, leading to a mutual understanding and a collaborative solution.")
    commonResponses.Set("how does this position fit in with your longterm career goals", "This role aligns perfectly with my desire to contribute to innovative projects while continuing to develop my expertise and leadership abilities.")
    commonResponses.Set("what is your first goal if you get this role", "My initial goal would be to fully understand the team's dynamics and ongoing projects to identify where I can contribute most effectively from the start.")
    commonResponses.Set("describe your last position and what you accomplished", "In my last role, I focused on streamlining processes and enhancing team collaboration, resulting in significant efficiency improvements and project success.")
    commonResponses.Set("describe your education in university, trade school or college", "My education was rigorous and diverse, equipping me with both theoretical knowledge and practical skills applicable to a wide range of scenarios.")
    commonResponses.Set("what did you major in while in college", "My major focused on a field that combines analytical thinking with creativity, preparing me for the multifaceted challenges of today's work environment.")
    commonResponses.Set("do you have an undergraduate degree", "Yes, I completed an undergraduate program that deepened my understanding of key concepts and prepared me for professional challenges.")
    commonResponses.Set("what was your favorite class in college", "A class that combined theory with real-world applications, allowing me to explore complex problems and develop practical solutions.")
    commonResponses.Set("did you complete any minors or certificates while in school", "Yes, I pursued additional certifications that complemented my major, broadening my expertise and enhancing my versatility.")
    commonResponses.Set("do you have any advanced degrees", "I have pursued advanced studies that have deepened my knowledge and provided specialized skills relevant to my professional path.")
    commonResponses.Set("what are your advanced degrees focused on", "My advanced studies focused on areas that require critical thinking and strategic planning, equipping me with tools to tackle complex challenges.")
    commonResponses.Set("when did you graduate from high school or earn your ged", "I graduated in a timeframe that provided me with the necessary academic foundation to pursue further education and professional development.")
    commonResponses.Set("when did you graduate from college", "I graduated during a period that allowed me to immediately apply my education to the professional world, gaining valuable experience.")
    commonResponses.Set("have you ever been published", "Yes, I've had the opportunity to contribute to publications where I shared insights and findings relevant to my field of expertise.")
    commonResponses.Set("what was your first position", "My first position provided a strong foundation in the basics of professional conduct, offering invaluable lessons that I carry with me today.")
    commonResponses.Set("what did you learn from your first job", "My first job taught me the importance of responsibility, attention to detail, and the value of teamwork in achieving common goals.")
    commonResponses.Set("how did you earn money as a kid", "I started by taking on small entrepreneurial tasks, which taught me the value of hard work and financial independence from an early age.")
    commonResponses.Set("have you completed any volunteer work", "Yes, I've volunteered in initiatives that align with my values, contributing my skills to causes that positively impact the community.")
    commonResponses.Set("how have you stayed current with trends in your career", "I stay current by engaging with industry news, participating in professional networks, and attending relevant seminars and conferences.")
    commonResponses.Set("how did you learn about this job opportunity", "I learned about this opportunity through a combination of professional networks and my ongoing research into companies that align with my career aspirations.")
    commonResponses.Set("how do you continue your education", "I am committed to lifelong learning, regularly engaging in courses, workshops, and self-study to stay current in my field.")
    commonResponses.Set("are you willing to obtain another degree or certificate if the role requires it", "Absolutely, I am open to furthering my education to better align with the demands of the role and contribute more effectively.")
    commonResponses.Set("what industry developments are you excited about", "I'm excited about developments that integrate technology and human-centered design, offering innovative solutions to contemporary challenges.")
    commonResponses.Set("which industry developments are you wary about", "I approach certain rapid technological changes with caution, considering their long-term implications and the balance between innovation and ethics.")
    commonResponses.Set("why did you or do you want to leave your present position", "I'm seeking new challenges that align more closely with my long-term goals and offer opportunities for growth and contribution.")
    commonResponses.Set("why did you change your mind last", "I reassessed my priorities based on new information, leading me to make a decision that better aligned with my long-term goals.")
    commonResponses.Set("what are your it and programming language capabilities", "I possess a solid foundation in various programming languages and IT systems, adept at quickly learning and applying new technologies to meet project needs.")
    commonResponses.Set("describe the technology and tools you used in your previous position", "I utilized a range of tools that supported data analysis, project management, and communication, ensuring efficient and effective task completion.")
    commonResponses.Set("are there any technologies you'd like to learn how to use", "I'm always eager to learn new technologies that can enhance productivity and innovation, particularly those that are emerging in the market.")
    commonResponses.Set("do you have experience mentoring others", "I've had the opportunity to mentor colleagues, focusing on their growth by sharing insights and providing constructive feedback to help them reach their potential.")
    commonResponses.Set("describe a time you displayed good oral communication skills", "I have effectively communicated complex ideas to diverse audiences by breaking down technical jargon into understandable concepts, ensuring clarity and engagement.")
    commonResponses.Set("how have you solved conflict in your workplace", "I address conflicts by listening to all perspectives, fostering open communication, and working towards a resolution that benefits the team.")
    commonResponses.Set("what is your leadership style", "My leadership style is collaborative and supportive, ensuring that team members feel valued and motivated to contribute their best work.")
    commonResponses.Set("have you held managerial positions in the past", "Yes, I've managed teams where I focused on empowering individuals, fostering collaboration, and driving toward our collective goals.")
    commonResponses.Set("please list 23 dates and time ranges that you could do an interview", "I am available on weekdays, preferably taking meetings in the afternoons, but I can be flexible to accommodate your schedule.")
    commonResponses.Set("describe your writing skills", "I possess strong writing skills, capable of crafting clear, concise, and compelling content that communicates ideas effectively across various formats.")
    commonResponses.Set("describe your management skills", "I have a proven track record of managing teams and projects efficiently, ensuring goals are met while fostering a positive and productive work environment.")
    commonResponses.Set("describe your experience with customer service", "I have a solid background in customer service, consistently delivering solutions that exceed client expectations and foster long-term relationships.")
    commonResponses.Set("describe your experience with networking", "I've successfully built and maintained professional networks that have provided valuable opportunities for collaboration and career growth.")
    commonResponses.Set("do you consider yourself a team player", "Absolutely, I thrive in collaborative environments where diverse ideas contribute to innovative solutions and shared success.")
    commonResponses.Set("what motivates you", "I'm motivated by the opportunity to solve complex problems, make meaningful contributions, and continuously learn and grow professionally.")
    commonResponses.Set("what are three words that best describe you, and why", "Curious, resilient, and proactive—these qualities drive me to continuously learn, adapt to challenges, and take initiative.")
    commonResponses.Set("what is something interesting about you", "I have a passion for problem-solving, which often leads me to find creative solutions in both professional and personal endeavors.")
    commonResponses.Set("tell us about your hobbies", "My hobbies include activities that challenge my mind and body, such as strategic games, fitness, and exploring new technologies.")
    commonResponses.Set("how do you spend your free time", "I enjoy a mix of activities that keep me mentally stimulated and physically active, balancing relaxation with personal development.")
    commonResponses.Set("what do you do outside of work", "Outside of work, I engage in activities that broaden my perspective, such as reading, staying active, and participating in community initiatives.")
    commonResponses.Set("what is the last book you read", "The last book I read was focused on leadership and strategy, offering valuable insights that I apply in my work.")
    commonResponses.Set("what is the last article you read", "I recently read an article on emerging trends in technology, which sparked ideas for how these innovations could be applied in various industries.")
    commonResponses.Set("what would you like to achieve while working here", "I aim to contribute to significant projects that drive the company forward, while also developing my skills and growing within the organization.")
    commonResponses.Set("explain three steps you might take to improve this business", "I'd start by analyzing current processes, identifying areas for efficiency gains, and implementing technology-driven solutions to enhance productivity.")
    commonResponses.Set("is there a quote that you live by", "“The only way to do great work is to love what you do.” This motivates me to pursue excellence and find passion in every task.")
    commonResponses.Set("what is it", "“The only way to do great work is to love what you do.” This motivates me to pursue excellence and find passion in every task.")
    commonResponses.Set("why should we hire you over other qualified candidates", "My proactive approach, coupled with a deep understanding of the required skills, ensures I can make a meaningful impact from day one.")
    commonResponses.Set("when can you start", "Immediately")
    commonResponses.Set("do you speak english", "Yes")
    commonResponses.Set("do you speak spanish", "No")
    SetupConfig()  ; If config file doesn't exist, open GUI for setup
} else {
    LoadConfig()   ; Otherwise, load the existing configuration
}

; Hotkey to open the GUI for editing settings (Ctrl + E)
^e::SetupConfig()

CheckConfig(section, key, default, configFile) {
    result := IniRead(configFile, section, key, "MISSING")
    if (result = "MISSING") {
        ShowToolTipWithTimer("Missing configuration for " key ". Defaulting to setup.",,1000)
        SetupConfig(section, key, default)  ; Assume SetupConfig can handle setting a specific config
        WinWaitClose("Config.ini")
        result := default
    }
    return result
}

; Function to load config values from the .ini file
LoadConfig() {
    ; Define global variables for config values
    global strJobExcludeList, strExcludeJobTypes, phone, email, linkedIn, currentEmployer, cityState, timezone, salaryRange, travelPreference, willingToRelocate, citizenshipStatus, industryExperience, sponsorshipStatus, zeroYearsOfExperience, oneYearOfExperience, speakSpanish
    global backgroundCheck, needTimeOff, highestAchieved, strCheckboxPatterns, checkboxPatterns
    global commonResponses, configFile, jobExcludeList, ExcludeJobTypes, jobSearchKeywords, resumeSpecifiedPrompt
    global resume

    resume := CheckConfig("Settings", "Resume", resume, configFile)
    jobSearchKeywords := CheckConfig("Settings", "Job Search Keywords", jobSearchKeywords, configFile)
    resumeSpecifiedPrompt := CheckConfig("Settings", "Resume Specified Prompt", resumeSpecifiedPrompt, configFile)
    strJobExcludeList := CheckConfig("Settings", "Exclude Job Details", strJobExcludeList, configFile)
    strExcludeJobTypes := CheckConfig("Settings", "Exclude Job Types", strExcludeJobTypes, configFile)
    phone := CheckConfig("Settings", "Phone", phone, configFile)
    email := CheckConfig("Settings", "Email", email, configFile)
    linkedIn := CheckConfig("Settings", "LinkedIn", linkedIn, configFile)
    currentEmployer := CheckConfig("Settings", "Current Employer", currentEmployer, configFile)
    cityState := CheckConfig("Settings", "City, State", cityState, configFile)
    timezone := CheckConfig("Settings", "Timezone", timezone, configFile)
    travelPreference := CheckConfig("Settings", "Travel Preference", travelPreference, configFile)

    ; Load HandleKeywords strings
    salaryRange := CheckConfig("Settings", "Salary Range", salaryRange, configFile)
    travelPreference := CheckConfig("Settings", "Travel Preference", travelPreference, configFile)
    willingToRelocate := CheckConfig("Settings", "Willing to Relocate", willingToRelocate, configFile)
    citizenshipStatus := CheckConfig("Settings", "Citizenship Status", citizenshipStatus, configFile)
    industryExperience := CheckConfig("Settings", "Industry Experience", industryExperience, configFile)
    sponsorshipStatus := CheckConfig("Settings", "Sponsorship Status", sponsorshipStatus, configFile)

    ; Load HandleYearQuestions strings
    zeroYearsOfExperience := CheckConfig("Settings", "Years of Experience 0", zeroYearsOfExperience, configFile)
    oneYearOfExperience := CheckConfig("Settings", "Years of Experience 1", oneYearOfExperience, configFile)

    ; Load keyword responses
    backgroundCheck := CheckConfig("Settings", "Background Check", backgroundCheck, configFile)
    needTimeOff := CheckConfig("Settings", "Need Time Off", needTimeOff, configFile)
    highestAchieved := CheckConfig("Settings", "Highest Achieved Quota", highestAchieved, configFile)
    speakSpanish := CheckConfig("Settings", "Speak Spanish", speakSpanish, configFile)
    strCheckboxPatterns := CheckConfig("Settings", "Checkbox Patterns", strCheckboxPatterns, configFile)

    checkboxPatterns := StrSplit(strCheckboxPatterns, ", ")
    jobExcludeList := StrSplit(strJobExcludeList, ", ")
    excludeJobTypes := StrSplit(strExcludeJobTypes, ", ")
    ; Load common responses
    LoadCommonResponses()
    LoadPatterns()
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

LoadPatterns() {
    global configFile, strCheckboxPatterns, checkboxPatterns
    section := "[Checkbox Patterns]"
    isInSection := false

    ; Load the patterns from the INI file
    Loop Read, configFile
    {
        line := Trim(A_LoopReadLine)  ; Trim leading/trailing spaces
        ; Check if we're in the desired section
        if (line = section) {
            isInSection := true
            continue
        }
        ; If another section is found, exit the Patterns section
        if (isInSection && line ~= "^\[.*\]$") {
            break
        }
        ; Process key-value pairs within the Patterns section
        if (isInSection && InStr(line, "=")) {
            keyValue := StrSplit(line, "=")
            questionKey := Trim(keyValue[1])
            response := Trim(keyValue[2])
            checkboxPatterns[questionKey] := response  ; Add key-value pair to map
        }
    }
}

; GUI for setting or editing configuration
SetupConfig(section := "", key := "", value := "") {
    global jobExcludeList, excludeJobTypes, phone, email, linkedIn, currentEmployer, cityState, timezone, salaryRange, travelPreference, willingToRelocate, citizenshipStatus, industryExperience, sponsorshipStatus, zeroYearsOfExperience, oneYearOfExperience
    global backgroundCheck, needTimeOff, highestAchieved, speakSpanish, strCheckboxPatterns
    global configFile, commonResponses, editFields, ScrollGui
    global jobExcludeListEdit := jobExcludeList, excludeJobTypesEdit := excludeJobTypes, phoneEdit := phone, emailEdit := email, linkedInEdit := linkedIn, currentEmployerEdit := currentEmployer, cityStateEdit := cityState, timezoneEdit := timezone, salaryRangeEdit := salaryRange, travelPreferenceEdit := travelPreference, willingToRelocateEdit := willingToRelocate, citizenshipStatusEdit := citizenshipStatus, industryExperienceEdit := industryExperience, sponsorshipStatusEdit := sponsorshipStatus, zeroYearsOfExperienceEdit := zeroYearsOfExperience, oneYearOfExperienceEdit := oneYearOfExperience
    global backgroundCheckEdit := backgroundCheck, needTimeOffEdit := needTimeOff, highestAchievedEdit := highestAchieved, speakSpanishEdit := speakSpanish, checkboxPatternsEdit := strCheckboxPatterns
    global jobSearchKeywordsEdit := jobSearchKeywords, resumeSpecifiedPromptEdit := resumeSpecifiedPrompt
    global resumeEdit := resume

    ; Dynamically create input fields for each question and response
    editFields := []  ; Array to store dynamically created Edit controls
    yPos := 10

    if section != "" {
        scrollGui := Gui("+Resize +0x300000", "Config.ini")
        ScrollGui.OnEvent("Size", ScrollGui_Size)
        ScrollGui.OnEvent("Close", ScrollGui_Close)
        ScrollGui.Add("Text", "x20 y15", key)
        responseEdit := ScrollGui.Add("Edit", "y10 w300 cRed", value)
        editFields.Push(key, responseEdit)
        ScrollGui.Add("Text", "x10 y" yPos " h0")
        ScrollGui.Add("Button", "x80 w100", "Submit").OnEvent("Click", (*) => SaveSingleConfig(responseEdit.Value, configFile, section, key))
        ScrollGui.Add("Button", "x+15 w100", "Cancel").OnEvent("Click", (*) => ExitApp())
        scrollGui.Show()
        Return 
    }

    ;Scrollable Gui - Proof of Concept - Scripts and Functions - AutoHotkey Community
    ;https://autohotkey.com/board/topic/26033-scrollable-gui-proof-of-concept/#entry168174
    ; MK_SHIFT = 0x0004, WM_MOUSEWHEEL = 0x020A, WM_MOUSEHWHEEL = 0x020E, WM_NCHITTEST = 0x0084

    ScrollGui := Gui("+Resize +0x300000", "Config.ini") ; WS_VSCROLL | WS_HSCROLL
    ScrollGui.OnEvent("Size", ScrollGui_Size)
    ScrollGui.OnEvent("Close", ScrollGui_Close)

    OnMessage(0x0115, OnScroll) ; WM_VSCROLL
    OnMessage(0x0114, OnScroll) ; WM_HSCROLL
    OnMessage(0x020A, OnWheel)  ; WM_MOUSEWHEEL

    ; Process input fields similarly as the original code, with adjusted y positions
    AddInputField(ScrollGui, "Resume (+ Name, city, state, and zip)", &resumeEdit, &yPos, resume)
    AddInputField(ScrollGui, "Job Search Keywords (Not Comma Separated)", &jobSearchKeywordsEdit, &yPos, jobSearchKeywords)
    AddInputField(ScrollGui, "Resume Specified Prompt (prompt for ChatGPT)", &resumeSpecifiedPromptEdit, &yPos, resumeSpecifiedPrompt)
    AddInputField(ScrollGui, "Excluded Job Details/Jobs/Companies", &excludeListEdit, &yPos, strJobExcludeList)
    AddInputField(ScrollGui, "Excluded Job Types (Comma Separated)", &excludeJobTypesEdit, &yPos, strExcludeJobTypes)
    AddInputField(ScrollGui, "Phone Number (xxx) xxx-xxxx", &phoneEdit, &yPos, phone)
    AddInputField(ScrollGui, "Email: (address@domain.com)", &emailEdit, &yPos, email)
    AddInputField(ScrollGui, "LinkedIn URL (linkedin.com/in/FIRST-LAST-li)", &linkedInEdit, &yPos, linkedIn)
    
    AddInputField(ScrollGui, "Checkboxes to ignore(checked by default)", &checkboxPatternsEdit, &yPos, strCheckboxPatterns)
    AddInputField(ScrollGui, "Industry Experience (Comma Separated)", &industryExperienceEdit, &yPos, industryExperience)
    AddInputField(ScrollGui, "Industries with 0 to 0.5 yrs of exp", &zeroYearsOfExperienceEdit, &yPos, zeroYearsOfExperience)
    AddInputField(ScrollGui, "Industries with 0.5 to 1.5 yrs of exp", &oneYearOfExperienceEdit, &yPos , oneYearOfExperience)
    AddInputField(ScrollGui, "Current Employer (N/A if none)", &currentEmployerEdit, &yPos, currentEmployer)
    AddInputField(ScrollGui, "Citizenship Status (2 for yes, 1 for no)", &citizenshipStatusEdit, &yPos, citizenshipStatus)
    AddInputField(ScrollGui, "Visa Sponsorship Needed (Yes/No)", &sponsorshipStatusEdit, &yPos, sponsorshipStatus)
    AddInputField(ScrollGui, "Ok with background check? (Yes/No)", &backgroundCheckEdit, &yPos, backgroundCheck)
    AddInputField(ScrollGui, "Need Time Off in the next 90 days?", &needTimeOffEdit, &yPos, needTimeOff)
    AddInputField(ScrollGui, "Max travel time? (0-100%)", &travelPreferenceEdit, &yPos, travelPreference)
    AddInputField(ScrollGui, "Willing to Relocate (Yes/No)", &willingToRelocateEdit, &yPos, willingToRelocate)
    AddInputField(ScrollGui, "City, State (i.e.Seattle, WA)", &cityStateEdit, &yPos, cityState)
    AddInputField(ScrollGui, "Timezone (i.e. Central Time (CST))", &timezoneEdit, &yPos, timezone)
    AddInputField(ScrollGui, "Do you speak Spanish? (Yes/No)", &speakSpanishEdit, &yPos, speakSpanish)
    AddInputField(ScrollGui, "Salary Range (i.e.$50k - $70k)", &salaryRangeEdit, &yPos, salaryRange)
    AddInputField(ScrollGui, "Highest Achieved Quota? (sales)", &highestAchievedEdit, &yPos, highestAchieved)

    for keyCR, valueCR in commonResponses {
        ;ScrollGui.Add("Text", "w50 h15", key)
        AddInputField(ScrollGui, keyCR, &responseEdit, &yPos, valueCR, keyCR)
        editFields.Push([keyCR, responseEdit])  ; Store the Edit controls
    }

    ScrollGui.Add("Text", "x10 y" yPos " h0")
    ScrollGui.Add("Button", "x80 w100", "Submit").OnEvent("Click", (*) => SaveConfig())
    ScrollGui.Add("Button", "x+15 w100", "Cancel").OnEvent("Click", (*) => ExitApp())
    ScrollGui.Show("w400 h300")
    Return
    ; ======================================================================================================================
    ScrollGui_Size(GuiObj, MinMax, Width, Height) {
        If (MinMax != 1) {
            UpdateScrollBars(GuiObj)
        }
    }
    ; ======================================================================================================================
    ScrollGui_Close(*) {
        ExitApp
    }
    ; ======================================================================================================================
    UpdateScrollBars(GuiObj) {
        ; SIF_RANGE = 0x1, SIF_PAGE = 0x2, SIF_DISABLENOSCROLL = 0x8, SB_HORZ = 0, SB_VERT = 1
        ; Calculate scrolling area.
        WinGetClientPos( , , &GuiW, &GuiH, GuiObj.Hwnd)
        L := T := 2147483647   ; Left, Top
        R := B := -2147483648  ; Right, Bottom
        For CtrlHwnd In WinGetControlsHwnd(GuiObj.Hwnd) {
            ControlGetPos(&CX, &CY, &CW, &CH, CtrlHwnd)
            L := Min(CX, L)
            T := Min(CY, T)
            R := Max(CX + CW, R)
            B := Max(CY + CH, B)
        }
        L -= 8, T -= 8
        R += 8, B += 8
        ScrW := R - L ; scroll width
        ScrH := B - T ; scroll height
        ; Initialize SCROLLINFO.
        SI := Buffer(28, 0)
        NumPut("UInt", 28, "UInt", 3, SI, 0) ; cbSize , fMask: SIF_RANGE | SIF_PAGE
        ; Update horizontal scroll bar.
        NumPut("Int", ScrW, "Int", GuiW, SI, 12) ; nMax , nPage
        DllCall("SetScrollInfo", "Ptr", GuiObj.Hwnd, "Int", 0, "Ptr", SI, "Int", 1) ; SB_HORZ
        ; Update vertical scroll bar.
        ; NumPut("UInt", SIF_RANGE | SIF_PAGE | SIF_DISABLENOSCROLL, SI, 4) ; fMask
        NumPut("Int", ScrH, "UInt", GuiH,  SI, 12) ; nMax , nPage
        DllCall("SetScrollInfo", "Ptr", GuiObj.Hwnd, "Int", 1, "Ptr", SI, "Int", 1) ; SB_VERT
        ; Scroll if necessary
        X := (L < 0) && (R < GuiW) ? Min(Abs(L), GuiW - R) : 0
        Y := (T < 0) && (B < GuiH) ? Min(Abs(T), GuiH - B) : 0
        If (X || Y) {
            DllCall("ScrollWindow", "Ptr", GuiObj.Hwnd, "Int", X, "Int", Y, "Ptr", 0, "Ptr", 0)
        }
    }
    ; ======================================================================================================================
    OnWheel(W, L, M, H) {
        If !(HWND := WinExist()) || GuiCtrlFromHwnd(H) {
            Return
        }
        HT := DllCall("SendMessage", "Ptr", HWND, "UInt", 0x0084, "Ptr", 0, "Ptr", l) ; WM_NCHITTEST = 0x0084
        If (HT = 6) || (HT = 7) { ; HTHSCROLL = 6, HTVSCROLL = 7
            SB := (W & 0x80000000) ? 1 : 0 ; SB_LINEDOWN = 1, SB_LINEUP = 0
            SM := (HT = 6) ? 0x0114 : 0x0115 ;  WM_HSCROLL = 0x0114, WM_VSCROLL = 0x0115
            OnScroll(SB, 0, SM, HWND)
            Return 0
        }
    }
    ; ======================================================================================================================
    OnScroll(WP, LP, M, H) {
        Static SCROLL_STEP := 10
        If !(LP = 0) { ; not sent by a standard scrollbar
            Return
        }
        Bar := (M = 0x0115) ; SB_HORZ=0, SB_VERT=1
        SI := Buffer(28, 0)
        NumPut("UInt", 28, "UInt", 0x17, SI) ; cbSize, fMask: SIF_ALL
        If !DllCall("GetScrollInfo", "Ptr", H, "Int", Bar, "Ptr", SI) {
            Return
        }
        RC := Buffer(16, 0)
        DllCall("GetClientRect", "Ptr", H, "Ptr", RC)
        NewPos := NumGet(SI, 20, "Int") ; nPos
        MinPos := NumGet(SI,  8, "Int") ; nMin
        MaxPos := NumGet(SI, 12, "Int") ; nMax
        Switch (WP & 0xFFFF) {
            Case 0: NewPos -= SCROLL_STEP ; SB_LINEUP
            Case 1: NewPos += SCROLL_STEP ; SB_LINEDOWN
            Case 2: NewPos -= NumGet(RC, 12, "Int") - SCROLL_STEP ; SB_PAGEUP
            Case 3: NewPos += NumGet(RC, 12, "Int") - SCROLL_STEP ; SB_PAGEDOWN
            Case 4, 5: NewPos := WP >> 16 ; SB_THUMBTRACK, SB_THUMBPOSITION
            Case 6: NewPos := MinPos ; SB_TOP
            Case 7: NewPos := MaxPos ; SB_BOTTOM
            Default: Return
        }
        MaxPos -= NumGet(SI, 16, "Int") ; nPage
        NewPos := Min(NewPos, MaxPos)
        NewPos := Max(MinPos, NewPos)
        OldPos := NumGet(SI, 20, "Int") ; nPos
        X := (Bar = 0) ? OldPos - NewPos : 0
        Y := (Bar = 1) ? OldPos - NewPos : 0
        If (X || Y) {
            ; Scroll contents of window and invalidate uncovered area.
            DllCall("ScrollWindow", "Ptr", H, "Int", X, "Int", Y, "Ptr", 0, "Ptr", 0)
            ; Update scroll bar.
            NumPut("Int", NewPos, SI, 20) ; nPos
            DllCall("SetScrollInfo", "ptr", H, "Int", Bar, "Ptr", SI, "Int", 1)
        }
    }
}

; Helper function to add input fields in a standardized way
AddInputField(gui, label, &editControl, &yPos, value, labelEdit := "") {
    if labelEdit != "" {
        editControl := ScrollGui.Add("Edit", "x10 y" yPos " w150 h40 cRed", labelEdit)
        ;yPos += 30
        editControl := ScrollGui.Add("Edit", "x170 y" yPos " w300 h40 cRed", value)
        yPos += 45  ; Adjust yPos for the next input
    } else {
        ScrollGui.Add("Text", "x10 y" yPos + 10 " w150 h40", label)
        ;yPos += 30
        editControl := gui.Add("Edit", "x170 y" yPos " w300 h40 cRed", value)
        yPos += 45  ; Adjust yPos for the next input
    }
}

; Function to save the configuration
SaveConfig() {
    global configFile, commonResponses, jobExcludeList, excludeJobTypes
    global jobExcludeListEdit, excludeJobTypesEdit, phoneEdit, emailEdit, linkedInEdit, currentEmployerEdit, cityStateEdit, timezoneEdit, salaryRangeEdit, travelPreferenceEdit, willingToRelocateEdit, citizenshipStatusEdit, industryExperienceEdit, sponsorshipStatusEdit, zeroYearsOfExperienceEdit, oneYearOfExperienceEdit
    global backgroundCheckEdit, needTimeOffEdit, highestAchievedEdit, speakSpanishEdit, checkboxPatternsEdit
    jobExcludeList := jobExcludeListEdit.Value, excludeJobTypes := excludeJobTypesEdit.Value, phone := phoneEdit.Value, email := emailEdit.Value, linkedIn := linkedInEdit.Value, currentEmployer := currentEmployerEdit.Value, cityState := cityStateEdit.Value, timezone := timezoneEdit.Value, salaryRange := salaryRangeEdit.Value
    travelPreference := travelPreferenceEdit.Value, willingToRelocate := willingToRelocateEdit.Value, citizenshipStatus := citizenshipStatusEdit.Value, industryExperience := industryExperienceEdit.Value, sponsorshipStatus := sponsorshipStatusEdit.Value, zeroYearsOfExperience := zeroYearsOfExperienceEdit.Value, oneYearOfExperience := oneYearOfExperienceEdit.Value
    backgroundCheck := backgroundCheckEdit.Value, needTimeOff := needTimeOffEdit.Value, highestAchieved := highestAchievedEdit.Value, speakSpanish := speakSpanishEdit.Value, strCheckboxPatterns := checkboxPatternsEdit.Value
    global jobSearchKeywords := jobSearchKeywordsEdit.Value, resumeSpecifiedPrompt := resumeSpecifiedPromptEdit.Value
    ; First, clear the existing CommonResponses section in the .ini file
    IniDelete(configFile, "CommonResponses")

    ; Iterate through the dynamic fields and save the new question and response pairs
    for fieldPair in EditFields {
        question := Trim(fieldPair[1])  ; Get the edited question
        response := Trim(fieldPair[2].Text)  ; Get the edited response

        ; Ensure both the question and response are present before saving
        if (question != "" && response != "") {
            ; Write each key-value pair to the [CommonResponses] section in config.ini
            IniWrite(response, configFile, "CommonResponses", question)
        }
    }

    ; Write all values to config.ini
    IniWrite(jobSearchKeywords, configFile, "Settings", "Job Search Keywords")
    IniWrite(resumeSpecifiedPrompt, configFile, "Settings", "Resume Specified Prompt")
    IniWrite(jobExcludeList, configFile, "Settings", "Exclude Job Details")
    IniWrite(excludeJobTypes, configFile, "Settings", "Exclude Job Types")
    IniWrite(phone, configFile, "Settings", "Phone")
    IniWrite(email, configFile, "Settings", "Email")
    IniWrite(linkedIn, configFile, "Settings", "LinkedIn")
    IniWrite(currentEmployer, configFile, "Settings", "Current Employer")
    IniWrite(cityState, configFile, "Settings", "City, State")
    IniWrite(timezone, configFile, "Settings", "Timezone")
    IniWrite(salaryRange, configFile, "Settings", "Salary Range")
    IniWrite(travelPreference, configFile, "Settings", "Travel Preference")
    IniWrite(willingToRelocate, configFile, "Settings", "Willing to Relocate")
    IniWrite(citizenshipStatus, configFile, "Settings", "Citizenship Status")
    IniWrite(industryExperience, configFile, "Settings", "Industry Experience")
    IniWrite(sponsorshipStatus, configFile, "Settings", "Sponsorship Status")
    IniWrite(zeroYearsOfExperience, configFile, "Settings", "Years of Experience 0")
    IniWrite(oneYearOfExperience, configFile, "Settings", "Years of Experience 1")
    IniWrite(backgroundCheck, configFile, "Settings", "Background Check")
    IniWrite(needTimeOff, configFile, "Settings", "Need Time Off")
    IniWrite(highestAchieved, configFile, "Settings", "Highest Achieved Quota")
    IniWrite(speakSpanish, configFile, "Settings", "Speak Spanish")
    IniWrite(strCheckboxPatterns, configFile, "Settings", "Checkbox Patterns")
    ShowToolTipWithTimer("Configuration saved!",,1000)

    ScrollGui.Destroy()
}

SaveSingleConfig(responseEditValue, configFile, section, key) {
    global commonResponses

    IniWrite(ResponseEditValue, configFile, section, key)
    ScrollGui.Destroy()
    ShowToolTipWithTimer("Configuration saved!",,1000)
}

; Function to log missing questions and get answer dynamically
HandleMissingQuestion(missingQuestion, relatedStrVar := "", relatedArrVar := [], relatedAssArrVar := {}, specifiedPrompt := "") {
    global resume, configFile, inputName, associatedLabel
    global relatedStrArrVar := "", relatedStrAssArrVar := ""

    try {
        if GetArrayLength(relatedArrVar) > 0 {
            for i in relatedArrVar {
                relatedStrArrVar .= i " "
            }
        }
    } catch {
        relatedStrArrVar := ""
    }

    try {
        if relatedAssArrVar.Length > 0 {
            for key, value in relatedAssArrVar {
                relatedStrAssArrVar .= key ": " value " "
            }
        }
    } catch {
        relatedStrAssArrVar := ""
    }

    ; Check if the question is already in commonResponses
    response := IniRead(configFile, "CommonResponses", associatedLabel, "")
    if (response != "") {
        return response  ; If it's already in the config, return the existing response
    }

    if relatedStrVar != "" || relatedStrArrVar != "" || relatedStrAssArrVar != "" {
        ; If not found, generate a new response using ChatGPT
        ChatGPTResponse := ChatGPT(inputName "`nPreferred answer context: " relatedStrVar relatedStrArrVar relatedStrAssArrVar, specifiedPrompt, resume, , , , getGPTFeedback := "True")
    } else {
        ChatGPTResponse := ChatGPT(inputName, specifiedPrompt, resume,,,, getGPTFeedback := "True")
    }
    
    global missingAnswer := ChatGPTResponse
    return missingAnswer
}

; Function to handle specific keywords
HandleKeywords(associatedLabel) {
    global email, phone, linkedIn, currentEmployer, salaryRange, travelPreference, willingToRelocate, citizenshipStatus, industryExperience, sponsorshipStatus, highestAchieved

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
        HandleMissingQuestion(associatedLabel, travelPreference)
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
    } else if InStr(associatedLabel, "require sponsorship") || InStr(associatedLabel, "visa") {
        FileAppend("Matched keyword: require sponsorship || visa`n", "JobApplicationQA_debug_log.txt")
        return sponsorshipStatus
    } else if InStr(associatedLabel, "highest") && InStr(associatedLabel, "achieved") {
        FileAppend("Matched keyword: Highest achieved`n", "JobApplicationQA_debug_log.txt")
        return highestAchieved
    } else if InStr(associatedLabel, "linkedin") || InStr(associatedLabel, " linkedin url") {
        FileAppend("Matched keyword: LinkedIn`n", "JobApplicationQA_debug_log.txt")
        return linkedIn
    } else if InStr(associatedLabel, "current employer") {
        FileAppend("Matched keyword: Current employer`n", "JobApplicationQA_debug_log.txt")
        return currentEmployer
    } else if InStr(associatedLabel, "have you ever been employed by") {
        return "No"
    }

    ; Add more patterns and responses as needed
    FileAppend("No HandleKeywords() match found for associatedLabel: " associatedLabel "`n", "JobApplicationQA_debug_log.txt")
    return ""
}


; Handle year-related questions
HandleYearQuestions(associatedLabel, input) {
    global zeroYearsOfExperience, oneYearOfExperience

    ; Determine the threshold based on the associated label and respond with "Yes" or "No"
    if RegExMatch(associatedLabel, "have more than") || RegExMatch(associatedLabel, "have over") || RegExMatch(associatedLabel, "how many years") {
        ; Capture the number in the label
        if RegExMatch(associatedLabel, "\b\d+\b", &numberMatch) {
            number := numberMatch[0]  ; Extract the matched number as a string
            number := number + 0      ; Convert it to a number for comparison

            ; Determine the threshold based on specific keywords
            threshold := 5  ; Default threshold

            if IsObject(zeroYearsOfExperience) {
                for keyword in zeroYearsOfExperience {
                    if InStr(associatedLabel, keyword) {
                        threshold := 0
                        break
                    }
                }
            }
            
            if IsObject(oneYearOfExperience) {
                for keyword in oneYearOfExperience {
                    if InStr(associatedLabel, keyword) {
                        threshold := 1
                        break
                    }
                }
            }

            if threshold == 5 {

            }

            ; Perform the comparison
            return number <= threshold ? "Yes" : "No"
        }
    }
    
    ; Assign fallback value for numerical answers
    fallbackValue := "5"  ; Default value

    if IsObject(zeroYearsOfExperience) {
        ; Check if fallback value can be reassigned to a known keyword value
        for keyword in zeroYearsOfExperience {
            if InStr(associatedLabel, keyword) {
                expValue := "0"
                return expValue
            }
        }
    }

    if IsObject(oneYearOfExperience) {
        ; Check if fallback value can be reassigned to a known keyword value
        for keyword in oneYearOfExperience {
            if InStr(associatedLabel, keyword) {
                expValue := "1"
                return expValue
            }
        }
    }
    
    ; If we've reached this point, no match was found. Log the error and return the fallback value
    FileAppend("No HandleYearQuestions() match found for associatedLabel: " associatedLabel "`n", "JobApplicationQA_debug_log.txt")
    return ""
}

; Handle general "do you" questions
HandleDoYouQuestions(associatedLabel, input) {
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

    timezoneKeywordB := Trim(timezoneKeywords[2])
    timezoneKeywordB := StrSplit(timezoneKeywordB, " ")

    ; Determine the threshold based on the associated label and respond with "Yes" or "No"
    if InStr(associatedLabel, "Do something here in HandleDoYouQuestions()") {
        MsgBox("Do something here in HandleDoYouQuestions()")
    } else {
        FileAppend("No HandleDoYouQuestions() match found for associatedLabel: " associatedLabel "`n", "JobApplicationQA_debug_log.txt")
        return ""
    }
}

; Main function to handle custom job application questions
JobApplicationQA(input, specifiedPrompt) {
    global commonResponses, relatedStrVar := "", relatedArrVar := [], relatedAssArrVar := {}
    global associatedLabel := Trim(input.Name)
    global inputName := Trim(input.Name)
    ; Remove the standard leading sentence
    associatedLabel := RegExReplace(associatedLabel, "^This is an employer\-written question\. You can report inappropriate questions to Indeed through the `"Report Job`" link at the bottom of the job description\. ?", "")
    inputName := RegExReplace(inputName, "This is an employer\-written question\. You can report inappropriate questions to Indeed through the `"Report Job`" link at the bottom of the job description\.", "")
    ; Remove the trailing (optional)
    associatedLabel := RegExReplace(associatedLabel, "\(optional\)", "")
    inputName := RegExReplace(inputName, "\(optional\)", "")
    
    ; Convert to lowercase after removing punctuation
    associatedLabel := Utility.StrLower(Utility.RemovePunctuation(associatedLabel))

    ; Trim any extra spaces or quotes that may be left
    associatedLabel := Trim(associatedLabel)

    response := ""
    global answerReview
    global userAnswerSQ

    ; Handle specific keywords first
    response := HandleKeywords(associatedLabel)
    if response {
        if answerReview {
            holdResponse := response
            lastWindow := WinActive()
            answerReviewGui := Gui("+Resize -E0x200", "Answer Review")  ; Create a new GUI with the -E0x200 style to remove default styling
            answerReviewGui.BackColor := "Black"     ; Set the GUI background to black
            questionText := answerReviewGui.Add("Text", "w300 h80 x0 Center -E0x200 BackgroundBlack", inputName) ; Add a text control to the GUI
            questionText.SetFont("s10 cWhite") ; Set font size and color to white for visibility
            EditBox := answerReviewGui.Add("Edit", "w300 h35 x0 y+20 Center -VScroll -E0x200 BackgroundBlack", response)
            EditBox.BackColor := "Black" ; Set the background color of the edit box to black
            EditBox.SetFont("s10 cWhite") ; Set font size and color to white for visibility
            submitBtn := answerReviewGui.Add("Button", "x100 w100 +Default -E0x200 BackgroundBlack", "Submit").OnEvent("Click", (*) => InputElement(input))

            ; Handle pressing Enter while in the EditBox
            ;EditBox.Focus() ; Set focus on the Edit control

            ; Wait for the user to press Enter or close the GUI
            answerReviewGui.OnEvent("Close", (*) => ExitApp())
            answerReviewGui.Show()
            WinWaitClose("Answer Review")
            if holdResponse != response {
                IniWrite(response, configFile, "CommonResponses", associatedLabel)
            }
            return userAnswerSQ
        }
        IniWrite(response, configFile, "CommonResponses", associatedLabel)
        ; If the Gui fails, you can grab input from the InputBox
        ;inputBoxValue := InputBox("Question:`n`n" element.Name,,, inputValue)
        ;inputValue := inputBoxValue.Value
        if response != "skip" {
            input.Value := response
        }
        return response
    }

    ; Handle year-related questions
    if InStr(associatedLabel, "year") || InStr(associatedLabel, "years") {
        response := HandleYearQuestions(associatedLabel, input)
        if response {
            if answerReview {
                holdResponse := response
                lastWindow := WinActive()
                answerReviewGui := Gui("+Resize -E0x200", "Answer Review")  ; Create a new GUI with the -E0x200 style to remove default styling
                answerReviewGui.BackColor := "Black"     ; Set the GUI background to black
                questionText := answerReviewGui.Add("Text", "w300 h80 x0 Center -E0x200 BackgroundBlack", inputName) ; Add a text control to the GUI
                questionText.SetFont("s10 cWhite") ; Set font size and color to white for visibility
                EditBox := answerReviewGui.Add("Edit", "w300 h35 x0 y+20 Center -VScroll -E0x200 BackgroundBlack", response)
                EditBox.BackColor := "Black" ; Set the background color of the edit box to black
                EditBox.SetFont("s10 cWhite") ; Set font size and color to white for visibility
                submitBtn := answerReviewGui.Add("Button", "x100 w100 +Default -E0x200 BackgroundBlack", "Submit").OnEvent("Click", (*) => InputElement(input))

                ; Handle pressing Enter while in the EditBox
                ;EditBox.Focus() ; Set focus on the Edit control

                ; Wait for the user to press Enter or close the GUI
                answerReviewGui.OnEvent("Close", (*) => ExitApp())
                answerReviewGui.Show()
                WinWaitClose("Answer Review")
                if holdResponse != response {
                    IniWrite(response, configFile, "CommonResponses", associatedLabel)
                }
                return userAnswerSQ
            }
            ; If the Gui fails, you can grab input from the InputBox
            ;inputBoxValue := InputBox("Question:`n`n" element.Name,,, inputValue)
            ;inputValue := inputBoxValue.Value
            if response != "skip" {
                input.Value := response
            }
            return response
        }
    }

    ; Handle general "do you" questions
    if InStr(associatedLabel, "do you") {
        response := HandleDoYouQuestions(associatedLabel, input)
        if response && response != "" {
            if answerReview {
                holdResponse := response
                lastWindow := WinActive()
                answerReviewGui := Gui("+Resize -E0x200", "Answer Review")  ; Create a new GUI with the -E0x200 style to remove default styling
                answerReviewGui.BackColor := "Black"     ; Set the GUI background to black
                questionText := answerReviewGui.Add("Text", "w300 h80 x0 Center -E0x200 BackgroundBlack", inputName) ; Add a text control to the GUI
                questionText.SetFont("s10 cWhite") ; Set font size and color to white for visibility
                EditBox := answerReviewGui.Add("Edit", "w300 h35 x0 y+20 Center -VScroll -E0x200 BackgroundBlack", response)
                EditBox.BackColor := "Black" ; Set the background color of the edit box to black
                EditBox.SetFont("s10 cWhite") ; Set font size and color to white for visibility
                submitBtn := answerReviewGui.Add("Button", "x100 w100 +Default -E0x200 BackgroundBlack", "Submit").OnEvent("Click", (*) => InputElement(input))

                ; Handle pressing Enter while in the EditBox
                ;EditBox.Focus() ; Set focus on the Edit control

                ; Wait for the user to press Enter or close the GUI
                answerReviewGui.OnEvent("Close", (*) => ExitApp())
                answerReviewGui.Show()
                WinWaitClose("Answer Review")
                if holdResponse != response {
                    IniWrite(response, configFile, "CommonResponses", associatedLabel)
                }
                return userAnswerSQ
            }
            ; If the Gui fails, you can grab input from the InputBox
            ;inputBoxValue := InputBox("Question:`n`n" element.Name,,, inputValue)
            ;inputValue := inputBoxValue.Value
            if response != "skip" {
                input.Value := response
            }
            return response
        }
        
    }

    ; Check if the question exists in commonResponses
    comResp := IniRead(configFile, "CommonResponses", associatedLabel, "")
    if comResp && comResp != "" {
        if answerReview {
            holdComResp := comResp
            lastWindow := WinActive()
            answerReviewGui := Gui("+Resize -E0x200", "Answer Review")  ; Create a new GUI with the -E0x200 style to remove default styling
            answerReviewGui.BackColor := "Black"     ; Set the GUI background to black
            questionText := answerReviewGui.Add("Text", "w300 h80 x0 Center -E0x200 BackgroundBlack", inputName) ; Add a text control to the GUI
            questionText.SetFont("s10 cWhite") ; Set font size and color to white for visibility
            EditBox := answerReviewGui.Add("Edit", "w300 h35 x0 y+20 Center -VScroll -E0x200 BackgroundBlack", comResp)
            EditBox.BackColor := "Black" ; Set the background color of the edit box to black
            EditBox.SetFont("s10 cWhite") ; Set font size and color to white for visibility
            submitBtn := answerReviewGui.Add("Button", "x100 w100 +Default -E0x200 BackgroundBlack", "Submit").OnEvent("Click", (*) => InputElement(input))

            ; Handle pressing Enter while in the EditBox
            ;EditBox.Focus() ; Set focus on the Edit control

            InputElement(element) {
                global userAnswerSQ
                answerReviewGui.Hide()
                userAnswerSQ := EditBox.Value
                if EditBox.Value != "skip" {
                    input.Value := EditBox.Value
                }
                answerReviewGui.Destroy()
            }

            ; Wait for the user to press Enter or close the GUI
            answerReviewGui.OnEvent("Close", (*) => ExitApp())
            answerReviewGui.Show()
            WinWaitClose("Answer Review")
            if userAnswerSQ != holdComResp {
                IniWrite(userAnswerSQ, configFile, "CommonResponses", associatedLabel)
            }
            return userAnswerSQ
        }
        ; If the Gui fails, you can grab input from the InputBox
        ;inputBoxValue := InputBox("Question:`n`n" element.Name,,, inputValue)
        ;inputValue := inputBoxValue.Value
        if comResp != "skip" {
            input.Value := comResp
        }
        return comResp
    }

    missingAnswer := HandleMissingQuestion(inputName, relatedStrVar, relatedArrVar, relatedAssArrVar, specifiedPrompt)
    if missingAnswer != "" {
        return missingAnswer
    } else {
        failureMessage := "No matches found and unable to get answer dynamically, inputting defaultResponse for associatedLabel: "
        FileAppend(failureMessage "`n" associatedLabel "`n", "JobApplicationQA_debug_log.txt")
        ShowToolTipWithTimer(failureMessage "`n" associatedLabel,, 1000)
        return ""
    }
}

; Function to handle radioButtons
HandleRadioButtons(rootElement, answerReview := false) {
    try {
        global allQuestions, currentOptions, radioButtonAnswer, radioButtonAlreadySelected, resume
        logFile := "ChatGPT_Debug_Log.txt"
        ; Find all radio groups
        radioGroups := rootElement.FindAll({ LocalizedType: "radio group" })
        if radioGroups.Length == 0 {
            return true
        }
        for radioGroup in radioGroups {
            ; Retrieve and display specific properties of the radio group element
            allQuestions .= radioGroup.Name "`n"
            radioGroupName := Utility.StrLower(Utility.RemovePunctuation(radioGroup.Name))
            ; Find radio buttons within this radio group
            radioButtons := radioGroup.FindAll({ LocalizedType: "radio button" })
            FileAppend("Radio Question: " radioGroupName "`n", "all_questions.txt")

            currentOptions := ""
            ; Check if any radio button in this group is already selected
            radioButtonAlreadySelected := false
            for radioButton in radioButtons {
                currentOptions .= radioButton.Name "`n"
                FileAppend("Radio button option: " radioButton.Name "`n", "all_questions.txt")
                if radioButton.IsSelected && !InStr(radioGroupName, "remote") {
                    ;MsgBox("A radio button is already selected in this group.")  ; Debugging output
                    radioButtonAlreadySelected := true
                }
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
                        if radioButton.IsSelected {
                            break
                        }
                        ClickElementByPath(radioButton)
                        radioButtonAlreadySelected := true
                        RandomDelay(200, 400)
                        FileAppend("Chosen option: " radioButtonName "`n", "all_questions.txt")
                        break  ; Stop after clicking the correct button
                    }
                }

                ; Special conditions for selecting "Yes" or "No" irrespective of current selection
                if InStr(radioGroupName, "authorized to work in the united states") {
                    if InStr(radioButtonName, "yes") {
                        if radioButton.IsSelected {
                            break
                        }
                        ToolTip("Clicking 'Yes' for authorized to work in the United States.")
                        WinActivate("ahk_exe chrome.exe")
                        RandomDelay(100, 300)
                        ClickElementByPath(radioButton)
                        radioButtonAlreadySelected := true
                        FileAppend("Chosen option: " radioButtonName "`n", "all_questions.txt")
                        RandomDelay(200, 400)
                        break
                    }
                } else if InStr(radioGroupName, "remote") || InStr(radioGroupName, "driver") || InStr(radioGroupName, "driver's") {
                    if InStr(radioButtonName, "yes") {
                        if radioButton.IsSelected {
                            break
                        }
                        ToolTip("Clicking 'Yes' for remote location or driver's license.")
                        WinActivate("ahk_exe chrome.exe")
                        RandomDelay(100, 300)
                        ClickElementByPath(radioButton)
                        radioButtonAlreadySelected := true
                        FileAppend("Chosen option: " radioButtonName "`n", "all_questions.txt")
                        RandomDelay(200, 400)
                        break
                    }
                } else if InStr(radioGroupName, "visa") || InStr(radioGroupName, "require sponsor") {
                    if InStr(radioButtonName, "no") {
                        if radioButton.IsSelected {
                            break
                        }
                        ToolTip("Clicking 'No' for visa/sponsorship question.")
                        WinActivate("ahk_exe chrome.exe")
                        RandomDelay(100, 300)
                        ClickElementByPath(radioButton)
                        radioButtonAlreadySelected := true
                        FileAppend("Chosen option: " radioButtonName "`n", "all_questions.txt")
                        RandomDelay(200, 400)
                        break
                    }
                } else if InStr(radioGroupName, "license") && !InStr(radioGroupName, "driver") && !InStr(radioGroupName, "driver's") {
                    if InStr(radioButtonName, "no") {
                        if radioButton.IsSelected {
                            break
                        }
                        ToolTip("Clicking 'No' for non-driver license related question.")
                        logFile := "radio_button_log.txt"
                        FileAppend("Clicked 'No' for RadioGroup: " radioGroupName "`n", logFile)
                        WinActivate("ahk_exe chrome.exe")
                        RandomDelay(100, 300)
                        ClickElementByPath(radioButton)
                        radioButtonAlreadySelected := true
                        FileAppend("Chosen option: " radioButtonName "`n", "all_questions.txt")
                        RandomDelay(200, 400)
                        break
                    }
                } else if InStr(radioGroupName, "what percentage of the time are you willing to travel for work") {
                    if radioButtonName == travelPreference {
                        if radioButton.IsSelected {
                            break
                        }
                        ToolTip("Clicking travel percentage question.")
                        WinActivate("ahk_exe chrome.exe")
                        RandomDelay(100, 300)
                        ClickElementByPath(radioButton)
                        radioButtonAlreadySelected := true
                        FileAppend("Chosen option: " radioButtonName "`n", "all_questions.txt")
                        RandomDelay(200, 400)
                        break
                    }
                } else if InStr(radioGroupName, "do you speak english") {
                    if InStr(radioButtonName, "yes") {
                        if radioButton.IsSelected {
                            break
                        }
                        ToolTip("Clicking 'Yes' for English question.")
                        WinActivate("ahk_exe chrome.exe")
                        RandomDelay(100, 300)
                        ClickElementByPath(radioButton)
                        radioButtonAlreadySelected := true
                        FileAppend("Chosen option: " radioButtonName "`n", "all_questions.txt")
                        RandomDelay(200, 400)
                        break
                    }
                } else if InStr(radioGroupName, "do you speak spanish") {
                    if InStr(radioButtonName, speakSpanish) {
                        if radioButton.IsSelected {
                            break
                        }
                        ToolTip("Clicking " speakSpanish " for Spanish question.")
                        WinActivate("ahk_exe chrome.exe")
                        RandomDelay(100, 300)
                        ClickElementByPath(radioButton)
                        radioButtonAlreadySelected := true
                        FileAppend("Chosen option: " radioButtonName "`n", "all_questions.txt")
                        RandomDelay(200, 400)
                        break
                    }
                } else if InStr(radioGroupName, "gender") {
                    if InStr(radioButtonName, "I decline to identify") {
                        if radioButton.IsSelected {
                            break
                        }
                        ToolTip("Clicking " radioButtonName " for gender question.")
                        WinActivate("ahk_exe chrome.exe")
                        RandomDelay(100, 300)
                        ClickElementByPath(radioButton)
                        radioButtonAlreadySelected := true
                        FileAppend("Chosen option: " radioButtonName "`n", "all_questions.txt")
                        RandomDelay(200, 400)
                        break
                    }
                }
            }

            if !radioButtonAlreadySelected {
                ; Handle unknown radio buttons
                radioButtonAnswer := ChatGPT("Question:`n" radioGroup.Name "`nAnswer Options:`n" currentOptions, "Directly answer the question using one of the options provided. Do not provide any other output. Example: Yes", resume,,,, getGPTFeedback := "True")
                if answerReview {
                    userAnswer := InputBox("Please edit answer if necessary. Click 'OK' to continue.`nQuestion: " radioGroupName "`nAnswer: " radioButtonAnswer, "GPT Oversight",, radioButtonAnswer)
                    radioButtonAnswer := userAnswer.Value
                }
                Trim(radioButtonAnswer)

                ; First, check if the key already has a value in the INI file
                existingValue := IniRead(configFile, "RadioButtons", radioGroupName, "")

                ; Only proceed with IniWrite if the key does not exist or is empty
                if (existingValue == "") {
                    IniWrite(radioButtonAnswer, configFile, "RadioButtons", radioGroupName)
                }

                for radioButton in radioButtons {
                    if InStr(radioButton.Name, radioButtonAnswer) {
                        ShowToolTipWithTimer("Successfully grabbed answer.",,2000)  ; Debugging output
                        WinActivate("ahk_exe chrome.exe")
                        ClickElementByPath(radioButton)
                        radioButtonAlreadySelected := true
                        FileAppend("Chosen option: " radioButton.Name "`n", "all_questions.txt")
                        RandomDelay(200, 400)
                        break  ; Stop after clicking the correct button
                    } else {
                        ToolTip("Failed to grab a proper answer from ChatGPT.")  ; Debugging output
                        FileAppend("Failed to grab a proper answer from ChatGPT.`nQuestion: " radioGroupName "`nAnswer Options:`n" currentOptions "`nChatGPT response: " ChatGPTResponse "`n`n", logFile)
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
        FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n", "JobApplicationQA_Debug_Log.txt")
        
        return false
    }
}

; Handle checkboxes
HandleCheckboxes(rootElement) {
    global resume, checkboxPatterns, strCheckboxPatterns, checkBoxSuccess := false, strCheckboxesA := "", strCheckboxesB := ""
    global answerReview, associatedLabel, parentCheckboxExcludeList, parentCheckboxFailure := "" ;UIA()
    global holdParentElementName := "", parentElementA := "", parentElementB := ""

    ; Find all checkbox elements
    checkboxes := rootElement.FindAll({ LocalizedType: "check box" })

    if GetArrayLength(checkboxes) == 0 {
        FileAppend("No checkboxes found.`n", "apply_debug_log.txt")
        return true
    }

    for checkbox in checkboxes {
        
        treeWalker := UIA.CreateTreeWalker(UIA.ControlViewCondition)
        parentElement := treeWalker.GetParentElement(checkbox)
        
        if parentElement.Name == holdParentElementName {
            ; Do nothing
        } else {
            FileAppend("Checkbox Question: " parentElement.Name "`n", "all_questions.txt")
        }

        try {
            holdParentElementName := parentElement.Name
        } catch {
            holdParentElementName := ""
        }
        
        FileAppend("Checkbox option: " checkbox.Name "`n", "all_questions.txt")
    }

    holdParentElementName := ""

    for i, checkbox in checkboxes {
        
        treeWalker := UIA.CreateTreeWalker(UIA.ControlViewCondition)
        parentElement := treeWalker.GetParentElement(checkbox)
        if holdParentElementName == "" {
            parentElementA := parentElement
            childrenElements := parentElement.FindAll({ LocalizedType: "check box" })
            holdParentElementName := parentElement.Name
            for childElement in childrenElements {
                strCheckboxesA .= childElement.Name ", "
            }
            continue
        }
        if parentElement.Name == holdParentElementName {
            ; Do nothing
        } else {
            parentElementB := parentElement
            childrenElements := parentElement.FindAll({ LocalizedType: "check box" })
            for childElement in childrenElements {
                strCheckboxesB .= childElement.Name ", "
            }
            holdParentElementName := parentElement.Name
        }
        
    }
    strCheckboxesA := RTrim(strCheckboxesA, ', ')
    strCheckboxesB := RTrim(strCheckboxesB, ', ')
    if strCheckboxesA == "" {
        FileAppend("No checkboxes found in strCheckboxesA.`n", "apply_debug_log.txt")
        return true
    }

    ;MsgBox("Checkboxes found: " strCheckboxes)
    for checkbox in checkboxes {
        global checkBoxSuccess, checkboxFailure := false, parentCheckboxExcludeList, parentCheckboxFailure, associatedLabel
        ;MsgBox("Processing checkbox: " checkbox.Name)

        ; Scroll the checkbox into view
        checkbox.ScrollIntoView()
        RandomDelay(100, 300)

        ; Get the TogglePattern to check the state
        if !(togglePattern := checkbox.GetPattern("TogglePattern")) {
            FileAppend("No TogglePattern available for checkbox: " checkbox.Name)
            continue
        }

        ; Creating a TreeWalker with specific filtering conditions
        treeWalker := UIA.CreateTreeWalker(UIA.ControlViewCondition)
        parentElement := treeWalker.GetParentElement(checkbox)

        if parentCheckboxFailure == parentElement.Name {
            FileAppend("parentElement: " parentElement.Name " is still on the ignore list for this option: " checkbox.Name ". Skipping question.`n", "skip_log.txt")
            continue
        }

        for each in parentCheckboxExcludeList {
            if InStr(parentElement.Name, each) {
                parentCheckboxFailure := parentElement.Name
                FileAppend("Parent element: " parentElement.Name " was matched with " each " on the ignore list. Skipping.`n", "skip_log.txt")
                break
            }
        }

        ; Check upon initial
        if parentCheckboxFailure == parentElement.Name {
            FileAppend("Parent element: " parentElement.Name " is on the ignore list. Skipping question.`n", "skip_log.txt")
            continue
        } else {
            parentCheckboxFailure := "" ;UIA()
        }

        if toggleState := togglePattern.ToggleState == 1 {
            FileAppend("Checkbox " checkbox.Name " for " parentElement.Name " is already selected. Skipping.`n", "apply_debug_log.txt")
            continue
        }

        global checkboxText := checkbox.Name
        ; Check if the associated text matches any pattern
        for pattern in checkboxPatterns {
            global checkboxText, checkboxFailure, parentCheckboxFailure
            if InStr(checkboxText, pattern) {
                FileAppend("Checkbox " checkboxText " for " parentElement.Name " is on the ignore list. Skipping question.", "all_questions.txt")
                FileAppend("Checkbox " checkboxText " for " parentElement.Name " is on the ignore list. Skipping question.", "skip_log.txt")
                checkboxFailure := true
                break
            }
        }
        if checkboxFailure {
            checkboxFailure := false
            continue
        }

        if checkboxSuccess {
            FileAppend("Checkbox for " checkboxText " is not on the ignore list. Clicking checkbox.`n", "apply_debug_log.txt")
            ClickElementByPath(checkbox, rootElement)
        }
    }
    ; Check if the last parent element is on the ignore list. If checkboxSuccess is still false, then it's safe to assume that all of the parent elements are on the ignore list.
    if parentCheckboxFailure != "" && !checkboxSuccess {
        FileAppend("Parent element: " parentCheckBoxfailure " is on the ignore list. Skipping question.`n", "skip_log.txt")
        return true
    }

    childrenCheckboxes := parentElementA.FindAll({ LocalizedType: "check box" })
    parentElement := parentElementA
    strCheckboxes := strCheckboxesA
    if !checkboxSuccess && parentCheckboxFailure != parentElement.Name {
        ;ToolTip("No answer found. Asking ChatGPT.")  ; Debugging output
        FileAppend("No checkbox answer found. Asking ChatGPT.`nQuestion: " parentElement.Name "`nAnswer Options:`n" strCheckboxes "`n`n", "JobApplicationQA_debug_log.txt")
        FileAppend("No checkbox answer found. Asking ChatGPT.`nQuestion: " parentElement.Name "`nAnswer Options:`n" strCheckboxes "`n`n", "apply_debug_log.txt")        

        answer := ChatGPT( parentElement.Name "`nAnswer Options: " strCheckboxes, "Using the following resume for context, directly answer the question using one or more of the options provided. Do not provide any other output and separate answer using a comma & space ', ' Example Options: Yes or No Example Answer: Yes", resume, , , , getGPTFeedback := "True")
        if answerReview {
            inputBoxValue := InputBox("Review Options: " strCheckboxes "`nfor Label: " associatedLabel,,, answer)
            inputValue := inputBoxValue.Value
            inputArrValue := StrSplit(inputValue, ", ")

            for i in inputArrValue {
                if InStr(strCheckboxes, i) {
                    for childCheckBox in childrenCheckboxes {
                        if childCheckBox.Name == i {
                            ClickElementByPath(childCheckBox, rootElement)
                            FileAppend("Found i: " i " and checked checkbox: " childCheckbox.Name " for parentElement.Name: " parentElement.Name "`n", "all_questions.txt")
                        }
                    }
                } else {
                    ToolTip("Failed to grab a proper answer from both user and ChatGPT. Really now?", 2000, 2000)  ; Debugging output
                    FileAppend("Failed to grab a proper answer from both user and ChatGPT.`n `nQuestion: " parentElement.Name "`nAnswer Options:`n" strCheckboxes "`nChatGPT response: " answer "`n`n", logFile)
                }
            }
        } else {
            if InStr(answer, ", ") {
                answer := StrSplit(answer, ", ")
                for each in answer {
                    strAnswer .= "`n" each
                }

                for i in answer {
                    if InStr(strCheckboxes, i) {
                        for childCheckBox in childrenCheckboxes {
                            if childCheckBox.Name == i {
                                ClickElementByPath(childCheckbox, rootElement)
                                FileAppend("Found i: " i " and checked checkbox: " childCheckbox.Name " for parentElement.Name: " parentElement.Name "`n", "all_questions.txt")
                            } else {
                                continue
                            }
                        }
                    } else {
                        ShowToolTipWithTimer("Failed to grab a proper answer from ChatGPT.", 2000, 2000)  ; Debugging output
                        MsgBox("Failed to grab a proper answer from ChatGPT.")
                        FileAppend("Failed to grab a proper answer from ChatGPT.`n `nQuestion: " parentElement.Name "`nAnswer Options:`n" strCheckboxes "`nChatGPT response: " strAnswer "`n`n", logFile)
                    }
                }
            } else {
                strAnswer := answer ; If there is only one answer from ChatGPT, go ahead and define strAnswer to maintain consistency in logging
                if InStr(strCheckboxes, strAnswer) {
                    for childCheckBox in childrenCheckboxes {
                        if childCheckBox.Name == strAnswer {
                            ClickElementByPath(childCheckbox, rootElement)
                            FileAppend("Found i: " strAnswer " and checked checkbox: " childCheckbox.Name " for parentElement.Name: " parentElement.Name "`n", "all_questions.txt")
                        } else {
                            continue
                        }
                    }
                } else {
                    ShowToolTipWithTimer("Failed to grab a proper answer from ChatGPT.", 2000, 2000)  ; Debugging output
                    MsgBox("Failed to grab a proper answer from ChatGPT.")
                    FileAppend("Failed to grab a proper answer from ChatGPT.`n `nQuestion: " parentElement.Name "`nAnswer Options:`n" strCheckboxes "`nChatGPT response: " strAnswer "`n`n", logFile)
                }
            }
        }
    }

    if strCheckboxesB == "" {
        FileAppend("No checkboxes found in strCheckboxesB.`n", "apply_debug_log.txt")
        return true
    }

    if parentElementB == "" {
        FileAppend("No parentElementB found.`n", "apply_debug_log.txt")
        return true
    }

    childrenCheckboxes := parentElementA.FindAll({ LocalizedType: "check box" })
    parentElement := parentElementB
    strCheckboxes := strCheckboxesB
    if !checkboxSuccess && parentCheckboxFailure != parentElement.Name {
        ;ToolTip("No answer found. Asking ChatGPT.")  ; Debugging output
        FileAppend("No checkbox answer found. Asking ChatGPT.`nQuestion: " parentElement.Name "`nAnswer Options:`n" strCheckboxes "`n`n", "JobApplicationQA_debug_log.txt")
        FileAppend("No checkbox answer found. Asking ChatGPT.`nQuestion: " parentElement.Name "`nAnswer Options:`n" strCheckboxes "`n`n", "apply_debug_log.txt")        

        answer := ChatGPT( parentElement.Name "`nAnswer Options: " strCheckboxes, "Using the following resume for context, directly answer the question using one or more of the options provided. Do not provide any other output and separate answer using a comma & space ', ' Example Options: Yes or No Example Answer: Yes", resume, , , , getGPTFeedback := "True")
        if answerReview {
            inputBoxValue := InputBox("Review Options: " strCheckboxes "`nfor Label: " associatedLabel,,, answer)
            inputValue := inputBoxValue.Value
            inputArrValue := StrSplit(inputValue, ", ")

            for i in inputArrValue {
                if InStr(strCheckboxes, i) {
                    for childCheckBox in childrenCheckboxes {
                        if childCheckBox.Name == i {
                            ClickElementByPath(childCheckBox, rootElement)
                            FileAppend("Found i: " i " and checked checkbox: " childCheckbox.Name " for parentElement.Name: " parentElement.Name "`n", "all_questions.txt")
                        }
                    }
                } else {
                    ToolTip("Failed to grab a proper answer from both user and ChatGPT. Really now?", 2000, 2000)  ; Debugging output
                    FileAppend("Failed to grab a proper answer from both user and ChatGPT.`n `nQuestion: " parentElement.Name "`nAnswer Options:`n" strCheckboxes "`nChatGPT response: " answer "`n`n", logFile)
                }
            }
        } else {
            if InStr(answer, ", ") {
                answer := StrSplit(answer, ", ")
                for each in answer {
                    strAnswer .= "`n" each
                }

                for i in answer {
                    if InStr(strCheckboxes, i) {
                        for childCheckBox in childrenCheckboxes {
                            if childCheckBox.Name == i {
                                ClickElementByPath(childCheckbox, rootElement)
                                FileAppend("Found i: " i " and checked checkbox: " childCheckbox.Name " for parentElement.Name: " parentElement.Name "`n", "all_questions.txt")
                            } else {
                                continue
                            }
                        }
                    } else {
                        ShowToolTipWithTimer("Failed to grab a proper answer from ChatGPT.", 2000, 2000)  ; Debugging output
                        MsgBox("Failed to grab a proper answer from ChatGPT.")
                        FileAppend("Failed to grab a proper answer from ChatGPT.`n `nQuestion: " parentElement.Name "`nAnswer Options:`n" strCheckboxes "`nChatGPT response: " strAnswer "`n`n", logFile)
                    }
                }
            } else {
                strAnswer := answer ; If there is only one answer from ChatGPT, go ahead and define strAnswer to maintain consistency in logging
                if InStr(strCheckboxes, strAnswer) {
                    for childCheckBox in childrenCheckboxes {
                        if childCheckBox.Name == strAnswer {
                            ClickElementByPath(childCheckbox, rootElement)
                            FileAppend("Found i: " strAnswer " and checked checkbox: " childCheckbox.Name " for parentElement.Name: " parentElement.Name "`n", "all_questions.txt")
                        } else {
                            continue
                        }
                    }
                } else {
                    ShowToolTipWithTimer("Failed to grab a proper answer from ChatGPT.", 2000, 2000)  ; Debugging output
                    MsgBox("Failed to grab a proper answer from ChatGPT.")
                    FileAppend("Failed to grab a proper answer from ChatGPT.`n `nQuestion: " parentElement.Name "`nAnswer Options:`n" strCheckboxes "`nChatGPT response: " strAnswer "`n`n", logFile)
                }
            }
        }
    }

    return true
}

HandleComboBoxes(rootElement, answerReview) {
    try {
        comboBoxes := rootElement.FindAll({ LocalizedType: "combo box" })
    } catch {
        return true
    }

    if GetArrayLength(comboBoxes) == 0 {
        return true
    }

    arrLengthA := GetArrayLength(comboBoxes)
    if arrLengthA != 0 {
        for comboBox in comboBoxes {
            global comboBoxSuccess := false
            global childNames := ""

            if comboBox.Value != "Select an option" {
                FileAppend("Skipping element, already has value: " comboBox.Value " for element: " comboBox.Name "`n", "skip_log.txt")
                continue
            }

            ; Retrieve and adjust the element's coordinates (adjust with ScrollIntoView and Send("{WheelDown}"))
            coords := GetElementCoordinates(comboBox, rootElement)
            if ClickElementByPath(comboBox, rootElement) {
                Sleep(800)
                children := comboBox.FindAll()
                for child in children {
                    childNames .= child.Name "`n"
                }
                ;MsgBox("Found the following combo box children:`n" childNames)

                for child in children {
                    if InStr(child.Name, "United States") || InStr(child.Name, "Associate's Degree") || InStr(child.Name, "Oklahoma") || InStr(child.Name, " OK ") || InStr(child.Name, "I decline to identify") || InStr(child.Name, "I prefer not to answer") || InStr(child.Name, "Decline To Self Identify") || InStr(child.Name, "I do not wish to answer") || InStr(child.Name, "I don't wish to answer") || InStr(child.Name, "Other") {
                        comboBoxSuccess := true
                        child.Invoke()
                        break
                    }
                }

                if !comboBoxSuccess {
                    global gptAnswer := ""
                    global gptAnswer := HandleMissingQuestion(comboBox.Name, childNames)

                    if gptAnswer != "" {
                        if answerReview {
                            inputBoxValue := InputBox("Review Options: " comboBox.Name "`nfor Label: " comboBox.Name,,, gptAnswer)
                            inputValue := inputBoxValue.Value
                            if InStr(inputValue, ", ") {
                                inputArrValue := StrSplit(inputValue, ", ")
                                for each in inputArrValue {
                                    if InStr(childNames, each) {
                                        for child in children {
                                            if child.Name == each {
                                                comboBoxSuccess := true
                                                child.Invoke()
                                                FileAppend("Found each: " each " and invoked comboBox: " child.Name " for comboBox.Name: " comboBox.Name "`n", "all_questions.txt")
                                                break
                                            } else {
                                                continue
                                            }
                                        }
                                    } else {
                                        ToolTip("Failed to grab a proper answer from both user and ChatGPT. Really now?", 2000, 2000)  ; Debugging output
                                        MsgBox("Failed to grab a proper answer from both user and ChatGPT. Really now?")
                                        FileAppend("Failed to grab a proper answer from both user and ChatGPT.`n `nQuestion: " comboBox.Name "`nAnswer Options:`n" childNames "`nChatGPT response: " gptAnswer "`n`n", logFile)
                                    }
                                }
                            } else {
                                for child in children {
                                    if InStr(child.Name, inputValue) {
                                        comboBoxSuccess := true
                                        child.Invoke()
                                        break
                                    } else {
                                        ToolTip("Failed to grab a proper answer from both user and ChatGPT. Really now?", 2000, 2000)  ; Debugging output
                                        MsgBox("Failed to grab a proper answer from both user and ChatGPT. Really now?")
                                        FileAppend("Failed to grab a proper answer from both user and ChatGPT.`n `nQuestion: " comboBox.Name "`nAnswer Options:`n" childNames "`nChatGPT response: " gptAnswer "`n`n", logFile)
                                    }
                                }
                            }
                        } else {
                            for child in children {
                                if InStr(child.Name, gptAnswer) {
                                    comboBoxSuccess := true
                                    child.Invoke()
                                    break
                                } else {
                                    continue
                                }
                            }
                        }
                    } else {
                        ShowToolTipWithTimer("Failed to grab a proper answer from ChatGPT.", 2000, 2000)  ; Debugging output
                        MsgBox("Failed to grab a proper answer from ChatGPT.")
                        FileAppend("Failed to grab a proper answer from ChatGPT.`n `nQuestion: " comboBox.Name "`nAnswer Options:`n" childNames "`nChatGPT response: " gptAnswer "`n`n", logFile)
                    }
                }

                try {
                    ;grandchildren := comboBox.Children[1].Children
                    ;for grandchild in grandchildren {
                    ;    if InStr(grandchild.Name, "I decline to identify") {
                    ;        grandchild.Invoke()
                    ;        break
                    ;    }
                    ;}
                } catch as e {
                    errorMessage := "Unable to find combo box grandchildren: " e.Message
                    errorLine := "Line: " e.Line
                    errorExtra := "Extra Info: " e.Extra
                    errorFile := "File: " e.File
                    errorWhat := "Error Context: " e.What
                    
                    ; Display detailed error information
                    ;MsgBox(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat)
                    
                    ; Log the detailed error information
                    FileAppend(errorMessage "`n" errorLine "`n" errorExtra "`n" errorFile "`n" errorWhat "`n", "apply_debug_log.txt")
                    
                    return false
                }
                
            }
        }
        Sleep(300)
        ; Check if the number of combo boxes has changed once a combo box has been clicked
        comboBoxes := rootElement.FindAll({ LocalizedType: "combo box" })
        arrLengthB := GetArrayLength(comboBoxes)
        if arrLengthA != arrLengthB {
            for combox in comboBoxes {
                if ClickElementByPath(combox, rootElement) {
                    Sleep(200)
                    children := combox.FindAll()
                    for child in children {
                        childNames .= child.Name "`n"
                    }
                    ;MsgBox("Found the following combo box children:`n" childNames)

                    for each, child in children {
                        if each == 1 {
                            continue
                        }
                        if InStr(child.Name, "Oklahoma") {
                            child.Invoke()
                            break
                        }
                    }
                }
            }
        }

        return true
    }
    

    return false
}