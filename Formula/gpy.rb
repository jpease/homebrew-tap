class Gpy < Formula
  desc "Fast shell prompt for Fish, Zsh and Bash with an agent-based architecture"
  homepage "https://github.com/jpease/gpy"
  url "https://github.com/jpease/gpy/archive/refs/tags/v0.10.2.tar.gz"
  sha256 "b2fca657cae7ced9e19aa03d30df4c681e1e4d3ab7eee0ab260c3d8106c69465"
  license "GPL-3.0-or-later"
  head "https://github.com/jpease/gpy.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/jpease/homebrew-tap/releases/download/gpy-0.10.2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "4be8e3edf52ff83020defcdca2ee22b3e7edca4bc117677bec61035e79fd0969"
    sha256 cellar: :any,                 x86_64_linux:  "af333d70d2c7e81205602f2b69967049f65e98f1d1b08f644a8ea2cc301d0cb2"
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

  def caveats
    <<~EOS
      GPY is installed, but Homebrew formulas don't modify your dotfiles.
      To wire it into the shell you use (Fish, Zsh or Bash), run:

        gpy setup

      It detects your shell from $SHELL; pass --shell fish|zsh|bash to pick
      another. Then restart your shell with `exec $SHELL`.
      Run 'gpy doctor' any time to check your setup.
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
