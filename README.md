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
- Directives identify a file to execute, carry optional arguments, and may
  depend on another directive.
- The cube reports the directive's resulting status and output to the service.
- AI tools and MCP clients connect to the MCP endpoint to inspect cubes and
  manage their work.

Cube API tokens are encrypted at rest using Active Record Encryption.

## Requirements

- Ruby 3.4.8
- SQLite 3
- Bundler

## Getting started

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

## API

All API authentication uses a bearer token:

```http
Authorization: Bearer <token>
Accept: application/json
```

### Cube API

Except for initial registration, cube endpoints require the token of a cube
whose `registered` flag is set to `true`.

| Method | Endpoint | Description |
| --- | --- | --- |
| `POST` | `/api/v1cube/cubes` | Introduce a cube using a new token |
| `GET` | `/api/v1cube/cubes` | Return the authenticated cube |
| `GET` | `/api/v1cube/cube_files` | Return available Ruby files as Base64-encoded content |
| `GET` | `/api/v1cube/directives` | List pending directives for the cube |
| `GET` | `/api/v1cube/directives/:id` | Return one directive belonging to the cube |
| `PATCH` | `/api/v1cube/directives/:id` | Update a directive's status and output |

Initial cube registration:

```sh
curl \
  -X POST \
  -H "Authorization: Bearer $CUBE_TOKEN" \
  -H "Accept: application/json" \
  http://localhost:3000/api/v1cube/cubes
```

Registration creates a pending, unapproved cube when the supplied token is
new. Before that cube can use the other cube endpoints, set its `registered`
attribute to `true`, for example from the Rails console:

```ruby
cube = Cube.find_by!(api_token: ENV.fetch("CUBE_TOKEN"))
cube.update!(registered: true)
```

## MCP

Borg Collective exposes its management interface as a stateless, Streamable
HTTP MCP endpoint at `POST /mcp`. MCP requests use a user's API token, not a
cube token. Only administrators can currently list cubes and directives or
create directives.

Create or retrieve an administrator API token from the Rails console:

```ruby
user = User.find_by!(email_address: "admin@localhost")
user.api_token
```

Configure an MCP client with:

- URL: `http://localhost:3000/mcp`
- Authorization header: `Bearer <user-api-token>`

The server currently provides tools for inspecting the current user, cubes,
tags, and directives, plus `create_directives` for assigning work to cubes.

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
  --data '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"create_directives","arguments":{"filename":"ping.rb","cube_ids":[1]}}}'
```

The tool returns the created directive IDs. A connected cube polls for its
pending directives, downloads `ping.rb`, executes `Ping.run`, and reports the
result (`pong`) to Borg Collective. The cube must be running and have its
`registered` flag set to `true`.

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
from `storage/borg_cube_files/*.rb`.

## Main domain objects

- **Cube** — a remote agent identified by an encrypted token, registration
  state, and execution status.
- **Directive** — a unit of work assigned to a cube, including its filename,
  arguments, dependency, status, and captured output.
