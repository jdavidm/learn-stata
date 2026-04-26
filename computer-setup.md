---
layout: page
title: Computer Setup
---

<a href="#Stata">Stata</a> \| <a href="#Slack">Slack Desktop</a> \| <a href="#GitHub">GitHub</a> \| <a href="#GitHubDesktop">GitHub Desktop</a> \| <a href="#GitBash">Git Bash</a> \| <a href="#GitLFS">Git Large File Storage</a> \| <a href="#Overleaf">Overleaf and LaTeX</a> \| <a href="#Java">Java</a>

***AAE 497A/597A students will need their own laptops set up with Stata before the first class meeting along with Github Desktop and Slack Desktop by week 2.***

## Stata <a name="Stata"></a>
Purchase a [6-month copy of Stata BE](https://www.stata.com/order/new/edu/profplus/student-pricing/) for $48. Stata will send you a license, username, and password to [download and install](https://download.stata.com/download/).

## Slack Desktop <a name="Slack"></a>
1. Download either [Slack for Windows](https://slack.com/downloads/windows) or [Slack for Mac](https://slack.com/downloads/mac).
2. Your instructor will send an invitation to join a Slack Workspace to your `@arizona.edu` email address.
3. Accept the invitation and join the workspace by creating a username.

## GitHub <a name="GitHub"></a>
1. Create an account on [GitHub](https://github.com) using the `Sign up for
   GitHub` form on the right side of the page.
2. Send your username to your instructor **via a direct message (DM) on Slack**.
3. Once your instructor adds you to the course GitHub repository you will
   receive an email asking you to accept the invitation. Click on the link to
   accept.
4. Check if this worked
    1. Go to [https://github.com](https://github.com).
    2. Sign in if necessary.
    3. In the upper left corner click on the dropdown with your name.
    4. Confirm that the name of the course GitHub repository is present


## GitHub Desktop <a name="GitHubDesktop"></a>
1. Download [Github Desktop](https://desktop.github.com/download/) and install it.
2. Check if the installation is working:
    1. If you have not already done so, Slack your username to your instructor. Once you have received a GitHub invite to the class organization accept it and only then proceed.
    2. On the GitHub course webpage, click the green code button.
    ![Clone button on Github repo]({{ site.baseurl }}/images/github_clone.png)
    3. From the dropdown menu select "Open with GitHub Desktop".
    4. In the pop up window on GitHub Desktop change the local path to `C:\Users\`your username`\git\`repo name`\`.
    5. Click "Clone"
    6. From the buttons along the top of GitHub Desktop, click "Fetch origin"
    ![Fetch origin button on Github Desktop]({{ site.baseurl }}/images/github_fetch.png)
    7. Once you have fetched the repo from the internet, click on the button "Current branch" and create a new branch and name it using your last name.
    ![Name new branch on Github Desktop]({{ site.baseurl }}/images/github_branch.png)
    8. Having created a new branch, you now need to publish it to the internet by click on the "Publish branch" button.
    ![Publish branch button on Github Desktop]({{ site.baseurl }}/images/github_publish.png)
    9. Once the branch is published, return to the course Github page and click on the "main" button and verify that your branch is listed in the dropdown menu.
    ![Verify new branch on Github repo]({{ site.baseurl }}/images/github_newbranch.png)

## Git Bash <a name="GitBash"></a>

**Git Bash** is a command-line application that lets you run Git commands on your computer. While GitHub Desktop provides a visual interface for common Git tasks, some operations — like configuring Git Large File Storage (below) — require typing commands in a terminal. Git Bash gives you a Unix-style terminal on Windows that understands Git commands.

**Mac users**: You do not need to install Git Bash. Your Mac already has a built-in Terminal application (found in Applications → Utilities → Terminal) that works the same way. macOS also comes with Git pre-installed. You can verify by opening Terminal and typing `git --version`.

**Windows users**:
1. Download Git for Windows from [https://git-scm.com/downloads/win](https://git-scm.com/downloads/win).
2. Run the installer. You can accept all the default settings — just click "Next" through each screen and then "Install."
3. Once installed, you can open Git Bash by searching for "Git Bash" in the Windows Start menu. You should see a dark terminal window with a blinking cursor.
4. Verify the installation by typing the following command and pressing Enter:
    ```
    git --version
    ```
    You should see output like `git version 2.47.1.windows.1` (the exact version number may differ). If you see an error instead, try restarting your computer and repeating this step.

## Git Large File Storage <a name="GitLFS"></a>

GitHub has a file size limit of 100 MB. **Git Large File Storage (Git LFS)** is an extension that lets you store large files — such as datasets (`.dta`, `.csv`), images, and other binary files — outside the main Git repository while still tracking them through Git. When you clone or pull a repository that uses Git LFS, the large files are downloaded automatically.

We use Git LFS in this course because some of our Stata datasets exceed GitHub's file size limit. Without Git LFS, you would not be able to push or pull these files.

**Prerequisites**: You must have Git Bash (Windows) or Terminal (Mac) installed before proceeding. See the [Git Bash](#GitBash) section above.

### Installing Git LFS

1. Download Git LFS from [https://git-lfs.com](https://git-lfs.com) and run the installer.

2. Open **Git Bash** (Windows) or **Terminal** (Mac) and run the following command to set up Git LFS on your computer:
    ```
    git lfs install
    ```
    You should see `Git LFS initialized` in the output. You only need to run this command once per computer.

### Configuring Git LFS for the course repository

After installing Git LFS, you need to tell Git which file types to track with LFS. Your instructor has already configured this for the course repository, so you should not need to do this step yourself. However, if you are setting up a new repository, here is how it works:

1. Open **Git Bash** (Windows) or **Terminal** (Mac).

2. Navigate to your repository folder. For example:
    ```
    cd /c/Users/your-username/git/repo-name
    ```

3. Tell Git LFS to track a file type. For example, to track all `.dta` files:
    ```
    git lfs track "*.dta"
    ```
    This creates (or updates) a `.gitattributes` file in your repository that tells Git which files should be handled by LFS.

4. Make sure to add and commit the `.gitattributes` file:
    ```
    git add .gitattributes
    git commit -m "Track .dta files with Git LFS"
    git push
    ```

For more information, see the [GitHub documentation on configuring Git LFS](https://docs.github.com/en/repositories/working-with-files/managing-large-files/configuring-git-large-file-storage).

## Overleaf and LaTeX <a name="Overleaf"></a>
1.  Create an account on [Overleaf](https://www.overleaf.com/) using using the `Sign up for
   free` on the center of the page.
2. Send your username to your instructor **via a direct message (DM) on Slack**.
3. Once your instructor adds you to the course Overleaf project you will
   receive an email asking you to accept the invitation. Click on the link to
   accept.
4. Go to the course Overleaf project and create a new `.tex` file by clicking on the "New File" icon on the far right just below the "Menu" button. Use your last name for the file name.
    ![Create new file in Overleaf]({{ site.baseurl }}/images/overleaf_new_file.png)
5. Go to the file `michler.tex` and copy everything in that file.
6. Paste the content that you copied into the file with your name.

## Java (for H2O Machine Learning) <a name="Java"></a>

Stata 19's `h2oml` commands (random forest, gradient boosting) require an H2O cluster, which runs on Java. You must install a **Java Runtime Environment (JRE)** before using H2O.

1. Check if Java is already installed by opening a terminal (Command Prompt on Windows, Terminal on Mac) and typing:
    ```
    java -version
    ```
    If you see a version number (e.g., `java version "17.0.x"`), Java is installed and you can skip to step 4.

2. If Java is not installed, download the latest JRE from [Adoptium (Eclipse Temurin)](https://adoptium.net/). Select the **LTS** version (currently Java 21) for your operating system and install it.

3. After installation, close and reopen your terminal, then run `java -version` again to confirm the installation succeeded.

4. In Stata, test that H2O can start by running:
    ```stata
    h2o init
    h2o shutdown
    ```
    If both commands execute without errors, Java and H2O are configured correctly. If you encounter errors, consult Stata's documentation on [H2O setup](https://www.stata.com/manuals/h2oh2o.pdf) or the [StataCorp YouTube video on H2O setup](https://www.youtube.com/watch?v=Y1aPrScIdtg).