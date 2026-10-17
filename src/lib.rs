//! `url_whatwg` — URL parser plus its `url_whatwg.*` ops, registered into `lib-parse`.

pub const URL_WHATWG_HNL: &str = include_str!("index.hnl");

pub mod ops;

pub use ops::*;
