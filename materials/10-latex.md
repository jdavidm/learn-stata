---
layout: page
element: notes
title: Introducing LaTeX via Overleaf
language: Stata
---

So far, all of our results — regressions, graphs, summary statistics — have been produced in Stata. But how do you present them in a professional document? In economics, the standard is **LaTeX** (pronounced "lay-tech" not "lah-tech"), a typesetting system designed for technical writing.

This lecture covers:
- What LaTeX is and why researchers use it
- The structure of a LaTeX document
- Formatting text: sections, bold, italic, lists
- Writing math in LaTeX
- Including figures from Stata
- Including tables from Stata (preview — we'll produce them next lecture)

### Why LaTeX?

Most academic papers, theses, and working papers in economics are written in LaTeX. Compared to Word:

- **Math** looks professional and is easy to type once you learn the syntax
- **Tables and figures** are included as code, so they update automatically when you re-run your analysis
- **Cross-references**, numbered equations, and bibliography entries are managed automatically
- **Formatting** is consistent — you focus on content, LaTeX handles layout
- **Bibliography** management is built-in via BibTeX

The tradeoff: LaTeX has a learning curve. But with Overleaf (a free, cloud-based LaTeX editor), you can get started without installing anything.

### The Overleaf workflow for this course

One nice thing about Overleaf is that you can connect it to your git repository. That way you run your code in Stata, export the results to the repo, and then Overleaf will automatically update with the new results. So when you update a regression or table in Stata, you can just re-compile your LaTeX document and the new results will be included.

However, you can only connect an Overleaf project to the `main` branch of a git repository. In our `semester26` repo you are all working on your own branches. So, for this course, we will need to add one additional step to the workflow, which is uploading your results to Overleaf (instead of having it automatically sync). The workflow is:

1. Run your Stata code → graphs and tables are exported to your branch on the `semester26` repo
2. Upload your graphs and tables to each week's results folder within your own folder in the Overleaf project `semester26 -597A`
3. In your `lastname.tex` file, you use `\input{}` or `\includegraphics{}` to pull in those results
4. Compile your document in Overleaf to produce a PDF

This means your results are **always reproducible**, though for this course you won't be able to fully automate this process. 

### Structure of a LaTeX document

Every LaTeX document has the same skeleton:

```latex
\documentclass{article}
\usepackage{graphicx}       % for including images
\usepackage{booktabs,calc}  % for nice table formatting
\usepackage{amsmath}        % for math environments
\usepackage{placeins}       % for figure and table placement

\title{AAE 497A/597A: Semester 2026}
\author{Your Name}
\date{}

\begin{document}

\maketitle

\section*{Assignment 10}

\subsection*{Exercise 1 - \LaTeX \ Formatting and Math}

\subsubsection*{1.1}
% your content goes here

\FloatBarrier
\subsection*{Exercise 2 - Inserting a Stata Figure}
% your content goes here

\end{document}
```

Key pieces:

- `\documentclass{article}` — tells LaTeX this is a standard article
- `\usepackage{...}` — loads extra features (like including graphics)
- `\begin{document}` ... `\end{document}` — everything between these is the actual content
- `\maketitle` — renders the title, author, and date
- `\section*{...}` — creates a section heading (the `*` suppresses numbering)
- `\FloatBarrier` — prevents floats (figures and tables) from moving across sections

### Formatting text

LaTeX formatting is done with commands, not menus:

```latex
% sections and subsections
\section{Introduction}
\subsection{Background}
\subsubsection{Details}

% bold and italic
This is \textbf{bold} and this is \textit{italic}.

% unordered list
\begin{itemize}
    \item First point
    \item Second point
\end{itemize}

% ordered list
\begin{enumerate}
    \item First step
    \item Second step
\end{enumerate}
```

Note that `%` is the comment character in LaTeX — everything after `%` on a line is ignored by the compiler.

### Math in LaTeX

This is where LaTeX really shines. You'll recognize these equations from our regression lectures.

Surround math with dollar signs to write it inline:

```latex
The regression model is $Y = \beta_0 + \beta_1 X + \varepsilon$.
```

This renders as: The regression model is *Y = β₀ + β₁X + ε*.

For stand-alone equations, use the `equation` environment:

```latex
\begin{equation}
    Y = \beta_0 + \beta_1 X + \varepsilon
\end{equation}
```

Or use `\[` ... `\]` for an unnumbered displayed equation:

```latex
\[
    Y = \beta_0 + \beta_1 X + \varepsilon
\]
```

#### Common math symbols

| Symbol | LaTeX code | What it is |
|---|---|---|
| β | `\beta` | Greek letter |
| ε | `\varepsilon` | Error term |
| β̂ | `\hat{\beta}` | Estimate (hat) |
| Ȳ | `\bar{Y}` | Mean (bar) |
| Σ | `\sum_{i=1}^{n}` | Summation |
| √ | `\sqrt{x}` | Square root |
| ≠ | `\neq` | Not equal |
| ≤ | `\leq` | Less than or equal |
| ∞ | `\infty` | Infinity |
| subscript | `X_i` | Subscript |
| superscript | `X^2` | Superscript |
| fraction | `\frac{a}{b}` | Fraction a/b |

> Do [Exercise 1 - LaTeX Formatting and Math]({{ site.baseurl }}/exercises/10-latex-format/)

### Including figures

When your Stata code exports a graph (e.g., `graph export "$answ/coefplot.png", replace`), that file lands in your repo and syncs to Overleaf. To include it in your document:

```latex
\begin{figure}[htbp]
    \centering
    \caption{Coefficient plot of yield regression}
    \label{fig:coefplot}
    \includegraphics[width=0.8\textwidth]{coefplot.png}
\end{figure}
```

Key elements:

- `[htbp]` — tells LaTeX where to try placing the figure (here, top, bottom, own page)
- `\centering` — centers the figure
- `[width=0.8\textwidth]` — scales the image to 80% of the text width
- `\caption{...}` — adds a caption abovethe figure
- `\label{fig:coefplot}` — creates a label so you can cross-reference with `Figure~\ref{fig:coefplot}`

> Do [Exercise 2 - Inserting a Stata Figure]({{ site.baseurl }}/exercises/10-latex-figure/)

### Including tables

When your Stata code exports a table with `esttab using "table.tex"` (covered in the estout lecture), the `.tex` file contains LaTeX code for the table. To include it:

```latex
\begin{table}[htbp]
    \centering
    \caption{Regression results: yield on inputs}
    \label{tab:yield_reg}
    \input{table.tex}
\end{table}
```

The `\input{}` command pastes the contents of `table.tex` directly into your document. This means:

- When you re-run your Stata code and the `.tex` file updates, your document updates too
- You don't need to copy-paste tables — just re-compile

We'll create these `.tex` files in the estout lecture.

### Common mistakes and tips

1. **Missing closing braces**: every `{` needs a `}`. Overleaf highlights errors in red
2. **Special characters**: `%`, `&`, `$`, `_`, `#` have special meanings in LaTeX. To print them literally, use `\%`, `\&`, `\$`, `\_`, `\#`
3. **Spaces after commands**: `\beta x` prints "βx" — if you want a space, use `\beta\ x` or `\beta{} x`
4. **Compile often**: small errors are easier to find if you compile after each change

### Summary

- LaTeX is the standard typesetting system for academic economics
- Overleaf gives you a free, cloud-based editor with real-time compilation
- Your `semester26` workflow: Stata exports → git repo → Overleaf → PDF
- Master the basics: document structure, sections, bold/italic, and math mode
- Figures go in with `\includegraphics{}`, tables with `\input{}`

Next lecture: producing publication-ready tables with `estout`.
