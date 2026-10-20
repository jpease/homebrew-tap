class Gpy < Formula
  desc "Fast shell prompt for Fish, Zsh and Bash with an agent-based architecture"
  homepage "https://github.com/jpease/gpy"
  url "https://github.com/jpease/gpy/archive/refs/tags/v0.5.1.tar.gz"
  sha256 "2c01ac17817a28541c7377749678dcc2b9fae4b0a2d73024f9b14156fa132ac7"
  license "GPL-3.0-or-later"
  head "https://github.com/jpease/gpy.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/jpease/homebrew-tap/releases/download/gpy-0.5.1"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "6b65d7bf83331ded6c6f2ade9685507b02e252494397c2e727f560fe8a43ad0f"
    sha256 cellar: :any,                 x86_64_linux:  "6baee6a631b2adb1ba25765e2c9911c64ff747551a952742dcf6c8cd032c9065"
  end

  depends_on "rust" => :build

  def install
    # release-dist is the optimized profile the release binaries use; the
    # crate's plain `release` profile is tuned for build speed.
    system "cargo", "install", "--profile", "release-dist", *std_cargo_args(path: "gpy-agent")

    # Ship the three shell trees as-is. Nothing here needs a shell installed:
    # they are plain scripts, and `gpy setup` copies the one for the user's
    # shell into their config dir and wires their rc file.
    pkgshare.install "fish", "zsh", "bash"

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
    system "#{bin}/gpy-agent", "--help"
    system "#{bin}/gpy-agent", "oneshot", "git", "--cwd", testpath
    system "#{bin}/gpy-agent", "oneshot", "lang", "--cwd", testpath
    system "#{bin}/gpy", "--version"

    # The shipped layout is what `gpy setup` consumes.
    ENV["HOME"] = testpath
    system "#{bin}/gpy", "setup", "--shell", "zsh", "--non-interactive", "--from", pkgshare
    assert_path_exists testpath/".config/gpy/zsh/gpy.zsh"
  end
end
