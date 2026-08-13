# The regulatory perimeter is enforced by product design, not by licensing

**Status:** accepted (2026-08-11)

Three independent regulatory analyses converged: a merchant that accepts bitcoin as payment for
**its own services** sits outside e-money (EMD2), outside deposit-taking (CRD), outside MiCA, and
outside both the AML obliged-entity list and the travel rule. Not by exemption — by definition.
Bitcoin is not "funds" under PSD2 Art. 4(25), so nothing is "issued on receipt of funds"; a
closed-loop credit has no third-party acceptance network; and with no CASP in the payment chain
there is no "transfer of crypto-assets" within the meaning of Reg. 2023/1113 at all.

**That position is created entirely by product features we can choose, and destroyed by product
features we might casually add.** So the perimeter is written down here as a set of
prohibitions, and each one is load-bearing.

## The prohibitions

1. **No withdrawal of the balance in any form.** No fiat, no BTC, no partial. A fiat refund to a
   bank account is the worst single feature available: it trips e-money, deposit-taking and MiCA
   *simultaneously* — the operator would have taken crypto from a client and returned funds using
   its own capital, which is exchange-of-crypto-for-funds. A BTC refund is weaker but feeds the
   custody reading that `ADR-0003` already has to answer.
2. **The balance is non-transferable between customers**, and spendable only on the operator's
   own compute. Third-party acceptance is what makes something e-money; customer-to-customer
   transfer is what makes it a payment service.
3. **Title to the bitcoin passes on receipt.** The customer holds no claim to any crypto-asset —
   only a contractual claim to compute, priced in satoshis.
4. **The terms MUST NOT describe balances as "held", "backed", "reserved" or "segregated"**, and
   MUST state plainly that they are unsecured claims and that funds are used in the business.
   There is no EU safeguarding duty on an unlicensed business, and misdescribing the arrangement
   is what converts an unregulated position into misrepresentation.
5. **Sell to businesses only — AMENDED 2026-08-12 to say what this can and cannot be.** The
   Consumer Rights Directive Art. 9 gives consumers a 14-day distance-contract withdrawal right
   that cannot be drafted away; Dir. 93/13 can strike expiry and forfeiture terms as unfair. But
   `ADR-0005` collects nothing, so nothing distinguishes a business from a consumer, and `F28`
   correctly called the original rule unenforceable as written. **The decision (operator's, made
   explicitly): do not chase jurisdictional compliance.** Consumer-protection regimes differ
   across every country this product is reachable from and cannot all be satisfied — least of all
   by a seller who deliberately knows nothing about the buyer. The control is the *terms*: they
   MUST state, prominently and unmistakably, that there are **no refunds, ever**, that the
   service is sold for business use, and that balances are non-refundable prepaid claims. A
   consumer who buys anyway does so against explicit terms; the residual — a withdrawal claim on
   an unconsumed balance in some jurisdiction — is knowingly operator-borne, bounded by that
   customer's own top-ups, and sits on `F25`'s list for the lawyer as context, not as a blocker.
   *Rejected in the same decision: a business self-declaration checkbox and an
   express-performance consent ritual — offered as near-free controls, declined in favour of
   terms clarity alone.*
6. **Do not rely on PSD2's limited-network exception.** Invoking it is a *concession* that the
   activity might be a payment service, and it carries a €1m notification after which the
   national authority — not the operator — decides. Document being **outside** the definition,
   not exempt from it.
7. **Incorporate.** A natural person cannot be authorised as a CASP or a payment institution
   anywhere in the EU (MiCA Art. 59(2) requires a registered office and a Union-resident
   director; Germany's ZAG § 12 no. 1 refuses natural persons outright). A sole trader can commit
   the offence but has no path to authorisation — only shutdown — so design is the only available
   control.

## Consequences

- Jurisdiction matters mainly for how the edges are policed. Germany is the most hostile:
  BaFin decides limited-network status, and unauthorised payment or e-money business is criminal
  under ZAG § 63 with up to five years. Member-state AML scope extensions are permitted and
  unaudited across 27 states.
- ~~**Publishing the solvency invariant is a feature, not a disclosure risk.**~~ **REVERSED
  2026-08-13.** The original read: *"Stating it and then pledging the backing converts an
  unregulated act into actionable misrepresentation — which is the only enforcement the perimeter
  otherwise fails to supply."* The argument was sound and it collided with §4 of this very ADR:
  publishing "we hold satoshis equal to customer balances" **is** the description §4 bans, and a
  maintained one-to-one asset-to-claim ratio is what safekeeping looks like from outside whatever
  the contract says. The operator settled it by choosing silence — *any* public phrasing of the
  true position confuses a reader, and every short version drifts toward the banned words.
  **`LDG-19` now prohibits publication outright.** The cost is accepted and recorded: the
  enforcement this bullet described no longer exists, and a customer's recourse on operator
  failure is unsecured creditor status. §4's *disclaimer* requirement is unaffected and still
  mandatory (`LDG-19a`) — silence about the ratio is not silence about the arrangement.
- Timing: MiCA's transition ended EU-wide 1 July 2026 with no grandfathering left; the AMLR
  applies from 10 July 2027.
- Fedimint ecash is **legally untested** under MiCA's "or similar technology" limb. The exposure
  sits with the federation guardians rather than a merchant payee, but no guidance exists
  anywhere.

**None of this is legal advice.** Every claim above came from primary text, and two separate
research passes recorded that *summarised* fetches of legal instruments returned fabricated
content — in one case an entirely invented Article 3 list. Do not let a summarised legal
instrument into this specification, and get a written opinion in the member state of
establishment before launch.
