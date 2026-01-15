In this video I’m going to walk you through how to *finish* and *turn in* an assignment using GitHub, step by step.

---

### 1. Start with the assignment submission checklist

First, once you think you’re done with an assignment, **do not** jump straight to GitHub.

Instead, go to:

`jdavidm.github.io/learn-stata/materials/turn-in-checklist/`

[On screen: open this page in a browser.]

Quickly work through that checklist for your `.do` file. Things like:

* Does the file run top to bottom without errors?
* Are the comments clear?
* Are any file paths correct and reproducible?

Get in the habit of using this checklist **every time** before you turn something in.

---

### 2. Save your assignment in the right place, on your branch

Now let’s save the assignment file in the course repo.

[On screen: show Stata with your `.do` file.]

I’ll save this file into my **local copy** of the course repo, inside a folder called `assignments`.

The naming convention is:

* `assignment_X.do`
  where **X is the assignment number**
  For example: `assignment_1.do`, `assignment_2.do`, and so on.

[On screen: File → Save As → navigate to repo → `assignments` → save as `assignment_1.do`.]

Now I switch to **GitHub Desktop**.

Very important:
Make sure you are on **your personal branch**, **not** on `main`.

[On screen: show the branch dropdown and point out that it should have the student’s branch name, not `main`.]

All of your commits for this course should go to **your branch**.

---

### 3. Commit your changes and push to the remote repo

In GitHub Desktop, you should now see changes in the **Changes** tab, including the new or updated `assignment_X.do` file.

[On screen: click the file to show the diff.]

In the **Summary** box at the bottom left, write a clear message, for example:

> “Finish assignment 1”

Then click:

[On screen: click **“Commit to `<your-branch>`”** and point out that the button shows *your branch name*, not `main`.]

That saves the snapshot **locally** on your branch.

Next, we need to send it to GitHub.

At the top right, click:

[On screen: click **“Push origin”**.]

This pushes the commit on **your branch** to the **remote repo** at:

`github.com/jdavidm/semester26`

---

### 4. Tag your submission on GitHub

Now let’s tag the submission so I can easily find and grade it.

[On screen: open `github.com/jdavidm/semester26` in a browser and switch to the student’s branch or the relevant issue/PR for the assignment.]

For this course, we use **labels** on GitHub to mark assignments.

On your assignment submission page (this might be an issue or a pull request, depending on how the course is set up), add the **`submission`** label.

[On screen: show the Labels panel and select the `submission` label.]

This tells me: *“This is ready to grade.”*

---

### 5. Add `late` and `challenge` labels if needed

We also use labels to indicate whether the assignment was late and whether you completed the challenge problems.

On that same page:

* Add the **`late`** label if you turned it in after the deadline.
* Add the **`challenge`** label if you completed the optional challenge section.

You can apply **multiple labels at the same time**.
So a single submission might have: `submission`, `late`, and `challenge`.

---

That’s the whole workflow:

1. Use the **turn-in checklist**
2. Save your `.do` file as `assignment_X.do` in the `assignments` folder
3. **Commit to your own branch**, not `main`
4. **Push** your branch to GitHub
5. Label your submission with `submission`, plus `late` and `challenge` if they apply

If you follow these steps each time, your work will be organized, graded correctly, and easy for both of us to track.
