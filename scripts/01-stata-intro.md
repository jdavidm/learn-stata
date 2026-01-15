# Intro to the Stata Interface (GUI) – Video Script

[On screen: Launch Stata so the default layout is visible.]

When you first open Stata, it can look a little busy, so in this short video I just want to give you a tour of the main pieces of the interface.  
We’re **not** going to learn how to code yet—just what’s what on the screen.

---

## 1. The main Stata window

[On screen: Move the mouse slowly around the whole window.]

Stata’s main window is divided into several panes. Let’s start with the ones you’ll use all the time.

### Results window

[On screen: Point to the large top-center pane.]

This big pane in the middle is the **Results window**.  
Any time you run a command or an analysis, the output shows up here: regression tables, descriptive statistics, error messages—everything Stata is telling you.

### Command window

[On screen: Move the mouse to the narrow box at the very bottom.]

Down here is the **Command window**.  
This is where you can type a single Stata command and press Enter to run it.

Later in the course, most of your work will be in `.do` files, but this box is great for quick tests or one-off commands.

### History / Review window

[On screen: Point to the left-hand pane with the list of commands.]

Over on the left is the **History** (or **Review**) window.  
This keeps a running list of everything you’ve asked Stata to do in this session.

- You can scroll back through previous commands.  
- Double-click any command to run it again.  
- Or copy a command from here into a `.do` file so you don’t have to retype it.

### Variables window

[On screen: Point to the upper-right pane listing variable names, if data are loaded.]

On the right at the top is the **Variables** window.  
Once you’ve loaded a dataset, every variable will show up here.

Clicking on a variable lets you:

- Insert its name into a command.  
- See some basic information about it.  

We’ll use this a lot to remind ourselves what variables are available.

### Properties window

[On screen: Point just below the Variables window.]

Below that is the **Properties** window.  
This shows details about whatever you’ve selected—like:

- The label of a variable  
- Its type (numeric, string, etc.)  
- Its display format  

It’s the “details panel” for whatever you’re working with.

---

## 2. Do-file Editor and project pieces

[On screen: Click the Do-file Editor button to open it.]

Now let’s talk about where you’ll actually **write** your code.

This window is the **Do-file Editor**. It’s just a text editor built into Stata, and it’s where you’ll write and save your Stata code in `.do` files.

[On screen: Click inside the Do-file Editor, maybe type a simple comment like `* my first do-file`.]

In this course:

- You’ll write your real work in `.do` files here.  
- These `.do` files are what you’ll turn in for assignments.  

So think of it this way:

- **Do-file Editor** = where you *write* your work  
- **Results window** = where you *see the output* from that work

---

## 3. Data Editor / Browser

[On screen: Click the Data Editor (grid) button to open it.]

Stata also has a **Data Editor/Browser**, which looks like a spreadsheet.

- Each **row** is an observation.  
- Each **column** is a variable.

You can use it in:

- **Browse mode**, where you safely look at the data  
- **Edit mode**, where you can change values directly

For this class, we’ll mostly use it to **look at** data, not to manually edit everything by hand.

[On screen: Scroll a bit so students see rows and columns, then close the Data Editor.]

---

## 4. Viewer and Graph windows

[On screen: Open a help file, e.g., Help → Search or Help for any command.]

This window is the **Viewer**. Stata uses it for help files and documentation.

Whenever you ask for help on a command, it will open here with:

- A description of what the command does  
- The syntax  
- Examples you can copy and try

Later, when we make graphs, Stata will also open a **Graph window**, and you can use the **Graph Editor** to tweak titles, labels, and other formatting.

---

## 5. Quick recap

[On screen: Return to the main Stata layout and briefly point to each area as you name it.]

To recap, here are the main pieces of Stata’s interface:

- **Results window** – where output appears  
- **Command window** – where you can run one-line commands  
- **History/Review window** – past commands you can reuse  
- **Variables & Properties** – see and inspect variables and details  
- **Do-file Editor** – where you write and save `.do` files  
- **Data Editor/Browser** – spreadsheet-style view of your data  
- **Viewer & Graph windows** – help files and graphs

That’s all for this intro.  
In the next videos, we’ll start actually using these pieces to load data and run commands, but for now you should have a mental map of what you’re looking at when Stata opens.
