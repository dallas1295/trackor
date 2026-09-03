# trackor

This project was handwritten and researched without the use of AI, with the exception of this README.
The idea was to create an issue tracker to be used in my personal projects so i don't need to spam with todo comments and random commenting inline.

Trackor is simple, fast, per-directory issue tracker that lives in your terminal. Issues are plain markdown files — no database, no daemon, no lock-in. If you can `cat` it, you can read your issues.

## How it works

Running any trackor command in a directory uses (or creates) a `.trackor/` folder there. Every issue is a single markdown file named by its ID:

```markdown
---
id: 20260903-45097622
priority: MEDIUM
status: ACTIVE
---

Fix the login bug
```

- **IDs** are `YYYYMMDD-XXXXXXXX` — a zero-padded date plus an 8-digit random suffix, so every ID is a fixed 17 characters and sorts chronologically as plain text.
- **Storage is per working directory** — each project, repo, or scratch folder gets its own independent tracker.
- The files are the source of truth. Delete one, and the issue is gone. Edit one by hand, and trackor picks it up on the next run.

## Commands

| Command | Description |
|---|---|
| `trackor` | List issues (newest first, DONE hidden) |
| `trackor new DESC PRIORITY STATUS` | Create an issue |
| `trackor now` | What you're actively working on, most urgent first |
| `trackor now -t` | Your TODO backlog, most urgent first |
| `trackor e -s ID STATUS` | Set an issue's status |
| `trackor e -p ID PRIORITY` | Set an issue's priority |
| `trackor e -d ID` | Mark an issue DONE |
| `trackor ls` | Same as bare `trackor` |
| `trackor ls -so` | Oldest issues first |
| `trackor ls -su` | Sort by priority (URGENT on top) |
| `trackor ls -sur` | Sort by priority, reversed |
| `trackor ls -a` | Show all issues, including DONE |
| `trackor ls -fd` | Show only DONE issues (the archive) |
| `trackor ls -fs STATUS` | Filter by status |
| `trackor ls -fp PRIORITY` | Filter by priority |

### Values

- **Priority:** `LOW`, `MEDIUM`, `HIGH`, `URGENT`
- **Status:** `TODO`, `ACTIVE`, `DONE`, `BLOCKED`

All status and priority arguments are case-insensitive.

### ID prefixes

You never type a full ID. Any unique suffix prefix works:

```
trackor e -d 4509
```

If a prefix matches multiple issues, trackor lists the candidates and asks you to be more specific.

## Building

Requires the [Odin](https://odin-lang.org/) compiler.

```
odin build . -o:speed -out:trackor
```

## Additional Comments
trackor issues are saved and commited with PR's for both testing and keeping my own records straight in goals for the project.
if you'd like to get a peek at why I may add you can look in .trackor for more information.

## License

Copyright (C) 2026 A. Dallas Sherman

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. See [LICENSE.md](LICENSE.md) for details.

___

This README was generated using GLM-5.3 however the entire project is handwritten by me personally
