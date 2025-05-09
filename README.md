# Indeed-Apply-Bot_ChatGPT-Auto-Iteration

Frustrated that Indeed's "Easily Apply" has gradually turned into the opposite of easy? Welcome aboard.

**Please read below before creating an "issue".**

**Indeed Auto Apply / Check Reviews - find the right job for you as fast as possible, like Indeed should be doing already**

**ChatGPT Automatic Iteration - get the best results per prompt without a human-in-the-middle**

Indeed Apply Bot - This script automatically checks reviews and/or applies to specified job applications on Indeed **+** automatically answers custom questions from employers via user input while defaulting to ChatGPT when input is missing. Job types and job details can be excluded as long as the keyword is listed within the job title or job description. Review Check choices are: automatically per job or manually for the entire page of jobs.

ChatGPT Auto Iteration - This script works with Indeed Apply Bot while also working as a standalone script. It can utilize a set prompt (similar to custom instructions) **+** your question **+** previous ChatGPT responses. The set prompt and question The usage is a little complex for the non-GPT user, but I won't bother to explain until someone says they don't understand.

This script utilizes AutoHotKey v2 to mimic user input (the whole point of using AHK here), thus allowing the user to remain compliant with both Indeed's and OpenAI's TOS. The Indeed script also includes mouse click boundaries (avoids clicking the same spot) random wait times between certain interactions to allow for load times on older PC's / avoid Indeed's rate limiting to a large degree.

-----------------------------------------------------------------

**I will not know of every issue that exists, so please create an "issue" when you run into problems."

**BEWARE: Do NOT leave this script running when playing online games that have Anti-Cheat enabled! As with all scripts for many competitive games, the risk is always there.**

**This script currently only works on Windows PC + Chrome browser. As well, using ChatGPT via incognito window is currently disabled within the script. If this becomes a problem, please create an "issue".**

**Cover Letters are currently not supported**

**Indeed limits users to roughly 45 applications per hour before automatically rate limiting.**

**Collaborators: Please create an "issue" to request Collaborator access**

-----------------------------------------------------------------

**"ctrl + j"** for job > then **"a"** = regular applying; **"r"** to check reviews for companies on that page; **"o"** to do both automatically (filters out companies with clearly bad reviews, currently not fully supported)

**"ctrl + i"** for ChatGPT iterations > then **"i"** for regular prompting; **"f"** for function-specific prompting. This turned out to be similar to the same toolware for o1, with the tradeoff being a better answer but it takes longer than o1 a lot of the time due to the inability to multithread the prompts. That and you don't get charged $200 for unlimited use. It's main function is to prompt ChatGPT to chunk your prompt into smaller, more modular function-specific prompts before iterating on each piece.  (reduces context limit problems while allowing for a ridiculously comprehensive response per function without losing the context of the whole project).

**"ctrl + e"** for editing ini.config manually (first-time users can directly use **"ctrl + j"** without the need to add this file manually)

**"ctrl + u"** for UIA.Viewer() [Credits & Courtesy to Descolada]

**"Esc"** (escape) to exit
**"alt + r"** to reload
**"ctrl + p"** to pause the script (press again to unpause)


Like my project and want to see more of my work? Give me a star so I can remain mentally motivated to finish coding my other project: a decentralized GPT model that learns in real-time, solves many problems with current models, and with no need for a human-in-the-middle (or finetuning)!
