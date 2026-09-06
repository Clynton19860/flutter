# DartPad: copy-paste ready

Twelve self-contained pads for Day 1. **Every file in this folder has been run on
Dart 3.13.2 and exits clean.** Open a file, select all, paste into
**https://dartpad.dev**, press **Run**. Nothing needs merging or editing first.

| File | Handbook section | Run prints |
|---|---|---|
| `01_variables.dart` | Part 6 · Variables | one line of interpolated values |
| `02_null_safety.dart` | Part 6 · Null safety | `null` / `none` / `1` / `5` |
| `03_field_promotion.dart` | Part 6 · Null safety | `4`: the field-promotion trap |
| `04_functions.dart` | Part 6 · Functions | `1400.0` / `1500.0` / `42` |
| `05_classes.dart` | Part 6 · Classes | `ZAR 1450.00`, the JSON map, `ZAR 900.00` |
| `06_collections.dart` | Part 6 · Collections | the built list, `[VW]`, `3300.0` |
| `07_switch_sealed.dart` | Part 6 · Switch expressions | the three cover factors, `young driver` |
| `08_async.dart` | Part 6 · Async | `quote-q1`, countdown 3→0, `~505 ms` |
| `09_mixins_extensions.dart` | Part 6 · Mixins and extensions | `[QuoteService] quoting…`, `R 1450.00` |
| `10_lab_1_2_STARTER.dart` | LAB 1.2 | the target output they are aiming for |
| `11_lab_1_2_SOLUTION.dart` | LAB 1.2 | published after the lab |
| `12_lab_1_3_COMPLETE.dart` | LAB 1.3 | quote, states, `3 parallel quotes in ~1500 ms` |

---

## Two things that differ from the handbook, on purpose

**1. `12_lab_1_3_COMPLETE.dart` is one paste, not two.** The handbook asks
delegates to keep their Lab 1.2 pad, delete its `main()`, move an
`import 'dart:async';` to the top and append the new code. In a room of twenty
that is where ten minutes goes. This file is the finished article, new pad,
one paste, Run. It takes about 6 seconds; the delays are deliberate.

**2. `10_lab_1_2_STARTER.dart` prints its own target.** The handbook starter has
an empty `main()`, so pressing Run does nothing and delegates assume they broke
something. This version compiles from the first second and prints the exact
output they are working towards. They delete that block as they fill in the TODOs.

---

## Expected squiggles: say this once at the start

Two files report issues in DartPad **on purpose**. Everything else is silent.

| File | DartPad says | Why it is correct to ignore |
|---|---|---|
| `02_null_safety.dart` | 3 issues | Flow analysis has already *proved* `nickname` is null on the `?.` line and non-null after `??=`, so it thinks both operators are redundant. That is the lesson running live. |
| `04_functions.dart` | 1 issue | "Use a function declaration rather than a variable assignment", but storing a function **in a variable** is the point being made. |
| `10_lab_1_2_STARTER.dart` | 7 issues | The 7 `// TODO:` markers. The analyser lists TODOs. Use it as a progress bar. Delete each one as you implement it and the count walks to 0. |

The line for the room: **yellow means the analyser has an opinion; red means it
will not run.** Nothing today is red. And in real code the value comes off a
network call and the analyser can prove nothing, which is when `?.` and `!`
earn their keep.

---

*MO Integrations · Flutter Mobile Application Development · Day 1 of 5*
