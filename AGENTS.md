# lib-url-whatwg

`url_whatwg` — the WHATWG URL parser for the `parse` port, plus its
`url_whatwg.*` ops. Sibling of `lib-url-rfc` (RFC 3986).

## Layout

| path | role |
| --- | --- |
| `src/index.hnl`, `src/index_flat.hnl` | the .hnl surface |
| `src/parse.hnl` | the parser implementation |
| `src/internal/slist.hnl` | shared internals |
| `src/url_whatwg.test.hnl` | the .hnl test suite |
| `pkg.hnl`, `scripts/hnl-gate.sh`, `workflows/gate.yaml` | manifest / gate / bupha entry |

## Contract

- WHATWG URL Standard parsing registered into the `parse` port's
  caller-supplied parser table (`lib-parse`, Rule B).
- Note: README mentions a Rust crate (`url` backend) +
  `Cargo.toml`/`xtask`, but the repo currently ships only `.hnl`
  sources — no `Cargo.toml` is present.

## Verification

```bash
HNL=../host-cli/target/debug/hnl scripts/hnl-gate.sh
```

## License

MIT.

<!-- myco:agent-awareness -->

## Agent awareness

- Session start / any work discussion: run `myco status --prompt`
  before proposing next steps — know the board first.
- User describes new work → offer to capture it (`myco todo add`,
  `issue new`, `proposal new`). Don't wait to be asked.
- Picking up a task: `myco resume <ID>` is the briefing.
- Wrapping up: `myco handoff <ID>` anything resumable; keep statuses
  honest (claimed → in-progress → blocked/done).

<!-- /myco:agent-awareness -->
