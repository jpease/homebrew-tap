class Gpy < Formula
  desc "Fast shell prompt for Fish, Zsh and Bash with an agent-based architecture"
  homepage "https://github.com/jpease/gpy"
  url "https://github.com/jpease/gpy/archive/refs/tags/v0.10.0.tar.gz"
  sha256 "cc55127d16fb7617c687709b9d761393c51d64042424eb78218f61ccc47699ae"
  license "GPL-3.0-or-later"
  head "https://github.com/jpease/gpy.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/jpease/homebrew-tap/releases/download/gpy-0.10.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "2d6e8c22f9a12d98a568b011f5ed5a131b0d9e320250b0312c53f3a6d1cb66c7"
    sha256 cellar: :any,                 x86_64_linux:  "3a825675c6be23183488686bfbae7026a499957982321965e24a08d8cc55ea29"
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
