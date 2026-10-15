---
name: diagram-generator
description: generate, refine, validate, and render diagrams from natural language, notes, code snippets, schemas, tables, or existing diagram source. use for flowcharts, swimlanes, sequence diagrams, state diagrams, er diagrams, class diagrams, architecture/c4-style diagrams, dependency graphs, gantt charts, mind maps, user journeys, sankey-style flows, org charts, network graphs, and other visual models. supports mermaid by default, graphviz dot for complex graph layout, plantuml for uml-heavy engineering diagrams, and svg output when direct markup is more reliable.
---

# Diagram Generator

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Confirm whether the current task falls within the applicable scope of this skill
2. `NOW`: Read `../tool-index.md`, check tool availability and actual path
3. `NEXT`: Call bootstrap when tools are missing, don't guess the path
4. `ACT`: Enter the first step of the 'workflow' and execute, do not stay in the confirmation state

## Purpose

Create clear, editable diagrams from messy or structured inputs. Prefer text-based diagram source first so the result can be reviewed, versioned, and refined. Render to files only when the user asks for an xKx0005xKx or when a downloadable artifact would materially help.

## Default workflow

1. Identify the user's intent, audience, and source material.
2. Choose the diagram family and language using the decision table below.
3. Normalize entities, relationships, labels, states, branches, and xKx0006xKx information before writing diagram code.
4. Generate concise, readable diagram source.
5. Validate the syntax mentally and, when creating files, run xKx0007xKx.
6. Return the diagram source plus a short note about assumptions. When files are generated, include links to the output files.

Do not over-ask for clarification. If the request is underspecified, make reasonable assumptions and label them briefly.

## Diagram language decision table

Use Mermaid unless another language is clearly better.

| User wants | Prefer | Why |
|---|---|---|
| process flow, decision tree, simple swimlane | Mermaid flowchart | readable and easy to paste into Markdown |
| sequence of xKx0008xKx interactions | Mermaid sequenceDiagram or PlantUML sequence | Mermaid for docs; PlantUML for UML formality |
| lifecycle, state machine, transitions | Mermaid stateDiagram-v2 or PlantUML state | compact transition syntax |
| database schema, entities, relationships | Mermaid erDiagram | portable ER notation |
| xKx0009xKx model | Mermaid classDiagram or PlantUML class | Mermaid for docs; PlantUML for detailed UML |
| project schedule | Mermaid gantt | concise timeline syntax |
| hierarchy, ideas, notes | Mermaid mindmap | good default for idea maps |
| xKx0010xKx journey | Mermaid journey | built-in journey notation |
| git history | Mermaid gitGraph | built-in git notation |
| dependency graph, package graph, large network | Graphviz DOT | better layout engines for dense graphs |
| architecture with layers, clusters, boundaries | Mermaid flowchart with subgraphs, Graphviz clusters, or PlantUML C4-style | choose based on requested fidelity |
| weighted xKx0011xKx relationship | Mermaid sankey-beta when supported, otherwise SVG or Graphviz | Mermaid support may vary by renderer |
| custom visual where source languages fit poorly | SVG | precise control over layout and styling |

## Output policy

- Always provide editable source unless the user explicitly asks only for an image.
- Default to a single best diagram. Offer alternatives only when genuinely useful.
- Prefer stable, simple syntax over fancy features that may not render in older xKx0012xKx versions.
- Use short labels. Split long text into notes outside the diagram when needed.
- Avoid ambiguous node IDs. Use ASCII IDs and human-readable labels.
- Preserve user terminology, but standardize capitalization within a diagram.
- For technical diagrams, include boundaries such as client, service, database, queue, external API, and xKx0013xKx when they are implied.
- For business-process diagrams, distinguish happy path, decision points, failures, retries, and manual steps when present.
- For diagrams created from uncertain text, include an xKx0014xKx section after the code.

## Mermaid generation rules

Consult xKx0015xKx for compact templates.

General Mermaid rules:
- Start with the correct diagram directive, for example xKx0016xKx, xKx0017xKx, xKx0018xKx, xKx0019xKx, xKx0020xKx, or xKx0021xKx.
- For flowcharts, use xKx0022xKx unless the user asks for left-to-right; use xKx0023xKx for architecture and pipelines.
- Use subgraphs for swimlanes or architecture layers. Name subgraphs with readable labels.
- Keep node IDs stable and ASCII-only, for example xKx0024xKx.
- Quote labels that contain punctuation likely to confuse the parser.
- Use decision diamonds for branching: xKx0025xKx.
- Use consistent edge labels: xKx0026xKx, xKx0027xKx, xKx0028xKx, or xKx0029xKx only when meaningful.
- In sequence diagrams, declare participants before messages. Use xKx0030xKx for humans and xKx0031xKx for systems.
- Use xKx0032xKx, xKx0033xKx, xKx0034xKx, and xKx0035xKx blocks for conditional, optional, repeated, and parallel flows.

## Graphviz DOT generation rules

Use Graphviz for large, dense, or layout-sensitive relationship diagrams.

- Prefer xKx0036xKx for directed relationships and xKx0037xKx for undirected networks.
- Set layout-friendly graph attributes at the top: xKx0038xKx, xKx0039xKx, xKx0040xKx, and xKx0041xKx when helpful.
- Use xKx0042xKx for boundaries and subsystems.
- Use plain labels and restrained styling.
- Use edge labels only when they add meaning.
- For many nodes, group by domain with clusters and avoid crossing-heavy all-to-all edges.

## PlantUML generation rules

Use PlantUML when the user asks for UML or needs formal UML notation.

- Wrap diagrams with xKx0043xKx and xKx0044xKx.
- Use xKx0045xKx, xKx0046xKx, xKx0047xKx, xKx0048xKx, xKx0049xKx, or xKx0050xKx stereotypes when useful.
- Use xKx0051xKx, xKx0052xKx, or xKx0053xKx for architecture boundaries.
- For class diagrams, include only important xKx0054xKx unless the user asks for exhaustive detail.
- For activity diagrams, use clear xKx0055xKx markers and explicit branch labels.

## SVG generation rules

Use SVG only when text diagram languages cannot express the requested visual reliably.

- Keep SVG simple, accessible, and editable.
- Include xKx0056xKx and meaningful text labels.
- Prefer rectangles, lines, arrows, and groups over complex paths.
- Do not embed external fonts or remote images.

## Rendering files

When the user asks for xKx0057xKx, create a source file and run:

```bash
python "<SKILL_ROOT>/diagram-generator/scripts/render_diagram.py" input.mmd --format svg --out output.svg
python "<SKILL_ROOT>/diagram-generator/scripts/render_diagram.py" input.dot --format png --out output.png
python "<SKILL_ROOT>/diagram-generator/scripts/render_diagram.py" input.puml --format svg --out output.svg
```

> `<SKILL_ROOT>` is the actual path of the `references/` directory in this package, and AI should detect it automatically.

The renderer is intentionally dependency-tolerant. It tries common local tools and reports actionable installation hints if a renderer is unavailable. Do not claim an image was rendered unless the script completed successfully and the output file exists.

## Validation checklist

Before finalizing:

- The diagram type matches the user's task.
- The source is syntactically plausible for the chosen language.
- Labels are short enough to fit.
- Edges and message order reflect the input accurately.
- Assumptions are called out when the input was incomplete.
- For generated files, the output exists and opens or has nonzero size.

## Common response template

Use this structure for most diagram answers:

```markdown
Below is the editable [language] version:

```[language]
[source]
```

Assumptions:
- [only if needed]

Rendered file: [link] [only if generated]
```

For English user requests, respond in English. For Chinese user requests, respond in Chinese unless they ask otherwise.

---

## On-Demand Bootstrap

### Automation Capability Boundaries

| Tool | Can be installed automatically | Installation method | Description |
|------|-----------|---------|------|
| Mermaid CLI (mmdc) | ✓ | npm install -g @mermaid-js/mermaid-cli | Render Mermaid to PNG/SVG |
| Graphviz (dot) | ✗ | Manual Installation | https://graphviz.org/download/ |
| PlantUML | ✗ | Requires Java + plantuml.jar | https://plantuml.com/download |
| Python (render script) | ✓ | Already in bootstrap | `scripts/render_diagram.py` dependency |

### Explanation

This skill mainly outputs the source code of charts in text format (Mermaid/DOT/PlantUML), and a local rendering tool is not necessarily required. A corresponding renderer is only needed when the user explicitly requests to generate an PNG/SVG/PDF file.

If the renderer is unavailable, `scripts/render_diagram.py` will output an installation prompt instead of an error.

---

## Routing Context

**Upstream Input**: `references/README.md` (Main Control), `routing.md`
**Trigger conditions**: The user says "draw a diagram", "flowchart", "architecture diagram", "attack path diagram", "sequence diagram", "Mermaid", "Graphviz", "PlantUML"
**Downstream Exports**:
- The generated charts can be embedded in `docs-generator/`'s reports
- The attack path diagram can be used in conjunction with `pentest-tools/`'s penetration report

**Peer-related module**: `docs-generator/` (Charts embedded in the report)


## Task Completion Self-Check (MUST pass before claiming completion)

- [ ] Did I perform each step in the workflow (instead of just reading it)?
- [ ] Did I use a real tool path based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and filled in the Checklist items required by the RULES?