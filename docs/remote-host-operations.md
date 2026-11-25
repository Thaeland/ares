# Remote host, schedules and memory graph

Host, schedule and memory-graph calls go through the authenticated workspace owner (`DesktopGatewayClient.workspace` or `NextGenGateway.workspace`). A job action binds a separate owner whose profile is that job's `profile`. The open chat profile is not a substitute.

Logs are `GET /api/logs` for `agent`, `errors`, `gateway` or `desktop`, 200 lines, with an optional level and search. Health is `GET /api/status` on the remote gateway. It is not an Ares connection test or the client update check.

`Update remote Hermes` is enabled only when `GET /api/hermes/update/check` reports a git install, `can_apply`, `update_available`, and no `held` value. `POST /api/hermes/update` is not sent otherwise. The outcome is `judgeHostUpdate`: a receipt whose `action_id` matches the start response. A zero exit code, a different receipt, or a gateway that is still answering is `unknown` or `pending`, not success.

Restart, Doctor, security audit and Curator run are the named background actions. Memory-file reset and diagnostic share need an explicit confirmation; share sends `{consent: true}` and shows links only when the host sets `redacted: true`. Computer Use status is the remote host's driver and OS permissions.

Schedules load with `profile=all`. Stop is `POST /api/cron/jobs/{id}/cancel` on the owning profile and is separate from pause/resume. Catch-up is `true`, `false`, or `null`. Delivery is a comma-separated set and cannot be emptied. Blueprints are listed and instantiated on the selected profile.

The memory graph reads `GET /api/learning/graph`. Edit and archive/delete use `/api/learning/node` on that profile. The layout code is `HML1|zoom|playback|kind|pinned` and contains no labels or memory text. Provider configuration uses `/api/memory` and `/api/memory/providers/{name}/config?surface=declared`. Empty secret fields are not written.

No new package was added. These screens are macOS-hosted Flutter tests against a disposable loopback gateway, not on-device proof and not a live personal gateway.
