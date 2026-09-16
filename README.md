# gpconnect

Menu bar VPN client for GlobalProtect gateways on macOS, driving
[openconnect](https://www.infradead.org/openconnect/).

## Install

```sh
brew tap ergon/gpconnect
brew trust --cask ergon/gpconnect/gpconnect
brew install --cask gpconnect
```

The trust step is required once per machine: Homebrew refuses to load anything
from a tap it does not know, with an error rather than a prompt.

## Update

```sh
brew update && brew upgrade --cask gpconnect
```
