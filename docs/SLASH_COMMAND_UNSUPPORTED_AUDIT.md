# Slash-command audit: what the `/` dropdown offers vs. what the gateway will run

**Status: audit only — a client-side fix is in progress on our side.** This
document records a full audit of the slash-command dropdown against a live
stock Hermes gateway (v0.23.3, `hermes serve`), so that upstream and we can
decide together whether the app filters these entries, the catalog stops
advertising them, or both.

## Method

The dropdown is filled verbatim from the gateway's `commands.catalog` RPC:
243 rows — 98 stock Hermes commands, 1 plugin command (`/delegation`), and
144 skill commands. We drove the exact RPC path the app uses
(`session.create source=gui` → `slash.exec`) against the live gateway in a
throwaway session and ran every stock command bare, capturing the reply.
`/update` was deliberately not fired because it really runs `hermes update`
and restarts the gateway; it is refused by code (it is not in the gateway's
dispatch allow-list) and is listed as terminal-only in the catalog metadata.

## Results

**45 of 98 execute.** The gateway's accepted set matches the reviewed
allow-list in `gateway/session_commands.py` exactly — reads, session
controls, per-session settings, and prompt-directives:

> `approvals` `autoprune` `blueprint` `bundles` `busy` `codex-runtime`
> `context` `cron` `curator` `debug` `diff` `egress` `fast` `footer` `goal`
> `heartbeat` `help` `init` `insights` `kanban` `learn` `login` `loop`
> `memory` `moa` `personality` `plan` `platforms` `profile` `reasoning`
> `refine` `review` `skills` `status` `subgoal` `suggestions` `title`
> `topup` `usage` `verbose` `version` `voice` `whoami` `yolo`

(`/plan`, `/learn` and `/init` come back as `send` directives and are
submitted as prompts — that is the designed behavior.)

**52 of 98 are refused with `unsupported_command`.** Of those, `/new` (and
its alias `/reset`) is already handled client-side in #301, leaving **51
entries the dropdown advertises but the gateway will never run**:

`agents` `battery` `bg` `branch` `browser` `btw` `clear` `compress` `config`
`copy` `density` `export` `focus` `handoff` `hatch` `history` `image`
`import` `indicator` `journey` `logs` `model` `mouse` `new` `palette`
`paste` `pet` `plugins` `prompt` `queue` `quit` `redraw` `reload`
`reload-mcp` `reload-skills` `resume` `retry` `rewind` `rollback` `save`
`sessions` `skin` `snapshot` `statusbar` `steer` `stop` `subscription`
`timestamps` `tools` `undo` `wake` `worktree`

They fall into three groups:

1. **Terminal / client-machine commands** — they act on the text UI or the
   host the gateway may not share: `redraw` `statusbar` `battery`
   `timestamps` `focus` `skin` `indicator` `density` `mouse` `clear` `logs`
   `quit` `palette` `prompt` (needs `$EDITOR`) `copy` `paste` (clipboard)
   `image` (local file) `browser` (local Chromium CDP) `wake` (device mic)
   `subscription` (opens a browser on the host).
2. **Session-runtime commands the shared gateway keeps off `slash.exec`.**
   The app already covers several through dedicated RPCs or screens —
   `model` (model picker), `steer` (`session.steer`), `branch`
   (`session.branch`), `sessions`/`resume` (session browser) — but the
   slash text still leaks as prose: `history` `save` `retry` `undo`
   `rewind` `compress` `stop` `bg` `btw` `agents` `journey` `queue`
   `config` `tools` `reload` `reload-mcp` `reload-skills` `plugins` `pet`.
3. **Host-state commands where the gateway attaches an explicit
   "run this in a terminal instead" hint** (`data.detail` on the refusal):
   `export` `import` `snapshot` `rollback` `handoff` `worktree` `hatch`.

Partial refusals worth noting: `/cron` answers bare/list reads but refuses
write verbs from a viewer connection by design; `/kanban` refuses its
mutating verbs; `/usage reset`, `/suggestions accept` and `/voice tts` are
refused while their bare forms work.

## Why this is user-visible

When `slash.exec` answers `unsupported_command`, the app treats it like any
other send-path error and falls back to submitting the typed text as a
normal prompt (`_isSlashUnsupported` in `chat_screen.dart`). So picking
`/redraw` from the dropdown and sending it delivers the literal string
`/redraw` to the agent as a chat message. This is the same failure family
that broke `/new` (a command the shared surface cannot run interactively);
#301 fixed `/new` by handling it client-side, and the same lesson applies
to the rest: anything interactive or terminal-bound must either be handled
in the app or not be offered at all.

## Proposed directions (not exhaustive)

- **Client-side (ours, in progress):** filter the dropdown so refused
  entries are not offered — ideally driven by data rather than a hardcoded
  list, since the hardcoded `{'new','reset'}` mirror already showed it can
  drift (`//new` slipped past it). The catalog's per-command `desktop`
  metadata (`terminal`, `hidden`) is a natural display-intent signal the
  parser currently ignores, though it does not line up with the refusal set
  one-for-one (e.g. `/cron` is marked `terminal` yet works and is useful on
  mobile). We are also looking at surfacing the gateway's refusal hints
  instead of silently converting the text to prose, and wiring the
  commands that already have RPC equivalents (`model`, `steer`, `branch`)
  to them.
- **Upstream alternative:** simply stop advertising these rows in
  `commands.catalog` for non-terminal surfaces (or add an `executable`
  set — the app's catalog parser already tolerates an
  `executable`/`supported`/`slash_exec` key if one ever appears, and would
  gate both the dropdown and dispatch on it).

Happy to align whichever direction maintainers prefer; the client-side
filter can land regardless.
