# School content schema (one JSON per school → content/schools/<id>.json)

{
  "id": "reiki",
  "name": "Reiki",
  "tagline": "one short line",
  "overview": "2-4 sentences: what this is, where it comes from, what it's for",
  "kind": "traditional" | "evidence",
  "framing_note": "honest line: traditional practice (experiential, not medical) OR what research supports",
  "teachings": [ { "id": "reiki.t1", "title": "...", "body": "80-140 words, plain, instructional" } ],   // 4-5
  "routines": [                                                                                          // EXACTLY 25
    { "id": "reiki.r01", "title": "...", "group": "starter|core|deep|restorative",
      "minutes": 5, "purpose": "one line — what it's for",
      "steps": ["step 1", "step 2", "..."],            // 4-8 concrete steps
      "safety": "" ,                                    // fill when warranted
      "free": true }                                    // exactly ONE routine per school is free
  ],
  "sources": ["Author/Body, Title, year — what it supports"]                                             // 5-10 elite sources
}

Rules: experiential framing, NO medical/cure claims; traditional practices labeled traditional;
safety notes for cold/heat, breath retention, pregnancy, heart conditions; calm plain English.
