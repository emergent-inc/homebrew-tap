#!/usr/bin/env bash
set -euo pipefail

OCEAN_REPOSITORY="${OCEAN_REPOSITORY:-emergent-inc/homebrew-tap}"
OCEAN_VERSION="${OCEAN_VERSION:-}"
OCEAN_INSTALL_ROOT="${OCEAN_INSTALL_ROOT:-$HOME/Library/Application Support/Ocean}"
OCEAN_BIN_DIR="${OCEAN_BIN_DIR:-$HOME/.local/bin}"
OCEAN_APPLE_TEAM_ID="${OCEAN_APPLE_TEAM_ID:-T342J8UQGV}"
OCEAN_INSTALL_ONLY="${OCEAN_INSTALL_ONLY:-0}"

usage() {
  printf '%s\n' \
    "Mosaic installer" \
    "" \
    "Environment:" \
    "  OCEAN_VERSION       Install an exact release (for example, 0.2.1)" \
    "  OCEAN_INSTALL_ROOT  Override the versioned installation directory" \
    "  OCEAN_BIN_DIR       Override the command symlink directory"
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi
if [[ $# -ne 0 ]]; then
  printf 'mosaic installer: unknown argument: %s\n' "$1" >&2
  exit 2
fi

if [[ "$(uname -s)" != "Darwin" ]]; then
  printf 'Mosaic currently supports macOS 14 or newer.\n' >&2
  exit 1
fi
macos_version="$(sw_vers -productVersion 2>/dev/null || true)"
macos_major="${macos_version%%.*}"
if [[ ! "$macos_major" =~ ^[0-9]+$ ]]; then
  printf 'Mosaic could not determine the macOS version (found %s).\n' "${macos_version:-unknown}" >&2
  exit 1
fi
if (( macos_major < 14 )); then
  printf 'Mosaic requires macOS 14 or newer (found %s).\n' "${macos_version:-unknown}" >&2
  exit 1
fi

case "$(uname -m)" in
  arm64) ocean_arch="arm64" ;;
  x86_64) ocean_arch="x64" ;;
  *)
    printf 'Mosaic does not support this CPU architecture: %s\n' "$(uname -m)" >&2
    exit 1
    ;;
esac

if [[ -z "$OCEAN_VERSION" ]]; then
  OCEAN_VERSION="$(
    curl --fail --silent --show-error --location \
      -H "Accept: application/vnd.github+json" \
      "https://api.github.com/repos/$OCEAN_REPOSITORY/releases/latest" |
      sed -nE 's/.*"tag_name":[[:space:]]*"v?([^"]+)".*/\1/p' |
      head -n 1
  )"
fi
if [[ -z "$OCEAN_VERSION" || ! "$OCEAN_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][A-Za-z0-9.-]+)?$ ]]; then
  printf 'Mosaic could not resolve a valid release version.\n' >&2
  exit 1
fi

ocean_asset="ocean-darwin-${ocean_arch}.tar.gz"
ocean_base_url="https://github.com/$OCEAN_REPOSITORY/releases/download/v$OCEAN_VERSION"
ocean_temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/ocean-install.XXXXXX")"
trap 'rm -rf "$ocean_temp_dir"' EXIT

printf 'Downloading Mosaic %s for macOS %s…\n' "$OCEAN_VERSION" "$ocean_arch"
curl --fail --silent --show-error --location \
  "$ocean_base_url/$ocean_asset" \
  --output "$ocean_temp_dir/$ocean_asset"
curl --fail --silent --show-error --location \
  "$ocean_base_url/$ocean_asset.sha256" \
  --output "$ocean_temp_dir/$ocean_asset.sha256"

(
  cd "$ocean_temp_dir"
  shasum -a 256 --check "$ocean_asset.sha256"
  tar -xzf "$ocean_asset"
)

if [[ ! -x "$ocean_temp_dir/ocean" ||
      -L "$ocean_temp_dir/ocean" ||
      "$(readlink "$ocean_temp_dir/orgtrace")" != "ocean" ||
      ! -x "$ocean_temp_dir/rclone" ||
      ! -x "$ocean_temp_dir/Ocean.app/Contents/MacOS/OceanBackground" ]]; then
  printf 'Mosaic release archive is missing a required executable.\n' >&2
  exit 1
fi
ocean_signed_executable="$ocean_temp_dir/ocean"
if [[ -e "$ocean_temp_dir/node" || -e "$ocean_temp_dir/ocean.mjs" ]]; then
  if [[ ! -x "$ocean_temp_dir/node" || ! -f "$ocean_temp_dir/ocean.mjs" ]]; then
    printf 'Mosaic runtime archive is incomplete.\n' >&2
    exit 1
  fi
  ocean_signed_executable="$ocean_temp_dir/node"
fi
codesign --verify --deep --strict "$ocean_signed_executable"
codesign --verify --deep --strict "$ocean_temp_dir/rclone"
codesign --verify --deep --strict "$ocean_temp_dir/Ocean.app"
codesign --verify --verbose=2 -R="notarized" --check-notarization \
  "$ocean_signed_executable"
codesign --verify --verbose=2 -R="notarized" --check-notarization \
  "$ocean_temp_dir/rclone"
codesign --verify --verbose=2 -R="notarized" --check-notarization \
  "$ocean_temp_dir/Ocean.app"
ocean_signed_team="$(
  codesign --display --verbose=4 "$ocean_signed_executable" 2>&1 |
    sed -n 's/^TeamIdentifier=//p'
)"
if [[ "$ocean_signed_team" != "$OCEAN_APPLE_TEAM_ID" ]]; then
  printf 'Mosaic release was not signed by the expected Apple team.\n' >&2
  exit 1
fi

ocean_version_dir="$OCEAN_INSTALL_ROOT/versions/$OCEAN_VERSION"
mkdir -p "$ocean_version_dir"
install -m 0755 "$ocean_temp_dir/ocean" "$ocean_version_dir/ocean"
ln -sfn ocean "$ocean_version_dir/mosaic"
ln -sfn ocean "$ocean_version_dir/orgtrace"
install -m 0755 "$ocean_temp_dir/rclone" "$ocean_version_dir/rclone"
rm -rf "$ocean_version_dir/Ocean.app"
ditto "$ocean_temp_dir/Ocean.app" "$ocean_version_dir/Ocean.app"
if [[ -e "$ocean_temp_dir/node" ]]; then
  install -m 0755 "$ocean_temp_dir/node" "$ocean_version_dir/node"
  install -m 0644 "$ocean_temp_dir/ocean.mjs" "$ocean_version_dir/ocean.mjs"
fi
ln -sfn "$ocean_version_dir" "$OCEAN_INSTALL_ROOT/current"

mkdir -p "$OCEAN_BIN_DIR"
ln -sfn "$OCEAN_INSTALL_ROOT/current/ocean" "$OCEAN_BIN_DIR/mosaic"
ln -sfn "$OCEAN_INSTALL_ROOT/current/ocean" "$OCEAN_BIN_DIR/ocean"
ln -sfn "$OCEAN_INSTALL_ROOT/current/ocean" "$OCEAN_BIN_DIR/orgtrace"
ocean_json_root="${OCEAN_INSTALL_ROOT//\\/\\\\}"
ocean_json_root="${ocean_json_root//\"/\\\"}"
ocean_json_bin="${OCEAN_BIN_DIR//\\/\\\\}"
ocean_json_bin="${ocean_json_bin//\"/\\\"}"
ocean_manifest="$OCEAN_INSTALL_ROOT/installation-manifest.json"
ocean_manifest_temp="$ocean_manifest.$$"
printf '{\n  "schemaVersion": 1,\n  "method": "bootstrap",\n  "installRoot": "%s",\n  "binDir": "%s"\n}\n' \
  "$ocean_json_root" "$ocean_json_bin" > "$ocean_manifest_temp"
chmod 0600 "$ocean_manifest_temp"
mv "$ocean_manifest_temp" "$ocean_manifest"

printf 'Installed Mosaic %s.\n' "$OCEAN_VERSION"
if [[ ":$PATH:" != *":$OCEAN_BIN_DIR:"* ]]; then
  printf 'Mosaic is installed at %s/mosaic.\n' "$OCEAN_BIN_DIR"
  printf 'Add it to your shell PATH before future commands:\n  export PATH="%s:$PATH"\n' "$OCEAN_BIN_DIR"
fi
if [[ "$OCEAN_INSTALL_ONLY" == "1" ]]; then
  exit 0
fi
if { : </dev/tty; } 2>/dev/null && { : >/dev/tty; } 2>/dev/null; then
  exec "$OCEAN_BIN_DIR/mosaic" install </dev/tty >/dev/tty
fi
printf 'Mosaic setup needs an interactive terminal. Run "%s/mosaic" install, or use "%s/mosaic" install --yes for automation.\n' \
  "$OCEAN_BIN_DIR" "$OCEAN_BIN_DIR" >&2
exit 1
