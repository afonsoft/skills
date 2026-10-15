# Community Evolution: Experience in Contributing to the Main Repository

## Mechanism Description

Each time you complete a project and generate a field-journal entry, the AI will ask:

```
✅ Experience has been recorded in field-journal/

📤 Do you want to contribute this experience to the community main repository?
- The data has been desensitized according to the template requirements (domain/IP/Token/PII has been replaced)
- Only submit new files in the field-journal/ directory
- Will not submit your private files such as tool-index, scope, findings, etc.
- After contributing, other users can also reuse your experience

'Reply' is 'Submit, Reply'; 'No' is 'Skip'.
```

## Contribution Process

```text
1. AI-generated field-journal entries (anonymized)
2. AI asks the user whether to contribute
3. The user agrees → AI performs the following steps:
a. Check whether desensitization is complete (double-check that there are no real domain names /IP/Token)
b. Check whether it duplicates existing entries in the main repository (read-only _index.md, ~200 tokens)
c. If not duplicated → create a PR to the main repository
d. PR title format: [field-journal] YYYY-MM-DD Scene Type - Keywords
4. GitHub Actions Automatic Review:
- ✓ Only modified field-journal/*.md
- ✓ No prompt injection characteristics
- ✓ No unsanitized API key/token
- ✓ No executable code
- ✓ File size < 50KB
5. Approval → Automatic merge (no manual operation required by the repository maintainer)
6. Review failed → Automatically comment explaining the reason, PR remains open waiting for correction
```

### Security Assurance

| Threat | Protection |
|------|------|
| Modify non-journal files | Actions check changed files whitelist |
| Prompt injection | Regex detection of features like "ignore previous" / "you are now" |
| Malicious Code Obfuscation | Detect `#!/`, `import`, `exec(`, `eval(`, etc. |
| Non-masked token | Regex detection AWS key/npm token/GitHub token pattern |
| Garbage Data | Single File 50KB Limit |
| Large number of junk PRs | GitHub comes with rate limit + can add CODEOWNERS review |

## Technical Implementation

### Method 1: GitHub CLI (Recommended)

```bash
# 1. Fork the main repository (if you haven't forked it yet)
gh repo fork &lt;你的GitHub用户名&gt;/&lt;仓库名&gt; --clone=false

# 2. Create a contribution branch locally
git checkout -b contribute/journal-YYYY-MM-DD-keyword

# 3. Only add field-journal files
git add references/field-journal/YYYY-MM-DD_*.md
git add references/field-journal/_index.md

# 4. Submit
git commit -m "[field-journal] 场景类型: 关键词摘要"

# 5. Push to fork
git push origin contribute/journal-YYYY-MM-DD-keyword

# 6. Create PR
gh pr create --repo &lt;你的GitHub用户名&gt;/&lt;仓库名&gt; \
--title "[field-journal] YYYY-MM-DD Scene Type - Keywords"
  --body "## 贡献内容\n- 场景：xxx\n- 关键词：xxx\n- 脱敏确认：✓\n\n## 数据安全声明\n本条目已按模板要求完成脱敏，不包含真实目标信息。"
```

### Method 2: Direct Push (if the user has write access to the main repository)

```bash
git checkout -b contribute/journal-YYYY-MM-DD-keyword
git add references/field-journal/YYYY-MM-DD_*.md
git add references/field-journal/_index.md
git commit -m "[field-journal] 场景类型: 关键词摘要"
git push origin contribute/journal-YYYY-MM-DD-keyword
gh pr create --repo &lt;你的GitHub用户名&gt;/&lt;仓库名&gt; \
--title "[field-journal] YYYY-MM-DD Scene Type - Keywords"
--body "Desensitization Confirmation: ✓"
```

## Deduplication Rules (Low Token Consumption)

Before submission, AI only **needs to read the `_index.md` file** for deduplication, and does not need to read the full content of each journal entry.

### Deduplication Process

```text
1. Read field-journal/_index.md from the main repository (usually only a few dozen lines)
2. Extract the following for this entry: Scene classification + Keyword list
3. Search for existing entries in similar scenarios in _index.md
4. Keyword Matching:
- Overlapping ≥ 3 keywords → considered duplicate, do not submit
- Overlap 1-2 keywords → might be a variant, can submit
- No overlap → Completely new scenario, submit directly
```

### Why is this enough

- The xKx0000xKx format is fixed: xKx0001xKx
- Each item is only one line, 100 tips would just be 100 lines
- AI only needs to perform string matching, without needing to understand the full content
- Token consumption: Reading _index.md ≈ 200-500 tokens (vs reading all journals ≈ 10,000+ tokens)

### If _index.md is not available

If the main repository's _index.md cannot be obtained (due to network issues, etc.), submit directly, and the maintainer of the main repository will manually remove duplicates.

## Only Allowed Files to Submit

**Whitelist** (only these files can appear in the PR):
- xKx0002xKx (new experience entry)
- xKx0003xKx (Index Update)

**Blacklist** (must never appear in PR):
- xKx0004xKx (including the user's local path)
- xKx0005xKx (including target information)
- xKx0006xKx (including vulnerability details)
- xKx0007xKx (including operation records)
- xKx0008xKx (User Configuration)
- xKx0009xKx (User Configuration)
- Any xKx0010xKx, xKx0011xKx, xKx0012xKx files

## Secondary Desensitization Check

AI must scan the files to be submitted before submission to ensure they do not contain:

- [ ] Real domain name (not xKx0013xKx/xKx0014xKx)
- [ ] Real IP (not xKx0015xKx/xKx0016xKx)
- [ ] xKx0017xKx Key Original Text
- [ ] Phone number / Email / Username (Original Text)
- [ ] Company xKx0018xKx name (if it is an SRC target)

If any item is found to be not desensitized, stop submitting and prompt the user to make corrections.

## Value to Users

- The experience you contribute will help other users avoid falling into the same pitfalls
- The richer the main repository's field journal, the smarter the AI for all users.
- Your contributions will be retained in _index.md (anonymous, only scenes and keywords)