---
layout: page
title: Computer Setup
---

***AAE 497A/597A students will need their own laptops set up with Stata before the first class meeting along with Github Desktop and Slack Desktop by week 2.***

## Stata
Purchase a [6-month copy of Stata BE](https://www.stata.com/order/new/edu/profplus/student-pricing/) for $48. Stata will send you a license, username, and password to [download and install](https://download.stata.com/download/).

## Slack Desktop
1. Download either [Slack for Windows](https://slack.com/downloads/windows) or [Slack for Mac](https://slack.com/downloads/mac).
2. Your instructor will send an invitation to join a Slack Workspace to your `@arizona.edu` email address.
3. Accept the invitation and join the workspace by creating a username.

## GitHub
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


## GitHub Desktop
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

## Overleaf and LaTeX
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

## Java (for H2O Machine Learning)

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