//
//  SpelllessRules.swift
//  Squirrel
//
//  The two decisions behind SpelllessDocument, with no InputMethodKit in
//  sight: how many characters a commit is asking to take back, and whether
//  what is actually there may be taken.
//
//  Separate because they are the parts that can be wrong in an interesting
//  way, and because a file with no UI dependency can be compiled and run by
//  `swiftc` in CI -- see tests/SpelllessRulesTests.swift.  Whether a given
//  application honours a backwards replacement range is not testable that
//  way, and is not decided here.

import Foundation

enum SpelllessRules {
  /// How much of the text behind the caret the schema is shown.
  ///
  /// Enough for the spacing and capitalisation rules to see a sentence
  /// boundary and a word or two, and short enough that the read stays trivial
  /// on every keystroke.
  static let surroundingChars = 32

  /// The most characters one commit may take back.
  ///
  /// A bound rather than a policy: the schema asks for one space, or one word.
  /// Anything wilder than this is a bug somewhere upstream and should not
  /// reach the document.
  static let maxReclaim = 64

  /// How many characters the commit is asking to take back, and what is left
  /// of it once they are stripped.
  ///
  /// The convention is a run of U+0008 at the very front, one per character.
  /// It is a convention rather than a Rime feature because a commit is the
  /// only channel a schema has to the frontend, and it costs nothing on a
  /// frontend that has never heard of it -- there, the backspaces arrive as
  /// text, which is visible and harmless.
  static func split(commit: String) -> (erase: Int, text: String) {
    var erase = 0
    var rest = Substring(commit)
    while rest.first == "\u{8}" {
      erase += 1
      rest = rest.dropFirst()
    }
    return (erase, String(rest))
  }

  /// May `behind` be taken back, given that `replacement` is going in?
  ///
  /// The schema read this same text through `surrounding_text` before it
  /// decided, so a disagreement here means the document moved underneath us --
  /// a click, an arrow key, another window -- and the safe answer is to leave
  /// it alone.  Three things may legitimately be reclaimed and nothing else.
  static func mayReclaim(behind: String, replacement: String) -> Bool {
    guard !behind.isEmpty else { return false }

    // 1. Whitespace this input method wrote itself, so that punctuation can
    //    sit flush against the word before it: "hello " + "." -> "hello. ".
    if behind.allSatisfy({ $0 == " " }) {
      return true
    }

    // 2. The opening of the text being inserted, which is how a word being
    //    re-typed is picked up: "so" is replaced by "sooner".  Self-checking,
    //    because a wrong guess simply will not match.
    if replacement.count >= behind.count {
      let opening = replacement.prefix(behind.count)
      if opening.lowercased() == behind.lowercased() {
        return true
      }
    }

    // 3. A bare word, when nothing is being inserted: Backspace deleting a
    //    whole word.  Letters and apostrophes only, so a newline or a
    //    sentence's punctuation can never be taken by accident.
    if replacement.isEmpty && behind.allSatisfy({ $0.isLetter || $0 == "'" }) {
      return true
    }

    return false
  }
}
