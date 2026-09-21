# Sharing a Hermes skill outside the current profile

Channels, simplest to most formal. Pick the least formal one that reaches the intended audience.

1. **Direct file copy.** A skill is just a folder (`SKILL.md` plus optional `references/`, `templates/`, `scripts/`). Copy the directory into the target profile's `skills/` tree — no command needed.
2. **`hermes skills snapshot export <file>.json`** / **`snapshot import <file>.json`** — bulk export/import of installed skill config, for replicating a whole setup across machines or profiles.
3. **`hermes skills tap add <owner>/<repo>`** — register a GitHub repo (can be private) as a skill source; team members run `hermes skills install <owner>/<repo>/<skill>` from it. Default choice for team/org sharing since access control is just repo permissions — nothing becomes publicly discoverable.
4. **`hermes skills publish <path> --to github --repo <owner>/<repo>`** or **`--to clawhub`** — publishes to a registry other Hermes users can discover and install from directly. Public and effectively permanent once picked up.
4b. **Plain public GitHub repo, no `hermes skills` tooling** — valid when the user just wants a browsable public repo (e.g. "put this skill on GitHub") rather than registering it in Hermes's tap/install mechanism. Copy just the skill directory (e.g. `steelman-self-check/SKILL.md`, not the whole profile) into a fresh folder, add a short `README.md` describing the repo (skills are just `SKILL.md` + optional `references/`/`templates/`/`scripts/`, no build step), then `git init` + `gh repo create <name> --public --source . --push` — same EMU-account-switch caveat as any other public-repo creation (see `github`/`static-webapp-github-pages` skills). This produces a plain, discoverable repo without depending on `hermes skills publish` being available or configured.
5. **`.well-known/skills/index.json` on an owned domain** — for orgs that already run a docs site; discovered via `hermes skills search <domain> --source well-known`.

## Gate before channels 3–5 (and 4b)

Anything leaving the local machine to a shared repo or public registry: scan the skill body and any `references/`/`templates/` files for personal names, employer/account details, tokens, or credentials first. Personal data hides in more places than the visible prose — check specifically:
- the `author:` frontmatter field (often written as `Neo (<User>'s personal AI assistant)` or similar during personal-profile use — genericize to just the assistant/tool name before publishing)
- any "References"/"Verified via..." trailer that names the user or links to a private artifact (a personal Notion page, an internal doc URL) the intended public audience cannot open — either drop the reference or rephrase it as "verified via live testing on <date>" without the private link

Redact or fork a template copy with those stripped — once published publicly, other tooling may mirror or cache it, so deleting the source afterward does not guarantee removal everywhere. After stripping, `grep` the final copy for the user's name/handle as a cheap confirmation nothing was missed, and verify the *published* copy (raw file over HTTP, not the local one) since the sanitization edit and the push are two separate steps that can drift.
