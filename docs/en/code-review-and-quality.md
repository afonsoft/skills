# Code Review and Quality
This skill provides a structured, multi-axis framework for reviewing code changes to ensure professional quality before they reach the main branch.

## 🎯 Purpose
Prevent regressions, security vulnerabilities, and technical debt by evaluating every change across five critical dimensions: **Correctness, Readability, Architecture, Security, and Performance**.

## 🛠️ How it Works
The skill enforces a "Quality Gate" where no change is approved unless it improves the overall health of the codebase. It moves beyond "LGTM" (Looks Good To Me) to a rigorous checklist:
- **Correctness**: Does it actually solve the problem and handle edge cases?
- **Readability**: Is the code simple enough for others to maintain?
- **Architecture**: Does it fit the system design without introducing coupling?
- **Security**: Are there vulnerabilities or leaked secrets?
- **Performance**: Are there N+1 queries or unbounded loops?

## 🚀 Usage
Use this skill at the end of any implementation phase or when reviewing a Pull Request. The agent will categorize findings as **Critical**, **Required**, **Optional**, or **Nit**, ensuring that the author knows exactly what must be fixed versus what is a suggestion.

## 🔗 Correlation
- **Prerequisite**: Use `create-agent-harness` to set up the `review` sub-agent.
- **Companion**: Complements `sonarqube-autofix` for automated quality auditing.
