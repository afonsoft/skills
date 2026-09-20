# Create Agent Harness
The fundamental skill for bootstrapping a professional AI agent environment in any repository.

## 🎯 Purpose
Implement the "Agent = Model + Harness" principle. It transforms a raw repository into an AI-ready workspace by creating a system of feedforward (instructions) and feedback (validation) loops.

## 🛠️ How it Works
The skill follows a strict evidence-based workflow:
1. **Discovery**: Analyzes the repo's tech stack, architecture, and conventions.
2. **Artifact Generation**: Creates critical files:
   - `CLAUDE.md`: The Single Source of Truth.
   - `.claude/rules/`: Domain-specific guardrails.
   - `.claude/skills/`: Specialized behavioral guides.
   - `.claude/agents/`: Specialized sub-agents (Engineer, Plan, Review, Test, Architecture), each wired to its skill (`orchestrator`, `write-specs`, `qa-analyst` + `code-review-and-quality`, `quality-test-implementation`, `architecture`).
3. **Validation**: Ensures all artifacts are consistent and permissions are secure.

## 🚀 Usage
Run this skill first in any new project. It ensures that the agent doesn't "hallucinate" conventions but follows the actual evidence found in the code.

## 🔗 Correlation
- **Foundation**: This is the root skill. All other skills in the collection (like `code-review-and-quality`) are intended to be placed inside the `skills/` directory created by this harness.
- **Workflow**: It establishes the sub-agent patterns that `code-review-and-quality` depends on.
