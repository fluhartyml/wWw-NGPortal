# Session Summary: Claude Code CLI Workflow Integration
**Date:** 2025 November 01
**Time:** ~1145-1200
**Participants:** MLF (User) and Claude (Claude Code CLI)

---

## Session Overview
This session focused on updating the wWw NGPortal developer notes (wWw_DevNotes.swift) to accurately reflect the new workflow now that Claude operates as Claude Code CLI in the terminal alongside the user working in Xcode, rather than the previous web-based AI assistant workflow.

---

## What We Accomplished

### 1. Initial Context Gathering
- Claude read the developer notes file (`wWw_DevNotes.swift`) to get up to speed on the project
- Confirmed project details:
  - **Project:** wWw NGPortal - Un-sandboxed, self-distributed macOS web server with DDNS updater support
  - **Current Status:** Swift 6.0 upgraded, Vapor server running on 0.0.0.0:8080 with proper debug logging
  - **Recent Work:** Server startup fixes, UI status synchronization working correctly

### 2. Developer Notes Update Process
User requested line-by-line review and explicit approval for each change to prevent accidental deletion of important workflow information. Claude presented each proposed change one at a time in serial fashion (as user can only process one question at a time).

#### Changes Made to "CRITICAL WORKFLOW RULES" Section:

**Line 36 - AI Heavy Lifting Policy:**
- **OLD:** "AI ASSISTANTS DO ALL HEAVY LIFTING: AI does 100% of coding, file creation, problem-solving, and technical work."
- **NEW:** "AI ASSISTANTS DO ALL HEAVY LIFTING: Claude Code CLI does 100% of coding, file editing, problem-solving, and technical work via terminal/CLI commands. NEW files go to Drop folder only (to prevent Xcode duplicate file creation); existing files are edited in-place."
- **Rationale:** Clarified Claude Code CLI operates via terminal; reinforced Drop folder policy for new files to prevent Xcode from creating numbered duplicates (ContentView 2.swift, etc.)

**Line 37 - User Minimal Actions Policy:**
- **OLD:** "USER DOES MINIMAL ACTIONS ONLY: User only performs actions that AI assistants are physically prohibited from doing in Xcode."
- **NEW:** "USER DOES MINIMAL ACTIONS ONLY: User only performs actions that AI assistants are physically prohibited from doing in Xcode. ****Human does not CODE****"
- **Rationale:** Added explicit reinforcement that human never writes code

**Lines 41-42 - Screenshot Methodology:**
- **OLD:** Two separate lines: "User takes screenshot showing the result" + "User uploads screenshot to AI"
- **NEW:** Merged into one line: "User takes screenshot showing the result and tells CLI Claude to check Screenshots folder"
- **Rationale:** Reflects actual CLI workflow where user simply tells Claude to check Screenshots folder rather than "uploading" files

**Line 44 - Terminal Usage Policy (DELETED):**
- **OLD:** "USER PREFERS XCODE-ONLY WORKFLOW: No terminal commands ever."
- **NEW:** (Line deleted entirely)
- **Rationale:** This policy is now moot/irrelevant since Claude Code CLI runs in terminal alongside Xcode - terminal commands are integral to the workflow

**Line 45 - After Successful Build Policy:**
- **OLD:** "AFTER SUCCESSFUL BUILD: Claude must remind user to push to GitHub via Xcode Source Control."
- **NEW:** "AFTER SUCCESSFUL BUILD: When user provides screenshot of successful build, Claude suggests a GitHub commit message formatted as: YYYY MMM DD [description of what was successful about the build] (MLF) HHMM. User commits and pushes via Xcode Source Control GUI, then celebrates with Claude."
- **Rationale:**
  - Established new commit message format with date, description, author tag, and time
  - Clarified workflow: screenshot → commit message suggestion → user commits via Xcode → celebration
  - Preserves user's desire to retain git operations in Xcode GUI to celebrate successful builds
  - Commit message format: date first, description in middle, author tag, time last (24-hour format, no colon)

#### Changes Made to "GitHub & Repository Policy" Section:

**Lines 125 & 173 - Git Operations Workflow:**
- **OLD:** "Xcode-only workflow: use Source Control UI; no terminal."
- **NEW:** "Git operations via Xcode Source Control GUI only; CLI Claude handles all other terminal commands."
- **Rationale:**
  - Clarified that ONLY git operations stay in Xcode GUI
  - All other terminal work (coding, building, testing, file operations) happens via CLI Claude
  - Preserves user's preference to handle git commits manually in Xcode for celebrating builds
  - Prevents misunderstanding that "no terminal" applies to entire workflow

### 3. Project Status Entry Added
Added comprehensive summary entry to "Project Status & Chat Summary" section documenting all changes made during this session with timestamp [2025 NOV 01 1200].

---

## Key Workflow Clarifications Established

### Division of Labor:
- **Claude Code CLI:** All coding, file editing, problem-solving, technical work via terminal/CLI commands
- **Human (MLF):** Only Xcode GUI actions that CLI Claude cannot perform (adding files to project, Xcode-specific settings, git operations for celebrating builds)
- **Explicit Rule:** ****Human does not CODE****

### File Management:
- **New Files:** Always go to Drop folder first (prevents Xcode numbered duplicates)
- **Existing Files:** Edited in-place by Claude Code CLI
- **Screenshots:** Saved by user to Screenshots folder; user tells Claude to check folder

### Git Workflow:
- **User Retains:** All git operations via Xcode Source Control GUI
- **Reason:** Allows user to celebrate successful builds with Claude
- **Commit Message Format:** YYYY MMM DD [description] (MLF) HHMM
  - Example: `2025 NOV 01 Server startup and debug logging fixed (MLF) 1200`

### Screenshot Methodology:
- **Process:** Claude gives specific Xcode GUI instruction → User performs action → User takes screenshot and tells Claude to check Screenshots folder → Claude reads screenshot and continues
- **Purpose:** Creates calm, methodical, stress-free workflow
- **Scope:** Applies only to Xcode GUI actions; terminal work handled directly by Claude

---

## Why These Updates Mattered

### 1. Preventing Workflow Confusion
The old notes contained contradictory information (e.g., "no terminal commands ever") that didn't match the new Claude Code CLI reality where terminal commands are essential.

### 2. Preserving Critical Safeguards
The Drop folder policy prevents catastrophic Xcode duplicate file issues (ContentView 2.swift, ContentView 3.swift) that cause ambiguous type errors and break projects.

### 3. Maintaining User Preferences
User wants to retain git operations in Xcode GUI specifically to celebrate successful builds - this emotional/motivational aspect was preserved in the updated workflow.

### 4. Clear Division of Responsibilities
Explicit clarification that human does NOT code and AI does ALL technical work prevents scope creep or misunderstandings about who does what.

### 5. Session Continuity
Developer notes serve as persistent memory across AI chat sessions - keeping them accurate ensures future sessions start with correct context.

---

## Technical Context

### Project Structure:
```
~/developer/nightgard/wWw NGPortal/
├── .git/                           # Git repository
├── Screenshots/                     # User saves screenshots here
├── Drop/                           # Claude writes new files here
├── wWw NGPortal/                   # Main project folder
│   ├── wWw_DevNotes.swift         # Developer notes (this file we updated)
│   └── [other project files]
└── wWw NGPortal.xcodeproj/        # Xcode project
```

### Current Project Status (from notes):
- **Swift Version:** 6.0 (upgraded from 5.0)
- **Server:** Vapor-based HTTP server
- **Binding:** 0.0.0.0:8080 (accessible on LAN)
- **Status:** Server startup working correctly with comprehensive debug logging
- **UI:** Server status syncs properly (green "Running" / gray "Stopped")
- **DDNS:** DuckDNS integration with plans for additional providers

---

## Methodology Notes

### User's Preferred Communication Style:
- **Serial Processing:** One question at a time, wait for response before continuing
- **TL;DR:** Concise responses (1-2 short paragraphs)
- **Step Numbering:** Use 1) 2) 3) format with close parenthesis
- **Single-action Instructions:** One specific action per instruction when requesting Xcode GUI work

### Developer Notes Usage:
- **Purpose:** Persistent memory & virtual swap file across AI sessions
- **Format:** [YYYY MMM DD HHMM] (AUTHOR) Message
- **Authors:**
  - Claude uses "MF" when writing on behalf of user
  - User signs as "MLF"
  - AI assistants sign their own names (Claude, ChatGPT)
- **Organization:** Newest entries at TOP for quick scanning

---

## Session Outcome

Successfully updated all relevant workflow policies in developer notes to accurately reflect Claude Code CLI integration. The notes now serve as reliable persistent memory for future sessions, with clear distinction between:
- What Claude Code CLI handles (all coding, terminal commands, file operations)
- What user handles (Xcode GUI actions, git operations for celebrating builds)
- Critical safeguards (Drop folder for new files, no human coding, screenshot methodology)

The updated workflow maintains the user's preferences while adapting to the new technical reality of CLI-based AI assistance.

---

## Next Steps
User indicated we're ready to continue with project work now that workflow documentation is updated and accurate.

---

**Summary Prepared By:** Claude (Claude Code CLI)
**File Location:** Drop folder for user's reference
**Format:** Markdown for easy reading
