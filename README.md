# 🛡️ Entra ID Identity Hardening & Security Automation Lab

![Microsoft Entra ID](https://img.shields.io/badge/Microsoft-Entra%20ID-0078D4?logo=microsoftazure&logoColor=white)
![Conditional Access](https://img.shields.io/badge/Focus-Conditional%20Access-2563eb)
![Identity Protection](https://img.shields.io/badge/Identity-Protection%20%2B%20PIM-6941C6)
![PowerShell](https://img.shields.io/badge/Automation-PowerShell%20%2B%20Graph-012456?logo=powershell&logoColor=white)
![Licensing](https://img.shields.io/badge/Licensing-Entra%20ID%20P2-6941C6)
![Status](https://img.shields.io/badge/Status-Live-success)

> A hands-on lab that hardens a Microsoft Entra ID tenant against account-takeover attacks **and** automates the response — building a complete **mini-SOC loop: Detect → Triage → Contain.** Conditional Access, Identity Protection, PIM, PowerShell + Microsoft Graph automation, and an AI-assisted triage agent. Every control validated in report-only / What If before enabling.

---

## 📋 Overview

I built my own Entra ID tenant and configured a production-grade identity-security baseline, then layered on **automation and AI** to detect, triage, and contain threats end to end.

**The attacker's-eye view this defends against:** stolen password → blocked by MFA → attacker tries legacy auth to skip MFA → blocked → suspicious sign-in → challenged / flagged → leaked credential detected → account force-reset → an **impossible-travel** detection fires → an **AI agent triages** it into a ticket → a **PowerShell script revokes the sessions** and evicts the attacker.

---

## 🔁 The mini-SOC loop

| Stage | What does it | Built in |
|---|---|---|
| **Detect** | Identity Protection risk policies + a custom impossible-travel script | Days 4, 8 |
| **Triage** | AI SOC agent turns a raw event into a structured JSON incident ticket | Day 9 |
| **Contain** | PowerShell script revokes the compromised user's sessions | Day 7 |

---

## 🧱 Conditional Access baseline — at a glance

| Policy | Purpose | Trigger / Condition | Control | Excludes |
|---|---|---|---|---|
| **CA001** | Enforce MFA | All sign-ins | Require MFA | `CA-BreakGlass-Exclude` |
| **CA002** | Block legacy auth | Legacy client apps | Block access | `CA-BreakGlass-Exclude` |
| **CA003** | Risky sign-in defence | Sign-in risk = High | Require MFA | `CA-BreakGlass-Exclude` |
| **CA004** | Compromised-account defence | User risk = High | Require MFA + password change | `CA-BreakGlass-Exclude` |

*Naming convention: `CA + number + purpose + scope` — keeps the policy set auditable as it scales.*

---

## 🏗️ Lab environment

| Account | Role | Licence | Purpose |
|---|---|---|---|
| **LabAdmin** | Global Administrator | Entra ID P2 | Working admin |
| **Chris / Bala / Shahid** | *No admin rights* | Entra ID P2 | Standard test users (least privilege) |
| **bg-emergency01 / 02** | Global Administrator (permanent) | — | Break-glass emergency access |

Both break-glass accounts live in the security group **`CA-BreakGlass-Exclude`**, excluded from every policy.

---

# Part 1 — Identity Hardening (Conditional Access, Identity Protection, PIM)

## 🔐 Day 1 — Break-glass emergency accounts
Two cloud-only emergency admin accounts in an exclusion group.
> **Why:** emergency logins deliberately excluded from every policy, so a misconfiguration, MFA outage, or identity-provider failure can never lock the org out of its own tenant. Cloud-only, permanent admin, two for redundancy.

## 🔑 Day 2 — Enforce MFA — `CA001`
All users (excluding break-glass) → Require MFA. Built in **report-only**, validated in sign-in logs, then enabled. **Migrated the tenant off Security Defaults** to use granular Conditional Access.
> **Why:** MFA makes a stolen password useless alone — the top defence against account takeover.

## 🚫 Day 3 — Block legacy authentication — `CA002`
Condition scoped to legacy client apps only → **Block access**. Validated with the **What If** tool.
> **Why:** legacy protocols (POP/IMAP/SMTP) can't do MFA, so leaving them open lets attackers bypass MFA with a stolen password. Blocking them closes that back door.

## 🧠 Day 4 — Identity Protection risk policies — `CA003` & `CA004`
Adaptive, ML-driven policies:
- **Sign-in risk = High → require MFA** (is *this login* the real user?)
- **User risk = High → force password change** (is the *account* compromised? — e.g. leaked credentials). Enabled **SSPR** as the prerequisite.
> **Why:** MFA is static; Identity Protection is *adaptive* — it reacts to detected threats automatically.

## ⏱️ Day 5 — Privileged Identity Management (PIM)
Made a test user **eligible** (not active) for User Administrator, with **2-hour, MFA-and-justification-gated activation**.
> **Why:** eliminates *standing privilege* — admin rights exist only when activated, shrinking the attack window. Break-glass stays permanent as the deliberate exception.

---

# Part 2 — Security Automation (PowerShell + Microsoft Graph + AI)

## 💻 Day 6 — Microsoft Graph PowerShell — the automation gateway
Connected to Graph with **least-privilege scopes** (`User.Read.All`, `Group.Read.All`), then queried and filtered directory objects programmatically.
> **Why:** you can't click 5,000 users — Graph lets you read and act at scale. Delegated vs application permissions, and requesting only the scope the task needs.

## 🧯 Day 7 — Automated session revocation — `Revoke-Sessions.ps1`
Escalated to a **write scope** (`User.RevokeSessions.All`) and revoked a compromised user's sessions to force re-authentication.
> **Why:** a password reset alone doesn't kill live tokens — revoking sessions instantly evicts the attacker. This is the **Contain** step.

## 🧮 Day 8 — Impossible-travel detection — `Test-ImpossibleTravel.ps1`
A PowerShell script using the **haversine formula** to compute distance between two sign-in locations and derive implied travel speed — flagging physically impossible logins.
> **Why:** mirrors how Entra ID Protection detects atypical travel. Key insight: impossible travel is **distance ÷ time** — the same distance is impossible in 1 hour but plausible over 24. This is the **Detect** step.

## 🤖 Day 9 — AI SOC triage agent — `soc-triage-agent-prompt.txt`
An AI agent that ingests a raw security event and returns a **structured JSON incident ticket** — severity, MITRE ATT&CK mapping, indicators, and a recommended containment playbook.
> **Why:** automates Tier-1 triage so analysts focus on investigation. Structured JSON output is *machine-readable*, so it can feed a ticketing system or an automated playbook. This is the **Triage** step. See `example-triage-ticket.json`.

---

## 📁 Repository contents

```
entra-identity-hardening/
├── README.md
├── scripts/
│   ├── Revoke-Sessions.ps1          # Day 7 - containment
│   └── Test-ImpossibleTravel.ps1    # Day 8 - detection (haversine)
├── ai-agent/
│   ├── soc-triage-agent-prompt.txt  # Day 9 - agent design
│   └── example-triage-ticket.json   # Day 9 - sample output
└── screenshots/                     # policy + evidence screenshots
```

---

## 🎯 Key concepts demonstrated

- **Least privilege** — across users, PIM (just-in-time), break-glass exclusion, and Graph API scopes.
- **Safe change management** — report-only mode + the What If tool before enforcing.
- **Defence in depth** — MFA, legacy-auth blocking, risk-based policies layered together.
- **Security Defaults → Conditional Access migration** — blunt baseline to granular, testable control.
- **Automation at scale** — Microsoft Graph + PowerShell to read and act on the directory.
- **Threat containment** — session revocation vs password reset.
- **Detection logic** — impossible travel = distance ÷ time.
- **AI-assisted SOC** — structured, machine-readable triage that closes the loop.

---

## 🧰 Skills & technologies

`Microsoft Entra ID` · `Conditional Access` · `Entra ID Protection` · `Privileged Identity Management (PIM)` · `Multi-Factor Authentication` · `PowerShell` · `Microsoft Graph SDK` · `Identity & Access Management` · `Least Privilege` · `Incident Response` · `AI-assisted Security Operations` · `Defence in Depth`

---

## ✅ Outcome

A hardened Entra ID tenant with MFA enforced, legacy auth blocked, adaptive risk-based remediation, just-in-time privileged access, and protected break-glass access — **plus** an automated detect → triage → contain pipeline built with PowerShell, Microsoft Graph, and an AI triage agent. The standard secure identity baseline for a Microsoft organisation, extended into automation, and built and validated with professional rollout practices.

> *Part of an ongoing hands-on cloud security portfolio — building in public.*
> 
# 🛡️ Vulnerability Management Lab — Tenable Nessus + CVSS Scoring

![Tenable Nessus](https://img.shields.io/badge/Scanner-Tenable%20Nessus%20Essentials-00355F)
![Vulnerability Management](https://img.shields.io/badge/Focus-Vulnerability%20Management-2563eb)
![CVSS](https://img.shields.io/badge/Scoring-CVSS%20v3.1%20%2B%20CIA%20Triad-6941C6)
![Environment](https://img.shields.io/badge/Environment-Air--gapped%20Lab-9a6a12)
![Status](https://img.shields.io/badge/Status-Complete-success)

> A hands-on vulnerability-management lab: deploy **Tenable Nessus**, run authenticated and unauthenticated scans against an isolated Windows host, and score a real-world finding with **CVSS v3.1** from first principles using the **CIA triad**. Built and activated in a **restricted, air-gapped environment** — the offline workflow used in secure and government networks.

---

## 📋 Overview

I set up Tenable Nessus Essentials in an isolated lab, worked through the full vulnerability-management workflow — **scan → interpret → prioritise → (remediate) → verify** — and then scored a finding by hand to understand exactly where a severity number comes from. The lab environment sat behind a corporate secure web gateway performing TLS inspection, so I completed the deployment using Nessus's **offline / air-gapped registration** rather than the standard online activation.

**Lab environment:** a Windows 11 virtual machine (Oracle VirtualBox), scanned locally, with all testing confined to a system I own.

---

## 🧰 What I did

### 1. Deployed Tenable Nessus (offline / air-gapped)
- Installed Nessus Essentials and initialised the scanner.
- The environment's TLS inspection blocked the standard online activation (the scanner could not validate the licensing server's certificate).
- Diagnosed this as **SSL/TLS interception** — a classic secure-web-gateway behaviour — and completed activation the sanctioned, air-gapped way instead:
  - Generated a **challenge code** on the scanner (`nessuscli fetch --challenge`).
  - Registered it offline to obtain a **license file** and the **plugin feed bundle**.
  - Loaded both manually (`nessuscli fetch --register-offline`, `nessuscli update`), then created the admin user and brought the console online — **no internet dependency**.
- This mirrors how vulnerability scanners are operated in **air-gapped and government environments**, where the online plugin feed is never available and updates are applied manually.

### 2. Ran an unauthenticated (network) scan
- Basic Network Scan against `127.0.0.1`. Status: **Completed**.
- Result: mostly **informational** findings — the expected outcome for an outside-in scan of a firewalled host.
- **Key insight:** an unauthenticated scan sees a system the way an attacker on the network does — shallow, with more false positives.

### 3. Configured an authenticated (credentialed) scan
- Added Windows credentials so the scanner logs in and checks **actual patch levels and configuration** from the inside.
- **Credentialed scanning is what mature organisations run** — far more accurate and far fewer false positives than an unauthenticated scan.

### 4. Scored a finding with CVSS v3.1 (CIA triad)
Took a representative finding — **SMBv1 / EternalBlue (CVE-2017-0144, MS17-010)** — and scored it by hand on the FIRST.org CVSS v3.1 calculator:

| Metric | Value | Reasoning |
|---|---|---|
| Attack Vector | Network | Exploitable remotely |
| Attack Complexity | High | Exploit needs specific conditions |
| Privileges Required | None | No account needed |
| User Interaction | None | No user action required |
| Scope | Unchanged | Stays within the component |
| **Confidentiality** | **High** | RCE lets an attacker read all data |
| **Integrity** | **High** | RCE lets an attacker alter/encrypt data |
| **Availability** | **High** | RCE lets an attacker crash/seize the host |

**Result — matched the official NVD score exactly:**
```
Base Score: 8.1 (High)
Vector:     CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H
```

---

## 🎯 Key concepts demonstrated

- **CVSS is the CIA triad turned into a number** — the impact half of a score is simply how badly Confidentiality, Integrity, and Availability are affected; those inputs drive the number.
- **CVSS vs VPR** — CVSS rates *theoretical* severity (here, 8.1 despite "High" complexity); Tenable's **VPR** layers on *real-world exploitability*. EternalBlue was weaponised into WannaCry, so VPR keeps it top-priority even though CVSS complexity is High. *Score the severity, prioritise by exploitability.*
- **Authenticated vs unauthenticated scanning** — credentialed scans check real patch state and cut false positives.
- **The vulnerability-management loop** — detect → prioritise → remediate → **rescan to verify**, tracked through a governance process.
- **Secure-web-gateway / TLS inspection** — why an unmanaged host can't reach the internet through a corporate proxy, and how a cert-authority error is a client correctly detecting interception.
- **Air-gapped operation** — manual, offline plugin updates for isolated environments.

---

## 🧩 Skills & technologies

`Tenable Nessus` · `Vulnerability Management` · `CVSS v3.1` · `CIA Triad` · `Credentialed & Uncredentialed Scanning` · `Remediation & Verification` · `Air-gapped / Offline Operation` · `Windows Security` · `Oracle VirtualBox` · `Secure Web Gateway / TLS Inspection`

---

## ✅ Outcome

A working Tenable Nessus scanner deployed and activated in a restricted, air-gapped lab; unauthenticated and authenticated scans run against an isolated Windows host; and a real CVE scored by hand to an exact match with NVD. The lab demonstrates the end-to-end vulnerability-management workflow and the reasoning behind severity — not just how to run a tool, but how to interpret, prioritise, and justify what it finds.

> *Part of an ongoing hands-on cloud-security portfolio — building in public.*
> *All scanning was performed against systems I own, in an isolated lab, using non-production data.*
