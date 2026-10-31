#!/usr/bin/env bash
# bupha entry point (runner.kind = "script", cmd = "./ci.sh").
# The gate itself lives in scripts/hnl-gate.sh so it can be run by hand.
set -euo pipefail

# ---------------------------------------------------------------------------
# Layout plumbing - bupha runs this gate in a detached worktree of the
# pushed sha, where every relative sibling path (../host-cli for the hnl
# binary; ../host, ../kernel, ../engine-*, ../lib-* in [patch]/path deps)
# resolves against the worktree's PARENT, not this repo's parent. Recreate
# the sibling layout there before any gate step runs: ../lib-url-whatwg -> this
# worktree (the sha under test), every other ~/GitHub/handl-lang/* -> its
# real checkout. Same model as kernel/scripts/ci.sh and lib-base64/ci.sh.
# ---------------------------------------------------------------------------
cd "$(dirname "$0")"

JOBS="${CI_JOBS:-2}"
export CARGO_INCREMENTAL=0
export CARGO_PROFILE_DEV_DEBUG=0
export CARGO_PROFILE_TEST_DEBUG=0
export CARGO_NET_GIT_FETCH_WITH_CLI="${CARGO_NET_GIT_FETCH_WITH_CLI:-true}"
export CARGO_BUILD_JOBS="${CI_BUILD_JOBS:-2}"
export RUST_TEST_THREADS="$JOBS"

# Workspace root = parent of the *main* checkout (correct from both the
# checkout and any detached worktree of this repo).
GIT_COMMON="$(git rev-parse --path-format=absolute --git-common-dir)"
MAIN_CHECKOUT="$(dirname "$GIT_COMMON")"
WORKSPACE_ROOT="$(dirname "$MAIN_CHECKOUT")"
IN_WORKTREE=0
[ "$PWD" != "$MAIN_CHECKOUT" ] && IN_WORKTREE=1

# Shared target dir - a detached worktree's own target/ would cold-build
# every sha. The watcher serializes runs, so sharing is safe.
export CARGO_TARGET_DIR="${CI_TARGET_DIR:-$WORKSPACE_ROOT/.ci-target/lib-url-whatwg}"

ensure_siblings() {
  [ "$IN_WORKTREE" = 1 ] || return 0
  local parent; parent="$(cd .. && pwd)"
  if [ "$parent" = "$WORKSPACE_ROOT" ]; then
    echo "ci.sh: CI worktree sits inside $WORKSPACE_ROOT - ../lib-url-whatwg" >&2
    echo "       would resolve to the dev checkout instead of this sha." >&2
    echo "       Move the worktree base outside the workspace root." >&2
    return 1
  fi
  # Self: ../lib-url-whatwg must name THIS tree (the sha under test). Only ever
  # (re)point a symlink; refuse to clobber a real directory.
  if [ -e "$parent/lib-url-whatwg" ] && [ ! -L "$parent/lib-url-whatwg" ]; then
    echo "ci.sh: $parent/lib-url-whatwg is a real directory - refusing to clobber" >&2
    return 1
  fi
  ln -sfn "$PWD" "$parent/lib-url-whatwg"
  local d name
  for d in "$WORKSPACE_ROOT"/*/; do
    name="$(basename "$d")"
    [ "$name" = "lib-url-whatwg" ] && continue
    # refresh symlinks (a previous run's links may be stale); never clobber
    # a real directory that happens to sit in the parent.
    if [ -L "$parent/$name" ] || [ ! -e "$parent/$name" ]; then
      ln -sfn "$d" "$parent/$name"
    fi
  done
  # Second-spelling hazard: a self-patch `path = "../lib-url-whatwg"` would spell
  # this tree two ways and the lockfile write collides; rewrite it to this
  # worktree's absolute path - the worktree is throwaway so editing
  # Cargo.toml here is safe.
  [ -f Cargo.toml ] && sed -i "s|\.\./lib-url-whatwg|$PWD|g" Cargo.toml
}

ensure_siblings

# Skeleton repos have the layout but no implementation yet — a skipped gate is
# honest; a failing one would just be noise.
if ! find src -name '*.hnl' 2>/dev/null | grep -q .; then
  echo "no .hnl sources under src/ yet - gate skipped"
  exit 0
fi

exec ./scripts/hnl-gate.sh "$@"
