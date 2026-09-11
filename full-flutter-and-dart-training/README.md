# Full Flutter and Dart Training

**Flutter for Java Developers · 8-Day Programme**

Course materials: the slide deck and a delegate handbook for each of the eight
days.

---

## Contents

| Day | Topic | Handbook | Slides |
|---|---|---|---|
| 1 | Getting Oriented | [Day1_Handbook.md](handbooks/Day1_Handbook.md) | `Flutter_Java_Day1_Getting_Oriented.pptx` |
| 2 | Dart Core | [Day2_Handbook.md](handbooks/Day2_Handbook.md) | `Flutter_Java_Day2_Dart_Core.pptx` |
| 3 | Dart Advanced | [Day3_Handbook.md](handbooks/Day3_Handbook.md) | `Flutter_Java_Day3_Dart_Advanced.pptx` |
| 4 | Errors, Async and Isolates | [Day4_Handbook.md](handbooks/Day4_Handbook.md) | `Flutter_Java_Day4_Errors_Async_Isolates.pptx` |
| 5 | Flutter Foundations | [Day5_Handbook.md](handbooks/Day5_Handbook.md) | `Flutter_Java_Day5_Flutter_Foundations.pptx` |
| 6 | Layout | [Day6_Handbook.md](handbooks/Day6_Handbook.md) | `Flutter_Java_Day6_Layout.pptx` |
| 7 | Forms, Navigation and State | [Day7_Handbook.md](handbooks/Day7_Handbook.md) | `Flutter_Java_Day7_Forms_Navigation_State.pptx` |
| 8 | Data, Testing and Shipping | [Day8_Handbook.md](handbooks/Day8_Handbook.md) | `Flutter_Java_Day8_Data_Testing_Shipping.pptx` |

---

## The shape of the course

**Days 1–4 are Dart, with no Flutter at all.** That is deliberate: every Flutter
problem is a Dart problem wearing a costume, and a framework written in a
language you half know is a framework you will fight for months.

**Days 5–8 are Flutter**, building one application — *OrderFlow* — from the
domain model written in a browser on Day 2.

Each day runs four modules with three labs, and every lab builds on the last. By
the end of Day 8 the app calls a real HTTP API, stores data on the device, has
unit, model and widget tests, and builds a signed release.

## What is in a handbook

Each one is the complete delegate reference for that day:

- The agenda and per-module objectives
- Every code example from the slides
- **Lab starters, full solutions and expected output**
- A Java → Dart translation table where the day warrants one
- A symptom-to-fix troubleshooting table
- Every link used that day

The handbooks are written to be usable without the slides — delegates should not
be reconstructing anything from memory.

## The running example

`OrderFlow`, an order capture app. The domain — `Product`, `OrderLine`, `Order`
and `OrderStatus` — is built in DartPad on Day 2, extended with a sealed
`OrderState` on Day 3, and put on a screen from Day 5.

**The architectural rule that runs through all eight days:** the domain knows
nothing about the user interface. That is what makes the Day 8 test suite run in
milliseconds.

## Conventions used throughout

- Currency is South African Rand, formatted with a `Money` extension on `double`
- `flutter analyze` clean is a requirement, not a suggestion
- No hard-coded colours and no raw font sizes — everything comes from the theme
- Every failure becomes a sentence a customer could read
