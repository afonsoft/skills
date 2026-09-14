#!/usr/bin/env python3
"""Query skills.sh third-party security audits (Gen Agent Trust Hub, Socket, Snyk).

Example:
    python scripts/skills-sh-audit.py --source afonsoft/skills skills/
    python scripts/skills-sh-audit.py --source afonsoft/skills skills/ --json
    python scripts/skills-sh-audit.py --source afonsoft/skills --fail-on critical skills/
"""
import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path
from urllib.parse import urlencode

AUDIT_URL = "https://add-skill.vercel.sh/audit"
RISK_ORDER = {"safe": 1, "low": 2, "medium": 3, "high": 4, "critical": 5, "unknown": 0}


def discover_skills(base: Path):
    """Return skill slugs found under `base` (e.g. skills/<name>)."""
    return sorted(p.name for p in base.iterdir() if p.is_dir() and (p / "SKILL.md").is_file())


def fetch_audit(source: str, slugs: list[str], timeout: int = 30):
    """Call the skills.sh audit endpoint and return parsed JSON."""
    params = {"source": source, "skills": ",".join(slugs)}
    url = f"{AUDIT_URL}?{urlencode(params)}"
    request = urllib.request.Request(url, method="GET")
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8") if hasattr(e, "read") else ""
        raise SystemExit(f"Audit endpoint returned {e.code}: {body}")
    except Exception as e:
        raise SystemExit(f"Failed to fetch audit data: {e}")


def risk_emoji(risk: str) -> str:
    return {
        "safe": "✅",
        "low": "🟢",
        "medium": "🟡",
        "high": "🟠",
        "critical": "🔴",
        "unknown": "⚪",
    }.get(risk.lower() if risk else "unknown", "❓")


def risk_value(risk: str) -> int:
    return RISK_ORDER.get(risk.lower() if risk else "unknown", 0)


def format_table(results: dict, source: str, slugs: list[str]):
    """Return a Markdown table."""
    lines = [
        "## skills.sh Security Audit",
        "",
        "| Skill | Gen Agent Trust Hub | Socket | Snyk | Details |",
        "|-------|---------------------|--------|------|---------|",
    ]
    for slug in slugs:
        data = results.get(slug) or {}
        ath = data.get("ath", {}).get("risk", "unknown") if isinstance(data, dict) else "unknown"
        socket = data.get("socket", {}) if isinstance(data, dict) else {}
        snyk = data.get("snyk", {}).get("risk", "unknown") if isinstance(data, dict) else "unknown"

        socket_risk = socket.get("risk", "unknown") if socket else "unknown"
        socket_alerts = socket.get("alerts") if socket else None
        socket_cell = f"{risk_emoji(socket_risk)} {socket_risk or 'unknown'}"
        if socket_alerts:
            socket_cell += f" ({socket_alerts} alerts)"

        detail_url = f"https://skills.sh/{source}/{slug}"
        lines.append(
            f"| `{slug}` | {risk_emoji(ath)} {ath or 'unknown'} | "
            f"{socket_cell} | {risk_emoji(snyk)} {snyk or 'unknown'} | "
            f"[View]({detail_url}) |"
        )
    return "\n".join(lines)


def collect_findings(results: dict, slugs: list[str], threshold: int):
    """Return [(slug, scanner, risk)] for risks at or above threshold."""
    failures = []
    for slug in slugs:
        data = results.get(slug) or {}
        if not isinstance(data, dict):
            continue
        for scanner in ("ath", "socket", "snyk"):
            risk = data.get(scanner, {}).get("risk", "unknown") if isinstance(data.get(scanner), dict) else "unknown"
            if risk_value(risk) >= threshold:
                failures.append((slug, scanner, risk))
    return failures


def format_findings(results: dict, slugs: list[str]):
    """Human-readable count of non-safe findings for the summary tail."""
    findings = collect_findings(results, slugs, RISK_ORDER["low"])
    if not findings:
        return "All skills report safe/unknown on every scanner."
    counts = {}
    for _, _, risk in findings:
        counts[risk] = counts.get(risk, 0) + 1
    parts = ", ".join(f"{n} {risk}" for risk, n in sorted(counts.items(), key=lambda kv: -RISK_ORDER[kv[0]]))
    return f"**{len(findings)} finding(s) at low risk or above:** {parts}"


def emit_github_annotations(results: dict, source: str, slugs: list[str], fail_on: str):
    """Emit GitHub Actions annotations for risks at or above the threshold.

    With --fail-on none (report-only), findings are never emitted as
    ::error — high/critical become warnings, anything lower a notice.
    """
    report_only = fail_on == "none"
    threshold = RISK_ORDER["low"] if report_only else RISK_ORDER.get(fail_on, 5)
    for slug in slugs:
        data = results.get(slug) or {}
        if not isinstance(data, dict):
            continue

        ath = data.get("ath", {}).get("risk", "unknown")
        socket = data.get("socket", {}).get("risk", "unknown")
        snyk = data.get("snyk", {}).get("risk", "unknown")
        detail_url = f"https://skills.sh/{source}/{slug}"

        for scanner, risk in [("Gen Agent Trust Hub", ath), ("Socket", socket), ("Snyk", snyk)]:
            if risk and risk_value(risk) >= threshold:
                message = f"{scanner} reports {risk} risk for {slug}. Details: {detail_url}"
                if not report_only and risk in ("critical", "high"):
                    print(f"::error title={scanner} {risk}::{message}")
                elif risk in ("critical", "high", "medium"):
                    print(f"::warning title={scanner} {risk}::{message}")
                else:
                    print(f"::notice title={scanner} {risk}::{message}")


def main():
    parser = argparse.ArgumentParser(description="Run skills.sh security audit on local skills.")
    parser.add_argument("skills_dir", type=Path, help="Directory containing skill subdirectories (e.g. skills/)")
    parser.add_argument("--source", default=None, help="GitHub owner/repo of the skill collection (default: GITHUB_REPOSITORY env)")
    parser.add_argument("--timeout", type=int, default=30, help="HTTP timeout in seconds")
    parser.add_argument("--json", action="store_true", help="Output raw JSON instead of Markdown")
    parser.add_argument("--fail-on", choices=["low", "medium", "high", "critical", "none"], default="critical", help="Fail when any audit reaches this risk or higher; 'none' = report-only, never fails (default: critical)")
    parser.add_argument("--summary", type=Path, default=None, help="Write Markdown summary to a file")
    args = parser.parse_args()

    source = args.source or os.environ.get("GITHUB_REPOSITORY")
    if not source:
        parser.error("Provide --source or set GITHUB_REPOSITORY environment variable")

    if not args.skills_dir.is_dir():
        parser.error(f"Skills directory not found: {args.skills_dir}")

    slugs = discover_skills(args.skills_dir)
    if not slugs:
        print("No skills found.")
        sys.exit(0)

    results = fetch_audit(source, slugs, timeout=args.timeout)

    if args.json:
        print(json.dumps(results, indent=2))
        return

    findings_tail = format_findings(results, slugs)
    table = f"{format_table(results, source, slugs)}\n\n{findings_tail}\n"
    print(table)

    if args.summary:
        args.summary.write_text(table)

    if os.environ.get("GITHUB_ACTIONS"):
        emit_github_annotations(results, source, slugs, args.fail_on)

    if args.fail_on == "none":
        print("Report-only mode (--fail-on none): findings above do not fail the run.")
        return

    threshold = RISK_ORDER.get(args.fail_on, 5)
    failures = collect_findings(results, slugs, threshold)

    if failures:
        print("\nFailures:")
        for slug, scanner, risk in failures:
            print(f"  - {slug} / {scanner}: {risk}")
        sys.exit(1)

    print("\nAll skills passed the configured risk threshold.")


if __name__ == "__main__":
    main()
