# Goulm CLI — Terminal Agent Integrated Environment (AIE)

<p align="center">
  <strong>Fast. Lightweight. Private. An autonomous engineering agent built directly for your terminal.</strong>
</p>

<p align="center">
  <a href="#quick-installation">Installation</a> •
  <a href="#why-goulm">Why Goulm?</a> •
  <a href="#first-run-guide">First-Run Guide</a> •
  <a href="#key-commands">Commands</a> •
  <a href="#privacy--security">Privacy</a> •
  <a href="#license">License</a> •
  <a href="#support--donate">Support</a>
</p>

---

```text
  ██████╗  ██████╗ ██╗   ██╗██╗     ███╗   ███╗
 ██╔════╝ ██╔═══██╗██║   ██║██║     ████╗ ████║
 ██║  ███╗██║   ██║██║   ██║██║     ██╔████╔██║
 ██║   ██║██║   ██║██║   ██║██║     ██║╚██╔╝██║
 ╚██████╔╝╚██████╔╝╚██████╔╝███████╗██║ ╚═╝ ██║
  ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝╚═╝     ╚═╝
```

## Quick Installation

Open **PowerShell** (no Administrator privileges required) and paste:

```powershell
irm https://raw.githubusercontent.com/LRGolden/Goulm_packages/main/install.ps1 | iex
```

> **What this does:**
> - Automatically detects your native CPU architecture (`amd64` or `arm64`).
> - Installs Goulm cleanly into `%LOCALAPPDATA%\Programs\Goulm`.
> - Permanently registers Goulm in your Windows User `PATH` (works immediately in any terminal).
> - Creates safety backups so you can rollback anytime.

### Useful Installation Flags

| Action | Command |
| :--- | :--- |
| **Instant Install (CI / Automated)** | `irm https://raw.githubusercontent.com/LRGolden/Goulm_packages/main/install.ps1 \| iex -args -AcceptLicense` |
| **Rollback to Previous Version** | `irm https://raw.githubusercontent.com/LRGolden/Goulm_packages/main/install.ps1 \| iex -args -Rollback` |
| **Clean Uninstall** | `irm https://raw.githubusercontent.com/LRGolden/Goulm_packages/main/install.ps1 \| iex -args -Uninstall` |

---

## Why Goulm?

Modern development tools have become bloated. Goulm was engineered from the ground up in Go as a native, zero-friction agent that respects your machine’s resources.

### 🪶 Featherweight Footprint (~13 MB RAM)
Unlike heavy Electron-based tools that consume gigabytes of memory, Goulm launches in milliseconds and idles at **around 13 MB of RAM** (<100 MB under heavy agent loops). This leaves all your RAM and GPU headroom untouched for your builds, Docker containers, and local AI models.

### ⚡ True Independence: Your Keys, Your Models
Goulm does not lock you into a single proprietary ecosystem. Connect cloud providers (Claude, OpenAI, OpenRouter, DeepSeek) or run **100% offline and locally** with Ollama or local inference engines.

### 🛡️ 100% Private by Design
- **Zero Telemetry**: Goulm does not collect, track, or phone home your source code, commands, or prompts.
- **Hardware-Backed Encryption**: Your API keys are encrypted locally using AES-256-GCM and Windows DPAPI. Your credentials never leave your machine.

### 🎯 Purpose-Built Work Modes
- **Code Mode**: Full autonomy to read, inspect, refactor, run tests, and manage Git repositories.
- **Arch Mode**: Read-only architectural planning. Lets Goulm analyze large codebases and design systems without modifying files.

---

## First-Run Guide

### 1. Launch Goulm
Open Windows Terminal, PowerShell, or Command Prompt and run:

```cmd
goulm
```

### 2. Connect Your AI Provider
Inside Goulm, type `/connect` to launch the interactive setup wizard:

```text
/connect
```

You can configure:
- **Cloud Providers**: OpenRouter, Anthropic (Claude), OpenAI, DeepSeek.
- **Local Models**: Ollama (`http://localhost:11434`) for private, offline coding.

### 3. Start Coding
Ask Goulm to inspect your project, troubleshoot bugs, or build new features:

```text
> "Analyze this repository and explain the project structure"
> "Find why the login endpoint is returning 401 in auth.go"
> "Refactor pkg/tools to add unit tests for files.go"
```

---

## Key Commands Inside Goulm

| Command | Description |
| :--- | :--- |
| `/connect` | Setup or switch AI provider API keys |
| `/model <id>` | Switch AI model on the fly (e.g., `/model deepseek/deepseek-chat`) |
| `/mode <code\|arch>` | Toggle between Code mode and read-only Architecture mode |
| `/copy` | Copy last response or error directly to clipboard |
| `/clear` | Clear terminal conversation history |
| `/help` | View full command palette and shortcuts |

---

## Non-Interactive & Scripting Mode

Goulm isn't just an interactive terminal; you can also pipe it into scripts and CI workflows:

```powershell
# Plain output for pipes and files
goulm run --plain "Summarize the changes in git diff" > summary.txt

# Structured JSON output for automation
goulm run --json "List all exported Go functions in pkg/"
```

---

## License & Terms

Goulm Terminal is distributed under a **Proprietary EULA** ([legal/LICENSE](legal/LICENSE)):

- **Free for Individuals**: Independent developers (*Indies*), hobbyists, personal projects, and individual freelancers (even when charging clients).
- **Commercial License Required**: All registered companies, corporations, startups, and incorporated legal entities (including one-person companies / single-member LLCs) require a commercial license.
- **Human in the Loop**: Goulm provides AI assistance. Users remain responsible for reviewing and approving all code changes and terminal commands before execution.

---

## Support Independent Engineering ☕

Goulm is developed with passion to provide developers with a fast, private, and bloat-free engineering environment.

If Goulm saves you time and enhances your workflow, consider supporting its continuous development:

- ☕ **Ko-fi**: [https://ko-fi.com/dorado44](https://ko-fi.com/dorado44)

Thank you for supporting independent software development!
