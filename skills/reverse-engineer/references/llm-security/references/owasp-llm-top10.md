# OWASP LLM & Agentic AI Top 10 (2025-2026)

## OWASP Top 10 for LLM Applications v2.0 (2025)

| # | Risk | Core Issues | Test Direction |
|---|------|---------|---------|
| LLM01 | Prompt Injection | Control model behavior through constructed inputs | Direct injection, indirect injection, coding bypass |
| LLM02 | Sensitive Information Disclosure | PII/API Key/training data leakage | Prompt word extraction, output analysis |
| LLM03 | Supply Chain | Poisoning model/library/dataset | Model source verification, dependency scanning |
| LLM04 | Data & Model Poisoning | Training/fine-tuning data backdoor | Data traceability, behavioral anomaly detection |
| LLM05 | Improper Output Handling | Output results in XSS/SQLi/RCE | Downstream system injection testing |
| LLM06 | Excessive Agency | Too much tool/autonomy leading to actual harm | Permission audit, human-in-the-loop testing |
| LLM07 | System Prompt Leakage | Extract hidden instructions/keys/business logic | Cascade extraction, canary token |
| LLM 08 | Vector and Embedding Weaknesses | RAG pipeline attack, embedding inversion | Retrieval poisoning, semantic similarity attack |
| LLM09 | Misinformation | Hallucinations pose safety risks in high-risk scenarios | Factual verification, confidence calibration |
| LLM10 | Unbounded Consumption | DoS/Denial-of-Wallet | Token consumption test, rate limit |

## OWASP Top 10 for Agentic Applications (ASI 2026)

| # | Risk | Core Hazards | Test Direction |
|---|------|---------|---------|
| ASI01 | Agent Goal Hijack | Malicious input/tool output hijacking target | Command overwriting, target tampering |
| ASI02 | Tool Misuse & Exploitation | Unintended use of legitimate tools | Tool chain splicing, parameter injection |
| ASI03 | Identity & Privilege Abuse | Agent unauthorized operation | Credential theft, delegation chain test |
| ASI04 | Agentic Supply Chain | MCP Descriptor/Third Party Tools Real-time Risk | Dynamic Supply Chain Scanning |
| ASI05 | Unexpected Code Execution | Tips → Tools → Script RCE Chain | Multi-layer code execution testing |
| ASI06 | Memory & Context Poisoning | Long-term memory/embedded poisoning | Memory persistence attack |
| ASI07 | Insecure Inter-Agent Communication | Inter-agent communication tampering | Man-in-the-middle, replay attack |
| ASI08 | Cascading Failures | Single point failure triggers system-level collapse | Fault propagation testing |
| ASI09 | Human-Agent Trust Exploitation | Manipulating human operators into approving dangerous operations | Authority bias/urgency test |
| ASI10 | Rogue Agents | Agent self-replication/persistent malicious behavior | Persistent backdoor detection |

## Actual data distribution

Proportion of problems found in real assessment:
- LLM01 Prompt Injection: ~45%
- LLM06 Sensitive Info Disclosure: ~20%
- LLM08 Excessive Agency: ~15%
- The remaining 7 items: ~20%

## Key Defense Principles

1. Separation of planning and execution — model for interpreting intentions ≠ model for executing actions
2. Bind identity/purpose/scope/timeliness — don’t use broad environmental permissions
3. Log everything — tool calls/memories/communications as first-class security telemetry
4. Explosion radius control – circuit breaker/rollback/emergency stop takes precedence over convenience
5. All natural language input (including search content) is considered untrustworthy
6. Output is also untrustworthy — sanitize before rendering/executing/querying