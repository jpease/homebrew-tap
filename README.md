# jpease/homebrew-tap

Homebrew tap for [GPY](https://github.com/jpease/gpy).

```sh
brew install jpease/tap/gpy
```

Then run `gpy setup` to wire GPY into Fish, Zsh or Bash (see the printed
caveats or the [install guide](https://github.com/jpease/gpy/blob/main/docs/INSTALL.md)).

## Bottles

Formula changes go through pull requests. `brew test-bot` (`tests.yml`) builds
and tests bottles on macOS 15 (Apple Silicon and Intel) and Linux x86_64. Once
it is green, publish them with:

```sh
gh workflow run publish.yml -R jpease/homebrew-tap -f pull_request=<number>
```

`brew pr-pull` uploads the bottles to a release in this repository, adds the
`bottle do` block to the formula, pushes to `main` and closes the pull request.
Do not merge the pull request yourself.
