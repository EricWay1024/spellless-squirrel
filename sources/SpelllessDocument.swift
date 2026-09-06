//
//  SpelllessDocument.swift
//  Squirrel
//
//  Letting the schema see, and edit, the text already in the document.
//
//  Rime's own view of the document is its commit history, which is a record of
//  what the input method itself put there.  That is not the document: librime
//  clears the history on Backspace and Return (commit_history.cc), it never
//  hears about a click or an arrow key, and it cannot see a thing typed while
//  another input method was active.  Every rule built on it -- where a
//  sentence starts, whether a space is due, whether the space behind the caret
//  is ours to take back -- is therefore a guess.
//
//  The frontend does not have to guess.  It holds an IMKTextInput and can
//  simply look.  Two things are added here, and they are the whole contract
//  the Spellless schema expects of a frontend:
//
//    1. the Rime property `surrounding_text`, set to the characters
//       immediately before the composition on every keystroke;
//    2. a commit that begins with U+0008 characters, each one asking for a
//       character already in the document to be taken back.
//
//  Both are ports of what WeaselTSF does on Windows, against a much smaller
//  API: `insertText(_:replacementRange:)` is the whole of what TSF needs
//  ITfComposition::ShiftStart plus an edit session for, and there is no
//  client/server split to carry it across.
//
//  Nothing here is required to succeed.  An application that will not answer
//  leaves the schema exactly as it was before, which is the stock behaviour.

import InputMethodKit

enum SpelllessDocument {
  // MARK: - reading

  /// The text immediately before `client`'s composition, or before the caret
  /// when nothing is being composed.
  ///
  /// Measured from the *start* of the marked range, not the caret: with inline
  /// preedit the text being composed is already in the document, and reading
  /// from the caret would hand the schema its own half-typed word as though it
  /// were what came before.
  static func surroundingText(client: IMKTextInput?) -> String? {
    guard let client, let anchor = anchor(of: client)?.location else { return nil }
    guard anchor > 0 else { return "" }  // start of the document

    let wanted = min(anchor, SpelllessRules.surroundingChars)
    let range = NSRange(location: anchor - wanted, length: wanted)
    return client.attributedSubstring(from: range)?.string
  }

  // MARK: - writing

  /// The range a commit of `text` should replace, having asked to take back
  /// `erase` characters, or nil to commit normally.
  ///
  /// The marked text is included when there is any: on this API a commit and
  /// the reclaim are one replacement, where TSF moves the composition's start
  /// and then writes through it.
  static func replacementRange(client: IMKTextInput?, erase: Int, text: String) -> NSRange? {
    guard let client, erase > 0, erase <= SpelllessRules.maxReclaim,
          let marked = anchor(of: client), marked.location >= erase
    else {
      return nil
    }

    let behindRange = NSRange(location: marked.location - erase, length: erase)
    guard let behind = client.attributedSubstring(from: behindRange)?.string,
          behind.count == erase,
          SpelllessRules.mayReclaim(behind: behind, replacement: text)
    else {
      return nil
    }
    return NSRange(location: marked.location - erase, length: erase + marked.length)
  }

  /// Where the composition sits, preferring the marked range and falling back
  /// to the caret.  nil when the client will not say -- plenty of them will
  /// not, and they simply get the behaviour they had before.
  private static func anchor(of client: IMKTextInput) -> NSRange? {
    let marked = client.markedRange()
    if marked.location != NSNotFound && marked.location != NSIntegerMax {
      return marked
    }
    let selected = client.selectedRange()
    if selected.location != NSNotFound && selected.location != NSIntegerMax {
      return NSRange(location: selected.location, length: 0)
    }
    return nil
  }
}
