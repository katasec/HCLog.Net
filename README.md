# HCLog.Net

> A HashiCorp-compatible `hclog` logger for .NET, designed to work seamlessly with Go hosts using [`go-plugin`](https://github.com/hashicorp/go-plugin).

## Features

- Emits logs in strict `hclog` JSON format expected by Go plugins
- Supports `debug`, `info`, `warn`, `error` levels
- Writes to `stderr` by default (compatible with go-plugin behavior)
- Minimal dependencies, .NET Standard 2.0 compatible

## Usage

```csharp
var logger = new HCLogger("plugin-core");
logger.Info("Starting plugin at {0}", DateTime.Now);
```
