# lib-url-whatwg

`url_whatwg` — the URL parser for the `parse` port, plus its `url_whatwg.*` ops.

## Layout

```text
src/        the .hnl sources (+ lib.rs)
pkg.hnl     package manifest — modules, deps, description, license
Cargo.toml  the crate manifest (url backend)
xtask/      cargo xtask gate (fmt → clippy → test → doc)
scripts/hnl-gate.sh   the gate
workflows/gate.yaml       bupha entry (handl-gates)
```

## Gate

```bash
HNL=../host-cli/target/debug/hnl scripts/hnl-gate.sh
```

The Rust crate gates via `cargo xtask gate`.

## License

MIT.
