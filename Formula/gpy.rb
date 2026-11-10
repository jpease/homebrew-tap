class Gpy < Formula
  desc "Fast shell prompt for Fish, Zsh and Bash with an agent-based architecture"
  homepage "https://github.com/jpease/gpy"
  url "https://github.com/jpease/gpy/archive/refs/tags/v0.10.5.tar.gz"
  sha256 "909ac73ab18af7e1e1aed5cbc4c88cb59014de4f5d5fddd248c0ebe5462ac43d"
  license "GPL-3.0-or-later"
  head "https://github.com/jpease/gpy.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
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
