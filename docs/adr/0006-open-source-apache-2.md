# ADR-0006 — Open-source under the Apache License, Version 2.0

**Date:** 2026-09-26
**Status:** Accepted

## Context

Where was initially published with no licence chosen ("all rights reserved").
To accept contributions, allow downstream packaging (e.g. Linux distributions)
and signal the project's values, a permissive open-source licence was needed.

Candidates considered:

| Licence | Patent grant | Copyleft | Notes |
|---|---|---|---|
| MIT | ❌ | None | Simple, but no explicit patent grant |
| Apache 2.0 | ✅ | None | Permissive + explicit patent termination clause |
| GPL-3.0 | ✅ | Strong | Deters some corporate contributors |
| MPL-2.0 | Partial | File-level | More complex to comply with |

## Decision

Adopt the **Apache License, Version 2.0** for all code in this repository.

- The explicit patent grant (§3) provides more protection than MIT.
- No copyleft requirement: companies can embed Where components without
  relicensing their products.
- Inbound = outbound (§5): contributions are licensed back under Apache 2.0
  automatically — no CLA required.
- `SPDX-License-Identifier: Apache-2.0` set in `Cargo.toml`; full text in `LICENSE`.

## Consequences

- `LICENSE` contains the full Apache 2.0 text.
- `NOTICE` lists third-party attributions as required by §4(d).
- `GOVERNANCE.md` documents the contribution model and clarifies that no CLA is
  required.
- The macOS `PRODUCT_COPYRIGHT` string reads *"Licensed under the Apache License,
  Version 2.0."* — not *"All rights reserved."*
- The `README.md` licence section now points to `LICENSE` and `GOVERNANCE.md`.
