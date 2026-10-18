//! `url_whatwg` — URL parser plus its `url_whatwg.*` ops, registered into `lib-parse`.

pub const URL_WHATWG_HNL: &str = include_str!("index.hnl");

pub mod ops;

pub use ops::*;

/// `.hnl` package source set — index + sibling files (wired into kits via
/// `handl_module_from_sources`).
pub const URL_WHATWG_FUNCS: &[&str] = &["parse"];
pub const URL_WHATWG_SOURCES: &[(&str, &str, &[&str])] = &[
    ("slist", include_str!("internal/slist.hnl"), &["slen","take","drop","s_slice","s_len"]),
    ("parse", include_str!("parse.hnl"), &["parse"]),
];
