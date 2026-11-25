# Fleet and remote access — implementation and acceptance limits

Open **More → Gateway fleet** in either layout. Nothing is published or installed by opening the page. The primary gateway in Ares and the primary in a remote Webapp are separate settings.

| Workflow | Implemented | Still open |
|---|---|---|
| F02: SSH | On a device with system OpenSSH, paste an independently obtained Ed25519 public host key; compare its SHA-256 fingerprint and confirm before it is written. Trust is keyed by host and port, not label. Every connection uses the pinned file and `StrictHostKeyChecking=yes`. Explicit actions open a direct SSH channel to read `/api/health`, a bounded, inert source preview of `/` on the selected remote loopback port, or a remote login shell with line input. There is no local listening port, shell fallback, public proxy, client config execution or agent forwarding. | These are on-demand channels, **not** a persistent, authenticated Ares chat connection through an owned remote `hermes serve`. No remote bootstrap/adoption, managed SSH update/recovery, interactive browser preview, jump-host support or mobile SSH implementation. Keys are never silently rotated. |
| F02: Cloud | The selected authenticated gateway asks its signed-in Portal account for agents. A multi-organisation response prompts a choice; the echoed organisation must match. Selecting an agent re-reads the inventory and pre-fills its own new-account sign-in. Showing its address neither dials it nor copies credentials. | This uses the serving gateway's existing Portal identity, not an independent native Cloud-account session. No real Cloud account, OAuth callback or recovery was exercised. |
| F03: fleet | Explicitly connect multiple saved gateways. Each has an independent reconnecting socket, roster, paginated sessions and retained chat controllers. Selecting another profile opens a separate owner rather than overriding an active chat's profile. Ares can launch on a chosen primary independently of last-used routing. “Reconnect in fleet on launch” restores only opted-in accounts, not chats or prompts; a saved credential edit or import clears that opt-in. | Additional profile attachments are session-only. The fleet conversation view is a text conversation, not a replacement for all features of either full chat view. |
| F03: updates | Check connected direct enrollments; skip Cloud, unknown provenance, non-applyable/non-git installs and known busy chats. Review the named eligible targets, recheck before POST, deduplicate by installation, and read only a matching action receipt. An unavailable receipt is not a successful update. | This is URL-backend dispatch, not the SSH drain/update/restore protocol. No update was run on a real installation. The client cannot promise other clients are idle. |
| F04: existing Webapp | Register an already-running gateway/Webapp with its own sign-in. Read the serving Webapp's machine registry, set its primary without touching `lastUsed`, and read/write shared chat text direction (`auto` deletes only this key). Both writes are read back on the original target. Diagnostics distinguish gateway health, host-only administration and unsupported listeners. | No publication, build, access-grant escalation or start/stop controls. Ares doesn't proxy an entire Webapp, migrate every machine preference, or operate browser tab grants. |

## Why SSH bootstrap and Web Access administration are not exposed

Verified at upstream **`b7ee21c14e38316273f88d8ed112491ba1c87d15`**:

- `hermes_cli/web_routers/gateway_connections_reach.py` exposes `POST /api/gateway-connections/{id}/ssh`; `gateway_connections_ssh.py` runs the remote bootstrap. Its `gateway_connections_ssh_transport.base_ssh_options` **hard-codes `StrictHostKeyChecking=accept-new`** and the public SSH action accepts no fingerprint, reviewed key or proof of prior enrollment. A confirmation dialog on Ares cannot change which key that server accepts. Do not substitute that API for an end-to-end pinned bootstrap, including on phones without system OpenSSH.
- `hermes_cli/web_routers/webapp_access.py` requires `native_http_principal` even to inspect its administration status. A remote cookie, bearer, or SSH tunnel isn't the gateway operator's private native grant. Status `403` is expected. In particular, do not work around it with a shell, generic command, or native-ticket emulator.
- `hermes_cli/web_server_surface.py` enables `gateway_connections` and `ui_preferences` on `webapp` only. Their `404` on an ordinary Dashboard is not evidence of a broken connection. `web_routers/status.py` scopes Cloud discovery to the profile; `cloud_agents.py` uses `409` for a missing/expired Portal sign-in, not for a successful organisation list. `web_routers/actions.py` distinguishes updater admission from the terminal receipt.

## Reproduce the narrow SSH gate

The app adds no Flutter/plugin or native library dependency. Desktop invokes the OS OpenSSH client; it does not redistribute it. `tool/fleet_ssh_fixture` is **test-only**: Go's `golang.org/x/crypto/ssh` (BSD-3-Clause). Its loopback listener never executes a command, forwards to a real port or contacts Hermes. It admits only the generated fixture user key. The test compares the fingerprint with the peer's independent Go implementation and verifies that real OpenSSH refuses a different server key.

```sh
mkdir -p build/fleet-tmp
export TMPDIR="$PWD/build/fleet-tmp" GOCACHE="$PWD/build/fleet-go-cache"
GOPROXY=off GOSUMDB=off go -C tool/fleet_ssh_fixture build -mod=readonly -o ../../build/fleet-ssh-fixture .
ARES_SSH_FIXTURE="$PWD/build/fleet-ssh-fixture" flutter test --no-pub --concurrency=1 \
  test/fleet_ssh_test.dart test/gateway_fleet_test.dart test/fleet_navigation_test.dart
```

The offline Go command requires the pinned module in the development cache. Without `ARES_SSH_FIXTURE`, the native SSH test is explicitly skipped. Flutter layout tests use throwaway HTTP/WS peers and temporary application-support storage. Protocol tests exercise colliding session/runtime/profile IDs, interleaved replies, fresh ticket issuance on reconnect, stale-send refusal, duplicate update requests, mismatched receipts and a credential-bearing redirect to a different port. Independent upstream preference-store execution verified that RTL→Auto preserved a sibling key; the upstream registry normalizer changed primary without changing last used.

**Verification boundary:** macOS-hosted Flutter and CLI OpenSSH, not packaged macOS sandbox/SSH-agent or key-file access, Windows OpenSSH, Linux runner, Android or iOS device validation. No live personal endpoints, real billing, real account sign-in, server publication, host update or inference. Leave the release gate open.
