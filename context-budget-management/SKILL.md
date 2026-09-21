---
name: context-budget-management
description: Use when adding rules or hitting memory/skill char limits.
---

# Context & Skill Budget Management

How to place information between persistent memory (`context_notes`, target="user") and skills for this profile, and how to avoid the mistakes that waste a write or corrupt routing.

## When to Use
- Adding, editing, or reviewing standing rules/preferences/identity facts for this user.
- Memory is near or at its character cap and needs to be trimmed.
- Moving detail out of memory into a new or existing skill.

## Procedure

1. **Decide placement first.**
   - Memory (`context_notes`, target="user"): facts needed almost every turn, small, low-volatility (identity, active standing rules/preferences).
   - Skill: anything detailed, looked up only sometimes, or that would push memory near its cap (career/background detail, full rule text with rationale, reference tables). A skill body has no practical size ceiling — treat it as the durable copy of record.

2. **Check remaining budget before writing to memory.** The save response reports a `usage` percentage — if it's already high, consolidate (replace/remove stale or verbose entries) in the SAME batch call as the new addition. `context_notes` writes are all-or-nothing: a write that would exceed the cap is rejected outright, it does not partially apply.

3. **When trimming memory to fit, back the full content up in a skill first**, and leave only a short pointer in memory (e.g. "full rules in skill 'x'"). Never let content be lost to a forced trim — expand the skill, not the compression of memory, when both can't fit.

4. **Skill `name` must be lowercase letters/digits/hyphens/underscores/dots only** — creation is rejected otherwise. If the user requests a specific-cased display name (e.g. "MyCustom-skill"), create the skill under a valid lowercase name and use the user's preferred casing only in prose/descriptions, never in the `name` field.

5. **Skill `description` must be ≤60 characters, one sentence, trigger-first, ending in a period.** The skill index truncates longer text and the routing signal is lost. Draft it short the first time instead of resubmitting past the limit repeatedly.

6. **After creating a skill meant to persist long-term** (rules backups, reference material), note that a skill created during a live/foreground session has no curator provenance marker — the curator will not auto-back-up or auto-archive it, but it also won't be touched by auto-consolidation. If durability matters, tell the user they can run `hermes curator adopt <name>` (and `pin` it) to bring it under curator management, or `hermes curator backup --reason "..."` for an ad-hoc snapshot before a risky edit.

7. **Make backup a habit, not a one-time fix.** Before any large edit to a durable skill, run `hermes curator backup --reason "<why>"` — it snapshots the whole `skills/` tree (tar.gz) to `.curator_backups/<timestamp>/` in seconds. Restore a whole snapshot with `hermes curator rollback --id <timestamp>` (`--list` to see available ones), or roll back a single file-level mutation with `hermes curator rollback <ledger_id>` after finding the id via `hermes curator ledger --skill <name>`. `hermes curator status` / `list-unmanaged` confirm whether a skill is actually protected.

8. **Before sharing or publishing any skill outside this profile, scan it for personal data or secrets first.** A skill built for one user accumulates names, employer, account handles, or credentials over time; pushing it to a public registry or shared repo (`hermes skills publish ... --to github/clawhub`, a shared `hermes skills tap`) makes that exposure effectively permanent — other tooling can mirror or cache a public entry before you can retract it. Strip to a template copy before any public channel; direct file copy or a private tap is fine as-is. See `references/sharing-skills.md` for the full channel list and commands.

## Pitfalls

- **The memory character cap counts raw Unicode characters — not UTF-8 bytes, not LLM tokens.** Don't translate memory content to English to "save space" without first counting characters of both versions. Thai (and other function-word-light languages) can be character-denser per idea than English, which needs more articles/prepositions — so translating can *increase* character usage even though it reduces token/byte cost at LLM inference time. These are two different constraints (a hard character ceiling on this write vs. token cost on every future API call); identify which one is actually binding before optimizing for it, and verify with an actual character count rather than a general "language X is more efficient" assumption.
- **Keep memory pointers in sync with real skill names.** Since names are forced lowercase, a pointer written with the user's requested-but-rejected casing will not resolve to the actual skill file.
- **A skill created by request during this session is the user's, not the curator's, going forward** — if a later review pass tries to patch it, expect (and respect) a user-owned/protected refusal; that skill is edited only in a live session with the user present.
- **`hermes curator adopt` + `pin` change lifecycle handling, not editing rights.** Adopting and pinning a user-owned skill protects it from auto-archival/auto-consolidation, but it does NOT make it curator-editable — a skill the user asked a foreground session to create stays off-limits to autonomous patches regardless of adopt/pin state.
- **When splitting a recurring artifact (diary, log, per-period report) into files, size the period to the trigger pattern, not calendar habit.** An event-driven/irregular trigger (e.g. "write an entry when something significant happens") produces sparse, hard-to-scan files at daily granularity; align the file period to the review cadence the content actually serves instead — e.g. ISO week (`date.isocalendar()`, not manual day-of-month math) for a weekly retrospective — so each file accumulates enough events to show a trend.
- **Before picking where a recurring artifact lives long-term, check how the user actually reads it, not just where it's easiest to write.** A local file the agent can `read_file`/`patch` fine may be unreadable to the user themselves if their only access is a messaging platform on mobile (no viewer app for raw `.md`/text). Confirm the read path works for the user's real device before treating a storage choice as settled; a service with a maintained mobile app and durable per-item URL (e.g. Notion) is worth the setup cost once cross-session revisiting matters, but is unnecessary if the user already has a viewer for the artifact's format.
