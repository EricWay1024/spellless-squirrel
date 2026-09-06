//
//  SpelllessRulesTests.swift
//  Squirrel
//
//  Run by CI with plain swiftc, no Xcode target and no logged-in Mac:
//
//      swiftc -O sources/SpelllessRules.swift tests/SpelllessRulesTests.swift \
//        -o /tmp/rules && /tmp/rules
//
//  These cover the decisions, which is the half that can be wrong in an
//  interesting way.  Whether a given application honours a backwards
//  replacement range is a property of that application, not of this code, and
//  no amount of testing here will tell you -- on Windows the same feature was
//  broken by VS Code's terminal in a way nothing in the source predicted.

import Foundation

var failures: [String] = []
var checks = 0

func check(_ condition: Bool, _ what: String) {
  checks += 1
  if !condition { failures.append(what) }
}

func eq<T: Equatable>(_ got: T, _ want: T, _ what: String) {
  checks += 1
  if got != want { failures.append("\(what): got \(got), want \(want)") }
}

@main
struct SpelllessRulesTests {
  static func main() {
    runAll()
    print("\(checks) checks, \(failures.count) failures")
    for failure in failures { print("  FAIL \(failure)") }
    exit(failures.isEmpty ? 0 : 1)
  }
}

// swiftlint:disable:next function_body_length
func runAll() {
// MARK: - split

let bs = "\u{8}"

eq(SpelllessRules.split(commit: "hello").erase, 0, "ordinary text asks for nothing")
eq(SpelllessRules.split(commit: "hello").text, "hello", "and comes back whole")
eq(SpelllessRules.split(commit: bs + ".").erase, 1, "one backspace, one character")
eq(SpelllessRules.split(commit: bs + ".").text, ".", "and the text behind it")
eq(SpelllessRules.split(commit: bs + bs + bs + "so").erase, 3, "a run is counted")
eq(SpelllessRules.split(commit: bs + bs + bs + "so").text, "so", "and stripped")
eq(SpelllessRules.split(commit: bs + bs).erase, 2, "a bare run is a deletion")
eq(SpelllessRules.split(commit: bs + bs).text, "", "with nothing to insert")
eq(SpelllessRules.split(commit: "").erase, 0, "an empty commit is empty")

// Only a *leading* run counts.  A backspace in the middle of a commit is text,
// and taking it as a request would let any candidate containing one eat the
// document.
eq(SpelllessRules.split(commit: "a" + bs + "b").erase, 0, "a backspace inside the text is text")
eq(SpelllessRules.split(commit: "a" + bs + "b").text, "a" + bs + "b", "and is left alone")

// MARK: - mayReclaim, rule 1: our own space

check(SpelllessRules.mayReclaim(behind: " ", replacement: "."),
      "the automatic space before a full stop is ours to take")
check(SpelllessRules.mayReclaim(behind: "  ", replacement: "!"),
      "and so are two of them")
check(!SpelllessRules.mayReclaim(behind: "\n", replacement: "."),
      "a newline is not a space we wrote")
check(!SpelllessRules.mayReclaim(behind: "\t", replacement: "."),
      "and neither is a tab -- it belongs to whoever typed it")
check(!SpelllessRules.mayReclaim(behind: "d", replacement: "."),
      "an ordinary letter is not ours because a full stop is coming")

// MARK: - rule 2: the opening of what is being inserted

check(SpelllessRules.mayReclaim(behind: "so", replacement: "sooner"),
      "a word being re-typed is picked up")
check(SpelllessRules.mayReclaim(behind: "So", replacement: "sooner"),
      "and the check ignores case, because we may be capitalising it")
check(SpelllessRules.mayReclaim(behind: "so", replacement: "SOONER"),
      "in both directions")
check(!SpelllessRules.mayReclaim(behind: "xy", replacement: "sooner"),
      "text that is not the opening is refused -- the document moved")
check(!SpelllessRules.mayReclaim(behind: "sooner", replacement: "so"),
      "and a replacement shorter than what it claims to cover is refused")

// MARK: - rule 3: a bare word, deleted

check(SpelllessRules.mayReclaim(behind: "word", replacement: ""),
      "Backspace may delete a whole word")
check(SpelllessRules.mayReclaim(behind: "don't", replacement: ""),
      "apostrophes included, because contractions are words")
check(!SpelllessRules.mayReclaim(behind: "word.", replacement: ""),
      "but not a sentence's full stop")
check(!SpelllessRules.mayReclaim(behind: "a b", replacement: ""),
      "and not across a space, which would be two words")
check(!SpelllessRules.mayReclaim(behind: "line\n", replacement: ""),
      "and never a newline")

// MARK: - the refusals that matter

check(!SpelllessRules.mayReclaim(behind: "", replacement: "."),
      "nothing behind us is nothing to take")
check(!SpelllessRules.mayReclaim(behind: "42", replacement: ""),
      "digits are not a word")

// Unicode.  These rules speak in Characters; the range arithmetic in
// SpelllessDocument speaks in UTF-16 offsets, and the two part company as soon
// as anything outside the Basic Multilingual Plane is involved.  This is *not*
// guarded here -- an accented letter is a letter and rule 3 admits it -- and
// deliberately so: the guard belongs where the offsets are, and
// SpelllessDocument refuses when `behind.count != erase`, which is exactly the
// case where a Character and a UTF-16 unit are not the same thing.
check(SpelllessRules.mayReclaim(behind: "é", replacement: ""),
      "an accented letter is a letter")
check(!SpelllessRules.mayReclaim(behind: "😀", replacement: ""),
      "but an emoji is not, so rule 3 does not admit it")
}
