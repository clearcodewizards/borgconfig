# Borgconfig

Borgconfig management tool. Let AI manage your infra.

## Borg Collective

Borg Collective is a Rails-based control plane for coordinating distributed
agents called **cubes**. It provides token-authenticated APIs through which
cubes can register, retrieve files and pending directives, and report their
execution status and output. Its Model Context Protocol (MCP) endpoint lets AI
tools discover cubes and execute directives through a standard interface.

> [!NOTE]
> This project is under active development. Both the cube API and MCP endpoint
> are functional.

## How it works

- A cube introduces itself using an API token and receives a generated name.
- An administrator approves the cube by marking it as registered.
- The cube authenticates with the same token to poll for pending directives.
- Directives identify a file to execute, carry arguments, and may
  depend on another directive.
- The cube reports the directive's resulting status and output to the service.
- AI tools and MCP clients connect to the MCP endpoint to inspect cubes and
  manage their work.

Cube and user API tokens are encrypted at rest using Active Record Encryption.

## Requirements

- Ruby 3.4.8
- SQLite 3
- Bundler

## Getting started

### Try it with Docker

For a disposable local demo, no Rails credentials are required:

```sh
docker compose up --build
```

Open <http://localhost:3000> and sign in with:

- Email: `admin@localhost`
- Password: `changeme`

To print the administrator's bearer token for an MCP connection:

```sh
docker compose exec borgconfig bin/rails users:api_token
```

For another user, pass their email address:

```sh
docker compose exec borgconfig bin/rails users:api_token EMAIL=user@example.com
```

The Compose setup loads `.env.demo`, which contains public application and
encryption keys and disables HTTPS for localhost. Do not use these values for a
public deployment or store sensitive data in the demo.

Application data is kept in the `borg_data` Docker volume between runs. To
start over with a fresh database, remove that volume:

```sh
docker compose down --volumes
```

For a real deployment, provide unique values for `SECRET_KEY_BASE`,
`ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY`,
`ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY`, and
`ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT`. Generate them with:

```sh
bin/rails secret
bin/rails db:encryption:init
```

Keep these values stable across restarts; changing the Active Record Encryption
keys makes existing encrypted values unreadable. HTTPS remains enabled unless
`FORCE_SSL=false` is explicitly set.

### Local development

Install dependencies, prepare the database, and start the development processes:

```sh
bin/setup
```

The setup script runs `bundle install` when needed, prepares the SQLite
database, clears temporary files, and starts the application with `bin/dev`.
To prepare the project without starting a server, run:

```sh
bin/setup --skip-server
```

You can then start it separately:

```sh
bin/dev
```

By default, the application is available at <http://localhost:3000>.

### Seed administrator

The database seeds create a development administrator:

- Email: `admin@localhost`
- Password: `changeme`

Run the seeds with:

```sh
bin/rails db:seed
```

Change the default password immediately anywhere beyond a disposable local
development environment.

## MCP

Borg Collective exposes its management interface as a stateless, Streamable
HTTP MCP endpoint at `POST /mcp`. MCP requests use a user's API token, not a
cube token. Read actions require `member` or higher. Current policy scopes
expose cubes and directives only to administrators; other permitted users
receive empty lists. Registering and updating cubes requires `admin`.

Retrieve an administrator API token with the Rails task:

```sh
docker compose exec borgconfig bin/rails users:api_token
```

Configure an MCP client with:

- URL: `http://localhost:3000/mcp`
- Authorization header: `Bearer <user-api-token>`

The server provides these tools:

| Tool | Purpose |
| --- | --- |
| `me` | Show the authenticated user's profile and role. |
| `cubes` | List cubes, optionally filtered by ID, partial name, or tag. |
| `register_cubes` | Approve a selected cube, or all unregistered cubes. |
| `update_cube` | Rename a cube and add tags. |
| `tags` | List tag names. |
| `directives` | List directives, optionally filtered by ID. |
| `directive_files` | List directive filenames and descriptions, excluding `borg_client.rb`. |
| `create_directives` | Assign a directive to cubes selected by IDs or tags. |

### Directive roles

Each executable directive class declares its minimum user role with a class
method, for example:

```ruby
def self.role
  :member
end
```

Roles are ordered `guest`, `member`, `editor`, `manager`, `admin`. The creation
policy loads the selected file and compares its class's role with the current
user's role; equal or higher roles are allowed. `ping.rb` requires `member`,
while `command.rb` requires `admin`. Unknown filenames and unrecognized role
values are rejected with an MCP tool error.

Cube access is checked separately through the policy scope. Under the current
scope, only administrators have target cubes, so a member's authorized ping
request returns an empty list of directive IDs. Authorized requests without
cube IDs or tags also create nothing. `borg_client.rb` is the cube runtime
helper and is not an executable directive with a role method.

### Execute `ping.rb` on a cube

First use the `cubes` tool to find the target cube. It supports an exact cube
ID, a partial cube name, or a tag. Then call `create_directives` with the
returned cube ID:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "create_directives",
    "arguments": {
      "filename": "ping.rb",
      "arguments": "",
      "cube_ids": [1]
    }
  }
}
```

The same call can target every cube carrying a tag:

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "create_directives",
    "arguments": {
      "filename": "ping.rb",
      "arguments": "",
      "tags": ["x86_64-linux"]
    }
  }
}
```

For example, invoke it directly after initializing an MCP session:

```sh
curl http://localhost:3000/mcp \
  -X POST \
  -H "Authorization: Bearer $USER_API_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  --data '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"create_directives","arguments":{"filename":"ping.rb","arguments":"","cube_ids":[1]}}}'
```

The tool returns the created directive IDs. A connected cube polls for its
pending directives, downloads `ping.rb`, executes `Ping.run`, and reports the
result (`pong`) to Borg Collective. The cube must be running and have its
`registered` flag set to `true`.

To execute a command on a cube, create a directive using `command.rb` and put
the shell command in `arguments`, for example:

```json
{
  "filename": "command.rb",
  "arguments": "uname -a",
  "cube_ids": [1]
}
```

The command directive returns the command's combined standard output and
standard error as the directive output. Commands run with the permissions of
the cube process, so only trusted users should be allowed to create them.

The MCP endpoint is also intended to support command-line workflows. Instead
of maintaining a project-specific CLI, users can connect with a general-purpose
MCP client such as [avelino/mcp](https://github.com/avelino/mcp).

## Development

Run the test suite:

```sh
bin/rails test
```

Run linting and security checks:

```sh
bin/rubocop
bin/brakeman
```

The application uses SQLite for its primary database and the Rails Solid
adapters for cache, jobs, and Action Cable. Files distributed to cubes are read
from `lib/directives/*.rb`. The standalone cube runtime is stored in
`lib/borg_cube`.

## Main domain objects

- **Cube** — a remote agent identified by an encrypted token, registration
  state, and execution status.
- **Directive** — a unit of work assigned to a cube, including its filename,
  arguments, dependency, status, and captured output.
