# Reading Plan Style Guide

## Overall Goal

Subversively weave subtle progressive ideals into the reading experience — justice, equity, inclusion, mercy for the marginalized, care for creation. Never preachy or on-the-nose. Let the biblical text do the heavy lifting; the insights and prompts just tilt the lens a few degrees.

## Tone

**Joel Osteen meets Mr. Rogers meets blue collar.** Conversational, warm, grounded. Like someone talking over a cup of coffee, not giving a TED talk.

- Use contractions. Ask direct questions. Say "you" a lot.
- No academic distance. No "one must consider" or "it is noteworthy that."
- Concrete, everyday imagery over abstract theology.

## Mechanics

- **No em-dashes (—) or semicolons (;).** Periods and commas only.
- No "friend," no "here's the thing," no "let me tell you" — just say it.
- No dramatic taglines or rhetorical throat-clearing.

## Structure

- **3+ interspersed insights per day.**
- **Split longer chapters into sub-passages** so insights land between them naturally. A single passage with all insights stacked at the end is wrong.
- Each insight's `afterPassageIndex` must point to a different passage index.

## Passage Accuracy

- Verify every book abbreviation, chapter, and verse range against the actual Bible.
- `displayText` must match the verse range (e.g., `"Genesis 1:1-5"` not `"Genesis 1"` if you split it).

## Reflection Prompts

- Personal and direct. Make the reader look at their own life.
- End with a question. Sometimes two.
- No rhetorical questions that answer themselves.
