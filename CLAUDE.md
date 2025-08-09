Note: think new vibe coders but don't ever state this is vibe coding in the documentation. This should all be treated effectively like a vibe coding tutorial for beginners.

---

I'm going to show my wife over the weekend how she can better utilize AI to get work done. She works at credentialengine.org as its chief operating officer. Her and her team regularly have to deal with data management, parsing data, and trying to pull credentials from various educational websites that are not presenting structured data. They have a small tool at https://github.com/udensidev/credential-engine-support-service-publisher but it doesn't really help them all that much.

With all that said, I'm going to introduce her to some of the workflows I regularly deal with when it comes to working with AI. I want to introduce her to some basic programming for the first time for various tasks. She'll use AI to get scripts she can run on her local machine and work with AI to fine tune the work.

I've been building out a rough structure for how I want to present this. I want it to be EXTREMELY user-friendly to the Explain-It-Like-I'm-5 level. 

I need your help. I need you to go in and look at the work I've done, and reshape it. I want you to add to what I've built, but massively edit my work if you need to make it more clear. You should be able to see my notes, and have a rough understanding of what else needs to be added. These are guidelines. If there are things you in your judgement believe should be added, clarified, expanded, or cut, do so. Any edits of importance you can create a file called EDITINGNOTES.md to share your rationale or stash the old versions in if you would like.

I want it to be encouraging but don't glaze them.

The file structure is below. Each file should at the very least have some notes in it that might help you. They are guiding notes, not directives.

Structure:
README.md - The main starting point and hub. Make sure the files are all linked through here in a logical state.
docs/getting-started.md - The simplest checklist imaginable to get started with Python. Keep this as simplistic as possible.
docs/installation.md - Walk them through the simplest setup imaginable. They are on Windows 11.
docs/editors.md - We want them to setup VSCode. We do not want to scare them at all.
docs/the-basics.md - High level overview of some of the things they might want to do with Python. A little cheat sheet that should be simple. Think vibe coding levels of depth here.
docs/learning-checklist.md - A list of the things you think they should learn about python, step-by-step, in order for them to become proficient with working with AI in a vibe coding-like environment.
docs/how-to-use-with-ai.md - Create a document about how they can interact with AI (i.e. vibe code) in a manner that most benefits them (i.e. I have two files and I want XYZ from them). They will almost certainly be using the Chat interfaces to send requests and receive code. explain to them that how they will want to describe their problems, what they expect for a solve, and what they want the ai to provide (e.g. well documented python code using xyz tools)
docs/starting-prompt.md - We will need a prompt that they can use to pre-seed conversations they have with AI. The prompt should include particulars about the environment the user is using (as we defined here), the tools available for use, the type of code we want back (i.e. well documented Python), and whatever else you can think of that would be useful for an AI to know. I don't know if AI wants to know the level of talent they are dealing with here.

* Documents should logically link to their next obvious couterpart for effective workflow.
* I tried adding "Why?" sections in the beginning, but I didn't add enough of them.  Format them in Markdown please. There should be asides/sidebars for as much as possible to explain the justifiction for why things are the way they are and what we are doing them. I don't know if Markdown is capable of supporting something like this...are they called infoboxes? I have no idea. I just know this text needs them.
* This is all to be formatted for Github Markdown
* I'm on the fence about where I inserted python notebooks. I feel like it could be useful, but I also worry it can clutter up their minds. I don't know if there is a place for it in the existing structure, if it should be it's own page, or if we should just omit it completely.
* Finally, I have provided you with my wife's scenario, but anything specific to her company should go in a special credential-engine.md document you create at the root level. I think there is potential value in me using the work you create with members of my own company.
