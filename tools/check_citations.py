#!/usr/bin/env python3
"""Citation-attribution gate.

A requirement that reports what another requirement SAYS is making a checkable
claim about a specific span of text. On 2026-09-03 several of those claims were
false, in both directions: `WIR-20` and `WIR-35` attributed this set's
wire-contract precedence rule to `WIR-1`, which carries the JSON, money and
timestamp conventions and says nothing of the kind; `DOM-30` reported that
`WIR-30` forbids what `WIR-30` in fact mandates. Two full review passes at
`high` effort read past all of them. See `ddd3df0` and `254fc24`.

The other gates cannot see this class. `check_ids.py` is satisfied -- the
citation resolves to a real identifier. `check_obligations.py` is satisfied --
no duty is being assigned. The sentence reads fluently. Only the relationship
between the claim and the cited text is broken.

FOUR RULES, deliberately narrow.

  QUOTED   A quoted phrase attributed to `X` must appear in X's own body, or in
           a document the same chunk cites: a document DOC matches by file name
           (a numbered requirement document, README.md, CONTEXT.md or
           AGENTS.md), or an ADR by `ADR-NNNN` -- that ADR's file alone. Until 2026-10-02 the
           concatenated text of every ADR satisfied any attribution, which let
           `11-open-findings.md` attribute to `OPS-47` and `OPS-39` wording
           only `ADR-0019` and `ADR-0021` still hold (`pv-vwe.25`).
           Hard failure: the quote either occurs there or it does not, so a
           finding is provable and needs no judgement. Reads the Markdown
           documents and /-- ... -/ and /-! ... -/ docstrings under tools/formal/,
           excluding .lake/. The Lean residue is ratcheted in
           citation-baseline.json's quoted_attributions, keyed by file:id:quote
           with the full normalized quote; its note owns the causes and exits.
           On 2026-09-15 a Lean docstring quoting withdrawn wording stayed green
           for a day, motivating the Lean QUOTED pass.
           REACH: a quote is checked only when its SPLIT chunk carries an
           ATTRIB match (a speech verb, or `X`'s <noun> that) before it and the
           chunk is neither HISTORICAL nor TEACHING. In Lean docstrings that is
           the minority: at `c5e31be` (2026-10-02), 56 of the 925 quotes of four
           or more normalised words were compared. The gate prints both figures
           on every run; the numbers here are that day's reading, not a rule.
           Paired quotations stay in one chunk, including sentence enders and
           spaced elisions. Marks are paired before length/word filtering, so a
           short span cannot steal the next quote's opening mark (pv-vwe.35).
           What it cannot see: unmatched or nested straight marks can still
           pair with the wrong mark within a paragraph. Blank lines are hard
           boundaries, including between separately extracted Lean docstrings.
           This is a paired-mark scanner, not a Markdown or Lean prose parser.
           Historical/teaching heuristics apply to the whole resulting chunk;
           a word inside a quotation can therefore suppress its comparison.

  EXISTS   Every quote of four or more normalised words in a Lean docstring
           must appear somewhere in the corpus -- every root *.md plus
           docs/adr/*.md -- whether or not its chunk carries an attribution
           (`pv-vwe.25`, decided 2026-10-01). A quote is what QUOTE matches:
           a paired span of at most 400 characters containing at least four
           normalised words. Longer quotations are counted by neither rule,
           but their marks are consumed before scanning the next span.
           Compared with norm() and, in this
           rule only, with ' and " removed from both sides, since a docstring
           writes a nested quotation with single marks where the document has
           double ones. Chunks HISTORICAL or TEACHING match are skipped, as
           QUOTED skips them, and elisions split a quote into fragments
           matched one by one, as QUOTED's do; both spaced `...` and `…`
           remain inside the paired quotation. Residue is ratcheted in
           citation-baseline.json's quoted_existence, keyed by file:quote, each
           entry carrying its own reason; a finding not in it is exit 1.
           Lean docstrings only: Markdown is out of its scope by decision.
           What it cannot see: a verbatim quote attributed to the wrong
           requirement passes, because no owner is consulted; a misquote
           that happens to match text anywhere in the corpus passes, including
           `11-open-findings.md`'s and the ADRs' records of withdrawn or wrong
           wording; and a quote QUOTE mispairs is as invisible here as under
           QUOTED, for the reasons given there. Explicit attribution syntax is
           the owner's named direction if verbatim-but-misattributed quotes
           start to matter (`pv-vwe.25`, the decision of 2026-10-01).

  UNQUOTED "`X` says/states/reads ..." with no quote at all is unverifiable by
           construction. Ratcheted against `citation-baseline.json` rather than
           failed outright, because such sentences already exist and a gate that
           fails a clean tree is a gate someone deletes. New ones are refused;
           the standing ones come down as their requirements are next edited.
           The count lives in that file and nowhere else -- a number written
           into prose is wrong the first time either end moves, which this set
           has now learned in `ADR-0003`, `ADR-0011` and `F16`.

Summary verbs are deliberately OUT OF SCOPE. "`OPS-12` forbids automatic retry"
is a correct, useful paraphrase, and most attributions in the set are of that
shape. Demanding a quote there would fire on legitimate prose, which is how a
checklist item ends up unsatisfiable by every conforming implementation
(`CNF-224`).

WHAT THIS DOES NOT CATCH, stated plainly because a gate's limits are part of its
contract: a wrong SUMMARY. "`WIR-30` forbids the server resolving eligibility
that way" reverses `WIR-30`'s meaning, uses a summary verb, and carries no
quote -- no lexical signal separates it from a correct summary. That one was the
worst defect of 2026-09-03 and it stays a review problem. Lean docstrings participate
in QUOTED and EXISTS only: they supply neither requirement bodies nor UNQUOTED or
NAMES input.

The fourth rule, added with the rendering gate (`ADR-0025`, 2026-09-15):

  NAMES    A backticked `Provisiond.*` name is a citation of a Lean declaration
           and must resolve against the index `lake exe gate` writes: a tagged
           declaration, a namespace or module holding one, or the `Explore`
           namespace `Gate.lean` exempts. A renamed declaration leaves a
           dangling name, and this is the gate that sees it. Hard failure. Not
           caught: a declaration renamed with a new one tagged under the old
           name, which resolves. The
           index is written by `tools/check_formal.sh`, which `check-all.sh`
           runs first; a missing index is a red gate, not a skipped rule.

Exit 0 = clean, 1 = an unverifiable quote, a Lean docstring quote found nowhere,
an unresolved name or a rise above a baseline or a failed extractor case, 2 = the
index is missing.
"""

import glob
import json
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASELINE = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                        "citation-baseline.json")
NS = "OVR|DOM|PRV|OPS|API|STO|RSC|SEC|DEF|CNF|LDG|WIR"

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from check_obligations import bodies  # noqa: E402  -- one span-splitter, not two

# Direct-speech attribution only. Summary verbs (forbids, requires, mandates,
# calls, makes) are out of scope by design -- see the module docstring.
#
# Two shapes, because the 2026-09-03 miscitations used one each: the verb form
# ("`WIR-1` says ...") and the possessive form ("`WIR-1`'s rule that ..."), which
# claims what a requirement contains just as directly.
SPEECH = r"says|said|states|stated|reads|read"
NOUN = r"rule|claim|wording|statement|sentence|words|text"
ATTRIB = re.compile(
    r"`((?:%s)-\d+[a-z]?)`(?:'s)?\s+(?:own\s+)?(%s)\b"
    r"|`((?:%s)-\d+[a-z]?)`'s\s+(?:own\s+)?(%s)\s+that\b" % (NS, SPEECH, NS, NOUN)
)

# "reads" is two verbs. "`WIR-9` reads \"...\"" attributes text; "`LDG-74` reads
# it" and "`LDG-38` reads both from this record" mean CONSULTS, and consulting
# never carries a quote -- so the unquoted rule would fire on every one of them.
# Checked when a quote is present, ignored when one is not.
CONSULTS = {"reads", "read"}
# A bullet whose items end in ";" is one sentence to any splitter, which lets
# one item's attribution collect the next item's quote. Break on list markers
# and blank lines as well as sentence enders.
SPLIT = re.compile(r"(?<=[.!?])\s+|\n\s*[-*]\s+|\n\s*\n|\n(?=\|)")

# Pair every span before filtering its length. A short or overlong span's closing
# mark must never be recycled as the opening mark of the next quotation.
QUOTE = re.compile(r'“((?:[^”\n]|\n(?!\s*\n))*)”|"((?:[^"\n]|\n(?!\s*\n))*)"')


def chunks(text):
    """Apply SPLIT only outside paired quotations, regardless of their length."""
    spans = iter(QUOTE.finditer(text))
    span = next(spans, None)
    start = 0
    for boundary in SPLIT.finditer(text):
        while span and span.end() <= boundary.start():
            span = next(spans, None)
        if span and span.start() < boundary.start() < span.end():
            continue
        yield text[start:boundary.start()]
        start = boundary.end()
    yield text[start:]


def quotations(text):
    """Yield (position, wording) after pairing, then applying the reach limits."""
    for match in QUOTE.finditer(text):
        wording = match.group(1) or match.group(2) or ""
        if len(wording) <= 400 and len(norm(wording).split()) >= 4:
            yield match.start(), wording


DOC = re.compile(r"`(\d\d-[a-z-]+\.md|README\.md|CONTEXT\.md|AGENTS\.md)`")
ADR = re.compile(r"`(ADR-\d{4})`")
LEAN = re.compile(r"`(Provisiond\.[A-Za-z0-9_.]+)`(?<!\.lean`)")  # `Provisiond.lean` is a file
INDEX = os.path.join(ROOT, "tools", "formal", ".lake", "index.jsonl")
MODULES = os.path.join(ROOT, "tools", "formal", "Provisiond.lean")

# A quotation of wording that was deliberately removed cannot be found in the
# body, and this set retains such quotations on purpose (README, "Identifiers
# are append-only. Text is not."). Recognise the sentence, do not check it.
HISTORICAL = re.compile(
    r"withdraw|withdrew|until 20|previously|the original|first draft|old (?:item|text|wording)"
    r"|earlier (?:draft|version|text|wording|revision|note|phrasing)|stood (?:here|there)"
    r"|used to|no longer|superseded|retired|amended|version one|version two|rewritten"
    r"|this said|it said|it read|had said|once (?:said|read|contained)|corrected|described it as|merged into|split into|the claim that did not",
    re.I,
)

# A document teaching this rule must be able to show the mistake it forbids.
TEACHING = re.compile(r"is an assertion|is a claim, and|checkable;|for example", re.I)


def norm(s):
    s = (s.replace("“", '"').replace("”", '"')
          .replace("’", "'").replace("‘", "'")
          .replace("—", "-").replace("–", "-"))
    s = re.sub(r"[*`~]", "", s)
    return re.sub(r"\s+", " ", s).lower().strip(" .,;:")


def fragments(q):
    """A `...`/`…` elision splits a normalised quote into fragments matched one by one."""
    return [x for x in (p.strip() for p in re.split(r"\.\.\.|…", q)) if x]


def load(rev=None):
    os.chdir(ROOT)
    def read(f):
        if rev:
            return subprocess.run(["git", "show", f"{rev}:{f}"],
                                  capture_output=True, text=True).stdout
        return open(f).read()
    docs = {f: read(f) for f in sorted(glob.glob("*.md"))}
    # Keyed by the id a chunk cites, so find() can admit one ADR's file and no other.
    adrs = {f"ADR-{os.path.basename(f)[:4]}": read(f)
            for f in sorted(glob.glob("docs/adr/*.md"))}
    reqs = {}
    for f, t in docs.items():
        for k, v in bodies(t).items():
            reqs.setdefault(k, (f, v))
    return docs, adrs, reqs


def docstrings(text):
    """Yield Lean doc comments, respecting nested block comments.

    Skip literals and line comments outside blocks so quoted or commented-out
    delimiters cannot become docstrings. Quotes inside blocks have no effect.
    Separate blocks stay separate sentences.
    """
    string = r'"(?:\\.|[^"\\])*"'
    raw = r'r(?P<hashes>#*)".*?"(?P=hashes)'
    char = r"'(?:\\(?:x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4}|.)|[^'\\])'"
    tokens = re.compile(raw + '|' + char + '|' + string + r'|--[^\n]*|/-', re.S)
    delimiters = re.compile(r'/-|-/')
    pos = 0
    while m := tokens.search(text, pos):
        pos = m.end()
        if m.group() != '/-':
            continue
        is_doc = text[pos:pos + 1] in ('-', '!')
        start, depth = pos + 1, 1
        while depth:
            end = delimiters.search(text, pos)
            if end is None:
                raise ValueError('unterminated Lean block comment')
            if end.group() == '/-':
                depth += 1
            elif end.group() == '-/':
                depth -= 1
            pos = end.end()
        if is_doc:
            yield text[start:end.start()]


def load_lean_docstrings():
    """Keep Lean prose separate from load()'s requirement and name sources."""
    docs = {}
    for directory, dirs, files in os.walk(os.path.join(ROOT, 'tools', 'formal')):
        dirs[:] = sorted(d for d in dirs if d != '.lake')
        for name in sorted(files):
            if name.endswith('.lean'):
                path = os.path.join(directory, name)
                with open(path) as source:
                    docs[os.path.relpath(path, ROOT)] = '\n\n'.join(docstrings(source.read()))
    return docs


def find(docs, adrs, reqs, corpus=None):
    """Return (unverified_quotes, unquoted_attributions, quotes_compared).

    `corpus` is where a cited root document (`DOC`) is looked up; it defaults to
    the texts being checked, which is right for Markdown and wrong for Lean
    docstrings, whose caller passes the Markdown set. Until 2026-10-02 the Lean
    pass looked the citation up in the Lean set and no root document ever
    resolved. The count is the quotes that sat after an attribution and were
    compared, after the HISTORICAL/TEACHING skip; main() prints it."""
    bad, unquoted, checked = [], [], 0
    ndocs = {f: norm(t) for f, t in (docs if corpus is None else corpus).items()}
    nadrs = {a: norm(t) for a, t in adrs.items()}
    for f, text in docs.items():
        for sent in chunks(text):
            m = ATTRIB.search(sent)
            if not m or HISTORICAL.search(sent) or TEACHING.search(sent):
                continue
            rid = m.group(1) or m.group(3)
            verb = (m.group(2) or "").lower()
            quotes = list(quotations(sent))
            # Only quotes AFTER the attribution verb: a quote earlier in the
            # chunk belongs to whatever introduced it, not to this attribution.
            # CNF-6's merge marker quotes its own withdrawn text and then
            # CNF-107's, in that order, in one chunk.
            quotes = [(p, q) for p, q in quotes
                      if p > m.start()]
            if not quotes:
                if verb not in CONSULTS:
                    unquoted.append((f, rid, " ".join(sent.split())[:100]))
                continue
            # What the chunk cites by name joins the pool: a root document, or
            # one ADR's file. Never every ADR -- withdrawn wording an ADR records
            # must be cited as that ADR's, not passed off as the requirement's.
            docpool = [ndocs[d] for d in DOC.findall(sent) if d in ndocs]
            docpool += [nadrs[a] for a in ADR.findall(sent) if a in adrs]
            for _pos, q in quotes:
                # The quote belongs to whoever the attribution verb attaches to,
                # NOT to the nearest citation before it: "`STO-43` says `STO-14`
                # 'reaches settled operations'" is STO-43's sentence about
                # STO-14, and blaming STO-14 for it inverts the claim. Bullet
                # lists are handled by SPLIT instead, which is where that
                # confusion actually came from.
                owner = rid
                pool = [norm(reqs[owner][1])] if owner in reqs else []
                pool += docpool
                checked += 1
                if not any(all(fr in p for fr in fragments(norm(q))) for p in pool):
                    bad.append((f, owner, norm(q)))
    return bad, unquoted, checked


def exists(lean, corpus):
    """EXISTS: return (absent_quotes, quotes_counted) over Lean docstrings.

    Owner-free, so quote marks are dropped on both sides here and nowhere else:
    a docstring's nested quotation is 'single' where the document's is "double"."""
    def unquoted(s):
        return s.replace('"', "").replace("'", "")
    corpus = [unquoted(norm(t)) for t in corpus]
    missing, total = [], 0
    for f, text in lean.items():
        for sent in chunks(text):
            quotes = [norm(q) for _, q in quotations(sent)]
            total += len(quotes)
            if HISTORICAL.search(sent) or TEACHING.search(sent):
                continue
            for q in quotes:
                frags = fragments(unquoted(q))
                if not any(all(fr in c for fr in frags) for c in corpus):
                    missing.append((f, q))
    return missing, total


def check_quotations():
    """Guard quote reach independently of the corpus's current wording."""
    source = "alpha beta gamma delta. epsilon zeta eta theta"
    cases = [
        ('two sentences', f'"{source}"'),
        ('spaced elision', '"alpha beta ... epsilon zeta eta theta"'),
        ('short span first', f'"now"; "{source}"'),
        ('empty span first', f'""; "{source}"'),
        ('overlong span first', '"' + 'x' * 401 + f'"; "{source}"'),
        ('curly marks', f'“now”; “{source}”'),
        ('four short words', '"a b c d"'),
    ]
    for name, quotes in cases:
        body = source + ' a b c d'
        text = '`OPS-41` says ' + quotes
        reqs = {'OPS-41': ('probe.md', body)}
        good = find({'probe': text}, {}, reqs)
        wrong = text.replace('epsilon', 'WRONG').replace('a b c d', 'a b c WRONG')
        bad, _, compared = find({'probe': wrong}, {}, reqs)
        missing, total = exists({'probe': wrong}, [body])
        if good != ([], [], 1) or len(bad) != 1 or compared != 1 or len(missing) != 1 or total != 1:
            print(f'FAIL: {name}: exact={good}; corrupted={bad}, {missing}, {compared}, {total}')
            return 1
        print(f'PASS: {name}: exact quote passes; corruption reaches QUOTED and EXISTS')
    return 0


def check_docstrings():
    """Check the extractor before trusting it with the specification artifacts.

    The quoted-closer case is omitted: Lean rejects that source because a quote
    does not escape a comment delimiter, so check_formal.sh owns it.
    """
    good = ' `OPS-41` says "metered through the outage". '
    cases = [
        ('module docstring', '/-! Module documentation. -/', [' Module documentation. ']),
        ('character literal', '''def c : Char := '"' ''', []),
        ('raw string', 'def s : String := r#"a " quote"#', []),
        ('string with closer', 'def s : String := "ends -/ here"', []),
        ('non-doc comment with odd quote', '/- A 5" disk note -/', []),
        ('docstring with odd quote', '/-- A 5" disk. -/\ndef b : String := "x"',
         [' A 5" disk. ']),
        ('nested comment', '/-- Outer /- inner -/ tail. -/\ndef first := 0',
         [' Outer /- inner -/ tail. ']),
        ('commented-out opener', '-- /-- a commented-out opener', []),
    ]
    for name, prefix, first in cases:
        text = f'{prefix}\n/--{good}-/\ndef after1 := 0\n/--{good}-/\ndef after2 := 0\n'
        try:
            assert list(docstrings(text)) == first + [good, good], name
            # A misquote after each construct must still reach QUOTED.
            wrong = text.replace('metered through the outage', 'billed through the blackout')
            bad, _, _ = find({'probe.lean': '\n\n'.join(docstrings(wrong))}, {},
                             {'OPS-41': ('probe.md', 'metered through the outage')})
            assert len(bad) == 2, (name, bad)
        except (AssertionError, ValueError) as exc:
            print(f'FAIL: {name}: {exc}')
            return 1
        print(f'PASS: {name}: following docstrings intact; both misquotes detected')
    # A root document a Lean docstring cites is looked up in the Markdown corpus,
    # not in the Lean set being checked (pv-vwe.25, 2026-10-02): the cited form
    # passes on the document alone, and the same docstring uncited fails.
    cited = '/-- `OPS-41` says, per `CONTEXT.md`, "metered through the outage". -/\ndef d := 0\n'
    corpus = {'CONTEXT.md': 'Billing is metered through the outage.'}
    reqs = {'OPS-41': ('probe.md', 'nothing of the kind')}
    probes = {'cited': cited, 'uncited': cited.replace(', per `CONTEXT.md`', '')}
    bad = {k: find({'probe.lean': '\n\n'.join(docstrings(v))}, {}, reqs, corpus=corpus)[0]
           for k, v in probes.items()}
    if bad['cited'] or len(bad['uncited']) != 1:
        print(f'FAIL: cited root document: {bad}')
        return 1
    print('PASS: cited root document: vouches for a Lean docstring quote; uncited fails')
    return 0


def read_index():
    """The index `lake exe gate` writes, as {declaration: requirement id}. Shared with
    check_regions.py -- one reader, not two. Missing = exit 2, never a skip."""
    if not os.path.exists(INDEX):
        print(f"FAIL: {INDEX} missing -- run tools/check_formal.sh first "
              f"(check-all.sh orders it before this gate)")
        sys.exit(2)
    rows = [json.loads(l) for l in open(INDEX) if l.strip()]
    return {r["decl"]: r["req"] for r in rows}


def lean_names():
    """Every name a document may cite: tagged declarations, their namespaces, the
    modules the build imports, and the one namespace the gate exempts by policy.
    Not caught: a declaration renamed and a new one tagged under the old name."""
    names = {"Provisiond.Explore"}
    for decl in read_index():
        parts = decl.split(".")
        names.update(".".join(parts[:k]) for k in range(1, len(parts) + 1))
    for line in open(MODULES):
        if line.startswith("import "):
            names.add(line.split()[1])
    return names


def unresolved(docs, adrs):
    names = lean_names()
    texts = list(docs.items()) + list(adrs.items())
    return [(f, n) for f, t in texts for n in LEAN.findall(t) if n not in names]


def main():
    if check_docstrings() or check_quotations():
        return 1
    docs, adrs, reqs = load()
    bad, unquoted, _ = find(docs, adrs, reqs)
    lean = load_lean_docstrings()
    lean_bad, _, compared = find(lean, adrs, reqs, corpus=docs)
    missing, total = exists(lean, list(docs.values()) + list(adrs.values()))
    try:
        with open(BASELINE) as source:
            baseline = json.load(source)
        quoted_base = set(baseline.get("quoted_attributions", []))
        exists_base = dict(baseline.get("quoted_existence", {}))
    except (OSError, ValueError, TypeError, AttributeError):
        # Without a readable baseline there are no exemptions, so ratcheted residue
        # surfaces as findings and fails the gate before the unquoted initializer.
        quoted_base, exists_base = set(), {}
    lean_new = [(f, rid, q) for f, rid, q in lean_bad
                if f"{f}:{rid}:{q}" not in quoted_base]
    bad += lean_new
    for f, rid, q in bad:
        print(f"  {f} attributes to {rid} a phrase {rid} does not contain:")
        print(f'      "{q}"')
    missing_new = [(f, q) for f, q in missing if f"{f}:{q}" not in exists_base]
    for f, q in missing_new:
        print(f"  {f} quotes a phrase found in no document or ADR:")
        print(f'      "{q}"')
    if bad or missing_new:
        print(f"\nFAIL: {len(bad)} unverifiable quoted attribution(s) and {len(missing_new)} "
              f"Lean docstring quote(s) found nowhere. Quote the requirement's own "
              f"words, or cite it without quoting.")
        return 1
    print(f"quoted attributions verified: clean")
    print(f"Lean quoted attributions: {len(lean_bad)}, none new against baseline {len(quoted_base)}")
    print(f"Lean docstring quotes: {total}; {compared} compared under QUOTED; EXISTS finds "
          f"{len(missing)} absent, none new against baseline {len(exists_base)}")

    dangling = unresolved(docs, adrs)
    for f, n in dangling:
        print(f"  {f} cites `{n}`, which the index does not carry")
    if dangling:
        print(f"\nFAIL: {len(dangling)} Provisiond.* name(s) do not resolve against "
              f"tools/formal/.lake/index.jsonl. Cite the tagged declaration by its current name.")
        return 1
    print(f"Provisiond.* names resolved: "
          f"{sum(len(LEAN.findall(t)) for t in list(docs.values()) + list(adrs.values()))}")

    sigs = sorted({f"{f}:{rid}" for f, rid, _ in unquoted})
    try:
        base = set(json.load(open(BASELINE))["unquoted_attributions"])
    except Exception:
        base = set(sigs)
        json.dump({"unquoted_attributions": sigs,
                   "note": "Sentences reporting what a requirement SAYS with no quote to "
                           "check, as file:id signatures rather than a count -- a count "
                           "cannot name which one is new. Ratchet: may shrink, never grow."},
                  open(BASELINE, "w"), indent=2)
        print(f"baseline written: {len(sigs)} signature(s)")
    new = [x for x in sigs if x not in base]
    if new:
        for sig in new:
            f, rid = sig.split(":", 1)
            ex = next(s for g, r, s in unquoted if g == f and r == rid)
            print(f"  {f} reports what {rid} says without quoting it:")
            print(f"      {ex}")
        print(f"\nFAIL: {len(new)} new unquoted attribution(s). Carry the "
              f"requirement's own words, or use a summary verb and drop the claim "
              f"to report what it says.")
        return 1
    print(f"unquoted attributions: {len(sigs)}, none new against baseline {len(base)}")
    return 0


if __name__ == "__main__":
    # The gate's known-positives are the 2026-09-03 miscitations. A gate nobody
    # has watched fail is a gate nobody has tested.
    if "--selftest" in sys.argv:
        rev = "5aecdbe"
        try:
            docs, adrs, reqs = load(rev)
        except Exception as exc:  # noqa: BLE001 -- selftest is best-effort
            print(f"SKIP: cannot read {rev} ({exc})")
            sys.exit(0)
        bad, unq, _ = find(docs, adrs, reqs)
        hit = [x for x in bad + unq if x[1] == "WIR-1"]
        if not hit:
            print(f"SELFTEST FAIL: no longer detects the {rev} WIR-1 miscitation")
            sys.exit(1)
        print(f"SELFTEST OK: detects {len(hit)} unquoted WIR-1 attribution(s) at {rev}")
        sys.exit(0)
    sys.exit(main())
