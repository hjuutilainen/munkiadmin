#!/usr/bin/env bash
#
# release.sh
#
# Automates the MunkiAdmin release process that was previously done by hand:
#   Product -> Archive
#   -> Distribute App -> Custom -> Direct Distribution -> Export
#      (Development Team: Hannes Juutilainen, Manually manage signing)
#   -> wrap into a .dmg
#   -> xcrun notarytool submit ... --wait
#   -> xcrun stapler staple ...
#
# Usage:
#   ./MunkiAdmin/Scripts/release.sh [options]
#
# Options:
#   -o, --output-dir DIR       Where to put the final .dmg (default: build/release)
#   -c, --configuration NAME   Xcode configuration to archive (default: Release)
#   -t, --team-id ID           Developer Team ID (default: 8XXWJ76X9Y)
#   -p, --keychain-profile P   notarytool keychain profile (default: notarization_credentials)
#       --skip-notarize        Build/export/dmg only, skip notarization+stapling
#       --force                Skip the "clean tree + on a tag" safety checks
#   -h, --help                 Show this help

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"
WORKSPACE="$REPO_ROOT/MunkiAdmin.xcworkspace"
SCHEME="MunkiAdmin"
CONFIGURATION="Release"
TEAM_ID="8XXWJ76X9Y"
SIGNING_CERTIFICATE="Developer ID Application"
KEYCHAIN_PROFILE="notarization_credentials"
OUTPUT_DIR="$REPO_ROOT/build/release"
SKIP_NOTARIZE=false
FORCE=false

usage() {
    sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output-dir) OUTPUT_DIR="$2"; shift 2 ;;
        -c|--configuration) CONFIGURATION="$2"; shift 2 ;;
        -t|--team-id) TEAM_ID="$2"; shift 2 ;;
        -p|--keychain-profile) KEYCHAIN_PROFILE="$2"; shift 2 ;;
        --skip-notarize) SKIP_NOTARIZE=true; shift ;;
        --force) FORCE=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
    esac
done

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$1"; }
warn() { printf '\nWarning: %s\n' "$1" >&2; }
die() { printf '\n\033[1;31mError:\033[0m %s\n' "$1" >&2; exit 1; }

xml_escape() {
    local s="$1"
    s="${s//&/&amp;}"
    s="${s//</&lt;}"
    s="${s//>/&gt;}"
    s="${s//\"/&quot;}"
    printf '%s' "$s"
}

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------
log "Running preflight checks"

for tool in xcodebuild xcrun git hdiutil ditto defaults codesign security; do
    command -v "$tool" >/dev/null 2>&1 || die "Required tool '$tool' not found in PATH"
done

[[ -d "$WORKSPACE" ]] || die "Workspace not found at $WORKSPACE"

if ! security find-identity -v -p codesigning | grep -F "$SIGNING_CERTIFICATE" | grep -qF "($TEAM_ID)"; then
    die "No '$SIGNING_CERTIFICATE' identity for team $TEAM_ID found in the keychain. Check 'security find-identity -v -p codesigning'."
fi

if [[ "$SKIP_NOTARIZE" == false ]]; then
    xcrun notarytool history --keychain-profile "$KEYCHAIN_PROFILE" >/dev/null 2>&1 \
        || die "notarytool keychain profile '$KEYCHAIN_PROFILE' not found or invalid. Set it up with 'xcrun notarytool store-credentials'."
fi

if [[ "$FORCE" == false ]]; then
    GIT_STATUS_OUTPUT="$(git -C "$REPO_ROOT" status --porcelain)" \
        || die "git status failed; cannot verify the working tree is clean."
    if [[ -n "$GIT_STATUS_OUTPUT" ]]; then
        die "Working tree has uncommitted changes. Commit/stash first, or pass --force."
    fi
    if ! git -C "$REPO_ROOT" describe --tags --exact-match >/dev/null 2>&1; then
        die "HEAD is not exactly on a tag, so the build would get a dev version string (e.g. 1.10.1-32-g<hash>). Tag the release commit first (git tag -a vX.Y.Z -m ...), or pass --force to build anyway."
    fi
fi

GIT_DESCRIBE="$(git -C "$REPO_ROOT" describe --tags)"
EXPECTED_VERSION="${GIT_DESCRIBE#*v}"
log "Building from $GIT_DESCRIBE ($(git -C "$REPO_ROOT" rev-parse --short HEAD))"

if [[ "$GIT_DESCRIBE" == *-*-g* ]]; then
    warn "HEAD is not exactly on a tag ($GIT_DESCRIBE); the DMG will be named with a development version string."
fi

# ---------------------------------------------------------------------------
# Workspace + cleanup
# ---------------------------------------------------------------------------
BUILD_TMP="$(mktemp -d "${TMPDIR:-/tmp}/munkiadmin-release.XXXXXX")"
SUCCESS=false
cleanup() {
    if [[ "$SUCCESS" != true && -n "${DMG_PATH:-}" && -f "$DMG_PATH" ]]; then
        warn "Release did not complete successfully; removing incomplete DMG at $DMG_PATH"
        rm -f "$DMG_PATH"
    fi
    rm -rf "$BUILD_TMP"
}
trap cleanup EXIT

ARCHIVE_PATH="$BUILD_TMP/MunkiAdmin.xcarchive"
EXPORT_PATH="$BUILD_TMP/export"
EXPORT_OPTIONS_PLIST="$BUILD_TMP/ExportOptions.plist"

# ---------------------------------------------------------------------------
# Archive (equivalent to Product -> Archive)
# ---------------------------------------------------------------------------
log "Archiving $SCHEME ($CONFIGURATION)"

xcodebuild clean archive \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination 'generic/platform=macOS' \
    -archivePath "$ARCHIVE_PATH"

[[ -d "$ARCHIVE_PATH" ]] || die "Archive was not created at $ARCHIVE_PATH"

# ---------------------------------------------------------------------------
# Export (equivalent to Distribute App -> Custom -> Direct Distribution)
# ---------------------------------------------------------------------------
log "Exporting with Developer ID (team $TEAM_ID)"

cat > "$EXPORT_OPTIONS_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>$(xml_escape "$TEAM_ID")</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>signingCertificate</key>
    <string>$(xml_escape "$SIGNING_CERTIFICATE")</string>
</dict>
</plist>
PLIST

xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
    -exportPath "$EXPORT_PATH"

APP_PATH="$EXPORT_PATH/MunkiAdmin.app"
[[ -d "$APP_PATH" ]] || die "Exported app not found at $APP_PATH"

VERSION="$(defaults read "$APP_PATH/Contents/Info" CFBundleShortVersionString)"
log "Exported MunkiAdmin.app version $VERSION"

if [[ "$VERSION" != "$EXPECTED_VERSION" ]]; then
    die "Version mismatch: git describe gives '$EXPECTED_VERSION' but the exported app's CFBundleShortVersionString is '$VERSION'."
fi

log "Verifying code signature"
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

# ---------------------------------------------------------------------------
# Wrap into a .dmg
# ---------------------------------------------------------------------------
log "Building disk image"

mkdir -p "$OUTPUT_DIR"
DMG_NAME="MunkiAdmin-${VERSION}.dmg"
DMG_PATH="$OUTPUT_DIR/$DMG_NAME"
rm -f "$DMG_PATH"

DMG_STAGE="$BUILD_TMP/dmg"
mkdir -p "$DMG_STAGE"
ditto "$APP_PATH" "$DMG_STAGE/MunkiAdmin.app"
ln -s /Applications "$DMG_STAGE/Applications"

hdiutil create \
    -srcFolder "$DMG_STAGE" \
    -format UDZO \
    -fs HFS+ \
    -volname "MunkiAdmin $VERSION" \
    -noscrub \
    -ov \
    "$DMG_PATH"

[[ -f "$DMG_PATH" ]] || die "Disk image was not created at $DMG_PATH"

log "Created $DMG_PATH"

# ---------------------------------------------------------------------------
# Notarize + staple
# ---------------------------------------------------------------------------
if [[ "$SKIP_NOTARIZE" == true ]]; then
    log "Skipping notarization (--skip-notarize)"
else
    log "Submitting for notarization (keychain profile: $KEYCHAIN_PROFILE)"

    SUBMIT_OUTPUT="$(xcrun notarytool submit "$DMG_PATH" --keychain-profile "$KEYCHAIN_PROFILE" --wait 2>&1)"
    echo "$SUBMIT_OUTPUT"

    SUBMISSION_ID="$(echo "$SUBMIT_OUTPUT" | grep -Eo 'id: [0-9a-fA-F-]{36}' | head -1 | awk '{print $2}')"

    if ! echo "$SUBMIT_OUTPUT" | grep -q "status: Accepted"; then
        if [[ -n "$SUBMISSION_ID" ]]; then
            log "Notarization failed, fetching log for submission $SUBMISSION_ID"
            if ! LOG_OUTPUT="$(xcrun notarytool log "$SUBMISSION_ID" --keychain-profile "$KEYCHAIN_PROFILE" 2>&1)"; then
                warn "Failed to fetch the notarization log itself:"
                echo "$LOG_OUTPUT" >&2
            else
                echo "$LOG_OUTPUT"
            fi
        fi
        die "Notarization was not accepted. See log above."
    fi

    log "Stapling notarization ticket"
    xcrun stapler staple "$DMG_PATH"

    log "Validating stapled ticket and Gatekeeper assessment"
    xcrun stapler validate "$DMG_PATH"
    if ! spctl -a -t open --context context:primary-signature -v "$DMG_PATH"; then
        warn "spctl assessment reported an issue, but the DMG was already notarized and stapled successfully above. Verify manually before distributing."
    fi
fi

SUCCESS=true

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
SHA256="$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')"

log "Done"
echo "Version:  $VERSION"
echo "DMG:      $DMG_PATH"
echo "SHA-256:  $SHA256"
