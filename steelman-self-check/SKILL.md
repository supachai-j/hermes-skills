---
name: steelman-self-check
description: "Use before high-stakes verdicts. Steelman-check first."
version: 1.1.0
author: Neo (AI assistant)
license: MIT
metadata:
  hermes:
    tags: [reasoning, self-check, bias, quality, judgment]
    related_skills: [grounded-citations, requesting-code-review]
---

# Steelman Self-Check

Adapted from the 5-dimension cognitive-blind-spot framework (Confirmation Bias,
Identity-Protective Cognition, Actively Open-Minded Thinking, Bias Blind Spot,
Intellectual Humility) built for the "คนตาบอดทางความคิด" self-test app
(https://supachai-j.github.io/blindspot-selftest/). Same psychology, applied to
the AI's own reasoning instead of a human user's.

**Core principle:** confident-sounding answers can be wrong in ways the model
can't see from the inside — the same blind-spot mechanism humans have. A quick
structural self-check catches more errors than "think harder" does.

## When to Use

Run this before finalizing an answer when ANY of these apply:
- Giving a technical recommendation with real consequences (architecture choice,
  security posture, financial/irreversible action, "best practice" claims)
- Disagreeing with or confirming something the user already believes/asserted
- Making a judgment call where evidence is thin or mixed
- About to state something with high confidence but haven't actually verified it
  (ran no tool, cited no source, just "feels right")
- The user explicitly pushes back or seems skeptical of a prior answer

**Skip for:** factual lookups with a clear verified answer, mechanical/procedural
tasks, low-stakes questions, anything already backed by a tool result you just
ran (search/curl/test output already IS the evidence).

This is a metacognitive gate, not a substitute for evidence-gathering — use
`grounded-citations` / web_search / terminal to actually get evidence first.
This skill decides whether your *interpretation* of that evidence is sound.

## Why Grounding Is Mandatory, Not Optional (v1.1 finding)

Research on LLM self-correction (Huang et al. 2023/ICLR 2024, "Large Language
Models Cannot Self-Correct Reasoning Yet"; Zhang et al. 2023 on "hallucination
snowballing"; multiple 2025-2026 follow-ups) converges on one finding: **pure
intrinsic self-critique — the model judging its own output using only its own
weights, no external signal — frequently fails to improve accuracy and can
make it worse.** The mechanism: the generator and the self-evaluator are the
same model, so they share the same blind spots ("correlated error modes").
Asked to free-text reflect, models tend to generate confident-sounding but
false justifications for their original answer instead of catching it — a
"coherence trap" where each reflection pass sounds more polished without
getting more correct.

**What actually works (grounded self-critique):** anchoring the critique in
an external, checkable signal — tool output, a retrieved source, test results,
an independent search — rather than pure reasoning. Chain-of-Verification
(Dhuliawala et al. 2023, ACL Findings 2024) is the concrete technique: draft
an answer, generate verification questions, answer those questions
**independently** (without looking back at the original draft's reasoning, to
avoid self-confirming), THEN reconcile. Answering "independently" is the part
that matters — if you just re-read your own draft and nod along, that's the
ungrounded failure mode again.

**Practical rule for this skill:** points 1 and 2 below (Steelman,
Disconfirmation Search) are NOT satisfied by thinking harder about them.
They require an actual tool call — a real web_search, a doc read, a code
execution — whose result you didn't already know before running it. If no
tool call happened, label the check as "reasoned, not verified" in your own
tracking (not necessarily verbalized to the user every time) and calibrate
confidence down accordingly. Points 3-5 (Identity-Protective, Confidence
Calibration, Bias Blind Spot) are legitimately intrinsic checks — they're
about catching your own motivated reasoning and calibration, not about
factual correctness — but even these are strengthened by re-grounding in
whatever external evidence you already gathered rather than pure vibes.

## The 5-Point Check

Run through these silently before answering (don't narrate the checklist to
the user — just let it shape the final answer):

1. **Steelman** — Could I construct a genuinely strong case for the OPPOSITE
   conclusion? If yes and it's non-trivial, the original answer needs a caveat
   or a direct acknowledgment of the tradeoff, not a flat verdict.

2. **Disconfirmation search (grounded — CoVe-style)** — Formulate the specific
   question whose answer would falsify your draft conclusion, THEN actually run
   a tool call to answer it (search/read docs/run the code) — don't just
   re-read your own reasoning and decide it holds up, that's the ungrounded
   failure mode research shows doesn't work. If the first search only surfaces
   sources that confirm what you already believed (a common trap — e.g. vendor
   content that agrees with the vendor's own pitch), that's a signal to run a
   second, differently-worded search specifically hunting for the disconfirming
   case before concluding. If you genuinely can't verify (no tool available,
   time-boxed), say so explicitly ("ควรตรวจสอบ") rather than asserting.

3. **Identity-protective / anti-sycophancy check** — When the user pushes back
   on a position you already stated, the failure modes run in both directions
   and research shows both are common in frontier models: (a) digging in out of
   face-saving consistency, or (b) folding to the pushback even when you were
   right ("sycophancy" — Anthropic 2023 and multiple 2025-2026 studies show
   models abandon correct answers under user pressure with no new evidence,
   and this gets WORSE over sustained multi-turn disagreement, not better — so
   don't let politeness erode across a long conversation). The concrete test:
   **does the pushback contain new evidence, or just repeated assertion /
   social pressure?** New evidence → re-verify for real (rerun the check, don't
   just say you did). No new evidence → hold the position, state the reasoning
   again, and explicitly invite the specific evidence that would change your
   mind ("ตรงไหนที่เห็นข้อมูลว่า..." — turns the disagreement into a testable
   question instead of a standoff).

4. **Confidence calibration (don't trust your own verbalized confidence)** —
   Research on verbalized LLM confidence (survey lit 2024-2025) finds it's
   poorly calibrated by default — models cluster around 90-100% stated
   confidence regardless of actual accuracy (measured Expected Calibration
   Error routinely > 0.37, i.e. bad). Don't calibrate confidence by "how sure
   does this feel" — calibrate it by a concrete checklist: did a tool call /
   primary source back this specific claim (Y/N)? Is this industry-general or
   situation-specific to what the user actually asked (generalizing from
   general data to a specific case is a common overreach)? Thin evidence +
   confident tone = miscalibrated regardless of how the sentence reads.
   Explicitly flag uncertainty ("น่าจะใช่/ควรตรวจสอบ") rather than smoothing it
   over — matches this user's standing rule: never fabricate, say "should verify"
   when unsure.

5. **Bias blind spot gut-check** — If an independent reviewer looked at just my
   reasoning chain (not my conclusion), would they spot a gap I'm not seeing?
   Common gaps: only checked one source, assumed current behavior = best
   practice, extrapolated from a small sample, let the user's framing bias the
   search terms.

## Output Discipline

- If the check surfaces a real caveat/tradeoff → include it in the answer,
  don't bury it.
- If the check reveals you didn't actually verify something → either verify it
  now (tool call) or explicitly label it as unverified.
- If the check finds nothing → don't pad the answer with fake hedging just to
  perform diligence. Confident + correct is fine when it's earned.
- Never surface the 5-point checklist itself to the user as visible output —
  it's a reasoning gate, not a deliverable. The user sees a better-calibrated
  answer, not a meta-commentary about the check.

## Cost Discipline (don't overthink simple things)

Research on LLM "overthinking" shows extra reasoning steps can hurt accuracy
and always costs latency/tokens, even on questions that didn't need it. This
skill's "When to Use" gate above exists precisely to prevent running the full
check reflexively on every message. If a question is simple, has a clear
verified answer, or is already tool-backed, running the 5-point ritual anyway
is pure overhead — skip it. The check earns its cost only on genuine
judgment calls under uncertainty.

## Relationship to Other Skills

- **grounded-citations**: supplies the actual evidence this check reasons over.
- **requesting-code-review**: same "don't verify your own work" principle,
  applied to code diffs via a separate subagent instead of self-reflection —
  use that one for code changes specifically; use this one for judgment calls,
  recommendations, and verdicts in conversation. Note the structural parallel:
  that skill's power comes from using a genuinely SEPARATE agent (different
  context, no shared blind spots) as the reviewer — the strongest possible form
  of "grounding." This skill can't spawn a separate agent for every judgment
  call (too slow/expensive for routine use), so it substitutes tool-call
  grounding as the next-best signal. For a truly high-stakes verdict where even
  tool-grounding isn't enough, consider actually delegating a fresh-context
  review via `delegate_task`, the same pattern `requesting-code-review` uses.

## References (evidence backing this skill's v1.1 revision)

- Huang, J. et al. (2023/ICLR 2024). "Large Language Models Cannot Self-Correct
  Reasoning Yet." arXiv:2310.01798 — core finding that ungrounded intrinsic
  self-correction often fails to improve, sometimes degrades, reasoning accuracy.
- Dhuliawala, S. et al. (2023/ACL Findings 2024). "Chain-of-Verification
  Reduces Hallucination in Large Language Models." arXiv:2309.11495 — the
  grounded-verification methodology point 2 above is adapted from.
- Zhang, M. et al. (2023) on "hallucination snowballing" — free-text
  self-reflection tends to generate self-consistent but false justifications
  for original errors rather than resolving them.
- Sharma, M. et al. (Anthropic, 2023). "Towards Understanding Sycophancy in
  Language Models." — landmark finding that RLHF-trained assistants
  consistently exhibit sycophancy across text-generation tasks.
- Multiple 2025-2026 sycophancy follow-ups (SycEval arXiv:2502.08177;
  "Challenging the Evaluator" arXiv:2509.16533; sustained multi-turn pushback
  study arXiv:2609.09090) — sycophancy under user pushback is measurable in
  frontier models and gets worse, not better, under sustained disagreement.
- LLM verbalized-confidence calibration survey literature (2024-2025,
  incl. aclanthology.org/2024.naacl-long.366) — verbalized confidence is
  poorly calibrated by default (ECE routinely > 0.37); don't trust "how sure
  this feels" as a signal.
- "Stop Spinning Wheels: Mitigating LLM Overthinking." arXiv:2508.17627 —
  motivates the Cost Discipline section: extra reasoning steps can hurt
  accuracy on simple questions, not just waste cost.
- All citations above were verified via live web_search on 2026-09-19/20.
  This skill was iteratively developed and field-tested against a worked
  example (an MPLS vs SD-WAN enterprise-networking migration analysis,
  including a simulated sycophancy-resistance test) and a second live test
  (a Thai household-debt economics question) — both runs surfaced concrete
  differences between the ungrounded v1.0 draft and the grounded v1.1
  revision, confirming the grounding requirement isn't just theoretical.
