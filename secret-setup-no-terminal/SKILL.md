---
name: secret-setup-no-terminal
description: Use when a skill needs an API key but user has no terminal.
---

# Setting Up Secrets/Credentials Without Terminal Access

Procedure for getting a required API key/credential into `~/.hermes/.env` (or profile-equivalent) when the user's only channel is a messaging platform (Discord/Telegram/etc.) with no filesystem, SSH, or local CLI access to the machine running Hermes.

## When to Use
- A skill reports `setup_needed` / `missing_required_environment_variables` and the fix requires putting a secret into `.env`.
- The user wants to connect a new integration (Notion, GitHub, cloud provider, etc.) and you need a token/key from them.

## Procedure

1. **Confirm the user's actual access before proposing a path.** Do not default to "I'll open a local CLI prompt for you to type it into" — that only works if the user has terminal/SSH access to this machine. Ask, or check the platform notes for the session, first. Proposing an option the user cannot use wastes a turn and forces a correction.
2. **Try non-messaging paths first, in order:**
   - If the user does have terminal access: have them run `hermes setup` or edit `.env` directly themselves.
   - If not, but a `hermes dashboard` (authenticated web UI) is reachable from their device (needs the port exposed / a tunnel), offer that — the secret is typed into a web form, never into chat history.
3. **If neither path is available, get explicit, informed consent before accepting the secret over chat.** State the concrete risk in plain terms — the key becomes plaintext in the platform's permanent message history/logs, readable by anyone with access to that account or those logs — and wait for the user to explicitly accept before they paste it. Do not proceed on an assumption that speed matters more than the acknowledgement.
4. **The instant the secret arrives, write it straight to `.env`** (`touch`, `chmod 600`, replace any existing line for that key, re-`chmod 600`) — never relay it into memory, a skill file, a diary/note, or any other persisted text. It exists in exactly one place outside the chat log.
5. **Verify with a real call before declaring success.** Export the var and make one live API request that exercises the new credential (e.g. read a known resource) — do not tell the user it's ready on the strength of the write succeeding alone.
6. **After confirming it works, suggest the user delete their message containing the secret** from the chat. This doesn't undo platform-side log retention, but removes the most visible copy.

## Pitfalls

- **Getting the risk acknowledgement is not optional even when the user is moving fast or has already said yes to "just send it."** Sending a secret over chat is a one-way exposure the instant it's typed — state the risk plainly before it happens, not after.
- **Don't write the secret anywhere but `.env`.** A secret pasted into a diary entry, a skill's example, or a memory note turns a single one-time exposure into a durable, repeatedly-surfaced one.
