#Requires AutoHotkey v2.0

#SingleInstance

; Function to handle Indeed titles
HandleIndeedTitles(script := "", titleCheck := "", timeout := 5000, checkInterval := 50, titles := [], keywordSearchTitles := []) {

    global screenerQuestionsTitle := "Answer screener questions from the employer | Indeed.com - Google Chrome",
        reviewJobAppTitle := "Review the contents of this job application | Indeed.com - Google Chrome",
        qualCheckTitle := "Qualification check | Indeed.com - Google Chrome",
        noQualificationsTitle := "It looks like you don't have some relevant qualifications - Google Chrome",
        humanVerifyTitle := ["Just a moment... - Google Chrome", "Security Check - Indeed.com - Google Chrome"],  ; "Verify You Are Human" check
        pageNotFoundTitle := "Page Not Found - Indeed.com - Google Chrome",
        indeedApplyTitle := "Indeed Apply - Google Chrome",
        applicationSubmittedTitle := "Your application has been submitted | Indeed.com - Google Chrome",
        keywordSearchTitleKeywords := ["Jobs", "in", "| Indeed.com - Google Chrome"],  ; Keywords for job search pages
        resumeUploadTitle := "Upload or build a resume for this application | Indeed.com - Google Chrome",
        relevantXPTitle := "Add relevant work experience information | Indeed.com - Google Chrome",
        reviewQualificationsTitle := "Review these qualifications found in the job post - Google Chrome",
        loadingTitle := ["Untitled - Google Chrome", "smartapply.indeed.com/beta/indeedapply/postresumeapply - Google Chrome"],
        documentTitle := "Add documents to support this application | Indeed.com - Google Chrome",
        ignoredWindowTitleA := "Questions from Indeed to improve your job matches - Google Chrome",
        ignoredWindowTitleB := "It looks like you may not have some common qualifications - Google Chrome",
        involuntaryWindowTitleA := "Answer voluntary self identification questions from the employer | Indeed.com - Google Chrome"

    titles := [{ title: screenerQuestionsTitle, label: "screenerQuestionsTitle" },
    { title: reviewJobAppTitle, label: "reviewJobAppTitle" },
    { title: qualCheckTitle, label: "qualCheckTitle" },
    { title: noQualificationsTitle, label: "noQualificationsTitle" },
    { title: humanVerifyTitle, label: "humanVerifyTitle" },
    { title: pageNotFoundTitle, label: "pageNotFoundTitle" },
    { title: indeedApplyTitle, label: "indeedApplyTitle" },
    { title: applicationSubmittedTitle, label: "applicationSubmittedTitle" },
    { title: resumeUploadTitle, label: "resumeUploadTitle" },
    { title: relevantXPTitle, label: "relevantXPTitle" },
    { title: reviewQualificationsTitle, label: "reviewQualificationsTitle" },
    { title: loadingTitle, label: "loadingTitle" },
    { title: documentTitle, label: "documentTitle" },
    { title: ignoredWindowTitleA, label: "ignoredWindowTitleA" },
    { title: ignoredWindowTitleB, label: "ignoredWindowTitleB" },
    { title: involuntaryWindowTitleA, label: "involuntaryWindowTitleA" }]

    global indeedWindowTitleFunctionMap := Map(
        "screenerQuestionsTitle", HandleScreenerQuestionsWrapper,
        "reviewJobAppTitle", HandleReviewJobApp,
        "qualCheckTitle", HandleQualCheck,
        "noQualificationsTitle", HandleNoQualifications,
        "humanVerifyTitle", VerifyHumanCheck,
        "pageNotFoundTitle", HandlePageNotFound,
        "indeedApplyTitle", HandleIndeedApply,
        "applicationSubmittedTitle", HandleApplicationSubmitted,
        "keywordSearchTitleKeywords", HandleJobSearch,
        "resumeUploadTitle", HandleResumeUpload,
        "jobSearchTitle", HandleJobSearch,
        "relevantXPTitle", HandleRelevantXP,
        "reviewQualificationsTitle", HandleRelevantXP,
        "loadingTitle", HandlePageLoad,
        "documentTitle", HandleDocumentUpload,
        "ignoredWindowTitleA", HandleIgnoredTitles,
        "ignoredWindowTitleB", HandleIgnoredTitles,
        "involuntaryWindowTitleA", HandleInvoluntaryWindowTitleA
    )

    ; Add dynamic job search titles
    keywordSearchTitles := [
        keywordSearchTitleKeywords[1],
        keywordSearchTitleKeywords[2],
        keywordSearchTitleKeywords[3]
    ]

    global foundTitle := ""

    ; Get the title of the current window if wasn't passed in
    if titlecheck == "" {
        titlecheck := WinGetTitle("A")
    }

    ; Wait for a matching title
    foundTitle := GetMatchingTitle(script := "IndeedApplySimple.ahk", titleCheck, titles, keywordSearchTitles)


    ; If a matching title is found, return it
    if foundTitle && !IsObject(foundTitle) {
        return foundTitle
    }
    MsgBox("No matching title found. foundTitle: " foundTitle)
    ; If not matching title is found, log and return "unknownTitle"
    FileAppend("Unknown title: " WinGetTitle("A") "`n", "missing_titles_log.txt")
    return "unknownTitle"
}

HandleIndeedKeywordSearchTitles(titleCheck, keywordSearchTitles) {

    keywordTitleMatch := 0
    ; Check for dynamic job search titles
    for i, keyword in keywordSearchTitles {
        if InStr(titleCheck, keywordSearchTitles[i]) {
            keywordTitleMatch++
            if keywordTitleMatch == 3 {
                return "jobSearchTitle"
            }
        }
    }

    ; If no matching titles found, return ""
    return ""
}