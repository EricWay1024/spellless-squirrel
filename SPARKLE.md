# Updates, and why this build does not offer any

This fork inherited Squirrel's Sparkle updater unchanged, and unchanged it was
pointed at upstream:

```
SUEnableAutomaticChecks   true
SUFeedURL                 https://rime.github.io/release/squirrel/appcast.xml
SUPublicEDKey             ukvWq2dKOWn3B9AsdsQIwOptiDdDKdUjAVNgFxSvB2o=
CURRENT_PROJECT_VERSION   1.1.2
```

Every one of those is upstream's, including the version number. Nothing was
offered while upstream sat at 1.1.2, because the versions compared equal. The
day rime/squirrel tagged 1.1.3, Sparkle would have found a newer build, signed
with the key this app already trusts, posted *"A new update is available"*, and
installed stock Squirrel over `/Library/Input Methods/Squirrel.app`.

That is the worst shape a failure can take here. `~/Library/Rime` is untouched,
so Spellless keeps typing — without the four features that need this build:
punctuation reclaiming its space, a caret inside a word meaning plain typing,
absorbing a re-typed word, and word-backspace. They would stop working, on
their own, with nothing on screen to say why. (`zzver` would show it: line four
reclaim off, line five document not readable.)

**So the feed now points at `appcast.xml` in this repository, which has no
items in it, and automatic checking is off.** Nothing is offered, by schedule
or by the *Check for updates…* menu item. Sparkle stays compiled in because
removing it means removing code that CI's `periphery` unused-code scan would
then reject — a much larger change than the problem needs.

Users update by downloading the current `.pkg` from the
[Spellless releases](https://github.com/EricWay1024/spellless/releases).

---

## Publishing real updates from here

Worth doing — it is the only way a macOS user hears about a new Spellless
release. Four things are needed, and the first is the one that cannot be
delegated.

**1. An EdDSA key pair.** Sparkle's `generate_keys` makes one and puts the
private half in your Keychain; `generate_keys -x private.key` exports it. The
key is an ordinary ed25519 pair, so a Mac is not required to create it — but
whoever creates it holds the authority to install software on every user's
machine, so create it yourself and let nothing else see it.

* private half → the `SPARKLE_PRIVATE_KEY` secret on this repository
* public half → `SUPublicEDKey` in `resources/Info.plist`, replacing
  upstream's, which is still there and is wrong for our purposes

**2. A version that increases.** `CURRENT_PROJECT_VERSION` is pinned at
upstream's `1.1.2` in `Squirrel.xcodeproj/project.pbxproj`. Sparkle compares
exactly that, so two Spellless builds are indistinguishable until it moves.
`1.1.2.1`, `1.1.2.2`, … keeps it honest about which Squirrel this is and sorts
above plain `1.1.2`; CI can set the last component from the tag.

**3. A release, with a stable download URL.** There is no release pipeline in
this repository yet. `release-ci.yml` fires on tags and on `master`; the
`spellless` branch only reaches `commit-ci.yml`, which uploads a `.pkg` as a
90-day artifact — an artifact URL is not something an appcast can point at. The
`.pkg` needs to be attached to a release, here or in the Spellless repository.

**4. Signing and the appcast.** `make package/sign_update` builds the signing
tool; `sign_update <pkg>` prints the `sparkle:edSignature` and length for the
enclosure. `generate_appcast` will write the whole file given a directory of
signed builds. An input-method `.pkg` installs to `/Library/Input Methods` and
so needs a privileged install: `SUEnableInstallerLauncherService` is already
`true`, and the appcast item wants `sparkle:installationType="package"`.

Until all four are in place, leave the feed empty. A feed with an item in it
that does not validate against `SUPublicEDKey` is not a broken update — it is
an update that gets rejected, which is the right failure, but it will also be a
confusing one to diagnose.
