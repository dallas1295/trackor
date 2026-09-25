# trackor

This project was handwritten and researched without the use of AI.
The idea was to create an issue tracker to be used in my personal projects so i don't need to spam with todo comments and random commenting inline.

Trackor is simple, fast, per-directory issue tracker that lives in your terminal. Issues are plain markdown files — no database, no daemon, no lock-in. If you can `cat` it, you can read your issues.

## How it works

Running any trackor command in a directory uses (or creates) a `.trackor/` folder there. Every issue is a single markdown file named by its ID:

```markdown
---
id: 20260903-45097622
status: open
priority: high
tag: bug
---

Fix the login bug
```

- **IDs** are `YYYYMMDD-XXXXXXXX` — a zero-padded date plus an 8-digit random suffix, so every ID is a fixed 17 characters and sorts chronologically as plain text.
- **Storage is per working directory** — each project, repo, or scratch folder gets its own independent tracker.
- The files are the source of truth. Delete one, and the issue is gone. Edit one by hand, and trackor picks it up on the next run.

## Commands

| Command                                      | Description                                                      |
| -------------------------------------------- | ---------------------------------------------------------------- |
| `trackor`                                    | List issues (newest first, highest priority, first, DONE hidden) |
| `trackor new DESC [STATUS] [PRIORITY] [TAG]` | Create an issue                                                  |
| `trackor now`                                | What you're actively working on, most urgent first               |
| `trackor delete ID`                          | Delete's an issue from .trackor dir based on the ID provided     |
| `trackor open`                               | Lists all currently open issues (newest first)                   |
| `trackor e -s ID STATUS`                     | Set an issue's status                                            |
| `trackor e -p ID PRIORITY`                   | Set an issue's priority                                          |
| `trackor e -c ID`                            | Mark an issue CLOSED                                             |
| `trackor grep`                               | displays issues in a grep compliant way, with paths included     |
| `trackor grep -c`                            | shows grep output for CLOSED issues                              |
| `trackor grep -p PRIORITY`                   | shows grep output for issues with the given priority             |
| `trackor grep -t TAG`                        | shows grep output for issues with the given TAG                  |
| `trackor ls`                                 | Same as bare `trackor`                                           |
| `trackor ls -so`                             | Oldest issues first                                              |
| `trackor ls -su`                             | Sort by priority, reversed                                       |
| `trackor ls -a`                              | Show all issues, including CLOSED                                |
| `trackor ls -fd`                             | Show only CLOSED issues (the archive)                            |
| `trackor ls -fs STATUS`                      | Filter by status                                                 |
| `trackor ls -fp PRIORITY`                    | Filter by priority                                               |

### Values

- **Priority:** `NULL`,`LOW`, `MEDIUM`, `HIGH`
- **Status:** `OPEN`, `CLOSED`
- **Tag:** `NULL`, `BUG`, `REFAC`, `IDEA`, `DESIGN`, `FEAT`

All status, priority, and tag arguments are case-insensitive.

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

if there are any additional features in development or ideas feel free to look in the .trackor in the project.

## License

Copyright (C) 2026 A. Dallas Sherman

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. See [LICENSE.md](LICENSE.md) for details.

---

This README was paritall generated using GLM-5.3 however the entire project is handwritten by me personally.
