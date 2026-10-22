Verified at `4c0bb4c`: the settled amendments are pending; `RSC-33` currently lists “(name, path, size, type, model, serial)” without WWN.

**Q1: (a).** Keep `name`. `RSC-33` calls the report “the record that tells an operator afterwards which disk was actually overwritten.” An observed name remains useful diagnostic evidence despite being unsuitable for identity. Adding the missing field preserves that reporting obligation.

**Q2: (ii).** Explicitly scope the whitespace prohibition to generated configuration fields, with drives represented by resolved paths. `RSC-22` says “generate the installer's configuration from a structured layout”; that transformation provides the boundary. Lookup inputs should receive the settled normalization without acquiring strategy-dependent restrictions.

**Q3:** Accept the brief’s list with these amendments:

- **1:** Give A distinct WWN and serial values; assert both returned fields and WWN preference for `identifier`.
- **2:** Check against an independently calculated canonical hash, including normalization and UTF-8 serialization ordering.
- **5:** Also test inventory values containing bare `0x`/`0X`; assert null conversion and serial fallback when the WWN normalizes empty.
- **6:** Every device carries observed `name` and `path`.
- **8:** Assert normalized serial `0xab` in the hash oracle; successful echo alone cannot detect implementations stripping repeatedly.
- **11:** Explicitly assert `identifier`, `wwn`, and `serial` are all null.
- **12:** Assert duplicate multiplicity against the hash oracle; padded echoes and internal-space serials resolve through both strategies, with only resolved paths entering installer configuration.
- **Add:** Well-formed unmatched identifiers abort `integrity` without writes through both strategies.
- **Add:** Generated configuration fields containing prohibited whitespace remain rejected.

**Q4:** The strongest objection is textual: `RSC-23` places “every drive a **stable identifier**” beside “no whitespace, CR, LF, or NUL in any config field.” Reading both as input-layout validation is reasonable. Choosing (ii) requires an explicit scope amendment; existing wording does not unambiguously establish it.