# Indeed-Apply-Bot_ChatGPT-Auto-Iteration

**This application currently only works on Windows PC + Chrome browser.**

**Cover Letters are currently not supported**

**All you need to do is download the one file: "IndeedApplySimple.exe" and run it.** The other files are source code for transparency and collaboration.

                                                                                                                        PREAMBLE

"Easily Apply" is anything but. Predatory listings. Ghost jobs. Pointless forms that feel like a test of patience. Some employers ask twenty irrelevant questions just because most people will jump through the hoops. It's unpaid labor disguised as opportunity. Let's put some power back into the hands of the working class by helping everyone work less. 

**Indeed Auto Apply / Check Reviews - find the right job for you as fast as possible** - Find better jobs faster. This tool does what Indeed should be doing already. Every new hire is a lost user for them. I’ve worked in sales long enough to tell you with confidence that companies care about profits over people and appearances over reality. This includes nonprofits. Indeed's real customer is the employer, not you. They want you applying endlessly so employers see a healthy talent pool. It’s not about helping you land a job. It's about keeping you stuck in the loop.

**ChatGPT Automatic Iteration - get the best results per prompt without a human-in-the-middle** - I built this because no one wants to back models that don’t live in the cloud or pump out profits. The fear is simple: If regular people get too much value, they stop needing the platform. That threatens the whole business model. Investors want hype, not access. Free models drive headlines by handing out free samples. That’s it. The good stuff stays locked up for the big spenders. It's the same sales playbook over and over. Tell the world it's expensive. Lock up the source. Sell it twice.

-----------------------------------------------------------------

Indeed Apply Bot - This script automatically checks reviews and/or applies to specified job applications on Indeed **+** automatically answers custom questions from employers via user input (ini.config, past, or in real-time) while defaulting to ChatGPT when input is missing. Job types (types + titles) and job details can be excluded as long as the given keyword is listed within the job title or job description. Review Check choices are: automatically per job or manually for the entire page of jobs.

ChatGPT Auto Iteration - This script works with Indeed Apply Bot while also working as a standalone script. It can utilize a set prompt (similar to custom instructions) **+** your question **+** previous ChatGPT responses. The set prompt and question (input text) always applies to each iteration, but the previous responses are capped to 3 or 60k token length, whichever happens first. This helps reduce the number of useless responses given by the model when nearing the context(token) limit. The "free GPT vs. paid vs. incognito mode" is mostly coded already for testing reasons (before temporary chats existed), so please leave a star and a comment in "Discussions" if you'd like to see this fully implemented and supported.

This script utilizes AutoHotKey v2 to mimic user input (the whole point of using AHK here), thus allowing the user to remain compliant with both Indeed's and OpenAI's TOS. Both scripts include random mouse click boundaries (avoids clicking the same spot repeatedly) and random wait times between certain interactions to simulate human behavior, allowing for load times on older PC's while avoiding Indeed's rate limiting to a large degree.

-----------------------------------------------------------------

**It's not possible to know of every issue that exists on every device, so please create an "issue" when you run into problems."**

**As well, using ChatGPT via incognito window is currently disabled within the script. If this becomes a problem, please create an "issue".**

**BEWARE: Do NOT leave this script running when playing online games that have Anti-Cheat software! While it is generally fine for most games, as with all scripts and for many competitive games, the risk of game bans is always there.**

**Indeed limits users to roughly 45 applications per hour before automatically rate limiting. If this happens frequently, let me know and I'll turn the rate timer back on.**

**Collaborators: Please create an "issue" to request Collaborator access**

-----------------------------------------------------------------

**"ctrl + j"** for job > then **"a"** = regular applying; **"r"** to check reviews for companies on that page; **"o"** to do both automatically (filters out companies with undeniably bad reviews, currently not fully supported)

**"ctrl + i"** for ChatGPT iterations > then **"i"** for regular prompting; **"f"** for function-specific prompting. This turned out to be similar to the same toolware for o1, with the tradeoff being a better answer but it takes longer than o1 a lot of the time due to the inability to multithread the prompts. That and you don't get charged $200 for unlimited use. It's main function is to prompt ChatGPT to chunk your prompt into smaller, more modular function-specific prompts before iterating on each piece.  (reduces context limit problems while allowing for a ridiculously comprehensive response per function without losing the context of the whole project).

**"ctrl + e"** for editing ini.config manually (first-time users can directly use **"ctrl + j"** without the need to add this file manually)

**"ctrl + u"** for UIA.Viewer() [Credits & Courtesy to Descolada]

**"Esc"** (escape) to exit
**"alt + r"** to reload
**"ctrl + p"** to pause the script (press again to unpause)


Like my project and want to see more of my work? Give me a star so I can remain mentally motivated to finish coding my other project: a decentralized GPT model that learns in real-time, solves many problems with current models, and with no need for a human-in-the-middle (or finetuning).

Credits & Courtesy to Descolada for providing and maintaining UIAv2, the underlying framework making this possible. Please check out their link below (Especially the package manager).

https://github.com/Descolada
