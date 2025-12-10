1. What are Git and GitHub?

Git is version control software.
You can think of it as a time machine for your files: it lets you save snapshots of your work, go back to older versions, and see what changed over time.

[On screen: Switch to your web browser.]

[On screen: In the address bar, type https://git-scm.com/ and press Enter.]

This is the official Git website. This is where Git is documented, and it’s also where you can download Git if you ever need the command-line version.

[On screen: In a new tab or the same tab, go to https://git-scm.com/cheat-sheet.]

Git itself runs on your computer, locally. You interact with Git via the command line or terminal. Git tracks changes to files in a repository (a folder that Git is watching). Once you make changes and save the file, you need to tell Git that you are commiting to those changes. These commits are snapshots of your work and you notate them with messages like “what changed and why.”

As you can see Git has a lot of commands and there are a number of steps involved is saving and synching your work. It doesn't do this automatically, like Dropbox or OneDrive or Google Drive. In this course, we’re not going to type these manually but it’s useful to know that this is what GitHub Desktop is doing behind the scenes.

Now let’s talk about GitHub.

[On screen: In the address bar, go to https://github.com/jdavidm.]

GitHub is a website that hosts Git repositories in the cloud.

So the distinction is:

Git = the tool that tracks changes on your computer.

GitHub = the place where those Git repositories live online and where you can collaborate with other people.

Here you’re looking at my GitHub profile.

[On screen: Point to the list of repositories.]

Each of these is a repository — basically a project tracked with Git. Some are for teaching but most host the computer code I and students write to do statistical analysis as part of a research project.

[On screen: Scroll down until the contribution graph (grid of squares) is visible.]

Down here you can see my contribution graph, sometimes called a punchcard, of my work. Each square represents how many contributions I made on a given day — things like commits, opening issues, or pull requests. The darker the square, the more activity that day.

So:

On your computer, you’ll work locally with Git (through GitHub Desktop).

When you’re ready to share your changes or back them up, you push them to GitHub, where they show up in a repository like these and contribute to this graph.

Now let’s see how that looks in practice using GitHub Desktop.

[On screen: Switch from the browser to GitHub Desktop.]

2. Cloning the course repo and creating your branch

Before you can follow along with me in this video, you need:

* A GitHub account
* GitHub Desktop installed
* The course repo cloned and your own branch created

I’m not going to walk through every click here, because I’ve written that all out for you.

[On screen: Briefly show a browser tab with jdavidm.github.io/learn-stata/computer-setup/ open so students can see the page.]

👉 If you haven’t done this yet, pause this video and go to the computer setup page of the course webpage.

Follow the instructions there to set up your account and download Github Desktop. Once you’ve done that, come back here.

3. How GitHub tracks changes

[On screen: Switch back to GitHub Desktop.]

Now I’m in GitHub Desktop.

Before we jump in to a simple example, I want to say a bit about what exactly Github Desktop is.

Git itself is something you normally use through the command line or terminal. That means you type text commands like git status or git commit instead of clicking on buttons. Github is the cloud storage site for repos that you create and control with Git.

GitHub Desktop is a GUIs, which stands for Graphical User Interface. A GUI is just a way of interacting with software using windows, buttons, menus, and lists instead of typing commands.

There are lots of different GUIs for Git out there — some are built into code editors and others are standalone apps. They all sit on top of Git and send those same Git commands for you in the background.

In this course, we’re going to use GitHub Desktop as our GUI for Git. It’s free, it works the same on Windows and Mac, and it keeps everyone in the class using the same workflow, which makes it much easier to help you when something goes wrong.

4. Tour of GitHub Desktop panes (simple example)

Now, I want to show you the features of Github Desktop.

* Current repository

Up at the top left, you should see the current repository. You’ll always need to make sure it’s set to the course repo, semester26. For most of you, the course repo will be the only repo on your machine, so being on the right repository is easy. For others of you that are currently doing research, you might have multiple repos that you will need to switch back and forth from.

[On screen: Click the repository dropdown and select semester26 if needed.]

As you can see, I have a lot of repos on my machine.

* Current branch

Right next to the repo dropdown is the current branch. I’m going to switch to my personal branch for the course.

[On screen: Click the branch dropdown and select your personal branch.]

* Fetch / Push

The Fetch origin button is how you tell Github Desktop to check with GitHub online to see if there are any changes to the repo that you don’t have yet. Once you make a commit, the Fetch button will change to a Push origin button. This sends your local commits up to GitHub. 

If the branch is new, you may see Publish branch instead of Push. That uploads your branch to GitHub for the first time.

* Simple example

Now let’s make a change so you can see how Git tracks it.

[On screen: In the menu bar, click “Repository” → “Show in Finder/Explorer”.
This opens the folder in your file browser.]

[On screen: From the file browser, open a simple text or markdown file in your editor (e.g., VS Code).]

I’ll open one simple file in the repo — for example, a markdown or text file.

[On screen: In the editor, type a short line such as:
“Adding a short note for the GitHub video demo.”
Then save the file (Ctrl+S / Cmd+S).]

* Left side: Changes / History

Now I switch back to GitHub Desktop.

[On screen: Bring GitHub Desktop to the front. Click on the Changes tab.]

You’ll see that GitHub Desktop has detected that I changed a file. The file appears in the Changes list on the left. The Changes tab shows all files you’ve modified but not yet committed.

[On screen: Click the History tab briefly.]

The History tab shows past commits with messages, dates, and who made them. This is the entire history of every change I made - and committed to - on this repository. This is Git’s “time machine” that allows me to go back to any point in time to see what I was doing. And, if necessary, I can revert to that version of the code. With Git, nothing is ever lost as long as you make commits.

* Center pane (diff)

[On screen: Click the changed file in the Changes list.]

When you click on a file in the Changes list, the center shows the changes you've made. Removed lines are highlighted in red and added lines are highlighted in green.

[On screen: Point with the mouse to the newly added line in the diff.]

This shows exactly what your are changing relative to your most recent commit.

* Bottom left: Commit box

[On screen: Move the mouse to the “Summary” and “Description” boxes.]

This is where you write a Summary and optional Description for your commit.

The button below (e.g., “Commit to <your-branch>”) creates the commit.

5. Making a commit (with a good summary)

Let’s commit to the change we just made.

In the Summary box, you should always write something short but meaningful.

A bad summary is “stuff” or “changes”. A better summary is “Add note to GitHub demo file”

[On screen: Click in the Summary box and type:
“Add note to GitHub demo file”.]

Once that looks good, I’ll click the commit button.

[On screen: Click “Commit to <your-branch>”.]

Notice that the file disappears from the Changes list, because there are no uncommitted changes now.

[On screen: Click the History tab and point at the new commit.]

If I click over to History, I can see the new commit with my summary.

That commit is now saved locally on my computer using Git.

6. Pushing the commit and seeing it on GitHub

Right now, Git knows about the change on my machine, but GitHub doesn’t.
To share it with GitHub, I need to push my commits.

[On screen: Switch back to the Changes tab if needed, then move the mouse to the top right.]

At the top right, you'll notice Fetch has changed to Push origin.

[On screen: Click “Push origin” (or “Publish branch” if it’s the first time).]

 I’ll click on that, which sends my new commit from my computer up to the remote repo on GitHub.

Now let’s see it on the GitHub website.

[On screen: Switch to your browser. In the address bar, go to https://github.com/jdavidm/semester26.]

This is the course repository on GitHub.

[On screen: Use the branch dropdown to switch to your personal branch.]

Make sure I’m on my branch, not main.

[On screen: Navigate through the folders to the file you edited and click it to open.]

You can see that the file I edited now includes the new text.

[On screen: Click on the “History” for that file or the repository’s “Commits” view, and point at the most recent commit.]

And the commit shows up in the commit history with the summary we wrote.

This is how Git and GitHub work together:

Git: tracks your changes locally, as commits.

GitHub: stores those commits in a repository online, where they’re backed up and shareable.

And GitHub Desktop is the tool we use to bridge between the two without having to type Git commands ourselves.

That’s the basic GitHub Desktop workflow we’ll use all semester:

[On screen: Go back to Desktop.]

Ensure you are on the correct repo and branch. Fetch any changes that might be on Github but not on your machine. 

Make changes in your files. Check them in GitHub Desktop. Write a clear commit summary and commit to those changes. And finally, push the commit to GitHub so it’s saved and shared.

We’ll build on this as we go, but if you can do these steps, you’ve got the core Git/GitHub skills you need for this course.