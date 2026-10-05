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
           Unbaselined findings fail. Reads the root *.md Markdown
           documents and /-- ... -/ and /-! ... -/ docstrings under tools/formal/,
           excluding .lake/. ADRs are sources, not QUOTED input. Standing
           Markdown residue is keyed by file:id:quote with individual reasons
           in citation-baseline.json's markdown_quoted_attributions. Each entry
           allows one finding only; further occurrences of that same signature
           fail, even if a different historical finding disappears. Lean
           residue is ratcheted in
           citation-baseline.json's quoted_attributions, keyed by file:id:quote
           with the full normalized quote; its note owns the causes and exits.
           On 2026-09-15 a Lean docstring quoting withdrawn wording stayed green
           for a day, motivating the Lean QUOTED pass.
           REACH: a quote is checked only when its SPLIT chunk carries an
           ATTRIB match (a speech verb, or `X`'s <noun> that) before it, or is
           directly after a bare possessive (`X`'s "four or more words"). The
           chunk must be neither HISTORICAL nor TEACHING. A bare possessive
           owns only its immediately following quote; each such pair is checked,
           even with multiple owners in a chunk. It never adds UNQUOTED input.
           In Lean docstrings that was the minority: at `c5e31be` (2026-10-02), 56 of the 925 quotes of four
           or more normalised words were compared. The gate prints both figures
           on every run; the numbers here are that day's reading, not a rule.
           Paired quotations stay in one chunk, including sentence enders and
           spaced elisions. Marks are paired before length/word filtering, so a
           short span cannot steal the next quote's opening mark (pv-vwe.35).
           Before these rules, unpaired straight or curly double marks fail
           with a source file and line, even in historical/teaching prose or
           spans outside the word/length limits. Each paragraph is checked
           independently; separately extracted Lean docstrings stay separate.
           What it cannot see: balanced nested or mispaired straight/curly
           marks can still select the wrong span within a paragraph. Balancing
           does not establish which quotation a mark belongs to. Blank lines
           are hard boundaries, including between separate Lean docstrings.
           This is a paired-mark scanner, not a Markdown or Lean prose parser.
           Historical/teaching heuristics apply to the whole resulting chunk;
           a word inside a quotation can therefore suppress its comparison.
           CNF-216's note beginning "Amended 2026-10-02" remains historical:
           corrupting "the greatest `increment end` among that subject's rows"
           there is skipped; the same attribution in a current chunk is checked.
           Possessives require a straight apostrophe and whitespace immediately
           followed by the opening quote; intervening prose or markup is not
           this shape. Quotes below four words remain outside QUOTED.
           Comparison locates candidate source spans without quotation marks,
           then compares their content, including adjacent apostrophes. Only
           locally paired delimiters are formatting; word-internal and unpaired
           trailing apostrophes remain content. See comparison_text() and
           span_content() for the bounds and ambiguous-punctuation limitation.
           Signature identity still uses norm(), retaining all marks.
           A chunk shaped `X` says `Y`'s "four or more words" compares against
           both owners; no precedence rule was chosen. A nested example can
           gain a second attribution. An allowance is per full signature, not
           positional: deleting its standing occurrence and restating it
           elsewhere in the same file can pass. Making the standing chunk
           historical (e.g. "was itself overbroad" -> "was previously overbroad")
           and restating identical wording as current can also pass.

  EXISTS   Every quote of four or more normalised words in a Lean docstring
           must appear somewhere in the corpus -- every root *.md plus
           docs/adr/*.md -- whether or not its chunk carries an attribution
           (`pv-vwe.25`, decided 2026-10-01). A quote is what QUOTE matches:
           a paired span of at most 400 characters containing at least four
           normalised words. Longer quotations are counted by neither rule,
           but their marks are consumed before scanning the next span.
           EXISTS removes every ' and " after norm() on both sides, since a docstring
           writes a nested quotation with single marks where the document has
           double ones. Unlike QUOTED, it also ignores word-internal apostrophes.
           Signature identity still uses norm(), retaining marks.
           Chunks HISTORICAL or TEACHING match are skipped, as
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
in the mark guard, QUOTED and EXISTS: they supply neither requirement bodies nor
UNQUOTED or NAMES input.

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

Exit 0 = clean, 1 = unpaired double marks, an unverifiable quote, a Lean docstring
quote found nowhere, an unresolved name, a rise above a baseline or a failed
extractor case, 2 = the index is missing.
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

# A bare possessive owns its immediately following quotation, not subsequent
# quotations in the chunk. Short quotes are ignored, never called UNQUOTED.
POSSESSIVE = re.compile(r"`((?:%s)-\d+[a-z]?)`'s\s+(?=[\"“])" % NS)

# "reads" is two verbs. "`WIR-9` reads \"...\"" attributes text; "`LDG-74` reads
# it" and "`LDG-38` reads both from this record" mean CONSULTS, and consulting
# never carries a quote -- so the unquoted rule would fire on every one of them.
# Checked when a quote is present, ignored when one is not.
CONSULTS = {"reads", "read"}
# Sentence enders may precede closing markup. The named group locates the
# boundary AFTER all closers, retaining them in the preceding chunk. chunks()
# tests that position (not the match start) against paired quotations, also for
# list markers and table rows. Blank lines stay hard boundaries: QUOTE cannot
# cross them.
SPLIT = re.compile(r'(?<=[.!?])[*`"”)\]]*(?P<sentence>\s+)|\n\s*[-*]\s+|\n\s*\n|\n(?=\|)')

# Pair every span before filtering its length. A short or overlong span's closing
# mark must never be recycled as the opening mark of the next quotation.
QUOTE = re.compile(r'“((?:[^”\n]|\n(?!\s*\n))*)”|"((?:[^"\n]|\n(?!\s*\n))*)"')


def chunks(text):
    """Apply SPLIT only outside paired quotations, regardless of their length."""
    spans = iter(QUOTE.finditer(text))
    span = next(spans, None)
    start = pos = 0
    while boundary := SPLIT.search(text, pos):
        pos = boundary.end()
        cut = boundary.start('sentence') if boundary.group('sentence') else boundary.start()
        while span and span.end() <= cut:
            span = next(spans, None)
        if span and span.start() < cut < span.end():
            continue
        yield text[start:cut]
        start = boundary.end()
        if boundary.group('sentence') and boundary.start() < cut:
            # A new cut after closers can consume the newline that used to
            # start a list delimiter. Let the existing structural alternative
            # consume that delimiter too; plain punctuation keeps its behavior.
            newline = text.find('\n', cut, start)
            structural = SPLIT.match(text, newline) if newline >= 0 else None
            if structural:
                start = max(start, structural.end())
        # Resume beyond everything consumed, so an overlapping match cannot
        # swallow a later list or paragraph boundary.
        pos = start
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


def comparison_text(s):
    """Normalize QUOTED source context, retaining pairing boundaries as newlines.

    These boundaries constrain delimiter pairing only, not substring reach.
    Whitespace still matches whitespace across sentences, paragraphs, list items
    and table rows. norm() and the finding signatures are deliberately unchanged.
    """
    def whitespace(m):
        gap = m.group()
        structural = ('\n' in gap and
                      (re.search(r'\n[ \t]*\n', gap) or
                       re.match(r'[-*]\s|\|', s[m.end():])))
        before = m.start() - 1
        while before >= 0 and s[before] in '*`"”)]':
            before -= 1
        sentence = before >= 0 and s[before] in '.!?'
        return '\0' if structural or sentence else ' '

    normalized = norm(re.sub(r'\s+', whitespace, s))
    # norm() can remove a list's '*' between two whitespace runs. Collapse those
    # runs together while retaining their boundary, just as norm() does without it.
    return re.sub(r'[ \0]*\0[ \0]*', '\n', normalized).strip(' \n.,;:')


def span_edges(text, start, end):
    """Include adjoining marks; a candidate edge is not a word edge."""
    while start and text[start - 1] in '\"\'':
        start -= 1
    while end < len(text) and text[end] in '\"\'':
        end += 1
    return start, end


def double_pairs(text, start, end):
    """Double-delimiter evidence in bounded context, including partial wrappers."""
    left = max(0, start - 401, text.rfind('\n', 0, start) + 1)
    boundary = text.find('\n', end)
    right = min(len(text), end + 401, boundary if boundary >= 0 else len(text))
    return [(left + pair.start(), left + pair.end() - 1)
            for pair in re.finditer(r'''(?<![\w"'])"[^"\n]{0,400}"(?!\w)''', text[left:right])]


def span_content(text, start, end, other, other_start, other_end):
    """Content of one candidate; single marks never borrow an outside partner.

    An opener follows neither a word nor another mark and precedes nonspace;
    a closer follows nonspace and precedes neither a word nor another mark.
    First use local double pairs on either side to establish corresponding
    delimiter roles at the same mark-free offsets. Transferring a role to single
    marks requires both endpoints inside both candidates and a lexical pair;
    double marks may inherit a partial wrapper's role. Thus nested pairs remain
    independent and a later possessive cannot replace an established closer.
    Remaining openers pair with the last closer before the next opener
    within a structural segment (at most 400 enclosed characters).
    Double marks have no apostrophe role, so a locally paired double wrapper may
    also enclose a partial candidate. Internal apostrophes can never be delimiters.
    This bounded convention is not an English parser: ambiguous punctuation within
    the candidate can still be mispaired; fragments cutting a single-delimiter
    pair may be conservatively rejected. Elision fragments retain their full
    quotation's double-pair context, but are still matched independently.
    """
    marks = '\"\''
    start, end = span_edges(text, start, end)
    other_start, other_end = span_edges(other, other_start, other_end)
    ignored = {p for pair in double_pairs(text, start, end) for p in pair}

    def mark_offsets(s, first, last):
        offsets, offset = {}, 0
        for pos in range(first, last):
            if s[pos] in marks:
                offsets[pos] = offset
            else:
                offset += 1
        return offsets

    offsets = mark_offsets(text, start, end)
    other_offsets = mark_offsets(other, other_start, other_end)
    for opening, closing in double_pairs(other, other_start, other_end):
        # Matching double marks can use their source's enclosing context even
        # when the candidate cuts the pair, as in a balanced partial quotation.
        slots = {other_offsets[p] for p in (opening, closing) if p in other_offsets}
        ignored.update(p for p, slot in offsets.items() if slot in slots and text[p] == '"')
        if opening not in other_offsets or closing not in other_offsets:
            continue
        opens = [p for p, slot in offsets.items() if slot == other_offsets[opening]
                 and text[p] == "'" and (not p or not re.match(r'[\w\"\']', text[p - 1]))
                 and p + 1 < len(text) and not text[p + 1].isspace()]
        closes = [p for p, slot in offsets.items() if slot == other_offsets[closing]
                  and text[p] == "'" and p and not text[p - 1].isspace()
                  and (p + 1 == len(text) or not re.match(r'[\w\"\']', text[p + 1]))]
        if len(opens) == len(closes) == 1:
            a, b = opens[0], closes[0]
            if 0 < b - a <= 401 and '\n' not in text[a:b]:
                ignored.update((a, b))
    opener = closer = None
    for pos in range(start, end):
        mark = text[pos]
        if mark == '\n':
            if opener is not None and closer is not None:
                ignored.update((opener, closer))
            opener = closer = None
        elif mark in marks and pos not in ignored:
            before = text[pos - 1] if pos else ' '
            after = text[pos + 1] if pos + 1 < len(text) else ' '
            if not (re.match(r'\w', before) or before in marks) and not after.isspace():
                if opener is not None and closer is not None:
                    ignored.update((opener, closer))
                opener, closer = pos, None
            elif (opener is not None and mark == text[opener]
                  and pos - opener - 1 <= 400 and not before.isspace()
                  and not (re.match(r'\w', after) or after in marks)):
                closer = pos
    if opener is not None and closer is not None:
        ignored.update((opener, closer))
    return ''.join(text[p] for p in range(start, end) if p not in ignored).replace('\n', ' ')


def contains_quote(source, quote):
    """Find spans by mark-free text, then require equal local punctuation content.

    Elision fragments remain independent and may occur anywhere in this source.
    Removing marks is candidate discovery only, never an acceptance fallback.
    """
    positions = [p for p, char in enumerate(source) if char not in '\"\'']
    plain = ''.join(source[p] for p in positions).replace('\n', ' ')
    quote = comparison_text(quote)
    quote_offset = 0
    for fragment in fragments(quote):
        qstart = quote.index(fragment, quote_offset)
        qend = qstart + len(fragment)
        quote_offset = qend
        needle = fragment.replace('"', '').replace("'", '').replace('\n', ' ')
        offset = 0
        while needle and (at := plain.find(needle, offset)) >= 0:
            start, end = positions[at], positions[at + len(needle) - 1] + 1
            content = span_content(quote, qstart, qend, source, start, end)
            if span_content(source, start, end, quote, qstart, qend) == content:
                break
            offset = at + 1
        else:
            return False
    return True


def unpaired_marks(text, first_line=1):
    """Yield (source line, mark kind) per malformed paragraph, before filtering.

    Straight marks have no direction; report the first mark of an odd set.
    Curly marks must balance in opening/closing order. Balanced nesting is not
    parsed here and remains a limitation of QUOTE's flat pairing.
    """
    offset = 0
    for paragraph in re.split(r'(\n\s*\n)', text):
        straight, curly, unmatched = [], [], []
        for pos, mark in enumerate(paragraph):
            if mark == '"':
                straight.append(pos)
            elif mark == '“':
                curly.append(pos)
            elif mark == '”':
                if curly:
                    curly.pop()
                else:
                    unmatched.append(pos)
        for kind, positions in [('straight', straight[:1] if len(straight) % 2 else []),
                                ('curly', unmatched + curly)]:
            if positions:
                yield first_line + text.count('\n', 0, offset + min(positions)), kind
        offset += len(paragraph)


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


def docstrings(text, with_offsets=False):
    """Yield Lean doc comments, respecting nested block comments.

    Skip literals and line comments outside blocks so quoted or commented-out
    delimiters cannot become docstrings. Quotes inside blocks have no effect.
    Separate blocks stay separate sentences. Optional character offsets refer
    to the original source, never to concatenated extracted prose.
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
            body = text[start:end.start()]
            yield (start, body) if with_offsets else body


def load_lean_docstrings(mark_errors=None):
    """Keep Lean prose separate from load()'s requirement and name sources."""
    docs = {}
    for directory, dirs, files in os.walk(os.path.join(ROOT, 'tools', 'formal')):
        dirs[:] = sorted(d for d in dirs if d != '.lake')
        for name in sorted(files):
            if name.endswith('.lean'):
                path = os.path.join(directory, name)
                with open(path) as source:
                    text = source.read()
                filename = os.path.relpath(path, ROOT)
                blocks = list(docstrings(text, with_offsets=True))
                if mark_errors is not None:
                    for start, body in blocks:
                        first_line = text.count('\n', 0, start) + 1
                        mark_errors.extend((filename, line, kind)
                                           for line, kind in unpaired_marks(body, first_line))
                docs[filename] = '\n\n'.join(body for _, body in blocks)
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
    ndocs = {f: comparison_text(t) for f, t in (docs if corpus is None else corpus).items()}
    nadrs = {a: comparison_text(t) for a, t in adrs.items()}
    for f, text in docs.items():
        for sent in chunks(text):
            if HISTORICAL.search(sent) or TEACHING.search(sent):
                continue
            quotes = list(quotations(sent))
            attributions = []
            m = ATTRIB.search(sent)
            if m:
                # Speech ownership follows the verb, not the nearest citation:
                # `STO-43` says `STO-14` "reaches settled operations and nothing
                # else" attributes STO-43's sentence about STO-14 to STO-43.
                # Choosing STO-14 instead would invert that claim.
                rid = m.group(1) or m.group(3)
                verb = (m.group(2) or "").lower()
                # Preserve the speech-verb contract: the first attribution owns
                # later quotes in its chunk, not quotes before its introduction.
                # CNF-6's merge marker quotes its own "two tenants cannot both
                # hold a record for the same external machine" before CNF-107
                # reads "two tenants cannot both hold the same ...". That site
                # is now skipped by HISTORICAL ("It read"); the ordering still
                # matters for the same shape in a current chunk.
                later = [(p, q) for p, q in quotes if p > m.start()]
                if later:
                    attributions.append((rid, later))
                elif verb not in CONSULTS:
                    unquoted.append((f, rid, " ".join(sent.split())[:100]))
            for possessive in POSSESSIVE.finditer(sent):
                direct = [(p, q) for p, q in quotes if p == possessive.end()]
                if direct:
                    attributions.append((possessive.group(1), direct))
            # What the chunk cites by name joins the pool: a root document, or
            # one ADR's file. Never every ADR -- withdrawn wording an ADR records
            # must be cited as that ADR's, not passed off as the requirement's.
            docpool = [ndocs[d] for d in DOC.findall(sent) if d in ndocs]
            docpool += [nadrs[a] for a in ADR.findall(sent) if a in adrs]
            for owner, attributed in attributions:
                pool = [comparison_text(reqs[owner][1])] if owner in reqs else []
                pool += docpool
                for _pos, q in attributed:
                    checked += 1
                    if not any(contains_quote(p, q) for p in pool):
                        bad.append((f, owner, norm(q)))
    return bad, unquoted, checked


def exists(lean, corpus):
    """EXISTS: return (absent_quotes, quotes_counted) over Lean docstrings.

    Owner-free; retains its established removal of all single and double marks."""
    def comparison(s):
        return norm(s).replace('"', "").replace("'", "")

    corpus = [comparison(t) for t in corpus]
    missing, total = [], 0
    for f, text in lean.items():
        for sent in chunks(text):
            quotes = [norm(q) for _, q in quotations(sent)]
            total += len(quotes)
            if HISTORICAL.search(sent) or TEACHING.search(sent):
                continue
            for q in quotes:
                frags = fragments(comparison(q))
                if not any(all(fr in c for fr in frags) for c in corpus):
                    missing.append((f, q))
    return missing, total


def check_quote_content():
    """Finite QUOTED comparisons through each existing input and source-pool path."""
    cases = []

    def case(name, source, quote, accepted, exists_ok=True):
        cases.append((name, source, quote, accepted, exists_ok))

    possessive = "the rows' values remain positive"
    plain = possessive.replace("'", '')
    case('trailing omission', possessive, plain, False)
    case('trailing insertion', plain, possessive, False)
    for marked in [possessive, "the tenant's balance remains positive"]:
        for mark in ["'", '‘', '’']:
            source = marked.replace("'", mark)
            for other in ["'", '‘', '’']:
                case('apostrophe typography', source, marked.replace("'", other), True)
            case('apostrophe omission', source, marked.replace("'", ''), False)
            case('apostrophe insertion', marked.replace("'", ''), source, False)
    multiple = "the rows' values and tenants' balances remain positive"
    for position in [multiple.index("'"), multiple.rindex("'")]:
        missing = multiple[:position] + multiple[position + 1:]
        case('independent possessive omission', multiple, missing, False)
        case('independent possessive insertion', missing, multiple, False)
    for phrase in ['Succeeds', 'rows', "the rows' values", "the tenant's balance"]:
        single = f"'{phrase}' means the resource is gone"
        double = f'"{phrase}" means the resource is gone'
        for source, quote in [(single, double), (double, single)]:
            case('nested delimiters', source, quote, True)
            case('nested wording', source, quote.replace(phrase, 'WRONG'), False, False)
            if "'" in phrase:
                case('nested possessive omission', source,
                     quote.replace(phrase, phrase.replace("'", '')), False)
    for gap in [' ', '. ', '\n\n', '\n- ', '\n* ', '\n|']:
        source = 'unrelated' + gap + possessive
        case('whitespace reach across boundaries', source, norm(source), True)
        case('outside opener before', "'unrelated" + gap + possessive, plain, False)
        case('outside opener after', possessive + gap + "'unrelated", plain, False)
        case('exact despite outside opener', "'unrelated" + gap + possessive,
             possessive, True)
        if gap != ' ':
            source = "'unrelated" + gap + possessive
            case('pairing boundary', source, norm(source).replace("'", ''), False)
            if gap != '\n\n':  # QUOTE deliberately cannot span a paragraph.
                case('exact structural content', source, source, True)
    for phrase, variant in [('Succeeds', 'Succeeds'),
                            ("the rows' values", "the rows' values"),
                            ("Succeeds' and 'Fails", 'Succeeds" and "Fails')]:
        tail = (" determine the tenants' balances" if 'rows' in phrase
                else " means the deposits' addresses are gone")
        single, double = f"'{phrase}'{tail}", f'"{variant}"{tail}'
        for source, quote in [(single, double), (double, single)]:
            case('R1 following possessive', source, quote, True)
            case('R1 same style', source, source, True)
            word = 'values' if 'rows' in phrase else 'Succeeds'
            case('R1 enclosed wording', source, quote.replace(word, 'WRONG'), False, False)
            for word in ['rows', 'tenants', 'deposits']:
                if word + "'" in quote:
                    missing = quote.replace(word + "'", word)
                    case('R1 independent omission ' + word, source, missing, False)
                    case('R1 independent insertion ' + word, missing, source, False)
    single = "'a \"the rows' values\" clause remains'"
    double = '"a \'the rows\' values\' clause remains"'
    for source, quote in [(single, double), (double, single)]:
        case('R2 nested pairs', source, quote, True)
        case('R2 same style', source, source, True)
        case('R2 enclosed wording', source, quote.replace('values', 'WRONG'), False, False)
        missing = quote.replace("rows'", 'rows')
        case('R2 possessive omission', source, missing, False)
        case('R2 possessive insertion', missing, source, False)
    for elision in ['…', '...']:
        source = f'the price is "an indicative quote {elision} binding is false", and the auction channel'
        case('R3 exact elision', source, source, True)
        case('R3 elision wording', source, source.replace('binding', 'WRONG'), False, False)
        marked = source.replace('quote ', "quotes' ")
        case('R3 exact possessive elision', marked, marked, True)
        missing = marked.replace("quotes'", 'quotes')
        case('R3 possessive omission', marked, missing, False)
        case('R3 possessive insertion', missing, marked, False)
    source = '"alpha beta" and then "gamma delta"'
    quote = 'alpha beta" and then "gamma'
    case('R4 balanced partial doubles', source, quote, True)
    case('R4 partial wording', source, quote.replace('beta', 'WRONG'), False, False)
    case('R4 inserted possessive', source, quote.replace('beta', "beta'"), False)
    case('R4 omitted possessive', source.replace('beta', "beta'"), quote, False)
    source = "watch only the rows' values remain positive"
    case('trailing candidate edge', source, 'watch only the rows', False)
    case('exact trailing candidate edge', source, "watch only the rows'", True)
    case('leading candidate edge', source, "' values remain positive", True)
    case('inserted edge apostrophe', plain, "'the rows values remain positive", False)
    case('substring reach', possessive, "ows' values remain positive", True)
    case('later valid candidate', plain + '; ' + possessive, possessive, True)
    case('double wrapper prefix', '"' + possessive + '"', "the rows' values remain", True)
    case('double wrapper suffix', '"prefix ' + possessive + '"', possessive, True)
    case('independent elisions', "balances stay positive; watch only the rows' values",
         "watch only the rows' ... balances stay positive", True)
    case('elision edge omission', "watch only the rows' values; balances stay positive",
         'watch only the rows ... balances stay positive', False)
    case('elision insertion', 'watch only the rows values; balances stay positive',
         "watch only the rows' … balances stay positive", False)
    limit = 'rows values remain ' + 'x' * (400 - len('rows values remain '))
    for mark in ["'", '"']:
        case('delimiter content length limit', mark + limit + mark, limit, True)

    name = ''
    try:
        for name, source, quote, accepted, exists_ok in cases:
            for pool in ['requirement', 'document', 'ADR']:
                cite = {'requirement': '', 'document': ', per `CONTEXT.md`',
                        'ADR': ', per `ADR-0001`'}[pool]
                prose = f'`OPS-41` says{cite} “{quote}”.'
                reqs = {'OPS-41': ('source.md', source if pool == 'requirement' else '')}
                corpus = {'CONTEXT.md': source} if pool == 'document' else {}
                adrs = {'ADR-0001': source} if pool == 'ADR' else {}
                for filename in ['probe.md', 'probe.lean']:
                    text = ('\n\n'.join(docstrings('/-- ' + prose + ' -/'))
                            if filename.endswith('.lean') else prose)
                    assert not list(unpaired_marks(text)), (name, text)
                    expected = [] if accepted else [(filename, 'OPS-41', norm(quote))]
                    actual = find({filename: text}, adrs, reqs, corpus=corpus)
                    assert actual == (expected, [], 1), (pool, filename, source, quote, actual)
                    missing = [] if exists_ok else [(filename, norm(quote))]
                    assert exists({filename: text}, [source]) == (missing, 1), (name, pool)
                    if pool != 'requirement':
                        uncited = text.replace(cite, '')
                        assert find({filename: uncited}, adrs, reqs, corpus=corpus) == (
                            [(filename, 'OPS-41', norm(quote))], [], 1), (name, pool)
        assert norm("“The rows’ values” and ‘tenant’s balance’") == (
            '\"the rows\' values\" and \'tenant\'s balance\'')
    except AssertionError as exc:
        print(f'FAIL: quote content: {name}: {exc}')
        return 1
    print('PASS: quote content: apostrophes, local delimiters, boundaries, edges and elisions; '
          'Markdown/Lean owners and cited pools; EXISTS and signatures unchanged')
    return 0


def check_sentence_boundaries():
    """Keep closing marks, then protect paired spans at the actual cut position."""
    name = 'closing markup'
    try:
        for ending in ['.', '!', '?']:
            for opening, closing in [('', ''), ('*', '*'), ('**', '**'), ('`', '`'),
                                     ('"', '"'), ('“', '”'), ('(', ')'), ('[', ']'),
                                     ('[(*`“', '”`*)]'), ('*' * 25, '*' * 25)]:
                first = f'The engine {opening}runs{ending}{closing}'
                text = first + ' Another sentence.'
                assert list(chunks(text)) == [first, 'Another sentence.'], text
        for separator in ['\n- ', '\n* ', '\n\n', '\n \n', '\n|']:
            text = 'first' + separator + 'second'
            second = '|second' if separator == '\n|' else 'second'
            assert list(chunks(text)) == ['first', second], text
        # Even structural candidates inside a paired span remain protected;
        # paragraphs and separate docstrings cannot form such a span.
        for separator in ['\n- ', '\n* ', '\n|']:
            text = '"alpha beta' + separator + 'gamma delta"'
            assert list(chunks(text)) == [text], text
        assert list(chunks('"alpha beta\n\ngamma delta"')) == ['"alpha beta', 'gamma delta"']
        print('PASS: sentence boundaries: closing markup and structural boundaries')

        name = 'closing markup before list delimiters'
        attribution = '`OPS-41` says "alpha beta gamma delta".'
        for first in ['Intro *ends.*', 'Intro **ends!**', 'Intro `ends?`',
                      'Intro [(*ends.*)]', 'Intro "ends."']:
            for separator in ['\n- ', '\n* ', '\n  - ', '\n\t* ',
                              '\n\n- ', '\n \n  * ']:
                text = first + separator + attribution
                assert list(chunks(text)) == [first, attribution], text
                reqs = {'OPS-41': ('source.md', 'alpha beta gamma delta')}
                assert find({'probe': text}, {}, reqs) == ([], [], 1), text
                wrong = text.replace('gamma', 'WRONG')
                assert find({'probe': wrong}, {}, reqs) == (
                    [('probe', 'OPS-41', 'alpha beta wrong delta')], [], 1), text
        assert list(chunks('Intro ends.\n- ' + attribution)) == [
            'Intro ends.', '- ' + attribution]
        for separator, second in [('\n|', '|next'), ('\n\n', 'next'),
                                  ('\n \n', 'next')]:
            assert list(chunks('Intro *ends.*' + separator + 'next')) == [
                'Intro *ends.*', second]
        for opening, closing in [('"', '"'), ('“', '”')]:
            for wording in ['*ends.*\n- x', '*ends.*\n  * ' + 'x' * 401]:
                text = opening + wording + closing
                assert list(chunks(text)) == [text], text
        assert list(chunks('"Intro *ends.*\n\n- next"')) == ['"Intro *ends.*', 'next"']
        print(f'PASS: sentence boundaries: {name}: chunks, protection and comparisons')

        for name, separator in [('consecutive empty list items', '\n-\n-\n- '),
                                ('empty list items before paragraph', '\n- \n-\n\n')]:
            text = 'Intro *ends.*' + separator + attribution
            expected = ['Intro *ends.*', '-', attribution]
            assert list(chunks(text)) == expected, (text, list(chunks(text)))
            reqs = {'OPS-41': ('source.md', 'alpha beta gamma delta')}
            assert find({'probe': text}, {}, reqs) == ([], [], 1), name
            assert exists({'probe': text}, ['alpha beta gamma delta']) == ([], 1), name
            wrong = text.replace('gamma', 'WRONG')
            assert find({'probe': wrong}, {}, reqs) == (
                [('probe', 'OPS-41', 'alpha beta wrong delta')], [], 1), name
            assert exists({'probe': wrong}, ['alpha beta gamma delta']) == (
                [('probe', 'alpha beta wrong delta')], 1), name
            print(f'PASS: sentence boundaries: {name}: chunks, owners, counts and corruption')

        first = '`LDG-59` says "**Falling back to the last known rate MUST NOT happen.**"'
        later = 'A purchase is "authorized like a purchase".'
        cases = [
            ('LDG-59 ownership', [first, later],
             {'LDG-59': '**Falling back to the last known rate MUST NOT happen.**',
              'LDG-62': 'authorized like a purchase'},
             [('LDG-59', '**Falling back to the last known rate MUST NOT happen.**')]),
            ('distinct sentence owners',
             ['`OPS-41` says "alpha beta gamma delta."',
              '`OPS-42` says “epsilon zeta eta theta.”'],
             {'OPS-41': 'alpha beta gamma delta.', 'OPS-42': 'epsilon zeta eta theta.'},
             [('OPS-41', 'alpha beta gamma delta.'), ('OPS-42', 'epsilon zeta eta theta.')]),
            ('inverted attribution', ['`OPS-41` says `OPS-42` "alpha beta gamma delta."'],
             {'OPS-41': 'alpha beta gamma delta.', 'OPS-42': 'epsilon zeta eta theta.'},
             [('OPS-41', 'alpha beta gamma delta.')]),
            ('bare possessive owners',
             ['`OPS-41`\'s "alpha beta gamma delta"; `OPS-42`\'s “epsilon zeta eta theta.”',
              'Another "unattributed four word phrase".'],
             {'OPS-41': 'alpha beta gamma delta', 'OPS-42': 'epsilon zeta eta theta.',
              'OPS-43': 'unattributed four word phrase'},
             [('OPS-41', 'alpha beta gamma delta'), ('OPS-42', 'epsilon zeta eta theta.')]),
        ]
        source = 'alpha *beta.* gamma delta. (epsilon.) zeta eta theta.'
        for prefix in ['', '"now. yes"; ', '""; ', '"x.** ' + 'x' * 401 + '"; ']:
            for quote in [source, 'alpha *beta.* ... zeta eta theta.',
                          'alpha *beta.* … zeta eta theta.']:
                text = '`OPS-41` says ' + prefix + f'“{quote}”'
                cases.append(('paired span ' + repr(prefix[:12]), [text, 'Following prose.'],
                              {'OPS-41': source}, [('OPS-41', quote)]))
        for name, parts, sources, attributed in cases:
            text = ' '.join(parts)
            reqs = {rid: ('source.md', body) for rid, body in sources.items()}
            assert list(chunks(text)) == parts, (name, list(chunks(text)))
            # Equality checks include comparison counts: losing a closing mark
            # must not make a valid quotation silently disappear.
            assert find({'probe': text}, {}, reqs) == ([], [], len(attributed)), name
            total = len(list(quotations(text)))
            assert exists({'probe': text}, sources.values()) == ([], total), name
            for owner, quote in attributed:
                wrong_quote = quote.replace(' ', ' WRONG ', 1)
                wrong = text.replace(quote, wrong_quote, 1)
                expected = [('probe', owner, norm(wrong_quote))]
                assert find({'probe': wrong}, {}, reqs) == (expected, [], len(attributed)), name
                assert exists({'probe': wrong}, sources.values()) == (
                    [('probe', norm(wrong_quote))], total), name
            print(f'PASS: sentence boundaries: {name}: exact owners and counts; named QUOTED/EXISTS corruption')
    except AssertionError as exc:
        print(f'FAIL: sentence boundaries: {name}: {exc}')
        return 1
    return 0


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
        if (list(unpaired_marks(text)) or good != ([], [], 1) or len(bad) != 1
                or compared != 1 or len(missing) != 1 or total != 1):
            print(f'FAIL: {name}: exact={good}; corrupted={bad}, {missing}, {compared}, {total}')
            return 1
        print(f'PASS: {name}: exact quote passes; corruption reaches QUOTED and EXISTS')
    return 0


def check_possessives():
    """Direct ownership must not collect a neighbour's quote or change UNQUOTED."""
    reqs = {'OPS-41': ('probe.md', 'alpha beta gamma delta'),
            'OPS-42': ('probe.md', 'epsilon zeta eta theta')}
    cases = [
        ("`OPS-41`'s \"alpha beta gamma delta\"", 1),
        ("`OPS-41`'s “alpha beta gamma delta”", 1),
        ("`OPS-41`'s \"now\"; `OPS-42`'s \"epsilon zeta eta theta\"", 1),
        ("`OPS-41`'s \"alpha beta gamma delta\"; `OPS-42`'s \"epsilon zeta eta theta\"", 2),
        ("`OPS-41`'s \"alpha beta gamma delta\"; another \"unattributed four word phrase\"", 1),
        ("`OPS-41`'s \"just three words\"", 0),
    ]
    for text, expected in cases:
        good = find({'probe': text}, {}, reqs)
        wrong = text.replace('delta', 'WRONG').replace('theta', 'WRONG')
        bad, unquoted, compared = find({'probe': wrong}, {}, reqs)
        if good != ([], [], expected) or len(bad) != expected or unquoted or compared != expected:
            print(f'FAIL: bare possessive: {text}: {good}, {bad}, {unquoted}, {compared}')
            return 1
    print('PASS: bare possessives: direct owner, adjacent owners, short spans, exact and corrupt quotes')
    return 0


def check_docstrings():
    """Check the extractor before trusting it with the specification artifacts.

    The quoted-closer case is omitted: Lean rejects that source because a quote
    does not escape a comment delimiter, so check_formal.sh owns it.
    The odd-mark docstring checks extraction integrity, not admission: main()
    rejects its malformed prose through the separate mark guard.
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
    if (check_sentence_boundaries() or check_docstrings() or check_quotations()
            or check_possessives() or check_quote_content()):
        return 1
    docs, adrs, reqs = load()
    mark_errors = [(f, line, kind) for f, text in docs.items()
                   for line, kind in unpaired_marks(text)]
    lean = load_lean_docstrings(mark_errors)
    for f, line, kind in mark_errors:
        print(f"  {f}:{line}: unpaired {kind} double quotation marks")
    if mark_errors:
        print(f"FAIL: {len(mark_errors)} unpaired quotation mark finding(s)")
        return 1
    bad, unquoted, markdown_compared = find(docs, adrs, reqs)
    lean_bad, _, compared = find(lean, adrs, reqs, corpus=docs)
    missing, total = exists(lean, list(docs.values()) + list(adrs.values()))
    try:
        with open(BASELINE) as source:
            baseline = json.load(source)
        quoted_base = set(baseline.get("quoted_attributions", []))
        exists_base = dict(baseline.get("quoted_existence", {}))
        markdown_base = dict(baseline.get("markdown_quoted_attributions", {}))
    except (OSError, ValueError, TypeError, AttributeError):
        # Without a readable baseline there are no exemptions, so ratcheted residue
        # surfaces as findings and fails the gate before the unquoted initializer.
        quoted_base, exists_base, markdown_base = set(), {}, {}
    lean_new = [(f, rid, q) for f, rid, q in lean_bad
                if f"{f}:{rid}:{q}" not in quoted_base]
    markdown_bad = bad
    remaining = set(markdown_base)
    bad = []
    for f, rid, q in markdown_bad:
        signature = f"{f}:{rid}:{q}"
        if signature in remaining:
            remaining.remove(signature)
        else:
            bad.append((f, rid, q))
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
    print("quoted attributions verified: no new findings")
    print(f"Markdown quoted attributions: {markdown_compared} compared; {len(markdown_bad)}, "
          f"none new against baseline {len(markdown_base)}")
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
                           "cannot name which one is new. Every baseline in this file "
                           "may shrink, never grow; remove an entry when its finding "
                           "disappears. A real misquote is fixed, never entered here."},
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
