---
name: messaging-only-credential-setup
description: Setup and content delivery for messaging-only (no filesystem) users.
---

# Operating Within a Messaging-Only Session

How to handle tasks for a user who reaches the agent only through a chat platform (Discord/Telegram/etc.) and has no terminal, SSH, or filesystem access to the backend host. Covers two recurring problem classes: provisioning third-party credentials, and delivering generated documents/files back to the user.

## When to Use
- A skill reports a missing required env var (e.g. `NOTION_API_KEY`) and the user's platform is messaging-only.
- You're about to hand the user a generated artifact (report, diary, long document) and need to decide inline text vs. file attachment vs. a hosted link.
Check the session's actual access before choosing a path in either case — do not assume based on what would be ideal.

## Part A — Credential Setup

1. **Check whether a low-exposure intake path is actually reachable this session** before offering it. "I'll open a local CLI prompt for you" or "use `hermes setup`" are only valid if the user can reach a terminal on that host — for a pure messaging user they are not, and offering them anyway is a promise you can't keep. Ask the user directly whether they have terminal/SSH access rather than assuming either way.
2. If a terminal/dashboard path is NOT reachable, lay out the trade-off explicitly and let the user decide — don't decide for them:
   - Pasting the secret directly in chat is the only path left, but it lands in the platform's permanent message history/logs in plaintext.
   - `hermes dashboard` (web UI with auth) is more secure but needs the agent to start it and the user to reach the port/URL from their device — extra setup, not always feasible (e.g. no public IP/tunnel).
3. Once the user consents and pastes a secret, write it straight to `~/.hermes/.env` — never into memory (`context_notes`) or a skill file, both of which persist as plaintext in the agent's own knowledge base and get re-read every session:
   ```bash
   ENV_FILE="$HOME/.hermes/.env"
   touch "$ENV_FILE" && chmod 600 "$ENV_FILE"
   grep -v "^KEY_NAME=" "$ENV_FILE" > "$ENV_FILE.tmp" 2>/dev/null || touch "$ENV_FILE.tmp"
   mv "$ENV_FILE.tmp" "$ENV_FILE"
   echo "KEY_NAME=<value>" >> "$ENV_FILE"
   chmod 600 "$ENV_FILE"
   ```
   Dedupe the existing line for that key first — appending blindly leaves stale duplicate keys that shadow each other depending on load order.
4. **Test the credential with a real API call immediately** (e.g. read a known resource) rather than trusting that the write succeeded — a typo or truncated paste is otherwise only caught on the next unrelated failure.
5. After confirming the credential works, tell the user they can delete the chat message containing the plaintext secret now that it's safely stored — the risk window is shortest if closed right away.

## Pitfalls (credential setup)
- Don't present a remediation path as an option before confirming it's reachable from the user's actual session/platform — verify access level (terminal vs. messaging-only) first, then choose which paths to offer.
- Never store a raw secret in memory or a skill body "temporarily to remember it" — both are read back into every future prompt, turning a one-time exposure into a standing one.
- Never let "it's just an integration token, not a full account password" become a reason to skip getting explicit consent — the consent belongs to the user's risk to take, not the agent's to assume.

## Part B — Delivering Generated Content

A file that opens fine on the machine that made it can be unreadable on the device the user actually reads from — a messaging-only user is very often on mobile, where there is no default app for `.md`/raw text files and a file attachment just sits there unopenable.

1. **Default to inline chat text for anything meant to be read immediately.** Reformat the content into the platform's native markdown (headers, bold, lists) and paste it directly in the reply rather than attaching a file — this works on every device with zero extra apps.
2. **Only attach a file when the format requires it** (an actual PDF/image/spreadsheet the user will open in a dedicated app they already have) or when the user explicitly asks for a downloadable file.
3. **For content that must persist and be browsable later** (a growing log, a document the user revisits across sessions), don't keep re-pasting it into chat — stand it up in a service with its own mobile app and durable URL (e.g. Notion) so the user has a bookmark instead of scrolling chat history.
4. **If a delivery format fails, ask what specifically broke** (no app to open it / blank content / garbled text) before guessing at a fix — "can't read it" has several distinct root causes (missing app, empty render, encoding) that each need a different fix, and jumping straight to a rewrite risks solving the wrong one.

### Pitfalls (content delivery)
- Don't assume a generated file is readable just because it opens correctly in your own tooling (`read_file`, terminal) — that only proves the bytes are valid, not that the user's device has a viewer for that extension.
- Don't keep defaulting to file attachments after one has already failed to open for the user — switch strategy (inline text or a hosted link) instead of resending the same format.
