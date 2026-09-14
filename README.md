📋 Overview

I built my own Entra ID tenant and configured the same identity-security baseline a secure Microsoft organisation runs in production — then extended it with Microsoft Entra ID Protection for intelligent, risk-based responses. The focus throughout: defence in depth and safe change management.

The attacker's-eye view this defends against: a stolen password → blocked by MFA → attacker tries a legacy protocol to skip MFA → blocked → attacker's IP looks suspicious → challenged again → the leaked password is detected on the dark web → the account is force-reset. Every layer closes a gap the previous one leaves open.

🧱 Conditional Access Baseline — at a glance
Policy	Purpose	Trigger / Condition	Control	Excludes
CA001	Enforce MFA	All sign-ins	Require MFA	CA-BreakGlass-Exclude
CA002	Block legacy auth	Legacy client apps	Block access	CA-BreakGlass-Exclude
CA003	Risky sign-in defence	Sign-in risk = High	Require MFA	CA-BreakGlass-Exclude
CA004	Compromised-account defence	User risk = High	Require MFA + password change	CA-BreakGlass-Exclude

Naming convention: CA + number + purpose + scope — keeps the policy set auditable as it grows.

🏗️ Lab Environment
Account	Role	Licence	Purpose
LabAdmin	Global Administrator	Entra ID P2	Working admin account
Chris Green, Bala Sandhu, Shahid Ghosi	No admin rights	Entra ID P2	Standard test users (least privilege)
bg-emergency01 / bg-emergency02	Global Administrator (permanent)	—	Break-glass emergency access

Both break-glass accounts sit in the security group CA-BreakGlass-Exclude, which is excluded from every policy.

🔐 Day 1 — Break-glass emergency accounts

Created two cloud-only emergency admin accounts and placed them in an exclusion group.

Why: Break-glass accounts are emergency logins excluded from the security policies that protect everyone else. If a policy is ever misconfigured and locks everyone out — including me — these are the guaranteed way back in. They're cloud-only (no dependency on external systems), have permanent admin (they work even if just-in-time systems fail), and there are two for redundancy. Excluding them via a group means every future policy simply excludes the same group.

🔑 Day 2 — Enforce MFA for all users — CA001-Require-MFA-AllUsers
Setting	Value
Users	All users — excluding CA-BreakGlass-Exclude
Target resources	All cloud apps
Grant	Require multi-factor authentication
Rollout	Report-only → validated in sign-in logs → enabled

Verified enforcement by signing in as a test user: after the password, they were correctly challenged for MFA (MFA is the second factor — it comes after the password).

Why: MFA makes a stolen password useless on its own — the single most effective defence against account takeover, which starts most breaches.

Key step — migrating off Security Defaults: Microsoft doesn't allow Security Defaults and Conditional Access to run together, so I disabled Security Defaults to move to Conditional Access. This is an upgrade — Conditional Access does everything Security Defaults did (blanket MFA) plus exclusions (e.g. break-glass), conditions, and report-only testing that Security Defaults can't offer.

🚫 Day 3 — Block legacy authentication — CA002-Block-LegacyAuth
Setting	Value
Users	All users — excluding CA-BreakGlass-Exclude
Condition (Client apps)	Legacy only — Exchange ActiveSync + Other clients
Grant	Block access
Validation	What If tool (simulated legacy sign-in) → confirmed → enabled

Why: Legacy protocols (POP, IMAP, SMTP, older clients) use basic authentication and cannot perform MFA. Left open, an attacker can use them to bypass MFA entirely with just a stolen password. Blocking legacy auth closes that back door so MFA can't be sidestepped. Scoping the policy to only legacy clients leaves modern sign-ins untouched.

🧠 Day 4 — Identity Protection: risk-based policies — CA003 & CA004

Added two adaptive policies using Microsoft Entra ID Protection, which scores risk in real time from Microsoft's threat intelligence and machine learning.

Two types of risk:

Risk type	Question it answers	Classic signal	Automated response
Sign-in risk (CA003)	Is this login the real user?	Impossible travel, anonymous/Tor IP, malware-linked IP	Require MFA — verify the login now
User risk (CA004)	Is the account compromised?	Leaked credentials (password found in a dark-web breach dump)	Force password change — burn the stolen password

Prerequisite — SSPR: I enabled Self-Service Password Reset first, because the "force password change" response is meaningless if the user can't reset their own password. The two features depend on each other.

Both were built in report-only and validated with the What If tool (simulating high risk) before enabling.

Why it matters: MFA (CA001) is static — it challenges every sign-in the same way. Identity Protection is adaptive — it reacts to detected threats. Without it, a stolen password could sit unnoticed; with it, Microsoft's intelligence catches the leak and automatically forces a reset (user risk) and challenges suspicious logins with MFA (sign-in risk). It's the intelligent layer on top of the always-on baseline.

🎯 Key concepts demonstrated
Least privilege — only accounts that need admin rights have them.
Break-glass / emergency access — fail-safe admin access excluded from all policies.
Safe change management — report-only mode + the What If tool to validate before enforcing.
MFA enforcement — defends against stolen-password attacks.
Blocking legacy authentication — prevents MFA bypass via basic-auth protocols.
Risk-based Conditional Access — adaptive response to compromised accounts and risky sign-ins.
Security Defaults → Conditional Access migration — moving from a blunt baseline to granular, testable control.
Naming conventions — keeping a policy set auditable as it scales.
🧰 Skills & technologies

Microsoft Entra ID · Conditional Access · Entra ID Protection · Multi-Factor Authentication · Identity & Access Management · Self-Service Password Reset · Least Privilege · Defence in Depth · Security Change Management

✅ Outcome

A hardened Entra ID tenant with MFA enforced, legacy authentication blocked, emergency break-glass access protected, and adaptive risk-based remediation layered on top — the standard secure identity baseline for a Microsoft organisation, built and validated using professional rollout practices.

Part of an ongoing hands-on cloud security portfolio — building in public
