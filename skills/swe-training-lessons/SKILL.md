---
name: swe-training-lessons
description: Generate programming lessons with exercises, optional scaffold code, and build assets for practicing software engineering concepts. Use when creating tutorial-style or drill-style lessons for a specified language, topic, difficulty, scaffolding mode, theme, or instructor voice.
---

# SWE Training Lessons

Create programming lessons that teach or drill a software development concept through short exercises.

## Inputs

Before writing files, gather the following information from the request:
- **Topic**: language and subject, e.g. "Golang - Core standard library interfaces".
- **Theme**: optional scenario for prose, examples, and code. If absent, use a neutral instructive tone.
- **Instructor**: optional personality or referenced file that controls explanations and code voice. Blend naturally with the theme if both are provided.
- **Difficulty**: Easy, Medium, or Hard. Default: Easy.
- **Lesson Style**: Instructional or Drilling. Default: Instructional.
- **Scaffolding Mode**: Normal, Bare, or None. Default: Normal.
- **Exercise Count**: default 8-12.
- **Output directory**: default `./[language]-[skill]-[lesson_style]-[difficulty]/`, with all parts derived from the topic and normalized to lowercase kebab-case. Example: `./golang-core-standard-library-interfaces-instructional-easy/`.

To make sure the user gets what they want, before planning anything else, output the settings you will be considering. Use the following format:

```
Current lesson settings:
- Topic: ...
- Difficulty: ...
- Lesson Style: ...
...
```

Ask the user for feedback or any changes. If the user says it's ok, proceed to planning out the lesson, and presenting the lesson plan.

## Options

### Difficulty

- **Easy**: fundamentals, avoiding off-topic constructs where possible. Exercises take 2-5 minutes.
- **Medium**: fundamentals plus common surrounding patterns. Exercises take 5-10 minutes.
- **Hard**: mastery problems that are more freeform and require deeper thinking. Exercises take 10-30 minutes.

### Lesson Style

- **Instructional**: teaches concepts with explanations and examples, then exercises.
- **Drilling**: keeps definitions brief, minimizes hand-holding and scaffolding, and emphasizes repeated practice.

### Scaffolding Mode

- **Normal**: follow the regular scaffolding guidelines.
- **Bare**: include files for the user to modify, with comments guiding the program shape. Include ubiquitous constructs such as main functions, imports, and includes as applicable, but nothing else.
- **None**: generate no source scaffolding code and do not reference files in exercises. Make exercises detailed enough that learners can deduce the program shape. The Makefile still creates an empty working `code/` directory as a scratchpad.

## Lesson Plan
> Before writing the lesson plan, make sure the user has approved the lesson settings first! Never write both the settings and the plan in one go.

Before writing the lesson itself, come up with a plan, and present the user with the list of exercises, along with the concepts which are to be tackled by each. Ask the user for any adjustments or additions to the lesson plan.

IMPORTANT: Always present the plan before writing any files.

Present the plan in the following format:

```
[Brief description of the concepts tackled by the lesson.]

[List of planned exercises in a table with the following format:]
| # | Concept | Key skill practiced |
|---|---------|---------------------|
| 1 | ...     | ...                 |
```

## Lesson Directory

```text
[language]-[skill]-[lesson_style]-[difficulty]/
  LESSON.md          # overview and exercise index; read-only source
  Makefile           # copied from assets/Makefile
  course.css         # copied from assets/course.css
  resources/         # only if exercises need external files; read-only source
  code/              # source scaffolding; only for Normal or Bare mode
```

Copy `assets/Makefile` and `assets/course.css` from this skill directory as-is. Do not rewrite them.

The Makefile supports out-of-source use: the lesson directory is read-only source material, while learners create a separate working directory and run:

```sh
mkdir ~/my-lesson
cd ~/my-lesson
make -f /path/to/[topic]-lesson/Makefile
```

This creates `index.html`, `course.css`, and a writable `code/` directory in the working directory. If source `code/` exists, it is copied; otherwise an empty `code/` scratchpad is created. `make clean` removes generated files.

## LESSON.md

Include:
- YAML title: `[Topic] - [Difficulty] Lesson`
- H1: `[Topic]: [Difficulty] Lesson`
- Metadata lines for Difficulty, Topic, optional Theme, optional Instructor, Lesson Style, and Scaffolding Mode
- One-paragraph summary of what the learner will practice
- `Core Concepts`: concept explanations, examples, and tables as appropriate
- `Running the exercises`: commands for compiling or running each exercise
- `Exercise Index`: linked list of exercises
- Each exercise in order, separated by `---`

Each exercise must include:
- **Objective**: what the exercise practices and why it is non-trivial
- **Task**: problem statement, constraints, and expected behavior
- **Files**: code files the learner must edit; omit this section for Scaffolding Mode `None`

Use the theme and instructor consistently throughout prose, examples, and code. If no theme is provided, avoid flavor text.

## Exercise Design

- Make exercises meaningfully different by varying scenarios, constraints, inputs/outputs, surrounding patterns, or failure modes.
- In Instructional lessons, build on prior exercises by introducing a new concept or challenge.
- Keep exercises open-ended enough that the learner must choose tools or techniques; avoid naming the target concept inside the exercise when that would give away the solution.
- For Easy and Medium in Normal mode, use comments in code files to mark where learners write code, but keep hints and snippets minimal.
- Avoid nested directories in `code/` unless required or clearly more convenient to build and run.
- Add auxiliary files only when needed, and never move target-concept work into shared helpers.

### Scaffolding

In Normal mode, code files should be sparse and may fail to compile or behave correctly until completed. This is expected, especially for syntax and language-concept lessons.

Keep scaffolding especially small around the target concept:
- If the exercise is about interfaces, do not provide method bodies.
- If it is about parsing, do not provide the parsing loop.
- If it is about tests, do not provide most of the test table.

Repetition is intentional. Even if the learner wrote something manually in an earlier exercise, prefer making them write it again over hiding it in reusable scaffolding.

In Bare mode, provide only the files, ubiquitous language boilerplate, and vague shape comments. Do not include target-concept constructs, partial solutions, helper logic, or detailed TODOs.

In None mode, do not create source scaffold files or mention file names in the exercises. Put enough detail in each task for the learner to infer what files and program structure to create. The generated working `code/` directory still exists as a scratchpad for the learner's solution.

## Resources

Only create `resources/` when exercises reference external inputs, data, configs, or similar files. Do not create it empty.

## README.md

Always include a README.md with each lesson, giving a brief description of the lesson plan and explaining how to set up the workspace using the provided makefile. Keep this file short, as it is not a part of the lesson itself.
