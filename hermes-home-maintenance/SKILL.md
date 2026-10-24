---
name: hermes-home-maintenance
description: "Audit and prune a Hermes home: snapshots, .bak, caches."
version: 0.1.0
author: Supachai Jaturaprom (supachai-j), Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [hermes, maintenance, backup, retention, housekeeping]
---

# Hermes Home Maintenance

Audit the Hermes home directory (`~/.hermes`) and, only with the owner's approval, prune what Hermes does not clean by itself. Companion to the article "Managing Hermes Agent: from structure to backups". It does not set up off-machine backups for you and it never reads secret contents.

## When to Use

- The owner asks "how big is Hermes home", "what can I delete", "is retention working", or disk is filling up.
- Setting up a weekly housekeeping job for a self-hosted Hermes.
- Don't use for: deleting conversation history (a data-owner decision), Docker or model caches, other users' profiles, or restoring from backup.

## Prerequisites

- Linux or macOS shell with `bash`, `du`, `find`, `df`, `awk`. `hermes` on PATH (used for `cron list` only).
- Scripts live in `scripts/` next to this file. If the skill was installed elsewhere, locate them with `search_files(pattern='audit.sh', target='files')`.

## Procedure

1. **Audit (read-only).** `terminal(command="bash <skill_dir>/scripts/audit.sh")`. Done when you can report: total size, top directories, snapshot count per label, `.bak` count and age, and whether a `sessions:` block exists in config.
2. **Compare with what the job claims.** Read the backup job's command (`hermes cron list`, then its script via `read_file`). If it passes `--keep N` together with `--quick`, the snapshot count may not match: `hermes backup --help` says `--keep` applies to full backups. Done when you state expected vs actual snapshot count.
3. **Dry-run the cleanup.** `terminal(command="SNAP_LABEL=<label> bash <skill_dir>/scripts/housekeeping.sh")`. `<label>` is the `-l` value of the quick-backup job. Without `SNAP_LABEL` snapshots are skipped. Done when you can list exactly what would be removed.
4. **Ask for approval** and show the dry-run line. Wait for an explicit yes. Do not combine this with any other deletion.
5. **Apply.** Same command plus `--apply`. Done when the output says `[APPLY]` and a second audit shows the new counts.
6. **Schedule (optional, owner approves).** Create a script-only weekly cron job (no LLM) that runs `housekeeping.sh --apply` with `SNAP_LABEL` set, delivered to the owner's channel. Run the dry-run by hand once before scheduling.

## Rules

- Never `cat`, print, or summarise `.env`, `auth.json`, `secrets/`, `vault/`, or `.bak` contents. The scripts only count and delete those files.
- Do not delete: `state.db`, `memories/`, `skills/`, `cron/`, `config.yaml`, any profile directory, or snapshots with a different label (manual and pre-update snapshots are deliberately kept).
- Retention of conversation data (`sessions.retention_days`, default per Hermes docs) is the data owner's decision. Report the current value; do not change it unprompted. Snapshots and off-machine backups keep old data after it is pruned from `state.db`.
- `KEEP` below 3 is refused by the script. Keep it that way.

## Pitfalls

- A label typo makes the snapshot step match nothing: the dry-run then shows `0 found`. Treat that as a failure, not as "nothing to do".
- Profiles have their own snapshots and `state.db`. `housekeeping.sh` only prunes the default home's snapshots; list profiles with `audit.sh` and ask before touching them.
- `.bak` files older than `AGE` days are removed even if you still wanted them. The dry-run count is the guard.
- Syntax-checked and run on one installation only. Test on your own copy first.

## Verification

- Dry-run output matches the audit numbers (same snapshot count, same `.bak` count).
- After `--apply`, `audit.sh` shows snapshots at `KEEP` and zero old `.bak` files, and `df` shows the space returned.
