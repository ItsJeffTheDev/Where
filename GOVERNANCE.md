# Governance

Where is an open-source project licensed under the [Apache License, Version 2.0](LICENSE).

## Maintainers

The project is currently maintained by **ItsJeffTheDev**. Maintainers review pull
requests, triage issues, cut releases and make final calls on technical direction.

## Contributing

All contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before
opening a pull request. For anything beyond a small fix, open an issue first so the
approach can be agreed on before you write the code.

## Licensing of contributions

By submitting a pull request you agree that your contribution is licensed to the
project under the same Apache License, Version 2.0 (see §5 of the licence). No
contributor licence agreement (CLA) is required. Inbound = outbound.

## Decision records

Significant technical choices are recorded as Architecture Decision Records (ADRs) in
[`docs/adr/`](docs/adr/). Each ADR captures the context, the options considered and
the reason for the choice made. If your pull request introduces a significant
architectural change, add an ADR alongside it.

## Code of conduct

All participants are expected to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Releases

Releases follow [Semantic Versioning](https://semver.org/). The release process is
documented in the [Engineering Guide](https://app.notion.so/Where):

1. Update `CHANGELOG.md` and the version in `Cargo.toml` + `pubspec.yaml`.
2. Push to `main`, then tag: `git tag -a vX.Y.Z -m "Where X.Y.Z"` and push the tag.
3. GitHub Actions builds all five release targets and publishes the release
   automatically.
