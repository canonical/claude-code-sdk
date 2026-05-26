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
3. On launch, the SDK configures `PATH` for the `claude` binary
   and adds a system prompt hint about the workshop environment.

### Start a coding session

Once the workshop is ready:

```bash
workshop shell
claude
```

This opens an interactive Claude Code session inside the workshop. You can ask
Claude to read files, write code, run commands, and navigate your project.

### Authenticate with Claude

To make your host Anthropic credentials available inside the workshop,
you have two alternatives:

- Set the `ANTHROPIC_API_KEY` or `ANTHROPIC_AUTH_TOKEN` [environment variable](https://code.claude.com/docs/en/env-vars) inside the workshop.
  You can pass it using the `--env` option with `workshop run` or `workshop exec`,
  or by other means such as [direnv](https://direnv.net/).

- If neither variable is set, Claude Code will prompt for an Anthropic API key
  or offer browser-based login on first interactive use.
  The mount plug persists these credentials between workshop updates.

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
