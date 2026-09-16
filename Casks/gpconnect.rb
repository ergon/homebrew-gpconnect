cask "gpconnect" do
  version "1.4.5,2"
  sha256 "2eb8d3842c50e35c2aa4f39d451a98c97672788a3e4ac2db1e663e6817f1848b"

  url "https://github.com/ergon/homebrew-gpconnect/releases/download/v#{version.csv.first}.#{version.csv.second}/gpconnect-#{version.csv.first}.pkg"
  name "gpconnect"
  desc "Menu bar VPN client for GlobalProtect gateways"
  homepage "https://github.com/ergon/homebrew-gpconnect"

  # gpconnect drives openconnect and cannot do anything without it, so brew installs it
  # rather than leaving the first connection attempt to explain the omission.
  depends_on formula: "openconnect"
  # The deployment target is 13.6; Homebrew has no finer grain than the major release.
  # A bare symbol already means "this version or newer" — the ">= :ventura" string form is
  # deprecated and warns on every install, twice.
  depends_on macos: :ventura

  pkg "gpconnect-#{version.csv.first}.pkg"

  # Before the payload is removed, while the app is still there to do it: SMAppService
  # unregistration can only be performed by the bundle that registered the service. Delete
  # the app first and the LaunchDaemon stays registered, pointing at nothing.
  #
  # Best-effort (`|| true`), deliberately: a preflight failure blocks the whole uninstall
  # — and an upgrade, which is an uninstall in disguise — and a helper that could not be
  # unregistered is not something keeping the app installed can fix. Binaries before 1.4.5
  # also exited 1 here whenever the service manager threw its spurious "Socket is not
  # connected", which walled every one of their upgrades until this stopped being fatal.
  uninstall_preflight_steps do
    if_path_exists "/Applications/gpconnect.app/Contents/MacOS/gpconnect" do
      run "/bin/sh", args: ["-c",
        "/Applications/gpconnect.app/Contents/MacOS/gpconnect --unregister-helper || true"]
    end
  end

  uninstall pkgutil: "ch.ergon.gpconnect"

  # Deliberately no zap of the Keychain item. `brew uninstall --zap` deleting someone's
  # stored VPN password is not a thing to do quietly, and the account survives a reinstall
  # usefully. Settings and the credential source are fair game.
  zap trash: "~/Library/Preferences/ch.ergon.gpconnect.plist"

  caveats <<~TEXT
    If an upgrade of gpconnect ever aborts with "--unregister-helper exited
    with 1": your previous install recorded a cask (1.4.4, or 1.4.5 on its
    first day) whose uninstall preflight treats that spurious failure as
    fatal, and brew runs the recorded copy rather than this one. The one-time
    repair — a no-op if yours is healthy — is here:

        https://github.com/ergon/homebrew-gpconnect#if-an-upgrade-fails
  TEXT
end
