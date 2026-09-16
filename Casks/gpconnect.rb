cask "gpconnect" do
  version "1.4.4,1"
  sha256 "a5156139911b4ec51ffaa42d0acf7646d80e781cb234a058b40094ea7417c45f"

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
  uninstall_preflight_steps do
    if_path_exists "/Applications/gpconnect.app/Contents/MacOS/gpconnect" do
      run "/Applications/gpconnect.app/Contents/MacOS/gpconnect", args: ["--unregister-helper"]
    end
  end

  uninstall pkgutil: "ch.ergon.gpconnect"

  # Deliberately no zap of the Keychain item. `brew uninstall --zap` deleting someone's
  # stored VPN password is not a thing to do quietly, and the account survives a reinstall
  # usefully. Settings and the credential source are fair game.
  zap trash: "~/Library/Preferences/ch.ergon.gpconnect.plist"
end
