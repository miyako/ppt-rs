# _pptcli_Controller
### Extends `_CLI_Controller` with stdout/stderr accumulation and progress parsing.

> _pptcli_Controller.new (CLI : cs.ppt_rs._CLI)

| Parameter | Type | | Description |
| --- | --- | --- | --- |
| CLI | cs.ppt_rs._CLI | -> | The owning `_CLI` instance |

## Description

`_pptcli_Controller` is the default controller used by [`pptcli`](pptcli.md). It inherits all command-queue and worker-management behaviour from [`_CLI_Controller`](_CLI_Controller.md) and overrides the data and response event handlers to:

- Accumulate stdout into `stdOut` for synchronous callers.
- Parse `pptcli` progress output from stderr and forward structured progress objects to `pptcli.onData`.
- Forward `onResponse`, `onError`, and `onTerminate` events to the corresponding callbacks on the owning `pptcli` instance.

### Properties

In addition to properties inherited from `_CLI_Controller`:

| Property | Type | Description |
| --- | --- | --- |
| stdOut | Text | Accumulated stdout text from the last command |
| stdErr | Text | Accumulated stderr text (consumed incrementally during progress parsing) |

### Methods

#### clear () → cs.ppt_rs._pptcli_Controller

Resets `stdOut` and `stdErr` to empty strings. Called automatically by the constructor and by `pptcli.execute` between successive synchronous commands.

| Result | Type | Description |
| --- | --- | --- |
| Result | cs.ppt_rs._pptcli_Controller | `This` — enables chaining |

### Overridden event callbacks

#### onData ($worker : 4D.SystemWorker; $params : Object)

Appends `$params.data` to `stdOut`.

#### onDataError ($worker : 4D.SystemWorker; $params : Object)

Handles stderr output from the `pptcli` process. When `pptcli.onData` is set, appends incoming data to `stdErr` and scans it with a regex for progress entries of the form `###…  nn.nn%`. For each match found, calls `pptcli.onData` with a context object:

| Property | Type | Description |
| --- | --- | --- |
| percentage | Real | Parsed progress percentage (0–100) |
| context | Object | Per-command context from `SYSTEM_WORKER_CONTEXT` keyed by worker PID |

Consumed characters are trimmed from `stdErr` after each scan pass, so partial lines are held until a complete match arrives. When `pptcli.onData` is not set, stderr is silently discarded.

#### onResponse ($worker : 4D.SystemWorker; $params : Object)

Forwards to `pptcli.onResponse` if set.

#### onError ($worker : 4D.SystemWorker; $params : Object)

Forwards to `pptcli.onError` if set.

#### onTerminate ($worker : 4D.SystemWorker; $params : Object)

Forwards to `pptcli.onTerminate` if set.

## See also

- [`_CLI_Controller`](_CLI_Controller.md) — parent class
- [`pptcli`](pptcli.md) — sets `onData`, `onResponse`, `onError`, `onTerminate` which this controller forwards to
