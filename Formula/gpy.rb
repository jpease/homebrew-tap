class Gpy < Formula
  desc "Fast shell prompt for Fish, Zsh and Bash with an agent-based architecture"
  homepage "https://github.com/jpease/gpy"
  url "https://github.com/jpease/gpy/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "d0ed3f9d3ef9c120722699dc605b1d8f50db4c544e5edf42d3c1e9797f8fad14"
  license "GPL-3.0-or-later"
  head "https://github.com/jpease/gpy.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "gpy-agent")

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
