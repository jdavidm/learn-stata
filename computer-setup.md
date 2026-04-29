---
layout: page
title: Computer Setup
---

<a href="#Stata">Stata</a> \| <a href="#Slack">Slack Desktop</a> \| <a href="#GitHub">GitHub</a> \| <a href="#GitHubDesktop">GitHub Desktop</a> \| <a href="#GitBash">Git Bash</a> \| <a href="#GitLFS">Git Large File Storage</a> \| <a href="#Java">Java and H2O</a> \| <a href="#Overleaf">Overleaf and LaTeX</a>

***AAE 497A/597A students will need their own laptops set up with Stata before the first class meeting along with Github Desktop and Slack Desktop by week 2.***

## Stata <a name="Stata"></a>
Purchase a [6-month copy of Stata BE](https://www.stata.com/order/new/edu/profplus/student-pricing/){:target="_blank"} for $48. Stata will send you a license, username, and password to [download and install](https://download.stata.com/download/){:target="_blank"}.

## Slack Desktop <a name="Slack"></a>
1. Download either [Slack for Windows](https://slack.com/downloads/windows){:target="_blank"} or [Slack for Mac](https://slack.com/downloads/mac){:target="_blank"}.
2. Your instructor will send an invitation to join a Slack Workspace to your `@arizona.edu` email address.
3. Accept the invitation and join the workspace by creating a username.

## GitHub <a name="GitHub"></a>
1. Create an account on [GitHub](https://github.com){:target="_blank"} using the `Sign up for
   GitHub` form on the right side of the page.
2. Send your username to your instructor **via a direct message (DM) on Slack**.
3. Once your instructor adds you to the course GitHub repository you will
   receive an email asking you to accept the invitation. Click on the link to
   accept.
4. Check if this worked
    1. Go to [https://github.com](https://github.com){:target="_blank"}.
    2. Sign in if necessary.
    3. In the upper left corner click on the dropdown with your name.
    4. Confirm that the name of the course GitHub repository is present


## GitHub Desktop <a name="GitHubDesktop"></a>
1. Download [Github Desktop](https://desktop.github.com/download/){:target="_blank"} and install it.
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

Git Bash is a command-line application that lets you run Git commands on your computer by typing them into a terminal window. While GitHub Desktop provides a visual interface for common Git tasks, some operations — like setting up Git Large File Storage (below) — require typing commands directly. Git Bash gives you a terminal on Windows that understands Git commands.

**Mac users**: You do not need to install Git Bash. Your Mac already has a built-in Terminal application (found in Applications → Utilities → Terminal) that works the same way. macOS also comes with Git pre-installed.
1. Open Terminal (Applications → Utilities → Terminal).
2. Type `git --version` and press Enter.
3. You should see output like `git version 2.39.5`. If you see this, you are ready to proceed to [Git Large File Storage](#GitLFS).

**Windows users**:
1. Go to [https://git-scm.com/downloads/win](https://git-scm.com/downloads/win){:target="_blank"}.
2. Click the download link for your system (64-bit is most common). Save the installer to your computer.
3. Run the installer. Accept all the default settings — just click "Next" through each screen and then click "Install."
4. Once installed, open Git Bash by clicking the Windows Start menu and searching for "Git Bash." Click on it. You should see a dark terminal window with a blinking cursor.
5. Type the following command and press Enter:
    ```
    git --version
    ```
6. You should see output like `git version 2.47.1.windows.1` (the exact number may differ). If you see this, Git Bash is installed correctly. If you see an error, restart your computer and try again from step 4.

## Git Large File Storage <a name="GitLFS"></a>

GitHub has a file size limit of 100 MB. Some of the Stata datasets we use in this course are larger than that, so we need a way to handle them. **Git Large File Storage (Git LFS)** is an extension that stores large files (like `.dta` datasets) outside the main repository while still letting you push and pull them through GitHub Desktop as usual. You need to install Git LFS so that these large files download correctly when you clone or pull the course repository.

1. Go to [https://git-lfs.com](https://git-lfs.com){:target="_blank"} and click the **Download** button.
2. Run the installer. Accept all default settings.
3. Open **Git Bash** (Windows) or **Terminal** (Mac).
4. Type the following command and press Enter:
    ```
    git lfs install
    ```
5. You should see the message `Git LFS initialized`. This means Git LFS is set up on your computer. You only need to run this command once.
6. Now navigate to your course repository folder. In Git Bash, type:
    ```
    cd /c/Users/your-username/git/repo-name
    ```
    Replace `your-username` with your Windows username and `repo-name` with the name of the course repository folder. On Mac, the path will look like `cd ~/git/repo-name`.
7. Tell Git LFS to track `.dta` files by typing:
    ```
    git lfs track "*.dta"
    ```
8. You should see the message `Tracking "*.dta"`. This creates a file called `.gitattributes` in your repository that tells Git which files to handle with LFS.
9. Add and commit the `.gitattributes` file:
    ```
    git add .gitattributes
    git commit -m "Track dta files with Git LFS"
    git push
    ```
10. Your instructor may have already completed steps 7–9 for the course repository. If you see a message that `.gitattributes` already exists or that `*.dta` is already tracked, that is fine — you are all set.

## Java and H2O Setup (for Machine Learning) <a name="Java"></a>

Stata 19's `h2oml` commands (random forest, gradient boosting) require two things to be installed on your computer: **Java** and the **H2O machine learning library**. Follow all the steps below.

### Step A — Install Java

1. Check if Java is already installed. Open **Git Bash** (Windows) or **Terminal** (Mac) and type:
    ```
    java -version
    ```
2. If you see a version number (e.g., `java version "17.0.12"` or `openjdk version "21.0.4"`), Java is already installed. Skip ahead to **Step B**.
3. If you see an error like `'java' is not recognized` or `command not found`, you need to install Java. Go to [https://adoptium.net/](https://adoptium.net/){:target="_blank"}.
4. The website should automatically detect your operating system. Click the large download button for the **Latest LTS Release** (currently Java 21). Save the installer to your computer and run it. Accept all the default settings.
5. After installation, close and reopen Git Bash (or Terminal), then type `java -version` again. You should now see a version number. If you still see an error, restart your computer and try again.

### Step B — Download the H2O library

6. Go to the H2O download page: [https://h2o.ai/resources/download/](https://h2o.ai/resources/download/){:target="_blank"}.
7. Under **H2O Open Source**, click the **Download H2O** button. This will download a `.zip` file (the file name will look something like `h2o-3.46.0.10.zip`). Save it somewhere easy to find, like your Downloads folder.
8. Unzip the file. On Windows, right-click the `.zip` file and select "Extract All..." On Mac, double-click the `.zip` file.
9. Open the unzipped folder. Inside, you will see a file named `h2o.jar`. This is the only file you need from this folder.

### Step C — Place `h2o.jar` where Stata can find it

10. Open Stata. In the Command window, type:
    ```stata
    sysdir
    ```
11. Stata will display a list of directory paths. Look for the one labeled **PLUS**. It will look something like:
    - **Windows**: `C:\ado\plus\`
    - **Mac**: `/Users/yourusername/ado/plus/`
12. Open that folder in File Explorer (Windows) or Finder (Mac). If the folder does not exist, create it.
13. Inside the PLUS folder, create a new folder called `jar`. The result should be:
    - **Windows**: `C:\ado\plus\jar\`
    - **Mac**: `/Users/yourusername/ado/plus/jar/`
14. Copy the `h2o.jar` file (from step 9) into this `jar` folder.

### Step D — Test that everything works

15. In Stata, type the following command in the Command window:
    ```stata
    h2o init
    ```
16. Wait for Stata to display a message confirming that the H2O cluster has started. You should see output that includes "H2O cluster up" or similar. If you see an error about `h2o.jar not found`, go back to steps 10–14 and make sure the `h2o.jar` file is in the correct `jar` folder inside your PLUS directory.
17. Once the cluster has started, shut it down by typing:
    ```stata
    h2o shutdown
    ```
18. If both commands run without errors, Java and H2O are configured correctly and you are ready for the machine learning assignments.

## Overleaf and LaTeX <a name="Overleaf"></a>
1.  Create an account on [Overleaf](https://www.overleaf.com/){:target="_blank"} using using the `Sign up for
   free` on the center of the page.
2. Send your username to your instructor **via a direct message (DM) on Slack**.
3. Once your instructor adds you to the course Overleaf project you will
   receive an email asking you to accept the invitation. Click on the link to
   accept.
4. Go to the course Overleaf project and create a new `.tex` file by clicking on the "New File" icon on the far right just below the "Menu" button. Use your last name for the file name.
    ![Create new file in Overleaf]({{ site.baseurl }}/images/overleaf_new_file.png)
5. Go to the file `michler.tex` and copy everything in that file.
6. Paste the content that you copied into the file with your name.
