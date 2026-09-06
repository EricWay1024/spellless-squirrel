# Spellless on macOS

This is [Squirrel](https://github.com/rime/squirrel) with the two things the
[Spellless](https://github.com/EricWay1024/spellless) schema needs from a
frontend and cannot do for itself. The schema half already runs on stock
Squirrel; this fork is only about the document.

## What it adds

A schema's view of the document is Rime's commit history, which is a record of
what the input method itself put there rather than of what is there: librime
clears it on Backspace and Return, it never hears about a click or an arrow
key, and it cannot see anything typed while another input method was active.
So every rule built on it — where a sentence starts, whether a space is due,
whether the space behind the caret is ours to take back — is a guess.

The frontend does not have to guess. It holds an `IMKTextInput` and can look.

1. **`surrounding_text`** — the Rime property is set on every keystroke to the
   32 characters before the composition, read with
   `attributedSubstring(from:)`.
2. **Commits that take text back** — a commit beginning with U+0008 characters
   asks for that many characters of the document to be reclaimed. With text to
   insert that is an `insertText(_:replacementRange:)` over a range extending
   backwards; with nothing to insert it is empty *marked* text over the same
   range, followed by `unmarkText`.

   The second case is not a stylistic choice. `insertText("", replacementRange:)`
   is what you would write and a great many clients ignore it — an empty insert
   reads as nothing to do, and the range goes with it. That is exactly why
   reclaiming the space before a full stop worked in the first build, where
   there is a full stop to insert, while absorbing a half-typed word, which
   inserts nothing at all, did not.

That is the whole contract, and it is the same one
[spellless-weasel](https://github.com/EricWay1024/spellless-weasel) implements
on Windows against TSF — where it needs `ITfComposition::ShiftStart`, an edit
session and an IPC hop to carry the text between the two processes. Here it is
two functions.

Three schema features ride on it: punctuation takes its automatic space back,
a word you re-type is picked up mid-word, and Backspace deletes a whole word.
All three ship **off** and are switched on in `spellless.custom.yaml`.

## What is checked, and what is not

`SpelllessRules` holds the two decisions — how many characters are being asked
for, and whether what is actually there may be taken — with no InputMethodKit
in sight, so CI compiles and runs them with plain `swiftc`:

```
swiftc -O -parse-as-library sources/SpelllessRules.swift \
  tests/SpelllessRulesTests.swift -o /tmp/rules && /tmp/rules
```

**Whether a given application honours a backwards replacement range is not
testable that way, and is the actual risk.** It is a property of that
application's `NSTextInputClient`. On Windows the same feature was broken by
VS Code's integrated terminal, which re-sends a hidden buffer whenever a
backwards edit changes it, so "Hello" + space + "." came out `Hello Hello.` —
and nothing in the source predicted that. It took someone typing.

So the first real test is a person at a Mac, typing into TextEdit, Notes,
Chrome, Safari, Terminal.app, iTerm2 and VS Code, and watching for a
duplicated line. Whatever misbehaves goes in the schema's `commit_only_apps`
by bundle identifier, exactly as `code.exe` is on Windows.

Refusal is silent and safe by design: when the client will not say where it
is, or what is behind the caret is not what the schema expected, the commit
lands on its own — spare space and all — which is precisely the behaviour of a
frontend that never heard of any of this.

## Building

Push to the `spellless` branch and GitHub Actions builds it: `.github/workflows/spellless-build.yml`,
on a `macos-26` runner, artifact `Squirrel-Spellless`. No Mac required to get
a `.pkg`.

The package is **not signed or notarised** — neither is upstream Squirrel's,
whose release CI publishes straight from Actions with no codesign step. macOS
will refuse it on first open; right-click the `.pkg` → **Open**, or
`xattr -d com.apple.quarantine <file>`.

## Installing

1. Install the `.pkg`, and log out and back in (macOS caches input methods).
2. Add **Squirrel** in System Settings → Keyboard → Input Sources.
3. Install the Spellless schema: take `spellless-<version>.zip` from the
   [releases](https://github.com/EricWay1024/spellless/releases) and run
   `python3 scripts/install.py` — it finds `~/Library/Rime` itself.
4. Deploy from the Squirrel menu-bar icon, then pick Spellless from the schema
   menu.
5. Type `zzver` in any text box. It reports the build actually running.

To switch the three features on, put this in
`~/Library/Rime/spellless.custom.yaml`:

```yaml
patch:
  spellless/reclaim_space: true
  spellless/absorb_fragment: true
  spellless/word_backspace: true
```

and deploy again. Leave them off and this is stock Squirrel behaviour.

## Licence

GPL-3.0, like Squirrel. The Spellless schema itself is MIT and lives in its
own repository.
