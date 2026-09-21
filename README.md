# hermes-skills

Public collection of [Hermes Agent](https://hermes.nousresearch.com/) skills
(reusable procedural-memory modules an AI assistant loads on demand).

Each subdirectory is one skill, following the standard `SKILL.md` format:
YAML frontmatter (name/description/version/tags) + a markdown body describing
when and how to use it.

## Skills in this repo

- **[steelman-self-check](./steelman-self-check/)** — A metacognitive
  self-check gate an AI runs before high-stakes verdicts/recommendations.
  Adapts a 5-dimension cognitive-blind-spot framework (Confirmation Bias,
  Identity-Protective Cognition, Actively Open-Minded Thinking, Bias Blind
  Spot, Intellectual Humility) to the model's own reasoning. v1.1 adds a
  mandatory-grounding requirement backed by LLM self-correction research
  (Huang et al. 2023 "LLMs Cannot Self-Correct Reasoning Yet", Chain-of-
  Verification, Anthropic's sycophancy research) — pure intrinsic
  self-critique without tool-call grounding is a known failure mode, so key
  checks in this skill require an actual search/read/execute, not just
  "thinking harder."

- **[messaging-only-credential-setup](./messaging-only-credential-setup/)** —
  How an AI agent should handle credential provisioning and content delivery
  when the user only has chat-platform access (Discord/Telegram/etc.), no
  terminal or filesystem. Covers checking actual access level before
  proposing a remediation path, writing secrets only to `.env` (never
  memory/skill files), and choosing inline text vs. file attachment vs. a
  hosted link based on what the user's device can actually open.

- **[secret-setup-no-terminal](./secret-setup-no-terminal/)** — Narrower
  companion to the above: the specific procedure for getting an API
  key/credential into an agent's `.env` when the only channel is messaging,
  including the informed-consent step before accepting a secret over chat
  and verifying the credential with a real API call before declaring success.

- **[context-budget-management](./context-budget-management/)** — How to
  decide what belongs in an AI agent's persistent memory (small, high-signal,
  read every turn) versus a skill (detailed, loaded contextually, no
  practical size ceiling), including a checklist for scrubbing personal
  data/credentials from a skill before sharing or publishing it outside its
  original profile (see `references/sharing-skills.md` for the full channel
  list — direct copy, snapshot export, private tap, public registry, or a
  plain public GitHub repo).

## Using these skills

Drop a skill's directory into your agent's skills folder (for Hermes:
`~/.hermes/profiles/<profile>/skills/` or the equivalent shared skills path)
and it becomes available for the agent to load contextually, or on explicit
request ("use steelman-self-check for this").

## License

MIT — see each skill's frontmatter for attribution.
