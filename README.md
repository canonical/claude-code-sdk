# Claude Code SDK for Workshop

This SDK provides the Claude Code CLI for AI-assisted coding within a
workshop. The agent is sandboxed in the workshop container. Credentials are
persisted between workshop updates.

---

## Reference workshop

A minimal workshop:

```yaml
# workshop.yaml
name: claude-code
base: ubuntu@24.04
sdks:
  - name: claude-code
    channel: latest/stable

actions:
  claude-yolo: claude --dangerously-skip-permissions "$@"

  claude-yolo-prompt: claude --dangerously-skip-permissions -p "$@"
```

This creates a basic Claude Code environment.
The agent is sandboxed by the workshop,
so interactive and non-interactive actions can use the YOLO mode.

---

## Using the SDK

### Prerequisites, project layout

1. No prerequisite SDKs are required.
2. Place your project files in your project directory. No special layout is
   required; Claude Code works with any codebase.
3. On launch, the SDK puts a `claude` wrapper on `PATH`
   and adds a system prompt hint about the workshop environment.
   The SDK pins the Claude Code version, so the wrapper sets
   `DISABLE_AUTOUPDATER=1` unless you set it yourself.

### Start a coding session

Once the workshop is ready:

```bash
workshop shell
claude
```

This opens an interactive Claude Code session inside the workshop. You can ask
Claude to read files, write code, run commands, and navigate your project.

### Authenticate with Claude

Claude Code accepts a Claude subscription token created with `claude setup-token`
(`CLAUDE_CODE_OAUTH_TOKEN`), an Anthropic Console API key (`ANTHROPIC_API_KEY`),
or a bearer token for an LLM gateway (`ANTHROPIC_AUTH_TOKEN`).

To make your credentials available inside the workshop,
you have these alternatives:

- Set one of these [environment variables](https://code.claude.com/docs/en/env-vars)
  inside the workshop.
  You can pass it using the `--env` option with `workshop run` or `workshop exec`,
  or by other means such as [direnv](https://direnv.net/).

- Connect a secret to the `oauth-token` or `api-key` plug, or both;
  see the plug descriptions below.
  If both are available, Claude Code's own
  [authentication precedence](https://code.claude.com/docs/en/iam#authentication-precedence)
  decides which one it uses;
  disconnect a plug to stop using its secret.

- Otherwise, Claude Code will prompt for an Anthropic API key
  or offer browser-based login on first interactive use.
  The mount plug persists these credentials between workshop updates.

#### Use a subscription token from the host keyring

1. On the host, create a long-lived token for your Claude subscription:

   ```bash
   claude setup-token
   ```

2. Store the token in the host keyring;
   `secret-tool` prompts for it, so paste the token there:

   ```bash
   secret-tool store --label="claude code" --collection=default service claude-code
   ```

   To check that it's stored, run `secret-tool lookup service claude-code`.

3. Expose the keyring item through a `secret` slot on the system SDK
   in your workshop definition:

   ```yaml
   sdks:
     - name: system
       slots:
         claude-oauth:
           interface: secret
           collection: default
           attributes:
             service: claude-code
     - name: claude-code
       channel: latest/stable
   ```

4. Once the workshop is launched, connect the slot to the `oauth-token` plug:

   ```bash
   workshop connect <workshop-name>/claude-code:oauth-token :claude-oauth
   ```

   The connection persists across `workshop refresh`;
   repeat it after `workshop restore` or after removing and launching
   the workshop again.
   To disconnect, use `workshop disconnect` with the same plug.
   To use an Anthropic Console API key instead,
   store it with a different attribute value, add a second slot for it,
   and connect that slot to `claude-code:api-key`.

---

## Plugs (resources this SDK consumes)

### `claude-config`

- Interface: `mount`
- Workshop target: `/home/workshop/.claude`
- Purpose: Preserves Claude's credentials and settings between workshop updates.
  You can also use `workshop remount` to control its contents on the host.
  To mount your existing `~/.claude` settings into the workshop, stop
  the workshop first, remount, then start it again:

  ```bash
  workshop stop <workshop-name>
  workshop remount <workshop-name>/claude-code:claude-config ~/.claude
  workshop start <workshop-name>
  ```

### `oauth-token`

- Interface: `secret`
- Purpose: Provides a Claude subscription token, created with `claude setup-token`,
  from the host's secret service.
  The `claude` wrapper reads it with `workshopctl get-secret claude-code.oauth-token`
  and exports it as `CLAUDE_CODE_OAUTH_TOKEN` for the Claude Code process,
  unless that variable is already set in the workshop environment.
  Because interactive onboarding would otherwise ask for a browser login,
  the wrapper also sets `hasCompletedOnboarding` in `~/.claude/.claude.json`
  whenever `CLAUDE_CODE_OAUTH_TOKEN` is set.
  Commands Claude Code runs inherit this variable unless you set
  `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1`.

### `api-key`

- Interface: `secret`
- Purpose: Provides an Anthropic Console API key from the host's secret service.
  When the secret is readable and `ANTHROPIC_API_KEY` isn't set,
  the `claude` wrapper configures
  [`apiKeyHelper`](https://code.claude.com/docs/en/settings-reference#apikeyhelper)
  to run `workshopctl get-secret claude-code.api-key`,
  so Claude Code fetches the key on demand and it never enters the environment
  of commands Claude Code runs.
  The wrapper passes this as the first `--settings` option;
  if you pass your own `--settings`, it replaces the wrapper's,
  and the API key secret isn't used.

## Slots (resources this SDK provides)

This SDK doesn't define any slots.

---

## Documentation and guidance

- [Claude Code official documentation](https://code.claude.com/docs)
- [Workshop documentation](https://ubuntu.com/workshop/docs/)

---

## Community and support

- Anthropic community: [Anthropic Discord](https://www.anthropic.com/discord)
- Workshop forum:
  [Discourse](https://discourse.ubuntu.com/)
- Please review our
  [Code of Conduct](https://ubuntu.com/community/ethos/code-of-conduct) before
  participating.

---

## Contributions

All contributions, including code, documentation updates, and issue reports,
are welcome!

- See `CONTRIBUTING.md` for guidelines.
- Open issues or pull requests on the official repository.

---

## License and copyright

Copyright 2026 Canonical Ltd.

This program is free software: you can redistribute it and/or modify it under
the terms of the
[GNU Lesser General Public License version 2.1 (LGPLv2.1)](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html)
as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

[Claude Code](https://code.claude.com/docs/) is licensed under
the [Anthropic Commercial Terms](https://www.anthropic.com/legal/commercial-terms).
