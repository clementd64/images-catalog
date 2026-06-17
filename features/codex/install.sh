#!/usr/bin/env bash
set -euo pipefail

VERSION="${VERSION:-latest}"
BIN_DIR="/usr/local/bin"

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    echo "This feature must run as root or have sudo available." >&2
    exit 1
  fi
}

resolve_target() {
  case "$(uname -m)" in
    x86_64 | amd64)
      echo "x86_64-unknown-linux-musl"
      ;;
    aarch64 | arm64)
      echo "aarch64-unknown-linux-musl"
      ;;
    *)
      echo "Unsupported architecture: $(uname -m)" >&2
      exit 1
      ;;
  esac
}

install_codex() {
  local target archive_name download_url tmp_dir extract_dir

  target="$(resolve_target)"
  archive_name="codex-${target}.tar.gz"
  if [ "${VERSION}" = "latest" ]; then
    download_url="https://github.com/openai/codex/releases/latest/download/${archive_name}"
  else
    download_url="https://github.com/openai/codex/releases/download/${VERSION}/${archive_name}"
  fi

  tmp_dir="$(mktemp -d)"
  extract_dir="${tmp_dir}/extract"
  mkdir -p "${extract_dir}"
  trap "rm -rf '${tmp_dir}'" EXIT

  curl -fsSL "${download_url}" -o "${tmp_dir}/${archive_name}"
  tar -xzf "${tmp_dir}/${archive_name}" -C "${extract_dir}"

  run_as_root install -m 0755 "${extract_dir}/codex-${target}" "${BIN_DIR}/codex"
}

export DEBIAN_FRONTEND=noninteractive
run_as_root apt-get update
run_as_root apt-get install -y --no-install-recommends ca-certificates curl tar bubblewrap
run_as_root rm -rf /var/lib/apt/lists/*

install_codex

if ! command -v codex >/dev/null 2>&1; then
  echo "Codex installation failed: codex was not found on PATH." >&2
  exit 1
fi
