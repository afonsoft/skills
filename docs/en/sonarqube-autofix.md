# SonarQube Auto-Fix

An automated system for analyzing SonarQube issues and producing approved SPEC SDDs with the proposed fixes.

## 🎯 Purpose

Bridge the gap between automated static analysis and executable specifications. It transforms a list of bugs, code smells, and vulnerabilities into approved SPEC SDDs that `execute-tdd-spec` implements.

## 🛠️ How it Works

1. **Stack Detection**: Identifies the project's language and build tools.
2. **Issue Extraction**: Downloads unresolved issues from SonarQube via API.
3. **Classification**: Groups issues by type: `bug`, `code smell`, or `security`.
4. **SPEC Generation**: Writes one approved `.specs/SPEC-{YYYYMMDD}-{issue-key}-{type}.md` per issue using `references/spec-sdd-template.md`.
5. **Hand-off**: Invokes `execute-tdd-spec` to implement each SPEC with tests and coverage.

## 🚀 Usage

Use this skill when a SonarQube report exists and you need the fixes formalized as SPECs before implementation. It is normally invoked by `code-review-and-quality` when the repository has SonarQube configured.

## 🔗 Correlation

- **Trigger**: `code-review-and-quality` calls this skill when it detects a SonarQube configuration.
- **Implementation**: Delegates the actual fix to `execute-tdd-spec`.
- **Sibling**: `quality-test-implementation` handles whole-repo quality without SonarQube.
