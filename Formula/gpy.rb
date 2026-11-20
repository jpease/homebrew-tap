class Gpy < Formula
  desc "Fast shell prompt for Fish, Zsh and Bash with an agent-based architecture"
  homepage "https://github.com/jpease/gpy"
  url "https://github.com/jpease/gpy/archive/refs/tags/v0.12.1.tar.gz"
  sha256 "c3370fb9b146060ab25e573498c6a45c89fe9edb71d15f0f52114e88320c63c1"
  license "GPL-3.0-or-later"
  head "https://github.com/jpease/gpy.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/jpease/homebrew-tap/releases/download/gpy-0.12.1"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "8d4d0ea89402255549bff7a8a1fce281695390d1c61be90600a538ab81f9e4a3"
    sha256 cellar: :any,                 x86_64_linux:  "659e698f1bf2bef9892d173f6a409e5d2eecd53b9bdb5b39c5c80b67b1ea3315"
  end

  depends_on "rust" => :build

  def install
    # release-dist is the optimized profile the release binaries use; the
    # crate's plain `release` profile is tuned for build speed.
    system "cargo", "install", "--profile", "release-dist", *std_cargo_args(path: "gpy-agent")

    # Ship the three shell trees and the bundled username/hostname plugins
    # as-is. Nothing here needs a shell installed: they are plain scripts, and
    # `gpy setup` copies the one for the user's shell into their config dir and
    # wires their rc file.
    pkgshare.install "fish", "zsh", "bash", "plugins"

    doc.install "README.md", "SECURITY.md"
  end

  # An agent still running from the previous version keeps serving (and can
  # fail) after an upgrade. Replace it when its socket exists; never start one.
  # Best effort: a failed restart must not fail the install.
  post_install_steps do
    if_path_exists ".cache/gpy/gpy.sock", base: :home do
      run "gpy-agent", base: :bin, args: ["restart"], must_succeed: false,
                       writable_paths: [".cache/gpy"], writable_base: :home
    end
  end

  def caveats
    <<~EOS
      GPY is installed, but Homebrew formulas don't modify your dotfiles.
      To wire it into the shell you use (Fish, Zsh or Bash), run:

        gpy setup

      It detects your shell from $SHELL; pass --shell fish|zsh|bash to pick
      another. Then restart your shell with `exec $SHELL`.
      Run 'gpy doctor' any time to check your setup.

      Upgrading from 0.12.0 or earlier? Run once, then `exec $SHELL`:

        brew postinstall jpease/tap/gpy && gpy setup

      Later upgrades refresh the agent and shell files on the next prompt.
    EOS
  end

  test do
    system bin/"gpy-agent", "--help"
    system bin/"gpy-agent", "oneshot", "git", "--cwd", testpath
    system bin/"gpy-agent", "oneshot", "lang", "--cwd", testpath
    system bin/"gpy", "--version"

    # The shipped layout is what `gpy setup` consumes.
    ENV["HOME"] = testpath
    ENV["XDG_DATA_HOME"] = testpath/".local/share"
    system bin/"gpy", "setup", "--shell", "zsh", "--non-interactive", "--from", pkgshare
    assert_path_exists testpath/".local/share/gpy/zsh/gpy.zsh"
    assert_path_exists testpath/".local/share/gpy/plugins/hostname/plugin.toml"
  end
end
