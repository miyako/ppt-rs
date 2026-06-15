# pptcli
### Wraps the `pptcli` CLI to generate PPTX presentations from Markdown or HTML via `4D.SystemWorker`.

> pptcli.new (class : 4D.Class)

| Parameter | Type | | Description |
| --- | --- | --- | --- |
| class | 4D.Class | -> | Optional custom controller class; must extend `_pptcli_Controller` (default: `cs.ppt_rs._pptcli_Controller`) |

## Description

`cs.ppt_rs.pptcli` extends [`_CLI`](_CLI.md) and wraps the `pptcli` executable, a tool for converting Markdown and HTML content into `.pptx` presentation files. It provides `execute()` to run one or more subcommands with support for both synchronous and asynchronous operation.

If a class that does not extend `_pptcli_Controller` is passed, the constructor silently falls back to `cs.ppt_rs._pptcli_Controller`. Detection walks the full superclass chain.

### Subcommands

| Subcommand | Input | Description |
| --- | --- | --- |
| `md2ppt` | Markdown file | Converts a Markdown document to a `.pptx` file; each `#` heading starts a new slide |
| `html2ppt` | HTML file | Converts an HTML document to a `.pptx` file; `<h1>` elements start new slides |

### Properties

| Property | Type | Description |
| --- | --- | --- |
| onData | 4D.Function | Called by the controller on each parsed progress update (async mode only) |
| onResponse | 4D.Function | Called by the controller when a command completes |
| onError | 4D.Function | Called by the controller on worker error |
| onTerminate | 4D.Function | Called by the controller when the worker terminates |
| worker | 4D.SystemWorker | The currently active worker (read-only, from controller) |
| controller | cs.ppt_rs._pptcli_Controller | The attached controller instance (read-only) |

### Methods

#### execute (option : Variant; events : Object) → Collection

Runs one or more `pptcli` commands built from a collection of task arrays, in sync or async mode.

| Parameter | Type | | Description |
| --- | --- | --- | --- |
| option | Collection \| Collection of Collections | -> | A single task array or a collection of task arrays (see below) |
| events | Object | -> | Event callbacks; if `events.onResponse` is set the call is asynchronous |
| Result | Collection | <- | Collection of stdout strings (one per task), or `Null` in async mode |

**Sync mode** (no `events.onResponse`): each worker runs to completion before the next starts. `controller.stdOut` is collected into `$results` and `controller.clear()` is called after each command. Returns a Collection of raw stdout strings.

**Async mode** (`events.onResponse` present): workers are started without waiting. Returns `Null` immediately. Progress updates are delivered to `events.onData` as percentage objects (see [`_pptcli_Controller`](_pptcli_Controller.md)).

**Task array element types** — each task is a flat collection where elements are interpreted by type:

| Element type | Behaviour |
| --- | --- |
| Text | Shell-escaped and appended to the command |
| Real / Integer | Appended as a numeric string |
| Boolean / Null | Ignored |
| 4D.File / 4D.Folder | Platform path is shell-escaped and appended |
| Object with `.data` | Value stored as the per-command context, accessible in callbacks via `SYSTEM_WORKER_CONTEXT` |
| Object with `.file` | Text or Blob posted to worker stdin |

Unlike `cs.curl` and `cs.xls_rs`, `pptcli` has no reserved text flag values — all text elements are passed through to the command without special handling.

### events object properties

| Property | Type | Description |
| --- | --- | --- |
| onResponse | 4D.Function | Required for async mode; called when each command completes |
| onData | 4D.Function | Optional; receives `{percentage, context}` progress objects |
| onError | 4D.Function | Optional; called on worker error |
| onTerminate | 4D.Function | Optional; called when the worker terminates |

## Examples

### Markdown to PPTX

Each `#` heading in the Markdown source becomes a new slide. The input file is passed as a positional argument; the output path follows immediately.

```4d
var $pptcli : cs.ppt_rs.pptcli
$pptcli:=cs.ppt_rs.pptcli.new(Null)

var $folder : 4D.Folder
$folder:=Folder(Temporary folder; fk platform path).folder(Generate UUID)
$folder.create()

var $in : 4D.File
$in:=$folder.file("slides.md")
$in.setText("# Introduction\n- Welcome\n- Agenda\n\n# Key Points\n- Point one\n- Point two")

var $out : 4D.File
$out:=Folder(fk desktop folder).file("slides.pptx")

var $events : Object
$events:={}
$events.onResponse:=Formula(ALERT("Done"))
$events.onError:=Formula(ALERT("Error"))

var $tasks : Collection
$tasks:=[]
$tasks.push(["md2ppt"; $in; $out; {data: $out; file: Null}])

$pptcli.execute($tasks; $events)
```

### HTML to PPTX

`<h1>` elements in the HTML source mark slide boundaries. Tables and lists are rendered as slide content.

```4d
var $html : Text
$html:="<h1>Slide One</h1><p>Intro text</p><ul><li>A</li><li>B</li></ul>"
$html+="<h1>Data</h1><table><tr><th>Item</th><th>Value</th></tr><tr><td>X</td><td>42</td></tr></table>"

var $in : 4D.File
$in:=$folder.file("slides.html")
$in.setText($html)

$out:=Folder(fk desktop folder).file("slides.pptx")

$tasks:=[]
$tasks.push(["html2ppt"; $in; $out; {data: $out; file: $html}])

$pptcli.execute($tasks; $events)
```

### Multiple conversions in one call

```4d
$tasks:=[]
$tasks.push(["md2ppt";   $mdFile;   $out1; {data: $out1; file: Null}])
$tasks.push(["html2ppt"; $htmlFile; $out2; {data: $out2; file: $html}])

$pptcli.execute($tasks; $events)
```

## See also

- [`_CLI`](_CLI.md) — parent class providing executable resolution and shell escaping
- [`_pptcli_Controller`](_pptcli_Controller.md) — default controller; handles progress parsing and event forwarding
- [`_CLI_Controller`](_CLI_Controller.md) — base controller providing the command queue
