Entra ID Identity Hardening Lab

A hands-on lab where I hardened a Microsoft Entra ID tenant against account-takeover attacks by building a Conditional Access baseline: enforced MFA, blocked legacy authentication, and protected emergency admin access — using safe rollout practices (report-only + the What If tool) before enabling anything.

Platform: Microsoft Entra ID · Conditional Access Licensing: Microsoft Entra ID P2

What I built

I set up my own Entra ID tenant and configured a real, hardened identity baseline — the kind every secure Microsoft organisation runs.

Accounts & structure

Created a dedicated admin account, LabAdmin, with the Global Administrator role and an Entra ID P2 licence.
Created 3 standard test users (Chris Green, Bala Sandhu, Shahid Ghosi), each P2-licensed and with no admin rights — representing normal employees (least privilege).
Created 2 break-glass emergency admin accounts (bg-emergency01, bg-emergency02) with permanent Global Administrator.
Created a security group CA-BreakGlass-Exclude containing both break-glass accounts.
Day 1 — Break-glass emergency accounts

I created two emergency admin accounts and put them in an exclusion group.

Why: Break-glass accounts are emergency logins that are excluded from the security policies that protect everyone else. If I ever misconfigure a policy and lock everyone out — including myself — these accounts are the guaranteed way back in. They're cloud-only, have permanent admin (so they work even if other systems fail), and there are two of them for redundancy. Excluding them via a group means every future policy just excludes the same group.

Day 2 — Enforce MFA for all users (CA001)

I built Conditional Access policy CA001-Require-MFA-AllUsers:

Users: All users, excluding the CA-BreakGlass-Exclude group.
Target: All cloud apps.
Grant: Require multi-factor authentication.

I created it in report-only first, confirmed it evaluated correctly in the sign-in logs, then enabled it. I verified enforcement by signing in as a test user — after entering the password, they were correctly challenged to set up MFA (MFA is the second factor, so it comes after the password).

Why: MFA makes a stolen password useless on its own — it's the single most effective defence against account takeover, which is how most breaches begin.

Key step — migrating off Security Defaults: Microsoft doesn't allow Security Defaults and Conditional Access to run at the same time, so I disabled Security Defaults to move to Conditional Access. This is an upgrade, not a downgrade — Conditional Access does everything Security Defaults did (blanket MFA) plus exclusions (e.g. break-glass), conditions, and report-only testing that Security Defaults can't offer.

Day 3 — Block legacy authentication (CA002)

I built Conditional Access policy CA002-Block-LegacyAuth:

Users: All users, excluding CA-BreakGlass-Exclude.
Conditions → Client apps: only the legacy options (Exchange ActiveSync + Other clients).
Grant: Block access.

I validated it using the What If tool — simulating a legacy sign-in for a test user and confirming CA002 would apply — then enabled it.

Why: Legacy protocols (POP, IMAP, SMTP, older clients) use basic authentication and cannot perform MFA. If left open, an attacker can use them to bypass MFA entirely with just a stolen password. Blocking legacy auth closes that back door, so MFA can't be sidestepped.

Key concepts demonstrated
Least privilege — only accounts that need admin rights have them.
Break-glass / emergency access — fail-safe admin access excluded from all policies.
Report-only mode + What If tool — validate a policy's behaviour before enforcing it (safe change management).
MFA enforcement — defends against stolen-password attacks.
Blocking legacy authentication — prevents MFA bypass via basic-auth protocols.
Security Defaults vs Conditional Access — why you migrate from the blunt baseline to granular, testable control.
Naming convention — CA + number + purpose + scope keeps a policy set auditable as it grows.
Result

A hardened Entra ID tenant with MFA enforced, legacy authentication blocked, and emergency break-glass access protected — the standard secure identity baseline for a Microsoft organisation, built and validated using professional rollout practices
