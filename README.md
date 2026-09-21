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

## Using these skills

Drop a skill's directory into your agent's skills folder (for Hermes:
`~/.hermes/profiles/<profile>/skills/` or the equivalent shared skills path)
and it becomes available for the agent to load contextually, or on explicit
request ("use steelman-self-check for this").

## License

MIT — see each skill's frontmatter for attribution.
