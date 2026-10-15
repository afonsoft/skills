# Reverse Engineer

Skill consolidada para engenharia reversa e análise de segurança — une a ferramenta REA (ledger de evidências) ao pacote de playbooks de domínio `reverse-skill`.

## 🎯 Propósito

Dar ao agente um único ponto de entrada para qualquer pergunta sobre artefatos distribuídos: binários, firmware, apps mobile, bundles JavaScript/Electron, assemblies .NET, protocolos de rede, amostras de malware, desafios CTF e tarefas autorizadas de pentest/análise. A skill roteia cada alvo para o motor correto (REA CLI/MCP quando disponível; toolchains clássicas caso contrário) e impõe gates de consentimento e escopo antes de qualquer ação sobre um alvo.

## 🛠️ Como funciona

- **Skill hub**: `skills/reverse-engineer/SKILL.md` é um roteador compacto. Todo o material pesado fica em `skills/reverse-engineer/references/` — 40+ guias de domínio, pacote CTF, guias REA, scripts, configs e docs operacionais.
- **Roteamento REA-first**: com o CLI `rea` ou as tools MCP `rea-agents` presentes, a inspeção passa pelo REA (`open_binary`, `analyze_javascript_application`, `inspect_android_package`, `inspect_firmware_regions`, `inspect_managed_artifact`, `list_browser_targets`, …), mantendo Evidence IDs. Sem REA, os guias de domínio dirigem Ghidra/IDA/Binary Ninja, radare2, jadx/apktool, Frida, angr/Qiling etc.
- **Gate de escopo**: `references/scripts/case-init.sh --hint "<tarefa>"` grava `work/<case>/scope.md`. Qualquer ACT sobre alvo exige `auth.status=granted` + `network_profile` válido ou sample offline explícito — `--force` nunca contorna.
- **Roteador determinístico**: `references/scripts/master-route.sh --hint "<tarefa>"` mapeia hints para o guia PRIMARY via `references/config/routing.json` (fonte única de verdade; `references/routing.md` é a matriz legível).
- **Prontidão de ferramentas**: `references/scripts/check-tools.sh <módulo>` reporta ferramentas required/optional por módulo (somente leitura, nunca instala), com hints para `references/scripts/bootstrap-manifest.json`.

## 🚀 Uso

1. **Artefato para entender** → `case-init.sh --hint "analisar app.apk offline"` → `master-route.sh --hint "apk jadx smali"` → abrir o guia PRIMARY.
2. **REA presente** → rotear o alvo com tools REA, summary-first, preservar Evidence IDs, fechar com `close_binary`.
3. **Ferramenta ausente** → `check-tools.sh <módulo>` mostra o que falta; instalar só após disclosure via `bootstrap-reverse.sh <capability>`.

Scripts auxiliares:

- `scripts/install-rea.sh` — instala/registra REA (`--check`, `--global`, `--client <id>`, `--dry-run`, `--print-manual`). Envolve os comandos oficiais `npx rea-agents`; nunca instala Node.js nem engines de análise.
- `references/scripts/check-tools.sh` — prontidão por módulo (`--all`, `--list`, `--json`).
- `references/scripts/master-route.sh` / `case-init.sh` / `case-guard.sh` — roteamento e escopo.
- `references/scripts/refresh-tool-index.sh` — regenera `tool-index.md` a partir do PATH.

## 📚 Mapa de referências (seleção)

| Área | Caminho |
|---|---|
| Workflow RE central | `references/reverse-engineering/` |
| APK / Android / mobile | `references/apk-reverse/`, `references/mobile-reverse/` |
| JavaScript / Electron | `references/js-reverse/` |
| .NET | `references/dotnet-reverse/` |
| IDA / Ghidra / Binary Ninja / radare2 | `references/ida-reverse/`, `references/ghidra-reverse/`, `references/binary-ninja-reverse/`, `references/radare2/` |
| Firmware / hardware / rádio | `references/firmware-pentest/`, `references/hardware-security/`, `references/radio-sdr/` |
| Malware / forense / threat intel | `references/malware-analysis/`, `references/digital-forensics/`, `references/threat-hunting/` |
| Protocolos / PCAP | `references/protocol-reverse/` |
| Exploit dev / patch diffing | `references/pwn-chain/`, `references/binary-diff/`, `references/patch-diff-exploit/` |
| Pacote CTF | `references/ctf-sandbox/`, `references/CTF-Sandbox-Orchestrator/` |
| Pentest / web / AD / cloud | `references/pentest-tools/`, `references/api-security/`, `references/windows-ad/`, `references/cloud-k8s/` |
| Guias REA | `references/rea/` |

## ⚠️ Gates de consentimento

- Ler arquivos da skill não autoriza executá-los; o primeiro efeito colateral local exige aprovação explícita.
- Autorização de alvo é separada: `scope.md` com `auth.status=granted` antes de qualquer ACT.
- Nunca executar samples desconhecidos, modificar originais ou ampliar escopo silenciosamente.
- Não reivindicar evidência de runtime a partir de análise estática; preservar Evidence IDs e limites de confiança.

## 🔗 Correlação

- **`diagnose`**: para bugs comuns em código cujo fonte você tem — reverse-engineer é para artefatos distribuídos.
- **`code-review-and-quality` / `quality-test-implementation`**: quando findings de RE viram correção no codebase.
- **`orchestrator`**: engajamentos longos multi-alvo podem ser rastreados como issues/epics.
