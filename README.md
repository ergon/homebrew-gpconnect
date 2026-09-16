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


## If an upgrade fails

An upgrade that aborts with `--unregister-helper exited with 1` means the
*previous* install recorded a cask (1.4.4, or 1.4.5 on its first day) whose
uninstall preflight treats that spurious failure as fatal — and brew runs the
recorded copy, not the tap's current one, so a fixed tap cannot reach it.
Repair the record once (it patches both the Ruby and the JSON form brew may
have written, and is a no-op if yours is healthy), then upgrade again:

```sh
find "$(brew --prefix)/Caskroom/gpconnect/.metadata" \( -name gpconnect.rb -o -name gpconnect.json \) -print0 |
  xargs -0 -n1 /usr/bin/ruby -rjson -e '
    f = ARGV[0]; s = File.read(f)
    if f.end_with?(".json")
      j = JSON.parse(s)
      j["artifacts"].reject! { |a| a.is_a?(Hash) && a.keys.any? { |k| k.to_s.start_with?("uninstall_preflight") } }
      File.write(f, JSON.generate(j))
    else
      File.write(f, s.gsub(/^  uninstall_preflight(_steps)? do\n(.*?\n)*?  end\n/, ""))
    end
    puts "patched #{f}"'
```

Skipping the unregister on an upgrade is safe: the helper registration points
at the same path the new app lands on, and the package's installer does the
process teardown. From 1.4.5 on this cannot recur.
